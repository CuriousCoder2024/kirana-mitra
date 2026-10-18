"""Repository layer.

`Repository` is the interface the service layer talks to. `InMemoryRepository`
is the Phase 1 mock. Phase 4 adds a Cloud SQL implementation with the same
methods; nothing above this module should know which one is in use.
"""

from __future__ import annotations

import secrets
from abc import ABC, abstractmethod
from collections import deque
from dataclasses import dataclass, field
from datetime import datetime
from zoneinfo import ZoneInfo

IST = ZoneInfo("Asia/Kolkata")


def now_iso() -> str:
    return datetime.now(IST).isoformat(timespec="seconds")


def new_id(prefix: str) -> str:
    return f"{prefix}_{secrets.token_hex(8).upper()}"


# ---- records --------------------------------------------------------------


@dataclass
class ShopRecord:
    shop_id: str
    shop_name: str
    owner_name: str
    language: str
    created_at: str
    auto_restock: bool = False
    distributor_phone: str | None = None


@dataclass
class ItemRecord:
    item_id: str
    shop_id: str
    name: str
    pack_size: str | None
    unit: str
    quantity: float
    reorder_level: float
    updated_at: str
    aliases: list[str] = field(default_factory=list)
    carton_size: int = 12  # base units per carton/box, used to convert spoken cartons
    price: int = 0  # MRP in rupees, for the evening sales total

    @property
    def low_stock(self) -> bool:
        return self.quantity <= self.reorder_level


@dataclass
class LedgerEntry:
    entry_id: str
    shop_id: str
    customer_name: str
    delta: int  # +ve = udhaar given (customer owes more), -ve = udhaar paid
    kind: str  # udhaar_given | udhaar_paid
    message_id: str
    at: str


@dataclass
class StockMove:
    item_id: str
    delta: float  # +ve = stock in, -ve = sale


@dataclass
class AppliedMessage:
    """Everything needed to undo one applied message."""

    message_id: str
    shop_id: str
    intent: str
    stock_moves: list[StockMove] = field(default_factory=list)
    ledger_entry_ids: list[str] = field(default_factory=list)
    sale_amount: int | None = None  # rupees the user quoted for a sale, if any
    order_id: str | None = None  # auto-order to cancel on undo
    at: str = field(default_factory=now_iso)


@dataclass
class OrderRecord:
    order_id: str
    shop_id: str
    created_at: str
    status: str  # placed | cancelled
    source: str  # auto | manual
    lines: list[dict]  # [{name, qty, unit}]
    text: str
    whatsapp_url: str


@dataclass
class BotMessageRecord:
    """A message the server posted into the shop's chat (auto-order notices)."""

    message_id: str
    shop_id: str
    created_at: str
    kind: str
    reply_text: str
    quick_actions: list[dict]
    order_id: str | None = None


@dataclass
class FeedbackRecord:
    feedback_id: str
    shop_id: str
    screen: str
    rating: str
    comment: str | None
    language: str
    app_version: str | None
    platform: str | None
    created_at: str


# ---- seed catalogue ---------------------------------------------------------

