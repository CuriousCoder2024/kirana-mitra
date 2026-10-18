# Kirana Mitra backend

FastAPI service that turns a shopkeeper's Hindi / Hinglish / English text or voice note into a
stock or udhaar (credit) entry, using Gemini on Vertex AI through the official `google-genai`
SDK with structured JSON output. Implements [`docs/api-contract.md`](../docs/api-contract.md) v1.

Phase 1 ships `/shops`, `/chat`, `/voice-note`, `/confirm`, `/undo`, `/stock`, `/ledger`,
`/health` (alias `/healthz`). Phase 3 adds `/shelf-scan` (Gemini vision counts units on a shelf photo). Phase 5
adds `/forecast` (BigQuery ML ARIMA_PLUS, festival-aware), `/summary` (evening hisaab) and
`/reorder` (order text plus WhatsApp link). Storage is an in-memory repository seeded with 15 common
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

Eval harness: 26 utterances in `tests/eval/samples.jsonl` (Hindi script, Hinglish, English,
all five intents plus deliberately ambiguous ones). It calls the running server's `/chat`,
prints intent accuracy, entity accuracy (item, quantity, customer, amount), p50/p95 latency,
and appends a row to `tests/eval/results.csv` with the date and model id.

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
