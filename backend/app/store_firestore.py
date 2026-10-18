"""Firestore implementation of `Repository` (Native mode).

Layout (one document per shop, everything else in subcollections):

    shops/{shop_id}                    shop_name, owner_name, language, created_at,
                                       auto_restock, distributor_phone
    shops/{shop_id}/items/{item_id}    name, pack_size, unit, quantity, reorder_level,
                                       updated_at, aliases, carton_size, price
    shops/{shop_id}/ledger/{entry_id}  customer_name, delta, kind, message_id, at
    shops/{shop_id}/messages/{id}      one document per message id; a document can play
                                       several roles (an auto-order is both an applied
                                       entry and a bot message), each behind a flag:
        is_applied: intent, stock_moves [{item_id, delta}], ledger_entry_ids, sale_amount,
                    order_id, undone
        is_pending: payload (the held extraction / shelf scan)
        is_bot:     bot_kind, reply_text, quick_actions, order_id
        created_at on all; writes merge so roles never overwrite each other
    shops/{shop_id}/orders/{order_id}  created_at, status, source, lines, text, whatsapp_url
    shops/{shop_id}/feedback/{id}      screen, rating, comment, language, app_version,
                                       platform, created_at

Timestamps are Firestore timestamps; the API keeps serialising them as ISO-8601
in Asia/Kolkata, exactly like the in-memory store. Queries use a single equality
filter and sort in Python so no composite index has to be created; per-shop
collections are small (one shop's day of entries), which keeps that cheap.

Stock changes and undo run in transactions: adjust_stock reads and writes the
item in one transaction, and pop_applied flips `undone` inside a transaction so
two Undo taps cannot both succeed. The "last 10 applied messages" undo window is
the 10 most recent applied, not-undone messages by created_at.
"""

from __future__ import annotations

from dataclasses import asdict
from datetime import datetime, timezone

from google.cloud import firestore

from app.store import (
    IST,
    SEED_ITEMS,
    AppliedMessage,
    BotMessageRecord,
    FeedbackRecord,
    ItemRecord,
    LedgerEntry,
    OrderRecord,
    Repository,
    ShopRecord,
    StockMove,
    new_id,
)


def _to_ts(iso: str | None) -> datetime | None:
    if not iso:
        return None
    dt = datetime.fromisoformat(iso)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=IST)
    return dt.astimezone(timezone.utc)


def _from_ts(value) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if value.tzinfo is None:
        value = value.replace(tzinfo=timezone.utc)
    return value.astimezone(IST).isoformat(timespec="seconds")


def _now() -> datetime:
    return datetime.now(timezone.utc)


