# Kirana Mitra API contract (v1)

Frozen for the parallel build. Backend implements it, Flutter consumes it,
data/infra seeds against it. Change it only by editing this file first and
telling the other sessions.

Base URL: `http://localhost:8080` locally (env `API_BASE_URL` in the app).
All bodies are JSON unless noted. All times are ISO-8601 in `Asia/Kolkata`.
Money is integer rupees. Languages: `hi` (Hindi, Devanagari), `en`, `hi-Latn`
(Hinglish, Roman script). `reply_text` is always in the shop's preferred
language unless the user's message itself was in a different mix, in which
case it mirrors the user's mix.

## Errors
```json
{ "error": { "code": "not_found | invalid | gemini_failed | undo_expired", "message": "human readable" } }
```
HTTP 400 for invalid, 404 for not_found, 502 for gemini_failed, 409 for undo_expired.

## POST /shops
```json
{ "shop_name": "Gupta General Store", "owner_name": "Ramesh Gupta", "language": "hi-Latn" }
```
→ 201
```json
{ "shop_id": "shp_01HX...", "shop_name": "...", "owner_name": "...", "language": "hi-Latn", "created_at": "..." }
```

## POST /chat
```json
{ "shop_id": "shp_...", "text": "Kal Parle-G ke 3 carton aaye" }
```
→ 200 `ExtractionReply` (below)

## POST /voice-note
`multipart/form-data`: field `shop_id` (text), field `audio` (file; `audio/m4a`,
`audio/mp4`, `audio/wav`, `audio/webm` or `audio/ogg`; ≤ 60 s). Audio goes to
Gemini as inline bytes; no separate speech-to-text step.
→ 200 `ExtractionReply`, with `transcript` filled in.

## ExtractionReply
```json
{
  "message_id": "msg_01HX...",
  "intent": "stock_in | sale | udhaar_given | udhaar_paid | question | unclear",
  "confidence": 0.0,
  "transcript": "optional, voice only: what Gemini heard, in the speaker's script",
  "language": "hi | en | hi-Latn",
  "entities": {
    "items": [ { "name": "Parle-G", "pack_size": "70g", "quantity": 3, "unit": "carton | piece | kg | litre | packet | box", "unit_price": null } ],
    "customer_name": "Gupta ji",
    "amount": 350,
    "date": "2026-10-17"
  },
  "applied": true,
  "reply_text": "Samjha: Parle-G 70g, 3 carton stock mein add kiya. Ab total 5 carton.",
  "quick_actions": [
    { "label": "Undo", "action": "undo", "payload": { "message_id": "msg_01HX..." } },
    { "label": "Stock dekho", "action": "open_stock", "payload": {} }
  ]
}
```
Rules:
- `applied` is true when the backend already wrote the entry (stock_in, sale,
  udhaar_given, udhaar_paid with confidence ≥ 0.7). Below 0.7, `applied` is
  false and `quick_actions` carries `{ "label": "Haan, add karo", "action": "confirm", "payload": { "message_id": "..." } }`.
- `question` and `unclear` never write; `reply_text` answers or asks back.
- `entities` fields not relevant to the intent are `null` (items `[]`).
- `quick_actions[].action` ∈ `undo | confirm | open_stock | open_udhaar | open_forecast | send_order`.

## POST /confirm
```json
{ "shop_id": "shp_...", "message_id": "msg_..." }
```
→ 200 `ExtractionReply` with `applied: true`.

## POST /undo
```json
{ "shop_id": "shp_...", "message_id": "msg_..." }
```
→ 200 `{ "undone": true, "reply_text": "Theek hai, Gupta ji ka ₹350 udhaar hata diya. Total ₹850." }`
Undo is allowed for the last 10 applied messages of the shop; older → 409.

## GET /stock/{shop_id}
→ 200
```json
{ "items": [ { "item_id": "itm_...", "name": "Parle-G", "pack_size": "70g", "quantity": 42, "unit": "packet", "reorder_level": 24, "low_stock": false, "updated_at": "..." } ] }
```

## GET /ledger/{shop_id}
→ 200
```json
{ "customers": [ { "customer_name": "Gupta ji", "balance": 1200, "last_entry_at": "..." } ], "total_outstanding": 4350 }
```

## POST /shelf-scan  (Phase 3; shape fixed now)
`multipart/form-data`: `shop_id`, `image` (jpeg/png ≤ 8 MB).
→ 200
```json
{ "message_id": "msg_...", "items": [ { "name": "Maggi", "pack_size": "70g", "count": 6, "confidence": 0.8 } ], "low_stock": [ { "name": "Maggi", "count": 6, "reorder_level": 12 } ], "reply_text": "...", "quick_actions": [ { "label": "Haan, update karo", "action": "confirm", "payload": { "message_id": "msg_..." } } ] }
```

## GET /forecast/{shop_id}  (Phase 5; shape fixed now)
→ 200
```json
{ "generated_at": "...", "weeks": ["2026-10-19", "2026-10-26", "2026-11-02", "2026-11-09"],
  "festivals": [ { "name": "Diwali", "date": "2026-11-08" } ],
  "items": [ { "item_id": "itm_...", "name": "Parle-G", "unit": "packet", "history_weekly": [40, 38, 45, 41], "forecast_weekly": [44, 52, 90, 48], "lower": [38, 44, 70, 40], "upper": [50, 60, 110, 56], "on_hand": 42, "reorder_qty": 120, "reorder_reason": "Diwali week demand ~2x" } ] }
```

