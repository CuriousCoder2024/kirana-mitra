"""Apply / confirm / undo logic on top of the repository.

Rules (docs/api-contract.md):
- stock_in, sale, udhaar_given, udhaar_paid with confidence >= threshold are
  written immediately (applied=true) and get an Undo quick action.
- Below the threshold the extraction is parked under its message_id and the
  reply offers a "Haan, add karo" confirm chip.
- question / unclear never write.
"""

from __future__ import annotations

from dataclasses import dataclass

from app.matching import match_customer, match_item
from app.models import (Entities, ExtractedItem, Extraction, ExtractionReply, QuickAction,
                        ShelfItem, ShelfLowStock, ShelfScan, ShelfScanReply)
from app.store import (IST, AppliedMessage, BotMessageRecord, OrderRecord, Repository,
                       ShopRecord, StockMove, new_id, now_iso)

WRITE_INTENTS = {"stock_in", "sale", "udhaar_given", "udhaar_paid"}


class UndoExpired(Exception):
    pass


class NotFound(Exception):
    pass


def _fmt_qty(q: float) -> str:
    return str(int(q)) if float(q).is_integer() else f"{q:g}"


def _rupees(n: int) -> str:
    return f"₹{n:,}"


def resolve_items(repo: Repository, shop_id: str, entities: Entities) -> Entities:
    """Fuzzy-match extracted item names to the catalogue, in place of the raw name."""
    catalogue = repo.list_items(shop_id)
    resolved: list[ExtractedItem] = []
    for raw in entities.items:
        hit = match_item(raw.name, catalogue)
        if hit:
            resolved.append(
                raw.model_copy(
                    update={
                        "name": hit.name,
                        "pack_size": raw.pack_size or hit.pack_size,
                        "unit": raw.unit or hit.unit,
                    }
                )
            )
        else:
            resolved.append(raw)
    return entities.model_copy(update={"items": resolved})


def _localized(language: str, hi: str, en: str, hinglish: str) -> str:
    """Python-side strings exist for hi, en and hi-Latn; every other code gets English."""
    return {"hi": hi, "hi-Latn": hinglish}.get(language, en)


def apply_extraction(
    repo: Repository, shop: ShopRecord, message_id: str, extraction: Extraction
) -> tuple[str, list[QuickAction]]:
    """Write the extraction. Returns (totals suffix for reply_text, quick actions)."""
    applied = AppliedMessage(message_id=message_id, shop_id=shop.shop_id, intent=extraction.intent)
    ent = extraction.entities
    lang = extraction.language
    totals: list[str] = []
    actions: list[QuickAction] = [
        QuickAction(label="Undo", action="undo", payload={"message_id": message_id})
    ]

    if extraction.intent in {"stock_in", "sale"}:
        sign = 1 if extraction.intent == "stock_in" else -1
        catalogue = {i.name: i for i in repo.list_items(shop.shop_id)}
        for it in ent.items:
            qty = it.quantity or 0
            if qty <= 0:
                continue
            rec = catalogue.get(it.name)
            if rec is None:
                rec = repo.add_item(
                    shop.shop_id, it.name, it.pack_size, it.unit or "piece", reorder_level=5
                )
                catalogue[rec.name] = rec
            base_qty = qty
            if it.unit in {"carton", "box"} and rec.unit not in {"carton", "box"}:
                base_qty = qty * rec.carton_size
            # use the record the store returns: a persistent store does not mutate `rec` in place
            rec = repo.adjust_stock(shop.shop_id, rec.item_id, sign * base_qty)
            catalogue[rec.name] = rec
            applied.stock_moves.append(StockMove(rec.item_id, sign * base_qty))
            conv = (f" ({_fmt_qty(qty)} {it.unit} = {_fmt_qty(base_qty)} {rec.unit})"
                    if base_qty != qty else "")
            totals.append(f"{rec.name} {_fmt_qty(rec.quantity)} {rec.unit}{conv}")
        if extraction.intent == "sale" and ent.amount:
            applied.sale_amount = int(ent.amount)
        label = _localized(lang, "अब स्टॉक", "Now in stock", "Ab total")
        suffix = f"{label}: {', '.join(totals)}." if totals else ""
        actions.append(
            QuickAction(label=_localized(lang, "स्टॉक देखो", "View stock", "Stock dekho"),
                        action="open_stock")
        )

    elif extraction.intent in {"udhaar_given", "udhaar_paid"}:
        customer = ent.customer_name or _localized(lang, "ग्राहक", "Customer", "Customer")
        customer = match_customer(customer, repo.customer_names(shop.shop_id))
        amount = int(ent.amount or 0)
        delta = amount if extraction.intent == "udhaar_given" else -amount
        entry = repo.add_ledger_entry(shop.shop_id, customer, delta, extraction.intent, message_id)
        applied.ledger_entry_ids.append(entry.entry_id)
        balance = repo.customer_balance(shop.shop_id, customer)
        label = _localized(lang, "कुल बकाया", "Balance", "Total")
        suffix = f"{label} {_rupees(balance)}."
        actions.append(
            QuickAction(label=_localized(lang, "उधार देखो", "View udhaar", "Udhaar dekho"),
                        action="open_udhaar")
        )
    else:
        return "", []

    repo.record_applied(applied)
    return suffix, actions


