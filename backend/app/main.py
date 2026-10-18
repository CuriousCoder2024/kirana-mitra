"""Kirana Mitra backend, FastAPI. Implements docs/api-contract.md v1 (Phase 1)."""

from __future__ import annotations

from fastapi import FastAPI, File, Form, Request, UploadFile
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import Settings, get_settings
from app.gemini import Extractor, GeminiFailed, make_extractor
from app.models import (
    ChatRequest,
    ExtractionReply,
    LedgerCustomer,
    LedgerReply,
    MessageRef,
    Shop,
    ShopCreate,
    StockItem,
    StockReply,
    UndoReply,
)
from app.service import NotFound, UndoExpired, build_reply, confirm, undo
from app.store import InMemoryRepository, Repository

ALLOWED_AUDIO = {"audio/m4a", "audio/mp4", "audio/x-m4a", "audio/wav", "audio/x-wav",
                 "audio/webm", "audio/ogg", "audio/mpeg", "audio/aac"}
MAX_AUDIO_BYTES = 10 * 1024 * 1024


class ApiError(Exception):
    def __init__(self, status: int, code: str, message: str) -> None:
        self.status, self.code, self.message = status, code, message


def create_app(settings: Settings | None = None, repo: Repository | None = None,
               extractor: Extractor | None = None) -> FastAPI:
    settings = settings or get_settings()
    repo = repo or InMemoryRepository(undo_window=settings.undo_window)
    app = FastAPI(title="Kirana Mitra API", version="1.0.0")
    # The Flutter web build runs on another origin (flutter run -d chrome picks a
    # random port), so allow any origin for the demo; tighten before production.
    app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"],
                       allow_headers=["*"])
    app.state.settings = settings
    app.state.repo = repo
    app.state.extractor = extractor  # built lazily so /healthz works without creds

    def get_extractor() -> Extractor:
        if app.state.extractor is None:
            app.state.extractor = make_extractor(settings)
        return app.state.extractor

    def model_id() -> str:
        if app.state.extractor is not None:
            return app.state.extractor.model
        return "mock-gemini" if settings.mock_gemini else settings.gemini_model

    def get_shop(shop_id: str):
        shop = repo.get_shop(shop_id)
        if shop is None:
            raise ApiError(404, "not_found", f"shop {shop_id} not found")
        return shop

    # ---- error shapes -----------------------------------------------------------

    @app.exception_handler(ApiError)
    async def _api_error(_: Request, exc: ApiError):
        return JSONResponse(status_code=exc.status,
                            content={"error": {"code": exc.code, "message": exc.message}})

    @app.exception_handler(RequestValidationError)
    async def _invalid(_: Request, exc: RequestValidationError):
        return JSONResponse(status_code=400,
                            content={"error": {"code": "invalid", "message": str(exc.errors()[:3])}})

    # ---- health -----------------------------------------------------------------

    @app.get("/healthz")
    def healthz():
        return {"ok": True, "model": model_id()}

    # ---- shops ------------------------------------------------------------------

    @app.post("/shops", status_code=201, response_model=Shop)
    def create_shop(body: ShopCreate):
        shop = repo.create_shop(body.shop_name, body.owner_name, body.language)
        return Shop(**shop.__dict__)

    # ---- chat / voice -----------------------------------------------------------

    @app.post("/chat", response_model=ExtractionReply)
    def chat(body: ChatRequest):
        shop = get_shop(body.shop_id)
        try:
            extraction = get_extractor().extract(
                body.text, None, repo.list_items(shop.shop_id), shop.language)
        except GeminiFailed as exc:
            raise ApiError(502, "gemini_failed", str(exc))
        return build_reply(repo, shop, extraction, settings.confirm_threshold)

    @app.post("/voice-note", response_model=ExtractionReply)
    async def voice_note(shop_id: str = Form(...), audio: UploadFile = File(...)):
        shop = get_shop(shop_id)
        mime = (audio.content_type or "").split(";")[0].strip().lower()
        if mime not in ALLOWED_AUDIO:
            raise ApiError(400, "invalid", f"unsupported audio type {mime!r}")
        data = await audio.read()
        if not data:
            raise ApiError(400, "invalid", "empty audio")
        if len(data) > MAX_AUDIO_BYTES:
            raise ApiError(400, "invalid", "audio too large (max 10 MB / 60 s)")
        if mime in {"audio/m4a", "audio/x-m4a"}:
            mime = "audio/mp4"  # what Gemini expects for AAC-in-MP4 voice notes
        if mime == "audio/x-wav":
            mime = "audio/wav"
        try:
            extraction = get_extractor().extract(
                None, (data, mime), repo.list_items(shop.shop_id), shop.language)
        except GeminiFailed as exc:
            raise ApiError(502, "gemini_failed", str(exc))
        return build_reply(repo, shop, extraction, settings.confirm_threshold)

    # ---- confirm / undo ---------------------------------------------------------

    @app.post("/confirm", response_model=ExtractionReply)
    def confirm_message(body: MessageRef):
        shop = get_shop(body.shop_id)
        try:
            return confirm(repo, shop, body.message_id, settings.confirm_threshold)
        except NotFound as exc:
            raise ApiError(404, "not_found", str(exc))

    @app.post("/undo", response_model=UndoReply)
    def undo_message(body: MessageRef):
        shop = get_shop(body.shop_id)
        try:
            text = undo(repo, shop, body.message_id)
        except UndoExpired as exc:
            raise ApiError(409, "undo_expired", str(exc))
        return UndoReply(undone=True, reply_text=text)

    # ---- reads ------------------------------------------------------------------

    @app.get("/stock/{shop_id}", response_model=StockReply)
    def stock(shop_id: str):
        shop = get_shop(shop_id)
        return StockReply(items=[
            StockItem(item_id=i.item_id, name=i.name, pack_size=i.pack_size, quantity=i.quantity,
                      unit=i.unit, reorder_level=i.reorder_level, low_stock=i.low_stock,
                      updated_at=i.updated_at)
            for i in repo.list_items(shop.shop_id)
        ])

    @app.get("/ledger/{shop_id}", response_model=LedgerReply)
    def ledger(shop_id: str):
        shop = get_shop(shop_id)
        by_customer: dict[str, LedgerCustomer] = {}
        for e in sorted(repo.list_ledger(shop.shop_id), key=lambda e: e.at):
            key = e.customer_name.strip().lower()
            cur = by_customer.get(key)
            if cur is None:
                by_customer[key] = LedgerCustomer(customer_name=e.customer_name, balance=e.delta,
                                                  last_entry_at=e.at)
            else:
                cur.balance += e.delta
                cur.last_entry_at = e.at
        customers = sorted(by_customer.values(), key=lambda c: -c.balance)
        return LedgerReply(customers=customers,
                           total_outstanding=sum(c.balance for c in customers if c.balance > 0))

    # ---- Phase 3/5 stubs (shapes frozen in docs/api-contract.md) --------------------

    def _not_implemented(phase: str):
        raise ApiError(501, "not_implemented", f"{phase}; see docs/api-contract.md for the shape")

    @app.post("/shelf-scan", status_code=501)
    async def shelf_scan(shop_id: str = Form(...), image: UploadFile = File(...)):
        """Phase 3. multipart: shop_id, image (jpeg/png ≤ 8 MB).

        200 → { "message_id": "msg_...",
                "items": [ { "name": "Maggi", "pack_size": "70g", "count": 6, "confidence": 0.8 } ],
                "low_stock": [ { "name": "Maggi", "count": 6, "reorder_level": 12 } ],
                "reply_text": "...",
                "quick_actions": [ { "label": "Haan, update karo", "action": "confirm",
                                     "payload": { "message_id": "msg_..." } } ] }
        """
        _not_implemented("shelf-scan lands in Phase 3")

    @app.get("/forecast/{shop_id}", status_code=501)
    def forecast(shop_id: str):
        """Phase 5. 200 →
        { "generated_at": "...", "weeks": ["2026-10-19", ...4 ISO dates],
          "festivals": [ { "name": "Diwali", "date": "2026-11-08" } ],
          "items": [ { "item_id": "itm_...", "name": "Parle-G", "unit": "packet",
                       "history_weekly": [40, 38, 45, 41], "forecast_weekly": [44, 52, 90, 48],
                       "lower": [38, 44, 70, 40], "upper": [50, 60, 110, 56],
                       "on_hand": 42, "reorder_qty": 120, "reorder_reason": "Diwali week demand ~2x" } ] }
        """
        _not_implemented("forecast lands in Phase 5")

    @app.get("/summary/{shop_id}", status_code=501)
    def summary(shop_id: str, date: str | None = None):
        """Phase 5. ?date=YYYY-MM-DD. 200 →
        { "date": "...", "sales_total": 8450, "entries": 23, "low_stock": [ ...as in /stock... ],
          "udhaar_given": 350, "udhaar_received": 500, "total_outstanding": 4350,
          "reply_text": "Aaj ka hisaab: ..." }
        """
        _not_implemented("summary lands in Phase 5")

    @app.post("/reorder/{shop_id}", status_code=501)
    def reorder(shop_id: str):
        """Phase 5. 200 →
        { "order_id": "ord_...", "lines": [ { "name": "Parle-G 70g", "qty": 120, "unit": "packet" } ],
          "text": "Order for Gupta General Store ...", "whatsapp_url": "https://wa.me/?text=..." }
        """
        _not_implemented("reorder lands in Phase 5")

    return app


app = create_app()