class FirestoreRepository(Repository):
    def __init__(self, project: str | None = None, database: str = "(default)",
                 root: str = "shops", undo_window: int = 10, seed: bool = True,
                 client: "firestore.Client | None" = None) -> None:
        self._db = client or firestore.Client(project=project, database=database)
        self.root = root
        self.undo_window = undo_window
        self.seed = seed

    # ---- helpers ----------------------------------------------------------------------

    def _shop(self, shop_id: str):
        return self._db.collection(self.root).document(shop_id)

    def _sub(self, shop_id: str, name: str):
        return self._shop(shop_id).collection(name)

    @staticmethod
    def _shop_record(doc) -> ShopRecord:
        d = doc.to_dict()
        return ShopRecord(shop_id=doc.id, shop_name=d["shop_name"], owner_name=d["owner_name"],
                          language=d.get("language", "hi-Latn"), created_at=_from_ts(d.get("created_at")),
                          auto_restock=bool(d.get("auto_restock", False)),
                          distributor_phone=d.get("distributor_phone"))

    @staticmethod
    def _item_record(shop_id: str, doc) -> ItemRecord:
        d = doc.to_dict()
        return ItemRecord(item_id=doc.id, shop_id=shop_id, name=d["name"], pack_size=d.get("pack_size"),
                          unit=d.get("unit", "piece"), quantity=float(d.get("quantity", 0)),
                          reorder_level=float(d.get("reorder_level", 0)),
                          updated_at=_from_ts(d.get("updated_at")), aliases=list(d.get("aliases") or []),
                          carton_size=int(d.get("carton_size", 12)), price=int(d.get("price", 0)))

    @staticmethod
    def _ledger_record(shop_id: str, doc) -> LedgerEntry:
        d = doc.to_dict()
        return LedgerEntry(entry_id=doc.id, shop_id=shop_id, customer_name=d["customer_name"],
                           delta=int(d["delta"]), kind=d.get("kind", ""), message_id=d.get("message_id", ""),
                           at=_from_ts(d.get("at")))

    @staticmethod
    def _applied_record(shop_id: str, doc) -> AppliedMessage:
        d = doc.to_dict()
        return AppliedMessage(
            message_id=doc.id, shop_id=shop_id, intent=d.get("intent", ""),
            stock_moves=[StockMove(m["item_id"], float(m["delta"])) for m in d.get("stock_moves") or []],
            ledger_entry_ids=list(d.get("ledger_entry_ids") or []),
            sale_amount=d.get("sale_amount"), order_id=d.get("order_id"),
            at=_from_ts(d.get("created_at")))

    # ---- shops ------------------------------------------------------------------------

    def create_shop(self, shop_name: str, owner_name: str, language: str) -> ShopRecord:
        shop_id = new_id("shp")
        now = _now()
        batch = self._db.batch()
        batch.set(self._shop(shop_id), {
            "shop_name": shop_name, "owner_name": owner_name, "language": language,
            "created_at": now, "auto_restock": False, "distributor_phone": None,
        })
        if self.seed:
            for name, pack, unit, qty, reorder, aliases, carton, price in SEED_ITEMS:
                batch.set(self._sub(shop_id, "items").document(new_id("itm")), {
                    "name": name, "pack_size": pack, "unit": unit, "quantity": float(qty),
                    "reorder_level": float(reorder), "updated_at": now, "aliases": list(aliases),
                    "carton_size": carton, "price": price,
                })
        batch.commit()
        return ShopRecord(shop_id, shop_name, owner_name, language, _from_ts(now))

    def get_shop(self, shop_id: str) -> ShopRecord | None:
        doc = self._shop(shop_id).get()
        return self._shop_record(doc) if doc.exists else None

    def list_shops(self) -> list[ShopRecord]:
        return [self._shop_record(d) for d in self._db.collection(self.root).stream()]

    def update_shop(self, shop_id: str, **fields) -> ShopRecord:
        allowed = {k: v for k, v in fields.items()
                   if k in {"auto_restock", "distributor_phone", "language", "shop_name", "owner_name"}}
        if allowed:
            self._shop(shop_id).update(allowed)
        shop = self.get_shop(shop_id)
        if shop is None:
            raise KeyError(shop_id)
        return shop

    # ---- items ------------------------------------------------------------------------

    def list_items(self, shop_id: str) -> list[ItemRecord]:
        items = [self._item_record(shop_id, d) for d in self._sub(shop_id, "items").stream()]
        # Seed order is what the in-memory store returns; keep it stable by name order of SEED_ITEMS
        seed_order = {name: i for i, (name, *_rest) in enumerate(SEED_ITEMS)}
        items.sort(key=lambda i: (seed_order.get(i.name, len(seed_order)), i.updated_at, i.name))
        return items

    def get_item(self, shop_id: str, item_id: str) -> ItemRecord | None:
        doc = self._sub(shop_id, "items").document(item_id).get()
        return self._item_record(shop_id, doc) if doc.exists else None

    def add_item(self, shop_id: str, name: str, pack_size: str | None, unit: str,
                 reorder_level: float) -> ItemRecord:
        item_id = new_id("itm")
        now = _now()
        self._sub(shop_id, "items").document(item_id).set({
            "name": name, "pack_size": pack_size, "unit": unit, "quantity": 0.0,
            "reorder_level": float(reorder_level), "updated_at": now, "aliases": [],
            "carton_size": 12, "price": 0,
        })
        return ItemRecord(item_id, shop_id, name, pack_size, unit, 0.0, float(reorder_level), _from_ts(now))

    def adjust_stock(self, shop_id: str, item_id: str, delta: float) -> ItemRecord:
        ref = self._sub(shop_id, "items").document(item_id)
        transaction = self._db.transaction()

        @firestore.transactional
        def _apply(tx):
            snap = ref.get(transaction=tx)
            if not snap.exists:
                raise KeyError(item_id)
            qty = max(0.0, float(snap.get("quantity") or 0) + float(delta))
            tx.update(ref, {"quantity": qty, "updated_at": _now()})
            return qty

        _apply(transaction)
        item = self.get_item(shop_id, item_id)
        assert item is not None
        return item

    # ---- ledger -----------------------------------------------------------------------

    def add_ledger_entry(self, shop_id: str, customer_name: str, delta: int, kind: str,
                         message_id: str) -> LedgerEntry:
        entry_id = new_id("led")
        now = _now()
        self._sub(shop_id, "ledger").document(entry_id).set({
            "customer_name": customer_name, "delta": int(delta), "kind": kind,
            "message_id": message_id, "at": now,
        })
        return LedgerEntry(entry_id, shop_id, customer_name, int(delta), kind, message_id, _from_ts(now))

    def remove_ledger_entry(self, shop_id: str, entry_id: str) -> None:
        self._sub(shop_id, "ledger").document(entry_id).delete()

    def list_ledger(self, shop_id: str) -> list[LedgerEntry]:
        # sort on the raw timestamp (microseconds) so same-second entries keep insertion order
        docs = sorted(self._sub(shop_id, "ledger").stream(), key=lambda d: d.get("at") or _now())
        return [self._ledger_record(shop_id, d) for d in docs]

    def customer_balance(self, shop_id: str, customer_name: str) -> int:
        key = customer_name.strip().lower()
        return sum(e.delta for e in self.list_ledger(shop_id) if e.customer_name.strip().lower() == key)

    def customer_names(self, shop_id: str) -> list[str]:
        seen: dict[str, str] = {}
        for e in self.list_ledger(shop_id):
            seen.setdefault(e.customer_name.strip().lower(), e.customer_name)
        return list(seen.values())

    # ---- applied messages (undo window) ---------------------------------------------------

    def record_applied(self, applied: AppliedMessage) -> None:
        self._sub(applied.shop_id, "messages").document(applied.message_id).set({
            "is_applied": True, "intent": applied.intent,
            "stock_moves": [{"item_id": m.item_id, "delta": float(m.delta)} for m in applied.stock_moves],
            "ledger_entry_ids": list(applied.ledger_entry_ids),
            "sale_amount": applied.sale_amount, "order_id": applied.order_id,
            # microsecond timestamp: the record's ISO `at` has second precision, which cannot
            # order the undo window when several entries land in the same second
            "created_at": _now(), "undone": False,
        }, merge=True)

    def _applied_docs(self, shop_id: str):
        q = self._sub(shop_id, "messages").where(filter=firestore.FieldFilter("is_applied", "==", True))
        return list(q.stream())

    def pop_applied(self, shop_id: str, message_id: str) -> AppliedMessage | None:
        live = [d for d in self._applied_docs(shop_id) if not d.get("undone")]
        live.sort(key=lambda d: d.get("created_at") or _now(), reverse=True)
        window = {d.id for d in live[: self.undo_window]}
        if message_id not in window:
            return None
        ref = self._sub(shop_id, "messages").document(message_id)
        transaction = self._db.transaction()

        @firestore.transactional
        def _flip(tx):
            snap = ref.get(transaction=tx)
            if not snap.exists or not snap.get("is_applied") or snap.get("undone"):
                return None  # a second tap loses the race
            tx.update(ref, {"undone": True, "undone_at": _now()})
            return snap

        snap = _flip(transaction)
        return self._applied_record(shop_id, snap) if snap is not None else None

    def list_applied_on(self, shop_id: str, day: str) -> list[AppliedMessage]:
        out = [self._applied_record(shop_id, d) for d in self._applied_docs(shop_id) if not d.get("undone")]
        return sorted((m for m in out if m.at[:10] == day), key=lambda m: m.at)

    # ---- pending (held) extractions -------------------------------------------------------

    def put_pending(self, shop_id: str, message_id: str, payload: dict) -> None:
        self._sub(shop_id, "messages").document(message_id).set({
            "is_pending": True, "payload": payload, "created_at": _now(),
        }, merge=True)

    def pop_pending(self, shop_id: str, message_id: str) -> dict | None:
        ref = self._sub(shop_id, "messages").document(message_id)
        transaction = self._db.transaction()

        @firestore.transactional
        def _take(tx):
            snap = ref.get(transaction=tx)
            if not snap.exists or not snap.get("is_pending"):
                return None
            tx.update(ref, {"is_pending": False, "payload": firestore.DELETE_FIELD})
            return snap.get("payload")

        return _take(transaction)

    # ---- orders -----------------------------------------------------------------------

    def add_order(self, order: OrderRecord) -> None:
        d = asdict(order)
        d["created_at"] = _to_ts(order.created_at) or _now()
        d.pop("order_id"); d.pop("shop_id")
        self._sub(order.shop_id, "orders").document(order.order_id).set(d)

    def _order_record(self, shop_id: str, doc) -> OrderRecord:
        d = doc.to_dict()
        return OrderRecord(order_id=doc.id, shop_id=shop_id, created_at=_from_ts(d.get("created_at")),
                           status=d.get("status", "placed"), source=d.get("source", "manual"),
                           lines=list(d.get("lines") or []), text=d.get("text", ""),
                           whatsapp_url=d.get("whatsapp_url", ""))

    def get_order(self, shop_id: str, order_id: str) -> OrderRecord | None:
        doc = self._sub(shop_id, "orders").document(order_id).get()
        return self._order_record(shop_id, doc) if doc.exists else None

    def list_orders(self, shop_id: str) -> list[OrderRecord]:
        docs = list(self._sub(shop_id, "orders").stream())
        docs.sort(key=lambda d: d.get("created_at") or _now(), reverse=True)
        return [self._order_record(shop_id, d) for d in docs]

    def set_order_status(self, shop_id: str, order_id: str, status: str) -> OrderRecord:
        ref = self._sub(shop_id, "orders").document(order_id)
        if not ref.get().exists:
            raise KeyError(order_id)
        ref.update({"status": status, "status_at": _now()})
        order = self.get_order(shop_id, order_id)
        assert order is not None
        return order

    # ---- bot messages -------------------------------------------------------------------

    def add_bot_message(self, msg: BotMessageRecord) -> None:
        self._sub(msg.shop_id, "messages").document(msg.message_id).set({
            "is_bot": True, "bot_kind": msg.kind, "reply_text": msg.reply_text,
            "quick_actions": list(msg.quick_actions), "order_id": msg.order_id,
            "created_at": _to_ts(msg.created_at) or _now(),
        }, merge=True)

    def list_bot_messages(self, shop_id: str, since: str | None = None,
                          limit: int = 50) -> list[BotMessageRecord]:
        q = self._sub(shop_id, "messages").where(filter=firestore.FieldFilter("is_bot", "==", True))
        docs = list(q.stream())
        docs.sort(key=lambda d: d.get("created_at") or _now(), reverse=True)
        out = []
        for doc in docs:
            d = doc.to_dict()  # DocumentSnapshot.get() takes no default; use the dict
            created = _from_ts(d.get("created_at"))
            if since and created <= since:
                continue
            out.append(BotMessageRecord(message_id=doc.id, shop_id=shop_id, created_at=created,
                                        kind=d.get("bot_kind", "auto_order"), reply_text=d.get("reply_text", ""),
                                        quick_actions=list(d.get("quick_actions") or []),
                                        order_id=d.get("order_id")))
            if len(out) >= limit:
                break
        return out

    # ---- feedback ----------------------------------------------------------------------

    def add_feedback(self, fb: FeedbackRecord) -> None:
        d = asdict(fb)
        d["created_at"] = _to_ts(fb.created_at) or _now()
        d.pop("feedback_id"); d.pop("shop_id")
        self._sub(fb.shop_id, "feedback").document(fb.feedback_id).set(d)

    def list_feedback(self, shop_id: str) -> list[FeedbackRecord]:
        out = []
        for doc in self._sub(shop_id, "feedback").stream():
            d = doc.to_dict()
            out.append(FeedbackRecord(feedback_id=doc.id, shop_id=shop_id, screen=d.get("screen", ""),
                                      rating=d.get("rating", ""), comment=d.get("comment"),
                                      language=d.get("language", ""), app_version=d.get("app_version"),
                                      platform=d.get("platform"), created_at=_from_ts(d.get("created_at"))))
        out.sort(key=lambda f: f.created_at)
        return out


def make_repository(settings) -> Repository:
    """STORE=firestore|memory; default firestore when GOOGLE_CLOUD_PROJECT is set."""
    from app.store import InMemoryRepository

    if settings.store == "firestore":
        return FirestoreRepository(project=settings.google_cloud_project,
                                   database=settings.firestore_database,
                                   undo_window=settings.undo_window)
    return InMemoryRepository(undo_window=settings.undo_window)