def build_reply(
    repo: Repository,
    shop: ShopRecord,
    extraction: Extraction,
    threshold: float,
    message_id: str | None = None,
    force_apply: bool = False,
) -> ExtractionReply:
    """Turn a raw extraction into the contract's ExtractionReply, writing if allowed."""
    message_id = message_id or new_id("msg")
    extraction = extraction.model_copy(
        update={"entities": resolve_items(repo, shop.shop_id, extraction.entities)}
    )
    intent = extraction.intent
    reply_text = extraction.reply_text.strip()
    applied = False
    actions: list[QuickAction] = []

    if intent in WRITE_INTENTS and _has_writable_entities(extraction):
        if force_apply or extraction.confidence >= threshold:
            suffix, actions = apply_extraction(repo, shop, message_id, extraction)
            applied = True
            if suffix:
                reply_text = f"{reply_text} {suffix}".strip()
        else:
            repo.put_pending(shop.shop_id, message_id, extraction.model_dump())
            ask = _localized(
                extraction.language,
                "क्या यह सही है?",
                "Is this right?",
                "Sahi hai?",
            )
            if ask not in reply_text:
                reply_text = f"{reply_text} {ask}".strip()
            actions = [
                QuickAction(
                    label=_localized(extraction.language, "हाँ, जोड़ दो", "Yes, add it", "Haan, add karo"),
                    action="confirm",
                    payload={"message_id": message_id},
                )
            ]
    elif intent in WRITE_INTENTS:
        # Writable intent but nothing to write with (no item / amount): treat as unclear.
        intent = "unclear"

    return ExtractionReply(
        message_id=message_id,
        intent=intent,
        confidence=extraction.confidence,
        transcript=extraction.transcript,
        language=extraction.language,
        entities=_clean_entities(intent, extraction.entities),
        applied=applied,
        reply_text=reply_text,
        quick_actions=actions,
    )


def _has_writable_entities(extraction: Extraction) -> bool:
    ent = extraction.entities
    if extraction.intent in {"stock_in", "sale"}:
        return any((it.quantity or 0) > 0 for it in ent.items)
    return bool(ent.amount and ent.amount > 0)


def _clean_entities(intent: str, ent: Entities) -> Entities:
    """Contract: fields not relevant to the intent are null (items [])."""
    if intent in {"stock_in", "sale"}:
        return ent.model_copy(update={"amount": ent.amount if intent == "sale" else None,
                                      "customer_name": None})
    if intent in {"udhaar_given", "udhaar_paid"}:
        return ent.model_copy(update={"items": []})
    return ent


def confirm(repo: Repository, shop: ShopRecord, message_id: str, threshold: float) -> ExtractionReply:
    pending = repo.pop_pending(shop.shop_id, message_id)
    if pending is None:
        raise NotFound("No pending message with that id")
    if pending.get("kind") == "shelf_scan":
        return apply_shelf_scan(repo, shop, message_id, ShelfScan.model_validate(pending["scan"]))
    extraction = Extraction.model_validate(pending)
    return build_reply(repo, shop, extraction, threshold, message_id=message_id, force_apply=True)


# ---- shelf scan (Phase 3) ------------------------------------------------------


