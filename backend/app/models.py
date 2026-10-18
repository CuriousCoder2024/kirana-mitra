"""Pydantic models mirroring docs/api-contract.md (v1) exactly."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

Intent = Literal["stock_in", "sale", "udhaar_given", "udhaar_paid", "question", "unclear"]
Language = Literal["hi", "en", "hi-Latn"]
Unit = Literal["carton", "piece", "kg", "litre", "packet", "box"]
QuickActionKind = Literal["undo", "confirm", "open_stock", "open_udhaar", "open_forecast", "send_order"]


# ---- requests -------------------------------------------------------------


class ShopCreate(BaseModel):
    shop_name: str
    owner_name: str
    language: Language = "hi-Latn"


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


class ShelfScan(BaseModel):
    """What Gemini vision returns for a shelf photo. Used as the response_schema."""

    items: list[ShelfItem] = Field(default_factory=list)
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


class ReorderReply(BaseModel):
    order_id: str
    lines: list[ReorderLine]
    text: str
    whatsapp_url: str


class ErrorBody(BaseModel):
    code: Literal["not_found", "invalid", "gemini_failed", "undo_expired", "not_implemented"]
    message: str


class ErrorReply(BaseModel):
    error: ErrorBody