# (name, pack_size, unit, opening qty, reorder level, aliases heard in voice notes,
#  units per carton, MRP rupees as in data/catalogue.csv)
SEED_ITEMS: list[tuple[str, str | None, str, float, float, list[str], int, int]] = [
    ("Parle-G", "70g", "packet", 42, 24, ["parle g", "parle ji", "parle", "पारले जी", "पारले"], 24, 10),
    ("Maggi", "70g", "packet", 30, 12, ["maggie", "मैगी"], 48, 14),
    ("Tata Salt", "1kg", "packet", 20, 10, ["tata namak", "namak", "टाटा नमक", "नमक"], 20, 28),
    ("Aashirvaad Atta", "5kg", "packet", 8, 5, ["atta", "ashirwad atta", "आटा", "आशीर्वाद आटा"], 4, 260),
    ("Surf Excel", "1kg", "packet", 12, 6, ["surf", "सर्फ एक्सेल", "सर्फ"], 12, 145),
    ("Amul Milk", "500ml", "packet", 25, 15, ["doodh", "milk", "अमूल दूध", "दूध"], 24, 27),
    ("Amul Butter", "100g", "piece", 10, 5, ["butter", "makkhan", "अमूल बटर", "मक्खन"], 20, 60),
    ("Britannia Good Day", "100g", "packet", 18, 10, ["good day", "गुड डे"], 24, 10),
    ("Colgate", "100g", "piece", 15, 8, ["colgate paste", "toothpaste", "कोलगेट"], 24, 65),
    ("Lifebuoy", "100g", "piece", 24, 12, ["lifebuoy soap", "sabun", "लाइफबॉय", "साबुन"], 48, 22),
    ("Fortune Oil", "1L", "litre", 14, 6, ["fortune tel", "tel", "oil", "फॉर्च्यून तेल", "तेल"], 12, 150),
    ("Red Label", "250g", "packet", 9, 5, ["red label chai", "chai", "रेड लेबल", "चाय"], 24, 150),
    ("Nescafe", "50g", "piece", 6, 3, ["coffee", "नेस्कैफे", "कॉफी"], 24, 195),
    ("Haldiram Namkeen", "200g", "packet", 16, 8, ["haldiram", "namkeen", "हल्दीराम", "नमकीन"], 20, 52),
    ("Dettol", "125g", "piece", 11, 6, ["dettol soap", "डेटॉल"], 36, 80),
]


# ---- interface -----------------------------------------------------------------


class Repository(ABC):
    # shops
    @abstractmethod
    def create_shop(self, shop_name: str, owner_name: str, language: str) -> ShopRecord: ...

    @abstractmethod
    def get_shop(self, shop_id: str) -> ShopRecord | None: ...

    @abstractmethod
    def list_shops(self) -> list[ShopRecord]: ...

    @abstractmethod
    def update_shop(self, shop_id: str, **fields) -> ShopRecord: ...

    # items
    @abstractmethod
    def list_items(self, shop_id: str) -> list[ItemRecord]: ...

    @abstractmethod
    def get_item(self, shop_id: str, item_id: str) -> ItemRecord | None: ...

    @abstractmethod
    def add_item(
        self, shop_id: str, name: str, pack_size: str | None, unit: str, reorder_level: float
    ) -> ItemRecord: ...

    @abstractmethod
    def adjust_stock(self, shop_id: str, item_id: str, delta: float) -> ItemRecord: ...

    # ledger
    @abstractmethod
    def add_ledger_entry(
        self, shop_id: str, customer_name: str, delta: int, kind: str, message_id: str
    ) -> LedgerEntry: ...

    @abstractmethod
    def remove_ledger_entry(self, shop_id: str, entry_id: str) -> None: ...

    @abstractmethod
    def list_ledger(self, shop_id: str) -> list[LedgerEntry]: ...

    @abstractmethod
    def customer_balance(self, shop_id: str, customer_name: str) -> int: ...

    @abstractmethod
    def customer_names(self, shop_id: str) -> list[str]: ...

    # applied messages (undo window)
    @abstractmethod
    def record_applied(self, applied: AppliedMessage) -> None: ...

    @abstractmethod
    def pop_applied(self, shop_id: str, message_id: str) -> AppliedMessage | None: ...

    @abstractmethod
    def list_applied_on(self, shop_id: str, day: str) -> list[AppliedMessage]:
        """Applied (not undone) messages whose `at` falls on the ISO date `day`."""

    # pending (low-confidence) extractions awaiting /confirm
    @abstractmethod
    def put_pending(self, shop_id: str, message_id: str, payload: dict) -> None: ...

    @abstractmethod
    def pop_pending(self, shop_id: str, message_id: str) -> dict | None: ...

    # orders
    @abstractmethod
    def add_order(self, order: OrderRecord) -> None: ...

    @abstractmethod
    def get_order(self, shop_id: str, order_id: str) -> OrderRecord | None: ...

    @abstractmethod
    def list_orders(self, shop_id: str) -> list[OrderRecord]:
        """Newest first."""

    @abstractmethod
    def set_order_status(self, shop_id: str, order_id: str, status: str) -> OrderRecord: ...

    # server-side bot messages
    @abstractmethod
    def add_bot_message(self, msg: BotMessageRecord) -> None: ...

    @abstractmethod
    def list_bot_messages(self, shop_id: str, since: str | None = None,
                          limit: int = 50) -> list[BotMessageRecord]:
        """Newest first, created after `since` (ISO) when given."""

    # feedback
    @abstractmethod
    def add_feedback(self, fb: FeedbackRecord) -> None: ...

    @abstractmethod
    def list_feedback(self, shop_id: str) -> list[FeedbackRecord]: ...


