"""Kirana Mitra backend, FastAPI. Implements docs/api-contract.md v1 (Phase 1)."""

from __future__ import annotations

import logging

from fastapi import FastAPI, File, Form, Header, Request, UploadFile
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.concurrency import run_in_threadpool

from app.config import Settings, get_settings
from app.gemini import Extractor, GeminiFailed, make_extractor
from app.feedback import FeedbackSink, make_feedback_sink
from app.forecast import ForecastSource, make_forecast_source, shape_forecast
from app.languages import LANGUAGES, detect_script, DEFAULT_LANGUAGE_FOR_SCRIPT
from app.models import (
    AutoRestockReply,
    AutoRestockSkip,
    BotMessage,
    ChatRequest,
    ExtractionReply,
    FeedbackCreate,
    FeedbackReply,
    ForecastReply,
    LanguageEntry,
    LanguagesReply,
    MessagesReply,
    Order,
    OrdersReply,
    ShopPatch,
    TopItemsReply,
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
from app.service import (NotFound, UndoExpired, auto_order_today, build_reply, build_shelf_reply, busy_text,
                         confirm, create_order, feedback_thanks, order_lines_from_forecast,
                         post_auto_order_message, summary_facts, summary_template, today_ist,
                         top_items, undo)
from app.store import FeedbackRecord, InMemoryRepository, Repository, new_id, now_iso

ALLOWED_AUDIO = {"audio/m4a", "audio/mp4", "audio/x-m4a", "audio/wav", "audio/x-wav",
                 "audio/webm", "audio/ogg", "audio/mpeg", "audio/aac"}
MAX_AUDIO_BYTES = 10 * 1024 * 1024
ALLOWED_IMAGE = {"image/jpeg", "image/jpg", "image/png"}
MAX_IMAGE_BYTES = 8 * 1024 * 1024


class ApiError(Exception):
    def __init__(self, status: int, code: str, message: str, reply_text: str | None = None) -> None:
        self.status, self.code, self.message, self.reply_text = status, code, message, reply_text


def create_app(settings: Settings | None = None, repo: Repository | None = None,
               extractor: Extractor | None = None,
               forecast_source: ForecastSource | None = None,
               feedback_sink: FeedbackSink | None = None) -> FastAPI:
    settings = settings or get_settings()
    if repo is None:
        from app.store_firestore import make_repository

        repo = make_repository(settings)  # STORE=firestore|memory
    app = FastAPI(title="Kirana Mitra API", version="1.0.0")
    # The Flutter web build runs on another origin (flutter run -d chrome picks a
    # random port), so allow any origin for the demo; tighten before production.
    app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"],
                       allow_headers=["*"])
    app.state.settings = settings
    app.state.repo = repo
    app.state.extractor = extractor  # built lazily so /healthz works without creds
    app.state.forecast_source = forecast_source
    app.state.feedback_sink = feedback_sink

    def get_feedback_sink() -> FeedbackSink:
        if app.state.feedback_sink is None:
            app.state.feedback_sink = make_feedback_sink(settings)
        return app.state.feedback_sink

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
        body = {"code": exc.code, "message": exc.message}
        if exc.reply_text:
            body["reply_text"] = exc.reply_text
        return JSONResponse(status_code=exc.status, content={"error": body})

    @app.exception_handler(RequestValidationError)
    async def _invalid(_: Request, exc: RequestValidationError):
        return JSONResponse(status_code=400,
                            content={"error": {"code": "invalid", "message": str(exc.errors()[:3])}})

    # ---- health -----------------------------------------------------------------

    # /health is the canonical health route (docs/api-contract.md): the run.app edge
    # answers the exact path /healthz with its own 404 before the request reaches the
    # container, which would make the app fall back to its mock in production.
    # /healthz stays as an alias for local use and older clients. Same JSON on both.
    @app.get("/health")
    @app.get("/healthz")
    def health():
        return {"ok": True, "model": model_id()}

    # ---- shops ------------------------------------------------------------------

    @app.post("/shops", status_code=201, response_model=Shop)
    def create_shop(body: ShopCreate):
        shop = repo.create_shop(body.shop_name, body.owner_name, body.language)
        if body.auto_restock or body.distributor_phone:
            shop = repo.update_shop(shop.shop_id, auto_restock=body.auto_restock,
                                    distributor_phone=body.distributor_phone)
        return Shop(**shop.__dict__)

    @app.get("/shops/{shop_id}", response_model=Shop)
    def get_shop_route(shop_id: str):
        return Shop(**get_shop(shop_id).__dict__)

    @app.patch("/shops/{shop_id}", response_model=Shop)
    def patch_shop(shop_id: str, body: ShopPatch):
        """Per-shop settings: auto_restock (default false), distributor_phone, language."""
        shop = get_shop(shop_id)
        fields = body.model_dump(exclude_unset=True)
        if "distributor_phone" in fields and fields["distributor_phone"] is not None:
            phone = fields["distributor_phone"].strip()
            if not (phone.startswith("+") and phone[1:].replace(" ", "").isdigit() and len(phone) >= 8):
                raise ApiError(400, "invalid", "distributor_phone must look like +91XXXXXXXXXX")
            fields["distributor_phone"] = phone.replace(" ", "")
        shop = repo.update_shop(shop.shop_id, **fields)
        return Shop(**shop.__dict__)

    @app.get("/languages", response_model=LanguagesReply)
    def languages():
        return LanguagesReply(languages=[LanguageEntry(**l.__dict__) for l in LANGUAGES])

    # ---- chat / voice -----------------------------------------------------------

    @app.post("/chat", response_model=ExtractionReply)
    def chat(body: ChatRequest):
        shop = get_shop(body.shop_id)
        try:
            extraction = get_extractor().extract(
                body.text, None, repo.list_items(shop.shop_id), shop.language)
        except GeminiFailed as exc:
            raise ApiError(502, "gemini_failed", str(exc), reply_text=busy_text(shop.language))
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
            raise ApiError(502, "gemini_failed", str(exc), reply_text=busy_text(shop.language))
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
            raise ApiError(502, "gemini_failed", str(exc), reply_text=busy_text(shop.language))
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
        wa.me share link; recorded as an Order with source "manual". Nothing is sent."""
        shop = get_shop(shop_id)
        try:
            _, _, items = await _forecast(shop)
        except Exception as exc:
            raise ApiError(502, "gemini_failed", f"forecast source failed: {exc}")
        lines = order_lines_from_forecast(repo, shop, items)
        order = create_order(repo, shop, lines, source="manual")
        return ReorderReply(order_id=order.order_id,
                            lines=[ReorderLine(**l) for l in lines],
                            text=order.text, whatsapp_url=order.whatsapp_url)

    # ---- Phase 7: top items, orders, auto-restock, messages, feedback -------------------

    @app.get("/top-items/{shop_id}", response_model=TopItemsReply)
    async def top_items_route(shop_id: str, weeks: int = 2, limit: int = 10):
        """Items ranked by forecast demand over the next `weeks` weeks (default 2, max 4),
        with the same-length window of history, trend, cover days and the 2-week reorder."""
        shop = get_shop(shop_id)
        if not 1 <= weeks <= 4 or not 1 <= limit <= 50:
            raise ApiError(400, "invalid", "weeks must be 1-4 and limit 1-50")
        try:
            _, _, items = await _forecast(shop)
        except Exception as exc:
            raise ApiError(502, "gemini_failed", f"forecast source failed: {exc}")
        return TopItemsReply(generated_at=now_iso(), weeks=weeks,
                             items=top_items(items, weeks, limit))

    @app.get("/orders/{shop_id}", response_model=OrdersReply)
    def orders(shop_id: str):
        shop = get_shop(shop_id)
        return OrdersReply(orders=[Order(**o.__dict__) for o in repo.list_orders(shop.shop_id)])

    @app.get("/messages/{shop_id}", response_model=MessagesReply)
    def messages(shop_id: str, since: str | None = None):
        """Bot messages created server-side (auto-order notices), newest first, last 50,
        optionally only those created after ?since=<ISO-8601>."""
        shop = get_shop(shop_id)
        if since:
            since = since.strip().replace(" ", "+")  # an unencoded "+05:30" arrives as a space
        return MessagesReply(messages=[
            BotMessage(**m.__dict__) for m in repo.list_bot_messages(shop.shop_id, since, 50)])

    @app.post("/auto-restock/run", response_model=AutoRestockReply)
    async def auto_restock_run(shop_id: str | None = None,
                               x_scheduler_token: str | None = Header(default=None)):
        """Cloud Scheduler entry point (header X-Scheduler-Token = env SCHEDULER_TOKEN).
        For every shop with auto_restock on (or just ?shop_id=), order the items that pass
        all three signals: top-10 seller by actual units over the last 4 weeks, on_hand
        covering fewer than 7 days at the forecast rate, and each of the last 2 weeks at
        least 1.2x the baseline weekly average. One auto order per shop per day, with an
        undoable bot message in the shop's chat explaining each line."""
        if not settings.scheduler_token or x_scheduler_token != settings.scheduler_token:
            raise ApiError(401, "unauthorized", "missing or wrong X-Scheduler-Token")
        shops = [get_shop(shop_id)] if shop_id else repo.list_shops()
        today = today_ist()
        placed: list[Order] = []
        skipped: list[AutoRestockSkip] = []
        for shop in shops:
            if not shop.auto_restock:
                skipped.append(AutoRestockSkip(shop_id=shop.shop_id, reason="auto_restock_off"))
                continue
            if auto_order_today(repo, shop.shop_id, today) is not None:
                skipped.append(AutoRestockSkip(shop_id=shop.shop_id, reason="already_ran_today"))
                continue
            try:
                _, _, items = await _forecast(shop)
            except Exception as exc:
                logging.getLogger("kirana.restock").warning("forecast failed for %s: %s",
                                                            shop.shop_id, exc)
                skipped.append(AutoRestockSkip(shop_id=shop.shop_id, reason="forecast_failed"))
                continue
            lines = order_lines_from_forecast(repo, shop, items, auto=True)
            if not lines:
                skipped.append(AutoRestockSkip(shop_id=shop.shop_id, reason="nothing_to_order"))
                continue
            order = create_order(repo, shop, lines, source="auto")
            post_auto_order_message(repo, shop, order)
            placed.append(Order(**order.__dict__))
        return AutoRestockReply(ran_at=now_iso(), shops_checked=len(shops), orders=placed,
                                skipped=skipped)

    def _store_feedback(shop, screen: str, rating: str, comment: str | None,
                        app_version: str | None, platform: str | None) -> FeedbackReply:
        script = detect_script(comment or "")
        language = (DEFAULT_LANGUAGE_FOR_SCRIPT.get(script, shop.language)
                    if script and script != "Latin" else shop.language)
        fb = FeedbackRecord(feedback_id=new_id("fb"), shop_id=shop.shop_id, screen=screen,
                            rating=rating, comment=comment, language=language,
                            app_version=app_version, platform=platform, created_at=now_iso())
        repo.add_feedback(fb)
        get_feedback_sink().send(fb)  # BigQuery when configured; never fails the request
        return FeedbackReply(feedback_id=fb.feedback_id, reply_text=feedback_thanks(shop.language))

    @app.post("/feedback", status_code=201, response_model=FeedbackReply)
    def feedback(body: FeedbackCreate):
        shop = get_shop(body.shop_id)
        if not body.screen.strip():
            raise ApiError(400, "invalid", "screen is required")
        return _store_feedback(shop, body.screen.strip(), body.rating, body.comment,
                               body.app_version, body.platform)

    @app.post("/feedback-voice", status_code=201, response_model=FeedbackReply)
    async def feedback_voice(shop_id: str = Form(...), screen: str = Form(...),
                             rating: str = Form(...), audio: UploadFile = File(...),
                             app_version: str | None = Form(default=None),
                             platform: str | None = Form(default=None)):
        """Same as /feedback but the comment is transcribed from a voice note by Gemini."""
        shop = get_shop(shop_id)
        if rating not in ("up", "down"):
            raise ApiError(400, "invalid", "rating must be up or down")
        mime = (audio.content_type or "").split(";")[0].strip().lower()
        if mime not in ALLOWED_AUDIO:
            raise ApiError(400, "invalid", f"unsupported audio type {mime!r}")
        data = await audio.read()
        if not data or len(data) > MAX_AUDIO_BYTES:
            raise ApiError(400, "invalid", "audio empty or too large (max 10 MB)")
        if mime in {"audio/m4a", "audio/x-m4a"}:
            mime = "audio/mp4"
        try:
            comment = await run_in_threadpool(get_extractor().transcribe, (data, mime), shop.language)
        except GeminiFailed as exc:
            raise ApiError(502, "gemini_failed", str(exc), reply_text=busy_text(shop.language))
        return _store_feedback(shop, screen.strip(), rating, comment or None, app_version, platform)

    return app


app = create_app()
