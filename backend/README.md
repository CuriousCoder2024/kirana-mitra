# Kirana Mitra backend

FastAPI service that turns a shopkeeper's Hindi / Hinglish / English text or voice note into a
stock or udhaar (credit) entry, using Gemini on Vertex AI through the official `google-genai`
SDK with structured JSON output. Implements [`docs/api-contract.md`](../docs/api-contract.md) v1.

Phase 1 ships `/shops`, `/chat`, `/voice-note`, `/confirm`, `/undo`, `/stock`, `/ledger`,
`/health` (alias `/healthz`). Phase 3 adds `/shelf-scan` (Gemini vision counts units on a shelf photo). Phase 5
adds `/forecast` (BigQuery ML ARIMA_PLUS, festival-aware), `/summary` (evening hisaab) and
`/reorder` (order text plus WhatsApp link). Phase 7 adds `/top-items`, per-shop settings
(`PATCH /shops/{id}`), `/auto-restock/run` for Cloud Scheduler, `/orders`, `/messages`,
`/feedback` and `/feedback-voice`, `/languages`, and replies in all 22 scheduled languages. Storage is an in-memory repository seeded with 15 common
kirana items; Phase 4 swaps in Cloud SQL behind the same `Repository` interface.

## Run locally

Requires [uv](https://docs.astral.sh/uv/) (`brew install uv`). Python 3.12 is pulled by uv.

```bash
cd backend
uv sync
cp .env.example .env        # then edit GOOGLE_CLOUD_PROJECT
uv run uvicorn app.main:app --port 8080 --reload
```

### Google Cloud auth (live Gemini)

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
gcloud services enable aiplatform.googleapis.com
```

Vertex AI Gemini calls are pay-per-token; nothing else (no Cloud SQL, no buckets) is needed
for Phase 1.

### Env vars (see `.env.example`)

| Var | Meaning |
|---|---|
| `GOOGLE_GENAI_USE_VERTEXAI` | `true`: use Vertex AI with ADC, not an API key |
| `GOOGLE_CLOUD_PROJECT` | your project id |
| `GOOGLE_CLOUD_LOCATION` | `global` (where Gemini 3.x Flash is served) |
| `GEMINI_MODEL` | `gemini-3.8-flash` (GA, audio in + structured output; [model page](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-8-flash)) |
| `MOCK_GEMINI` | `1`: offline regex extractor, no credentials, no cost. Use this to integrate the app without a project |
| `CONFIRM_THRESHOLD` | default `0.7`; below it the entry waits for a confirm tap |
| `FORECAST_SOURCE` | `bigquery` or `local`. Default `bigquery` when `GOOGLE_CLOUD_PROJECT` is set and `MOCK_GEMINI` is off, else `local` |
| `BQ_DATASET` | `kirana` (created by `data/load_bigquery.sh`) |
| `BQ_LOCATION` | `asia-south1`, the dataset's location |
| `DATA_DIR` | folder with `catalogue.csv`, `sales_history.csv`, `festivals.csv`, `festival_uplift.csv` for the local source; default `../data` |
| `SCHEDULER_TOKEN` | shared secret; `POST /auto-restock/run` requires header `X-Scheduler-Token` equal to it, else 401. Unset = always 401 |

Mock mode:

```bash
MOCK_GEMINI=1 uv run uvicorn app.main:app --port 8080 --reload
```

## Try it

```bash
curl -s -X POST localhost:8080/shops -H 'content-type: application/json' \
  -d '{"shop_name":"Gupta General Store","owner_name":"Ramesh Gupta","language":"hi-Latn"}'
```

Take the `shop_id` from the response, then:

```bash
curl -s -X POST localhost:8080/chat -H 'content-type: application/json' \
  -d '{"shop_id":"shp_...","text":"Gupta ji ne 350 rupaye udhaar liya"}'
```

```bash
curl -s -X POST localhost:8080/voice-note -F shop_id=shp_... -F audio=@note.m4a;type=audio/m4a
```

Shelf photo (jpeg/png, ≤ 8 MB). The counts come back held; confirm to set the stock:

```bash
curl -s -X POST localhost:8080/shelf-scan -F shop_id=shp_... -F image=@shelf.jpg
```

```bash
curl -s -X POST localhost:8080/confirm -H 'content-type: application/json' \
  -d '{"shop_id":"shp_...","message_id":"msg_..."}'
```

```bash
curl -s localhost:8080/stock/shp_...
curl -s localhost:8080/ledger/shp_...
curl -s -X POST localhost:8080/undo -H 'content-type: application/json' \
  -d '{"shop_id":"shp_...","message_id":"msg_..."}'
```

Forecast, evening summary and reorder list:

```bash
curl -s localhost:8080/forecast/shp_...
```

```bash
curl -s "localhost:8080/summary/shp_...?date=2026-10-18"
```

```bash
curl -s -X POST localhost:8080/reorder/shp_...
```

Health: `GET /health` (canonical; `/healthz` is an alias). On Cloud Run the run.app edge answers the
exact path `/healthz` with its own 404 before the container sees it, so clients must probe `/health`.

Top sellers, orders, auto-restock and feedback:

```bash
curl -s "localhost:8080/top-items/shp_...?weeks=2"
```

```bash
curl -s -X PATCH localhost:8080/shops/shp_... -H 'content-type: application/json' \
  -d '{"auto_restock":true,"distributor_phone":"+919876543210"}'
```

```bash
curl -s -X POST "localhost:8080/auto-restock/run?shop_id=shp_..." -H 'X-Scheduler-Token: change-me'
```

```bash
curl -s localhost:8080/orders/shp_...
curl -s "localhost:8080/messages/shp_...?since=2026-10-18T00:00:00+05:30"
```

```bash
curl -s -X POST localhost:8080/feedback -H 'content-type: application/json' \
  -d '{"shop_id":"shp_...","screen":"forecast","rating":"up","comment":"badhiya","app_version":"1.0.0","platform":"android"}'
```

```bash
curl -s -X POST localhost:8080/feedback-voice -F shop_id=shp_... -F screen=stock -F rating=down -F audio=@note.m4a
```

```bash
curl -s localhost:8080/languages
```

Interactive docs: http://localhost:8080/docs

## How a message is handled

1. `app/gemini.py` sends the text, or the audio bytes inline, to Gemini with one system prompt
   (few-shot in Devanagari, Hinglish and English) and `response_schema=Extraction`, so the
   reply is always valid JSON: intent, confidence, language, transcript, entities, reply_text.
2. `app/matching.py` fuzzy-matches each spoken item name against the shop's catalogue with
   rapidfuzz ("parle ji" → Parle-G) and merges near-duplicate customer names.
3. `app/service.py` applies the write when confidence ≥ 0.7 (`applied: true`, Undo chip),
   otherwise parks it by `message_id` and offers "Haan, add karo". `question` / `unclear`
   never write. Cartons/boxes are converted to the item's base unit using `carton_size`.
   The last 10 applied messages per shop can be undone.
4. `/shelf-scan` sends the image bytes inline with a second prompt and `response_schema=ShelfScan`
   (items with name, pack_size, count, confidence; each visible facing is one unit). Names are
   snapped to the catalogue, counts at or below `reorder_level` go into `low_stock`, and the
   result is held under `message_id`. `/confirm` then sets each item's stock to the counted
   quantity (an absolute set, not an add); `/undo` restores the previous quantities.

## Forecast, summary, reorder

`app/forecast.py` has a `ForecastSource` interface with two implementations that return the
same raw material (catalogue, 35 daily forecast points per item, 6 weeks of daily history,
festivals, uplift table); the shaping into the contract is shared and unit-tested:

- **BigQuery** (`FORECAST_SOURCE=bigquery`): `ML.FORECAST` on `kirana.item_demand_arima`, the
  ARIMA_PLUS model trained by `data/bqml/train_arima.sql`, plus the `sales_daily`, `catalogue`,
  `festivals` and `festival_uplift` tables. Results are cached for 10 minutes per series. Only
  `shp_demo` has history in BigQuery, so any other shop id (for example one created in the app)
  is served the demo series while its `on_hand` still comes from its own stock.
- **Local** (`FORECAST_SOURCE=local`, or automatically with `MOCK_GEMINI=1`): reads the CSVs in
  `data/` and makes a seasonal-naive forecast (same-weekday mean of the last 4 weeks), so the
  forecast screen works offline.

Shaping: 4 Monday-start weeks beginning on or after today; the festival multiplier from
`festival_uplift.csv` ramps over `pre_days` and holds through `post_days` (mirrors
`data/bqml/forecast.sql`). All 4 weeks are returned for the chart, but
`reorder_qty = max(0, round(sum of the next REORDER_COVER_WEEKS = 2 forecast weeks) - on_hand)`
rounded up to the item's carton size, so stock that already covers 2 weeks gets 0 and is left out
of `/reorder`; `reorder_reason` names a festival only when it falls inside those 2 weeks and is in
the shop's language. Only items the shop actually stocks are returned, joined to the data
catalogue by name and alias.

`/summary` sums the day's applied messages (sales at MRP, or the amount the user quoted),
the ledger's udhaar given and received, the outstanding total and the low-stock list.
`reply_text` is written by Gemini from those numbers, with a fixed template fallback so the
endpoint never fails because of Gemini. `/reorder` lists the forecast items with
`reorder_qty > 0` and returns a `wa.me` share link; nothing is sent.

Forecast accuracy: `data/bqml/evaluate.sql` retrains on history minus 14 days and compares the
forecast with the held-out actuals, per item, into `kirana.forecast_eval`. The headline numbers
are copied to `tests/eval/forecast_results.csv`: over 40 items the 14-day volume-weighted WAPE is
11.0%, the median per-item MAPE is 43.9% and the median per-item WAPE 50.9% (daily demand of
0 to 20 units is noisy, so per-item daily errors are high while totals over two weeks are close).

## Top items, auto-restock, orders, messages

- `GET /top-items/{shop_id}?weeks=2&limit=10` ranks the shop's items by forecast demand over the
  next `weeks` weeks (1 to 4), with the same-length window of history, `trend_pct`, `cover_days`
  (on_hand divided by forecast demand per day) and the same 2-week `reorder_qty` as `/forecast`.
- `PATCH /shops/{shop_id}` sets `auto_restock` (default false), `distributor_phone` (`+91...`,
  used as the `wa.me` number) and `language`. Both settings are in the Shop object.
- `POST /auto-restock/run[?shop_id=]` is the Cloud Scheduler entry point and needs the
  `X-Scheduler-Token` header. For each shop with `auto_restock` on it orders only the items that
  pass all three signals (constants in `app/service.py`):
  1. **top seller**: rank ≤ `TOP_SELLER_RANK` (10) by actual units sold over the last 4 complete
     weeks (history, not forecast);
  2. **low stock**: `cover_days` < `AUTO_COVER_DAYS` (7), where cover days = on_hand divided by the
     forecast daily rate over the next 2 weeks;
  3. **sustained demand**: each of the last `SUSTAINED_WEEKS` (2) weeks is at least `DEMAND_UPLIFT`
     (1.2) times the average of the 8 weeks before them; with fewer than 10 weeks of history, both
     weeks must beat the whole-history weekly average by that factor. `demand_ratio` is the weaker
     of the two weeks over the baseline.
  The quantity is the usual 2-week `reorder_qty`. Each auto line carries `rank`, `cover_days` and
  `demand_ratio`, and the bot message says why ("Parle-G 264 packet (top-1 seller, 2 din ka stock,
  2 hafte se demand 1.4x)"). If anything qualifies and no auto order exists for today, it records
  an Order (`source: auto`, `status: placed`) and posts that message into the shop's chat with
  `undo` and `open_orders` quick actions; `POST /undo` with the message id sets the order to
  `cancelled`. The run is idempotent per shop per day, cancelled orders included.
  `GET /top-items` exposes the same three signals per item (`rank`, `cover_days`, `demand_ratio`)
  plus `auto_restock_eligible`. Manual `POST /reorder` is unchanged: every item with
  `reorder_qty > 0`, no reasoning fields.
- `GET /orders/{shop_id}` lists orders newest first; `POST /reorder` records one with
  `source: manual`. `GET /messages/{shop_id}?since=` returns the last 50 server-side bot messages
  so the app can show them when it opens.

## Feedback

`POST /feedback` (JSON: shop_id, screen, rating up|down, comment, app_version, platform) and
`POST /feedback-voice` (multipart, the comment is transcribed from the audio by Gemini) store the
feedback in the repository and, when BigQuery is configured (`FORECAST_SOURCE=bigquery`), stream
it into `kirana.feedback` (feedback_id, shop_id, screen, rating, comment, language, app_version,
platform, created_at) from a background thread. A BigQuery failure is logged and never fails the
request. `language` is detected from the comment's script, else the shop's language.

## Languages

`app/languages.py` lists the 22 scheduled languages plus `en` and `hi-Latn` with English name,
native name, script and an `rtl` flag (`ks`, `sd`, `ur`); `GET /languages` returns the table. Every
`language` field accepts those codes. The extraction, shelf and summary prompts tell Gemini to
reply in the shop's language in its native script (Hinglish stays Roman) unless the user's message
is in a different language or script mix, in which case it mirrors the user; brand names in
`entities.items` are always written in Latin letters so the catalogue match works in every script.
Python-side strings (running totals, quick-action labels, the summary fallback) exist for `hi`,
`hi-Latn` and `en`; every other code gets English. The mock extractor detects the script
(Bengali, Tamil, Perso-Arabic, ...) to fill `language` and replies in English for codes it has
no template for.

## Tests and eval

Fast unit tests (Gemini scripted, no network):

```bash
uv run pytest -q
```

The BigQuery integration test is marked `slow` and skips itself unless `FORECAST_SOURCE=bigquery`
and the dataset and model exist:

```bash
uv run pytest -q -m slow
```

Eval harness: 44 utterances in `tests/eval/samples.jsonl` (Hindi script, Hinglish, English,
all five intents, deliberately ambiguous ones, and two each in Bengali, Tamil, Telugu, Marathi,
Gujarati, Kannada, Malayalam, Punjabi and Urdu). It creates one shop per language, calls `/chat`,
prints intent accuracy, entity accuracy (item, quantity, customer, amount), language detection,
whether the reply came back in the language's own script, p50/p95 latency and a per-language
table, and appends a row to `tests/eval/results.csv` with the date and model id.

```bash
uv run python -m tests.eval.run            # against http://localhost:8080
uv run python -m tests.eval.run --base https://your-cloud-run-url
```

Shelf-scan eval: five synthetic shelf images with exact per-brand counts in
`tests/eval/shelf/` (see its README for why synthetic). Reports detection recall, precision,
exact-count rate, mean absolute count error and latency, appending to
`tests/eval/shelf/results.csv`.

```bash
uv run python -m tests.eval.shelf.run --base http://localhost:8090
```

## Docker (Cloud Run, Phase 6)

```bash
docker build -t kirana-mitra-backend .
docker run -p 8080:8080 -e MOCK_GEMINI=1 kirana-mitra-backend
```

On Cloud Run set `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION=global`, `GEMINI_MODEL`; the
service account's ADC is used automatically.