def resolve_shelf_items(repo: Repository, shop_id: str, scan: ShelfScan) -> ShelfScan:
    """Snap Gemini's product names onto the catalogue and merge duplicates."""
    catalogue = repo.list_items(shop_id)
    merged: dict[str, ShelfItem] = {}
    unmatched = []
    for u in scan.unmatched:
        hit = match_item(u.name, catalogue)
        if hit is None:
            unmatched.append(u)
        else:  # Gemini called a catalogue product "unmatched": count it as that item
            scan = scan.model_copy(update={"items": [*scan.items, ShelfItem(
                name=hit.name, pack_size=hit.pack_size, count=u.count, confidence=0.6)]})
    for raw in scan.items:
        hit = match_item(raw.name, catalogue)
        if hit is None:
            # Gemini put a non-catalogue product in items: keep it as extra data, not stock
            from app.models import UnmatchedProduct

            unmatched.append(UnmatchedProduct(name=raw.name.strip(), count=raw.count))
            continue
        name = hit.name
        pack = raw.pack_size or hit.pack_size
        if name in merged:
            prev = merged[name]
            merged[name] = prev.model_copy(update={
                "count": prev.count + raw.count,
                "confidence": min(prev.confidence, raw.confidence)})
        else:
            merged[name] = raw.model_copy(update={"name": name, "pack_size": pack})
    return scan.model_copy(update={"items": list(merged.values()), "unmatched": unmatched})


def _units_list(entries) -> str:
    return ", ".join(f"{e.name} {e.count}" for e in entries)


def build_shelf_reply(repo: Repository, shop: ShopRecord, scan: ShelfScan,
                      message_id: str | None = None) -> ShelfScanReply:
    """Hold the counted stock under message_id (applied=false) and offer a confirm chip.

    Three cases: catalogue items seen (confirm sets their stock); products seen that are
    not in the catalogue (confirm adds them as items and sets their stock, deny dismisses);
    nothing recognised (no chips, ask for a closer photo)."""
    message_id = message_id or new_id("msg")
    scan = resolve_shelf_items(repo, shop.shop_id, scan)
    lang = shop.language
    catalogue = {i.name: i for i in repo.list_items(shop.shop_id)}
    low: list[ShelfLowStock] = []
    for it in scan.items:
        rec = catalogue.get(it.name)
        if rec and it.count <= rec.reorder_level:
            low.append(ShelfLowStock(name=it.name, count=it.count, reorder_level=rec.reorder_level))

    if not scan.items and not scan.unmatched:
        reply = _localized(lang,
                           "शेल्फ पर कोई प्रोडक्ट समझ नहीं आया, थोड़ा पास से फ़ोटो लें।",
                           "Could not make out any product on the shelf, please take the photo a bit closer.",
                           "Shelf pe koi product samajh nahi aaya, thoda paas se photo lo.")
        return ShelfScanReply(message_id=message_id, items=[], low_stock=[], reply_text=reply,
                              quick_actions=[], unmatched=[])

    head = _localized(lang, "शेल्फ पर दिखा:", "On the shelf:", "Shelf pe dikha:")
    if scan.items:
        reply = scan.reply_text.strip() or f"{head} {_units_list(scan.items)}."
    else:
        reply = f"{head} {_units_list(scan.unmatched)}."
    if low:
        kam = "; ".join(
            _localized(lang, f"{x.name} कम है (reorder {_fmt_qty(x.reorder_level)})",
                       f"{x.name} is low (reorder {_fmt_qty(x.reorder_level)})",
                       f"{x.name} kam hai (reorder {_fmt_qty(x.reorder_level)})")
            for x in low)
        reply = f"{reply} {kam}."
    if scan.unmatched:
        listed = "" if not scan.items else f" {_units_list(scan.unmatched)}:"
        reply = f"{reply}" + _localized(
            lang,
            f"{listed} ये कैटलॉग में नहीं हैं। नए आइटम जोड़कर स्टॉक सेट करूँ?",
            f"{listed} These are not in your catalogue yet. Add them and set stock?",
            f"{listed} Ye catalogue mein nahi hain. Naye item add karke stock set karoon?",
        ).replace("  ", " ")
        if not reply.startswith(head) and not scan.items:
            reply = f"{head} {reply}"
        actions = [
            QuickAction(label=_localized(lang, "हाँ, जोड़ दो", "Yes, add", "Haan, add karo"),
                        action="confirm", payload={"message_id": message_id}),
            QuickAction(label=_localized(lang, "नहीं", "No", "Nahi"), action="dismiss",
                        payload={"message_id": message_id}),
        ]
    else:
        reply = f"{reply} {_localized(lang, 'स्टॉक अपडेट करूँ?', 'Update stock?', 'Update karoon?')}"
        actions = [QuickAction(
            label=_localized(lang, "हाँ, अपडेट करो", "Yes, update", "Haan, update karo"),
            action="confirm", payload={"message_id": message_id})]

    repo.put_pending(shop.shop_id, message_id, {"kind": "shelf_scan", "scan": scan.model_dump()})
    return ShelfScanReply(message_id=message_id, items=scan.items, low_stock=low, reply_text=reply,
                          unmatched=scan.unmatched, quick_actions=actions)


