"""Kirana Mitra backend, FastAPI. Implements docs/api-contract.md v1 (Phase 1)."""

from __future__ import annotations

import logging

from fastapi import FastAPI, File, Form, Request, UploadFile
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.concurrency import run_in_threadpool

from app.config import Settings, get_settings
from app.gemini import Extractor, GeminiFailed, make_extractor
from app.forecast import ForecastSource, make_forecast_source, shape_forecast
from app.models import (
    ChatRequest,
    ExtractionReply,
    ForecastReply,
    ReorderLine,
    ReorderReply,
    SummaryReply,
    LedgerCustomer,
    LedgerReply,
    MessageRef,
    Shop,
    ShelfScanReply,
    ShopCreate,
    StockItem,
    StockReply,
    UndoReply,
)
from app.service import (NotFound, UndoExpired, build_reply, build_shelf_reply, confirm,
                         reorder_text, summary_facts, summary_template, today_ist, undo)
from app.store import InMemoryRepository, Repository, new_id, now_iso

ALLOWED_AUDIO = {"audio/m4a", "audio/mp4", "audio/x-m4a", "audio/wav", "audio/x-wav",
                 "audio/webm", "audio/ogg", "audio/mpeg", "audio/aac"}
MAX_AUDIO_BYTES = 10 * 1024 * 1024
ALLOWED_IMAGE = {"image/jpeg", "image/jpg", "image/png"}
MAX_IMAGE_BYTES = 8 * 1024 * 1024


class ApiError(Exception):
    def __init__(self, status: int, code: str, message: str) -> None:
        self.status, self.code, self.message = status, code, message


def create_app(settings: Settings | None = None, repo: Repository | None = None,
               extractor: Extractor | None = None,
               forecast_source: ForecastSource | None = None) -> FastAPI:
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
    app.state.forecast_source = forecast_source

    def get_forecast_source() -> ForecastSource:
        if app.state.forecast_source is None:
            app.state.forecast_source = make_forecast_source(settings)
        return app.state.forecast_source

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
            extraction = await run_in_threadpool(get_extractor().extract,
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

    @app.post("/shelf-scan", response_model=ShelfScanReply)
    async def shelf_scan(shop_id: str = Form(...), image: UploadFile = File(...)):
        """Phase 3. multipart: shop_id, image (jpeg/png ≤ 8 MB). Image bytes go to Gemini
        inline; the counts are held (applied=false) until POST /confirm sets the stock
        to the counted quantities. POST /undo restores the previous quantities."""
        shop = get_shop(shop_id)
        mime = (image.content_type or "").split(";")[0].strip().lower()
        if mime not in ALLOWED_IMAGE:
            raise ApiError(400, "invalid", f"unsupported image type {mime!r} (jpeg/png only)")
        data = await image.read()
        if not data:
            raise ApiError(400, "invalid", "empty image")
        if len(data) > MAX_IMAGE_BYTES:
            raise ApiError(400, "invalid", "image too large (max 8 MB)")
        if mime == "image/jpg":
            mime = "image/jpeg"
        try:
            scan = await run_in_threadpool(get_extractor().scan_shelf, (data, mime), repo.list_items(shop.shop_id),
                                              shop.language)
        except GeminiFailed as exc:
            raise ApiError(502, "gemini_failed", str(exc))
        return build_shelf_reply(repo, shop, scan)

    # ---- Phase 5: forecast / summary / reorder ----------------------------------------

    async def _forecast(shop):
        raw = await run_in_threadpool(get_forecast_source().load, shop.shop_id)
        weeks, festivals, items = shape_forecast(raw, repo.list_items(shop.shop_id), shop.language)
        return weeks, festivals, items

    @app.get("/forecast/{shop_id}", response_model=ForecastReply)
    async def forecast(shop_id: str):
        """4 Monday-start weeks of history + forecast per stocked item, with reorder_qty.
        Source: BigQuery ML ARIMA_PLUS (FORECAST_SOURCE=bigquery) or the local CSV
        seasonal-naive fallback (FORECAST_SOURCE=local / MOCK_GEMINI=1)."""
        shop = get_shop(shop_id)
        try:
            weeks, festivals, items = await _forecast(shop)
        except Exception as exc:
            raise ApiError(502, "gemini_failed", f"forecast source failed: {exc}")
        return ForecastReply(generated_at=now_iso(), weeks=[w.isoformat() for w in weeks],
                             festivals=festivals, items=items)

    @app.get("/summary/{shop_id}", response_model=SummaryReply)
    async def summary(shop_id: str, date: str | None = None):
        """Evening hisaab for ?date=YYYY-MM-DD (default today, Asia/Kolkata). The numbers
        come from the repository; reply_text is Gemini's narration with a fixed template
        fallback, so this endpoint never fails on Gemini."""
        shop = get_shop(shop_id)
        day = date or today_ist()
        try:
            from datetime import date as _d
            _d.fromisoformat(day)
        except ValueError:
            raise ApiError(400, "invalid", "date must be YYYY-MM-DD")
        facts = summary_facts(repo, shop, day)
        try:
            reply_text = await run_in_threadpool(get_extractor().summarize, facts, shop.language)
        except Exception as exc:  # GeminiFailed or missing credentials: fall back
            logging.getLogger("kirana.summary").warning("narration failed, using template: %s", exc)
            reply_text = summary_template(facts, shop.language)
        low = [StockItem(item_id=i.item_id, name=i.name, pack_size=i.pack_size, quantity=i.quantity,
                         unit=i.unit, reorder_level=i.reorder_level, low_stock=True,
                         updated_at=i.updated_at)
               for i in repo.list_items(shop.shop_id) if i.low_stock]
        return SummaryReply(date=day, sales_total=facts["sales_total"], entries=facts["entries"],
                            low_stock=low, udhaar_given=facts["udhaar_given"],
                            udhaar_received=facts["udhaar_received"],
                            total_outstanding=facts["total_outstanding"], reply_text=reply_text)

    @app.post("/reorder/{shop_id}", response_model=ReorderReply)
    async def reorder(shop_id: str):
        """Reorder list from the forecast (items with reorder_qty > 0), as text and a
        wa.me share link. Nothing is sent."""
        from urllib.parse import quote

        shop = get_shop(shop_id)
        try:
            _, _, items = await _forecast(shop)
        except Exception as exc:
            raise ApiError(502, "gemini_failed", f"forecast source failed: {exc}")
        catalogue = {i.item_id: i for i in repo.list_items(shop.shop_id)}
        lines = []
        for it in items:
            if it.reorder_qty <= 0:
                continue
            pack = catalogue[it.item_id].pack_size if it.item_id in catalogue else None
            lines.append((f"{it.name} {pack}".strip() if pack else it.name, it.reorder_qty, it.unit))
        text = reorder_text(shop, lines)
        return ReorderReply(
            order_id=new_id("ord"),
            lines=[ReorderLine(name=n, qty=q, unit=u) for n, q, u in lines],
            text=text,
            whatsapp_url="https://wa.me/?text=" + quote(text, safe=""),
        )

    return app


app = create_app()
