"""Apply / confirm / undo logic on top of the repository.

Rules (docs/api-contract.md):
- stock_in, sale, udhaar_given, udhaar_paid with confidence >= threshold are
  written immediately (applied=true) and get an Undo quick action.
- Below the threshold the extraction is parked under its message_id and the
  reply offers a "Haan, add karo" confirm chip.
- question / unclear never write.
"""

from __future__ import annotations

from app.matching import match_customer, match_item
from app.models import Entities, ExtractedItem, Extraction, ExtractionReply, QuickAction
from app.store import AppliedMessage, Repository, ShopRecord, StockMove, new_id

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
    return {"hi": hi, "en": en}.get(language, hinglish)


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
            repo.adjust_stock(shop.shop_id, rec.item_id, sign * base_qty)
            applied.stock_moves.append(StockMove(rec.item_id, sign * base_qty))
            conv = (f" ({_fmt_qty(qty)} {it.unit} = {_fmt_qty(base_qty)} {rec.unit})"
                    if base_qty != qty else "")
            totals.append(f"{rec.name} {_fmt_qty(rec.quantity)} {rec.unit}{conv}")
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
    extraction = Extraction.model_validate(pending)
    return build_reply(repo, shop, extraction, threshold, message_id=message_id, force_apply=True)


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
    head = _localized(lang, "ठीक है, हटा दिया.", "Okay, removed.", "Theek hai, hata diya.")
    detail = "; ".join(parts + customer_totals)
    return f"{head} {detail}.".strip() if detail else head