def apply_shelf_scan(repo: Repository, shop: ShopRecord, message_id: str,
                     scan: ShelfScan) -> ExtractionReply:
    """Set each counted item's stock to the counted quantity (absolute), undoably."""
    lang = shop.language
    applied = AppliedMessage(message_id=message_id, shop_id=shop.shop_id, intent="stock_in")
    catalogue = {i.name: i for i in repo.list_items(shop.shop_id)}
    items: list[ExtractedItem] = []
    totals: list[str] = []
    to_set = [(it.name, it.pack_size, it.count) for it in scan.items]
    # unmatched products become new catalogue items (unit packet, reorder 6) with their counts
    to_set += [(u.name, None, u.count) for u in scan.unmatched]
    for name, pack_size, count in to_set:
        rec = catalogue.get(name)
        if rec is None:
            rec = repo.add_item(shop.shop_id, name, pack_size, "packet", reorder_level=6)
            catalogue[rec.name] = rec
        delta = count - rec.quantity  # previous quantity = count - delta, restored by undo
        if delta:
            rec = repo.adjust_stock(shop.shop_id, rec.item_id, delta)
            catalogue[rec.name] = rec
            applied.stock_moves.append(StockMove(rec.item_id, delta))
        items.append(ExtractedItem(name=rec.name, pack_size=rec.pack_size, quantity=count,
                                   unit=rec.unit))
        totals.append(f"{rec.name} {_fmt_qty(rec.quantity)} {rec.unit}")
    repo.record_applied(applied)
    head = _localized(lang, "स्टॉक अपडेट किया:", "Stock updated:", "Stock update kiya:")
    return ExtractionReply(
        message_id=message_id, intent="stock_in",
        confidence=min((i.confidence for i in scan.items), default=1.0),
        transcript=None, language=lang,
        entities=Entities(items=items), applied=True,
        reply_text=f"{head} {', '.join(totals)}.",
        quick_actions=[
            QuickAction(label="Undo", action="undo", payload={"message_id": message_id}),
            QuickAction(label=_localized(lang, "स्टॉक देखो", "View stock", "Stock dekho"),
                        action="open_stock"),
        ],
    )


def undo(repo: Repository, shop: ShopRecord, message_id: str) -> str:
    applied = repo.pop_applied(shop.shop_id, message_id)
    if applied is None:
        raise UndoExpired("Message is not in the undo window")
    lang = shop.language
    parts: list[str] = []
    for move in applied.stock_moves:
        rec = repo.adjust_stock(shop.shop_id, move.item_id, -move.delta)
        parts.append(f"{rec.name} {_fmt_qty(rec.quantity)} {rec.unit}")
    customer_totals: list[str] = []
    entries = {e.entry_id: e for e in repo.list_ledger(shop.shop_id)}
    for entry_id in applied.ledger_entry_ids:
        entry = entries.get(entry_id)
        if entry is None:
            continue
        repo.remove_ledger_entry(shop.shop_id, entry_id)
        balance = repo.customer_balance(shop.shop_id, entry.customer_name)
        customer_totals.append(f"{entry.customer_name} {_rupees(abs(entry.delta))} → "
                               f"{_localized(lang, 'कुल', 'total', 'Total')} {_rupees(balance)}")
    if applied.order_id:
        repo.set_order_status(shop.shop_id, applied.order_id, "cancelled")
        return _localized(lang, "ठीक है, ऑर्डर रद्द कर दिया।", "Okay, the order is cancelled.",
                          "Theek hai, order cancel kar diya.")
    head = _localized(lang, "ठीक है, हटा दिया.", "Okay, removed.", "Theek hai, hata diya.")
    detail = "; ".join(parts + customer_totals)
    return f"{head} {detail}.".strip() if detail else head


# ---- evening summary (Phase 5) -----------------------------------------------------