## GET /summary/{shop_id}?date=YYYY-MM-DD  (Phase 5)
→ 200 `{ "date": "...", "sales_total": 8450, "entries": 23, "low_stock": [ ... as in /stock ... ], "udhaar_given": 350, "udhaar_received": 500, "total_outstanding": 4350, "reply_text": "Aaj ka hisaab: ..." }`

## POST /reorder/{shop_id}  (Phase 5)
→ 200 `{ "order_id": "ord_...", "lines": [ { "name": "Parle-G 70g", "qty": 120, "unit": "packet" } ], "text": "Order for Gupta General Store ...", "whatsapp_url": "https://wa.me/?text=..." }`

## Health
`GET /health` → 200 `{ "ok": true, "model": "<gemini model id in use>" }`

`/healthz` is kept as an alias for local tooling, but clients must call
`/health`: on Cloud Run the `*.run.app` edge answers `/healthz` itself with an
HTML 404 and the request never reaches the service (observed 2026-10-18).

---

# v1.1 additions (2026-10-18 evening): top sellers, auto-restock, feedback, languages

## Languages
`GET /languages` → 200 `{ "languages": [ { "code": "ta", "name_en": "Tamil", "name_native": "தமிழ்", "script": "Tamil", "rtl": false } ] }`
Codes: the 22 scheduled languages `as bn brx doi gu hi kn ks kok mai ml mni mr ne or pa sa sat sd ta te ur` plus `en` and `hi-Latn` (Hinglish). `rtl` is true for `ks sd ur`. `POST /shops.language` and `ExtractionReply.language` accept any of these; Gemini replies in the shop's language and native script (Hinglish stays Roman).

## Shop settings
`PATCH /shops/{shop_id}` `{ "auto_restock": true, "distributor_phone": "+919876543210" }` (both optional) → 200 Shop. The Shop object now carries `auto_restock` (default false) and `distributor_phone` (nullable).

## Top sellers
`GET /top-items/{shop_id}?weeks=2` → 200
```json
{ "generated_at": "...", "items": [ { "item_id": "itm_...", "name": "Parle-G", "unit": "packet", "rank": 1,
  "forecast_units": 301, "history_units": 259, "trend_pct": 16, "on_hand": 42, "cover_days": 1.9,
  "demand_ratio": 1.4, "reorder_qty": 264, "reorder_reason": "Diwali week demand ~1.8x", "auto_restock_eligible": true } ] }
```
Sorted by `forecast_units` desc, 10 items by default. `history_units` is the same-length window just ended. `demand_ratio` is the mean of the last 2 weeks' actual units over the weekly average of the 8 weeks before (or whole history when shorter).

## Automatic restock rule
An item is auto-ordered only when all three hold: top 10 by actual units over the last 4 weeks; `cover_days < 7`; each of the last 2 weeks ≥ 1.2 × the earlier weekly average. Manual `POST /reorder` is unchanged.

`POST /auto-restock/run?shop_id=` (optional) with header `X-Scheduler-Token: <SCHEDULER_TOKEN>` → 200 `{ "ran_at": "...", "shops_checked": 3, "orders": [Order...] }`; 401 without a valid token; idempotent per shop per day. Each placed auto order also appends a bot message to the shop's chat with `quick_actions` `[undo, open_orders]`.

## Orders and server-side messages
```json
Order = { "order_id": "ord_...", "shop_id": "shp_...", "created_at": "...", "status": "placed | cancelled", "source": "auto | manual",
  "message_id": "msg_... (for undo)", "lines": [ { "name": "Parle-G 70g", "qty": 264, "unit": "packet", "rank": 1, "cover_days": 1.9, "demand_ratio": 1.4 } ],
  "text": "...", "whatsapp_url": "https://wa.me/<distributor_phone or empty>?text=..." }
```
`GET /orders/{shop_id}` → 200 `{ "orders": [Order...] }` newest first. `POST /reorder/{shop_id}` now also records an Order with `source: "manual"`. `POST /undo` with an auto order's `message_id` sets it to `cancelled`.
`GET /messages/{shop_id}?since=<ISO>` → 200 `{ "messages": [ { "message_id", "created_at", "reply_text", "quick_actions": [...] } ] }`, last 50 server-generated bot messages (auto-order notices), for the app to show on open.

## Feedback
`POST /feedback` `{ "shop_id", "screen", "rating": "up | down", "comment": "optional", "app_version": "1.0.0+1", "platform": "android | web | ios" }` → 201 `{ "feedback_id": "fb_...", "reply_text": "Shukriya! Aapka feedback mil gaya." }`
`POST /feedback-voice` multipart `shop_id, screen, rating, audio` (+ optional app_version, platform) → 201 same shape, with the comment transcribed by Gemini. Stored in the repository and streamed to BigQuery `kirana.feedback` when configured; a BigQuery failure never fails the request.