# ---- in-memory implementation ------------------------------------------------------


class InMemoryRepository(Repository):
    def __init__(self, undo_window: int = 10, seed: bool = True) -> None:
        self.undo_window = undo_window
        self.seed = seed
        self._shops: dict[str, ShopRecord] = {}
        self._items: dict[str, dict[str, ItemRecord]] = {}
        self._ledger: dict[str, dict[str, LedgerEntry]] = {}
        self._applied: dict[str, deque[AppliedMessage]] = {}
        self._journal: dict[str, list[AppliedMessage]] = {}  # all applied, for /summary
        self._pending: dict[str, dict[str, dict]] = {}
        self._orders: dict[str, list[OrderRecord]] = {}
        self._bot_messages: dict[str, list[BotMessageRecord]] = {}
        self._feedback: dict[str, list[FeedbackRecord]] = {}

    # shops
    def create_shop(self, shop_name: str, owner_name: str, language: str) -> ShopRecord:
        shop = ShopRecord(new_id("shp"), shop_name, owner_name, language, now_iso())
        self._shops[shop.shop_id] = shop
        self._items[shop.shop_id] = {}
        self._ledger[shop.shop_id] = {}
        self._applied[shop.shop_id] = deque(maxlen=self.undo_window)
        self._journal[shop.shop_id] = []
        self._pending[shop.shop_id] = {}
        self._orders[shop.shop_id] = []
        self._bot_messages[shop.shop_id] = []
        self._feedback[shop.shop_id] = []
        if self.seed:
            for name, pack, unit, qty, reorder, aliases, carton, price in SEED_ITEMS:
                item = self.add_item(shop.shop_id, name, pack, unit, reorder)
                item.quantity = qty
                item.aliases = list(aliases)
                item.carton_size = carton
                item.price = price
        return shop

    def get_shop(self, shop_id: str) -> ShopRecord | None:
        return self._shops.get(shop_id)

    def list_shops(self) -> list[ShopRecord]:
        return list(self._shops.values())

    def update_shop(self, shop_id: str, **fields) -> ShopRecord:
        shop = self._shops[shop_id]
        for k, v in fields.items():
            setattr(shop, k, v)
        return shop

    # items
    def list_items(self, shop_id: str) -> list[ItemRecord]:
        return list(self._items.get(shop_id, {}).values())

    def get_item(self, shop_id: str, item_id: str) -> ItemRecord | None:
        return self._items.get(shop_id, {}).get(item_id)

    def add_item(
        self, shop_id: str, name: str, pack_size: str | None, unit: str, reorder_level: float
    ) -> ItemRecord:
        item = ItemRecord(new_id("itm"), shop_id, name, pack_size, unit, 0, reorder_level, now_iso())
        self._items[shop_id][item.item_id] = item
        return item

    def adjust_stock(self, shop_id: str, item_id: str, delta: float) -> ItemRecord:
        item = self._items[shop_id][item_id]
        item.quantity = max(0.0, item.quantity + delta)
        item.updated_at = now_iso()
        return item

    # ledger
    def add_ledger_entry(
        self, shop_id: str, customer_name: str, delta: int, kind: str, message_id: str
    ) -> LedgerEntry:
        entry = LedgerEntry(new_id("led"), shop_id, customer_name, delta, kind, message_id, now_iso())
        self._ledger[shop_id][entry.entry_id] = entry
        return entry

    def remove_ledger_entry(self, shop_id: str, entry_id: str) -> None:
        self._ledger[shop_id].pop(entry_id, None)

    def list_ledger(self, shop_id: str) -> list[LedgerEntry]:
        return list(self._ledger.get(shop_id, {}).values())

    def customer_balance(self, shop_id: str, customer_name: str) -> int:
        key = customer_name.strip().lower()
        return sum(
            e.delta for e in self._ledger.get(shop_id, {}).values()
            if e.customer_name.strip().lower() == key
        )

    def customer_names(self, shop_id: str) -> list[str]:
        seen: dict[str, str] = {}
        for e in self._ledger.get(shop_id, {}).values():
            seen.setdefault(e.customer_name.strip().lower(), e.customer_name)
        return list(seen.values())

    # applied
    def record_applied(self, applied: AppliedMessage) -> None:
        self._applied[applied.shop_id].append(applied)
        self._journal[applied.shop_id].append(applied)

    def list_applied_on(self, shop_id: str, day: str) -> list[AppliedMessage]:
        return [m for m in self._journal.get(shop_id, []) if m.at[:10] == day]

    def pop_applied(self, shop_id: str, message_id: str) -> AppliedMessage | None:
        window = self._applied.get(shop_id)
        if not window:
            return None
        for entry in window:
            if entry.message_id == message_id:
                window.remove(entry)
                self._journal[shop_id] = [m for m in self._journal[shop_id]
                                          if m.message_id != message_id]
                return entry
        return None

    # pending
    def put_pending(self, shop_id: str, message_id: str, payload: dict) -> None:
        self._pending[shop_id][message_id] = payload

    def pop_pending(self, shop_id: str, message_id: str) -> dict | None:
        return self._pending.get(shop_id, {}).pop(message_id, None)

    # orders
    def add_order(self, order: OrderRecord) -> None:
        self._orders[order.shop_id].append(order)

    def get_order(self, shop_id: str, order_id: str) -> OrderRecord | None:
        return next((o for o in self._orders.get(shop_id, []) if o.order_id == order_id), None)

    def list_orders(self, shop_id: str) -> list[OrderRecord]:
        # newest first; insertion order breaks ties within the same second
        return sorted(reversed(self._orders.get(shop_id, [])), key=lambda o: o.created_at, reverse=True)

    def set_order_status(self, shop_id: str, order_id: str, status: str) -> OrderRecord:
        order = self.get_order(shop_id, order_id)
        if order is None:
            raise KeyError(order_id)
        order.status = status
        return order

    # bot messages
    def add_bot_message(self, msg: BotMessageRecord) -> None:
        self._bot_messages[msg.shop_id].append(msg)

    def list_bot_messages(self, shop_id: str, since: str | None = None,
                          limit: int = 50) -> list[BotMessageRecord]:
        msgs = self._bot_messages.get(shop_id, [])
        if since:
            msgs = [m for m in msgs if m.created_at > since]
        return sorted(reversed(list(msgs)), key=lambda m: m.created_at, reverse=True)[:limit]

    # feedback
    def add_feedback(self, fb: FeedbackRecord) -> None:
        self._feedback.setdefault(fb.shop_id, []).append(fb)

    def list_feedback(self, shop_id: str) -> list[FeedbackRecord]:
        return list(self._feedback.get(shop_id, []))