def summary_facts(repo: Repository, shop: ShopRecord, day: str) -> dict:
    """The day's numbers from the repository: what /summary reports and Gemini narrates."""
    items = {i.item_id: i for i in repo.list_items(shop.shop_id)}
    applied = repo.list_applied_on(shop.shop_id, day)
    sales_total = 0
    for m in applied:
        if m.intent != "sale":
            continue
        if m.sale_amount:
            sales_total += m.sale_amount
        else:
            sales_total += int(round(sum(
                abs(mv.delta) * items[mv.item_id].price
                for mv in m.stock_moves if mv.item_id in items)))
    udhaar_given = sum(e.delta for e in repo.list_ledger(shop.shop_id)
                       if e.at[:10] == day and e.delta > 0)
    udhaar_received = -sum(e.delta for e in repo.list_ledger(shop.shop_id)
                           if e.at[:10] == day and e.delta < 0)
    balances: dict[str, int] = {}
    for e in repo.list_ledger(shop.shop_id):
        key = e.customer_name.strip().lower()
        balances[key] = balances.get(key, 0) + e.delta
    low = [i for i in items.values() if i.low_stock]
    return {
        "date": day,
        "shop_name": shop.shop_name,
        "sales_total": sales_total,
        "entries": len(applied),
        "udhaar_given": udhaar_given,
        "udhaar_received": udhaar_received,
        "total_outstanding": sum(b for b in balances.values() if b > 0),
        "low_stock": [{"name": i.name, "quantity": _fmt_qty(i.quantity), "unit": i.unit,
                       "reorder_level": _fmt_qty(i.reorder_level)} for i in low],
    }


def summary_template(facts: dict, language: str) -> str:
    """Fixed-wording fallback when Gemini is unavailable; never fails."""
    low = facts.get("low_stock") or []
    low_names = ", ".join(f"{x['name']} ({x['quantity']} {x['unit']})" for x in low)
    s, e = _rupees(facts["sales_total"]), facts["entries"]
    g, r, o = _rupees(facts["udhaar_given"]), _rupees(facts["udhaar_received"]), _rupees(facts["total_outstanding"])
    if language == "hi":
        low_txt = f"कम स्टॉक: {low_names}।" if low else "कोई सामान कम नहीं है।"
        return (f"आज का हिसाब: बिक्री {s}, {e} एंट्री। उधार दिया {g}, वापस आया {r}; "
                f"कुल बकाया {o}। {low_txt}")
    if language == "hi-Latn":
        low_txt = f"Kam stock: {low_names}." if low else "Koi item kam nahi hai."
        return (f"Aaj ka hisaab: bikri {s}, {e} entries. Udhaar diya {g}, wapas aaya {r}; "
                f"total baaki {o}. {low_txt}")
    # English for "en" and for every other language the Python templates do not cover
    low_txt = f"Low stock: {low_names}." if low else "No items are low on stock."
    return (f"Today's summary: sales {s} across {e} entries. Udhaar given {g}, received {r}; "
            f"total outstanding {o}. {low_txt}")


def today_ist() -> str:
    from datetime import datetime

    return datetime.now(IST).date().isoformat()


# ---- reorder (Phase 5) ---------------------------------------------------------------


def reorder_text(shop: ShopRecord, lines: list[tuple[str, int, str]]) -> str:
    lang = shop.language
    head = _localized(lang, f"{shop.shop_name} के लिए ऑर्डर:", f"Order for {shop.shop_name}:",
                      f"{shop.shop_name} ke liye order:")
    if not lines:
        return head + " " + _localized(lang, "अभी कुछ नहीं चाहिए।", "nothing needed right now.",
                                       "abhi kuch nahi chahiye.")
    body = "\n".join(f"- {name}: {qty} {unit}" for name, qty, unit in lines)
    tail = _localized(lang, "कृपया कल तक भेज दें। धन्यवाद!", "Please deliver by tomorrow. Thanks!",
                      "Please kal tak bhej dein. Dhanyavaad!")
    return f"{head}\n{body}\n{tail}"


# ---- top items and auto-restock signals (Phase 7) ----------------------------------------

from app.forecast import REORDER_COVER_WEEKS  # noqa: E402

