"""Pydantic models mirroring docs/api-contract.md (v1) exactly."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

from app.languages import LANGUAGE_CODES

Intent = Literal["stock_in", "sale", "udhaar_given", "udhaar_paid", "question", "unclear"]
Language = Literal[LANGUAGE_CODES]  # type: ignore[valid-type]  # the 22 scheduled + en + hi-Latn
Unit = Literal["carton", "piece", "kg", "litre", "packet", "box"]
QuickActionKind = Literal["undo", "confirm", "open_stock", "open_udhaar", "open_forecast", "send_order",
                          "open_orders", "dismiss"]


# ---- requests -------------------------------------------------------------


class ShopCreate(BaseModel):
    shop_name: str
    owner_name: str
    language: Language = "hi-Latn"
    auto_restock: bool = False
    distributor_phone: str | None = None


class ShopPatch(BaseModel):
    auto_restock: bool | None = None
    distributor_phone: str | None = None
    language: Language | None = None


class ChatRequest(BaseModel):
    shop_id: str
    text: str = Field(min_length=1)


class MessageRef(BaseModel):
    shop_id: str
    message_id: str


# ---- Gemini extraction (response_schema) -----------------------------------


class ExtractedItem(BaseModel):
    name: str
    pack_size: str | None = None
    quantity: float | None = None
    unit: Unit | None = None
    unit_price: int | None = None


class Entities(BaseModel):
    items: list[ExtractedItem] = Field(default_factory=list)
    customer_name: str | None = None
    amount: int | None = None
    date: str | None = None


class Extraction(BaseModel):
    """What Gemini returns. Used verbatim as the response_schema."""

    intent: Intent
    confidence: float = Field(ge=0.0, le=1.0)
    language: Language
    transcript: str | None = None
    entities: Entities = Field(default_factory=Entities)
    reply_text: str


# ---- responses -----------------------------------------------------------


class Shop(BaseModel):
    shop_id: str
    shop_name: str
    owner_name: str
    language: Language
    created_at: str
    auto_restock: bool = False
    distributor_phone: str | None = None


class QuickAction(BaseModel):
    label: str
    action: QuickActionKind
    payload: dict = Field(default_factory=dict)


class ExtractionReply(BaseModel):
    message_id: str
    intent: Intent
    confidence: float
    transcript: str | None = None
    language: Language
    entities: Entities
    applied: bool
    reply_text: str
    quick_actions: list[QuickAction] = Field(default_factory=list)


class UndoReply(BaseModel):
    undone: bool
    reply_text: str


class StockItem(BaseModel):
    item_id: str
    name: str
    pack_size: str | None
    quantity: float
    unit: Unit
    reorder_level: float
    low_stock: bool
    updated_at: str


class StockReply(BaseModel):
    items: list[StockItem]


class LedgerCustomer(BaseModel):
    customer_name: str
    balance: int
    last_entry_at: str


class LedgerReply(BaseModel):
    customers: list[LedgerCustomer]
    total_outstanding: int


# ---- shelf scan (Phase 3) --------------------------------------------------


class ShelfItem(BaseModel):
    name: str
    pack_size: str | None = None
    count: int = Field(ge=0)
    confidence: float = Field(ge=0.0, le=1.0)


class UnmatchedProduct(BaseModel):
    name: str  # brand/product as printed, not in the catalogue
    count: int = Field(ge=0)


class ShelfScan(BaseModel):
    """What Gemini vision returns for a shelf photo. Used as the response_schema."""

    items: list[ShelfItem] = Field(default_factory=list)
    unmatched: list[UnmatchedProduct] = Field(default_factory=list)
    reply_text: str


class ShelfLowStock(BaseModel):
    name: str
    count: int
    reorder_level: float


class ShelfScanReply(BaseModel):
    message_id: str
    items: list[ShelfItem]
    low_stock: list[ShelfLowStock]
    reply_text: str
    quick_actions: list[QuickAction] = Field(default_factory=list)
    # extra data the contract allows: products seen on the shelf that are not in the catalogue
    unmatched: list[UnmatchedProduct] = Field(default_factory=list)


# ---- forecast / summary / reorder (Phase 5) ------------------------------------


class ForecastItem(BaseModel):
    item_id: str
    name: str
    unit: Unit
    history_weekly: list[int]
    forecast_weekly: list[int]
    lower: list[int]
    upper: list[int]
    on_hand: int
    reorder_qty: int
    reorder_reason: str
    # complete weeks of actual units ending on the last sale, oldest first (internal, not serialised)
    history_weekly_long: list[int] = Field(default_factory=list, exclude=True)


class FestivalRef(BaseModel):
    name: str
    date: str


class ForecastReply(BaseModel):
    generated_at: str
    weeks: list[str]
    festivals: list[FestivalRef]
    items: list[ForecastItem]


class SummaryReply(BaseModel):
    date: str
    sales_total: int
    entries: int
    low_stock: list[StockItem]
    udhaar_given: int
    udhaar_received: int
    total_outstanding: int
    reply_text: str


class ReorderLine(BaseModel):
    name: str
    qty: int
    unit: Unit
    # auto-order lines carry the reasoning; manual lines leave these null
    rank: int | None = None
    cover_days: int | None = None
    demand_ratio: float | None = None


class ReorderReply(BaseModel):
    order_id: str
    lines: list[ReorderLine]
    text: str
    whatsapp_url: str


# ---- top items / orders / messages / feedback / languages --------------------------


class TopItem(BaseModel):
    item_id: str
    name: str
    unit: Unit
    forecast_units: int
    history_units: int
    trend_pct: int | None
    on_hand: int
    cover_days: int
    reorder_qty: int
    reorder_reason: str
    rank: int  # 1 = most units sold over the last 4 weeks of actual sales
    demand_ratio: float  # weaker of the last 2 weeks vs the baseline weekly average
    auto_restock_eligible: bool


class TopItemsReply(BaseModel):
    generated_at: str
    weeks: int
    items: list[TopItem]


class Order(BaseModel):
    order_id: str
    shop_id: str
    created_at: str
    status: Literal["placed", "cancelled"]
    source: Literal["auto", "manual"]
    lines: list[ReorderLine]
    text: str
    whatsapp_url: str


class OrdersReply(BaseModel):
    orders: list[Order]


class BotMessage(BaseModel):
    message_id: str
    shop_id: str
    created_at: str
    kind: Literal["auto_order"]
    reply_text: str
    quick_actions: list[QuickAction] = Field(default_factory=list)
    order_id: str | None = None


class MessagesReply(BaseModel):
    messages: list[BotMessage]


class AutoRestockSkip(BaseModel):
    shop_id: str
    reason: Literal["auto_restock_off", "already_ran_today", "nothing_to_order", "forecast_failed"]


class AutoRestockReply(BaseModel):
    ran_at: str
    shops_checked: int
    orders: list[Order]
    skipped: list[AutoRestockSkip]


class FeedbackCreate(BaseModel):
    shop_id: str
    screen: str
    rating: Literal["up", "down"]
    comment: str | None = None
    app_version: str | None = None
    platform: str | None = None


class FeedbackReply(BaseModel):
    feedback_id: str
    reply_text: str


class LanguageEntry(BaseModel):
    code: str
    name: str
    native_name: str
    script: str
    rtl: bool


class LanguagesReply(BaseModel):
    languages: list[LanguageEntry]


class ErrorBody(BaseModel):
    code: Literal["not_found", "invalid", "gemini_failed", "undo_expired", "not_implemented",
                  "unauthorized"]
    message: str
    reply_text: str | None = None  # gemini_failed: a sentence in the shop language for the chat


class ErrorReply(BaseModel):
    error: ErrorBody
