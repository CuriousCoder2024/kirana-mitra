# Kirana Mitra backend

FastAPI service that turns a shopkeeper's Hindi / Hinglish / English text or voice note into a
stock or udhaar (credit) entry, using Gemini on Vertex AI through the official `google-genai`
SDK with structured JSON output. Implements [`docs/api-contract.md`](../docs/api-contract.md) v1.

Phase 1 ships `/shops`, `/chat`, `/voice-note`, `/confirm`, `/undo`, `/stock`, `/ledger`,
`/healthz`. Phase 3 adds `/shelf-scan` (Gemini vision counts units on a shelf photo). 501 stubs
with the final shapes in their docstrings remain for `/forecast`, `/summary`, `/reorder`. Storage is an in-memory repository seeded with 15 common
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

## Tests and eval

Fast unit tests (Gemini scripted, no network):

```bash
uv run pytest -q
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