TOP_SELLER_RANK = 10      # (1) in the top N by actual units sold over the last 4 weeks
AUTO_COVER_DAYS = 7       # (2) on_hand covers fewer than this many days at the forecast rate
DEMAND_UPLIFT = 1.2       # (3) each of the last SUSTAINED_WEEKS weeks >= this x the baseline
SUSTAINED_WEEKS = 2
BASELINE_WEEKS = 8        # baseline = the 8 weeks before the sustained window (10 weeks total)
RANK_WEEKS = 4


@dataclass
class RestockSignals:
    rank: int
    units_4w: int
    cover_days: int
    demand_ratio: float
    top_seller: bool
    low_stock: bool
    sustained_demand: bool

    @property
    def eligible(self) -> bool:
        return self.top_seller and self.low_stock and self.sustained_demand


def cover_days_for(on_hand: int, forecast_weekly: list[int], weeks: int = REORDER_COVER_WEEKS) -> int:
    weeks_n = max(1, min(weeks, len(forecast_weekly)))
    per_day = sum(forecast_weekly[:weeks_n]) / (7 * weeks_n)
    return min(999, int(on_hand / per_day)) if per_day > 0 else 999


def demand_ratio_for(history_long: list[int]) -> float:
    """Weaker of the last SUSTAINED_WEEKS weeks divided by the baseline weekly average.

    Baseline = the BASELINE_WEEKS weeks before the window when there are at least
    SUSTAINED_WEEKS + BASELINE_WEEKS weeks of history, else the whole-history average.
    0.0 when there is no usable history."""
    if len(history_long) < SUSTAINED_WEEKS + 1:
        return 0.0
    last = history_long[-SUSTAINED_WEEKS:]
    before = history_long[:-SUSTAINED_WEEKS]
    if len(history_long) >= SUSTAINED_WEEKS + BASELINE_WEEKS:
        baseline_weeks = before[-BASELINE_WEEKS:]
    else:
        baseline_weeks = history_long
    baseline = sum(baseline_weeks) / len(baseline_weeks)
    if baseline <= 0:
        return 0.0
    return round(min(last) / baseline, 2)


def restock_signals(forecast_items) -> dict[str, RestockSignals]:
    """The three auto-restock signals per shaped forecast item, keyed by item_id."""
    units = {it.item_id: sum(it.history_weekly_long[-RANK_WEEKS:]) for it in forecast_items}
    ranked = sorted(forecast_items, key=lambda it: (-units[it.item_id], it.name))
    out: dict[str, RestockSignals] = {}
    for rank, it in enumerate(ranked, start=1):
        cover = cover_days_for(it.on_hand, it.forecast_weekly)
        ratio = demand_ratio_for(it.history_weekly_long)
        out[it.item_id] = RestockSignals(
            rank=rank, units_4w=units[it.item_id], cover_days=cover, demand_ratio=ratio,
            top_seller=rank <= TOP_SELLER_RANK and units[it.item_id] > 0,
            low_stock=cover < AUTO_COVER_DAYS,
            sustained_demand=ratio >= DEMAND_UPLIFT,
        )
    return out


def top_items(forecast_items, weeks: int, limit: int):
    """Rank shaped forecast items by expected demand over the next `weeks` weeks."""
    from app.models import TopItem

    signals = restock_signals(forecast_items)
    out = []
    for it in forecast_items:
        weeks_n = max(1, min(weeks, len(it.forecast_weekly)))
        forecast_units = sum(it.forecast_weekly[:weeks_n])
        history_units = sum(it.history_weekly[-weeks_n:])
        trend = (round((forecast_units - history_units) * 100 / history_units)
                 if history_units > 0 else None)
        sig = signals[it.item_id]
        out.append(TopItem(item_id=it.item_id, name=it.name, unit=it.unit,
                           forecast_units=forecast_units, history_units=history_units,
                           trend_pct=trend, on_hand=it.on_hand,
                           cover_days=cover_days_for(it.on_hand, it.forecast_weekly, weeks_n),
                           reorder_qty=it.reorder_qty, reorder_reason=it.reorder_reason,
                           rank=sig.rank, demand_ratio=sig.demand_ratio,
                           auto_restock_eligible=sig.eligible))
    out.sort(key=lambda t: (-t.forecast_units, t.name))
    return out[:limit]


# ---- orders and auto-restock (Phase 7) ---------------------------------------------------


def order_lines_from_forecast(repo: Repository, shop: ShopRecord, forecast_items,
                              auto: bool = False) -> list[dict]:
    """Manual: every item with reorder_qty > 0. Auto: only items passing all three signals,
    with the reasoning on each line."""
    catalogue = {i.item_id: i for i in repo.list_items(shop.shop_id)}
    signals = restock_signals(forecast_items) if auto else {}
    lines = []
    for it in forecast_items:
        if it.reorder_qty <= 0:
            continue
        if auto and not signals[it.item_id].eligible:
            continue
        pack = catalogue[it.item_id].pack_size if it.item_id in catalogue else None
        line = {"name": f"{it.name} {pack}".strip() if pack else it.name,
                "qty": it.reorder_qty, "unit": it.unit}
        if auto:
            sig = signals[it.item_id]
            line.update({"rank": sig.rank, "cover_days": sig.cover_days,
                         "demand_ratio": sig.demand_ratio})
        lines.append(line)
    if auto:
        lines.sort(key=lambda l: l["rank"])
    return lines


def create_order(repo: Repository, shop: ShopRecord, lines: list[dict], source: str) -> OrderRecord:
    from urllib.parse import quote

    text = reorder_text(shop, [(l["name"], l["qty"], l["unit"]) for l in lines])
    phone = (shop.distributor_phone or "").lstrip("+").replace(" ", "")
    url = f"https://wa.me/{phone}?text=" if phone else "https://wa.me/?text="
    order = OrderRecord(order_id=new_id("ord"), shop_id=shop.shop_id, created_at=now_iso(),
                        status="placed", source=source, lines=lines, text=text,
                        whatsapp_url=url + quote(text, safe=""))
    repo.add_order(order)
    return order


def auto_order_today(repo: Repository, shop_id: str, day: str) -> OrderRecord | None:
    """The auto order already placed (or cancelled) today, if any: the run is idempotent."""
    return next((o for o in repo.list_orders(shop_id)
                 if o.source == "auto" and o.created_at[:10] == day), None)


def _short_name(name: str) -> str:
    """'Britannia Good Day 100g' -> 'Britannia Good Day'."""
    import re

    return re.sub(r"\s+\S*\d\S*$", "", name)


def auto_line_reason(lang: str, line: dict) -> str:
    """'top-3 seller, 4 din ka stock, 2 hafte se demand 1.4x'."""
    rank, cover, ratio = line.get("rank"), line.get("cover_days"), line.get("demand_ratio")
    return _localized(
        lang,
        f"टॉप-{rank} सेलर, {cover} दिन का स्टॉक, {SUSTAINED_WEEKS} हफ़्ते से माँग {ratio}x",
        f"top-{rank} seller, {cover} days of stock, demand {ratio}x for {SUSTAINED_WEEKS} weeks",
        f"top-{rank} seller, {cover} din ka stock, {SUSTAINED_WEEKS} hafte se demand {ratio}x",
    )


def post_auto_order_message(repo: Repository, shop: ShopRecord, order: OrderRecord) -> BotMessageRecord:
    """Bot message in the shop's chat announcing the auto order, undoable like any write."""
    lang = shop.language
    parts = []
    for l in order.lines:
        why = f" ({auto_line_reason(lang, l)})" if l.get("rank") is not None else ""
        parts.append(f"{_short_name(l['name'])} {l['qty']} {l['unit']}{why}")
    head = _localized(lang, "ऑटो-ऑर्डर भेजा:", "Auto-order sent:", "Auto-order bheja:")
    tail = _localized(lang, "रद्द करें?", "Undo?", "Undo?")
    message_id = new_id("msg")
    repo.record_applied(AppliedMessage(message_id=message_id, shop_id=shop.shop_id,
                                       intent="auto_order", order_id=order.order_id))
    msg = BotMessageRecord(
        message_id=message_id, shop_id=shop.shop_id, created_at=order.created_at,
        kind="auto_order", reply_text=f"{head} {'; '.join(parts)}. {tail}",
        quick_actions=[
            {"label": "Undo", "action": "undo", "payload": {"message_id": message_id}},
            {"label": _localized(lang, "ऑर्डर देखो", "View orders", "Orders dekho"),
             "action": "open_orders", "payload": {}},
        ],
        order_id=order.order_id)
    repo.add_bot_message(msg)
    return msg


# ---- feedback (Phase 7) ----------------------------------------------------------------


def feedback_thanks(language: str) -> str:
    return _localized(language, "शुक्रिया! आपका फ़ीडबैक मिल गया।", "Thank you! Your feedback is in.",
                      "Shukriya! Aapka feedback mil gaya.")
