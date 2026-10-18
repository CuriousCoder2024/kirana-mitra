# Kirana Mitra: performance report

All measurements were taken on **2026-10-18** on project `kirana-mitra-app` with `gemini-3.8-flash` on Vertex AI
and the BigQuery dataset `kirana` in `asia-south1`. Every number below is copied from a file in this repo (named
in each table). Nothing here is measured on real shop data: sales history and shelf photos are synthetic, and the
samples are small. Read the caveat under each table before quoting a number.

## Summary

| Metric | Result | Sample | Source file |
|---|---|---|---|
| Item-count accuracy (shelf photo) | 25 of 26 counts exact (96.2%), recall 100%, precision 100%, mean absolute error 0.04 units | 5 synthetic images, 26 product counts, 144 units | `backend/tests/eval/shelf/results.csv` |
| Voice/text entry accuracy | intent 96.2% (25 of 26), entities 100% (26 of 26) | 26 typed utterances (Hindi, Hinglish, English); 6 also appear as prompt examples | `backend/tests/eval/results.csv` |
| Forecast error | 11.0% volume-weighted (WAPE) with festival uplift, 19.6% without; median per-item MAPE 43.9% | 40 items, 14-day holdout | `data/bqml/results.md`, `backend/tests/eval/forecast_results.csv` |
| Response time | text entry p50 2.5 s (p95 41.1 s); shelf scan p50 9.0 s (p95 113.3 s) | 26 and 5 requests | `backend/tests/eval/results.csv`, `backend/tests/eval/shelf/results.csv` |

## 1. Item-count accuracy (shelf-photo scan)

| | |
|---|---|
| Number | Exact-count rate **96.2%** (25 of 26 product counts exactly right). Detection recall **100%** (26 of 26 labelled products found). Precision **100%** (no product returned that was not labelled). Mean absolute count error **0.04** units (consistent with one product off by one). |
| Dataset | 5 images (`shelf_01_easy` to `shelf_05_noisy`), 26 labelled product counts, 144 units in total (per-image units 21, 34, 47, 8, 34). Labels in `backend/tests/eval/shelf/labels.json`; image table in `backend/tests/eval/shelf/README.md`. |
| How measured | `cd backend && uv run python -m tests.eval.shelf.run --base <server>` posts each image to `POST /shelf-scan` on a server running live Gemini, compares the returned counts with `labels.json`, and appends a row to `backend/tests/eval/shelf/results.csv`. Row used: `2026-10-18T21:04:21`, model `gemini-3.8-flash`, 0 HTTP failures. |
| Caveat | The images are **synthetic** (generated with Pillow by `make_images.py`, flat packs on shelf rows with jitter, overlap, blur and noise). No CC-licensed real kirana photos with countable units were found (searched Wikimedia Commons 2026-10-18), and hand-counting real photos would have made the labels unreliable. Five images is a tiny sample: one wrong count moves the exact rate by 3.8 points. Expect lower accuracy on real, cluttered shelves; this has not been measured. An earlier run (`2026-10-18T21:00:40`) scored recall 57.7% with 2 HTTP failures because the 40 s call deadline timed out on busy images; the deadline for vision was then raised to 90 s (`backend/app/gemini.py`) and the 21:04 run is the one reported. |
| Date | 2026-10-18 |

## 2. Voice-entry accuracy (intent and entity extraction)

| | |
|---|---|
| Number | Intent accuracy **96.2%** (25 of 26). Entity accuracy **100%** (26 of 26: item, quantity, customer and amount each matched where the sample defines them; the one sample with a `max_confidence` rule, `amb-01`, must also be held for confirmation). |
| Dataset | 26 utterances in `backend/tests/eval/samples.jsonl`: 10 Hinglish (Roman script), 7 Hindi (Devanagari), 6 English, 3 deliberately ambiguous ("shayad 5 maggi aaye, ya 6", "wo wala do", "Gupta ji wala hisaab"). All six intent values (`stock_in`, `sale`, `udhaar_given`, `udhaar_paid`, `question`, `unclear`) are covered. |
| How measured | `cd backend && uv run python -m tests.eval.run --base <server>` posts each utterance to `POST /chat`, scores intent, language and entities against the `expected` block, and appends a row to `backend/tests/eval/results.csv`. Row used: `2026-10-18T20:45:37`, model `gemini-3.8-flash`, 0 HTTP failures. The run before it (`20:40:38`) scored intent 96.2%, entities 96.2% with 1 HTTP failure (a timeout); the first row (`19:50:57`, model `mock-gemini`) is the offline regex stand-in, not Gemini. |
| Caveat | **The audio path is not what was measured.** The eval sends typed text to `/chat`; `/voice-note` (audio bytes straight to Gemini) is implemented and unit-tested with a scripted model, but no recorded-audio accuracy exists, so "voice accuracy" here means "accuracy on the transcript-level text". The 26 samples were written by the team, and **6 of them appear verbatim as few-shot examples in the system prompt** (`hi-latn-01`, `hi-latn-03`, `hi-latn-05`, `hi-01`, `en-02`, `amb-02` in `backend/app/gemini.py`), so the score is inflated and the real figure on unseen speech is lower; the demo phrases are among those six too. They are also cleaner than real noisy shop speech. 26 samples is small: one miss is 3.8 points. The results file does not say which sample missed the intent. |
| Date | 2026-10-18 |

## 3. Forecast error (BigQuery ML `ARIMA_PLUS` with festival uplift)

| | Raw ARIMA_PLUS | System (ARIMA_PLUS x festival uplift, what the API serves) |
|---|---|---|
| **Volume-weighted error over all items (WAPE)** | 19.6% | **11.0%** |
| Mean per-item MAPE | 45.7% | 47.3% |
| Median per-item MAPE | not recorded | 43.9% |
| Mean per-item WAPE | 61.3% | 60.7% |
| Median per-item WAPE | not recorded | 50.9% (`forecast_results.csv`) |

| | |
|---|---|
| Dataset | 40 items for shop `shp_demo`, 120 days of daily sales (2026-06-20 to 2026-10-17, 4,800 rows). Model retrained on history up to 2026-10-03 and scored on the **14 held-out days 2026-10-04 to 2026-10-17**, a window that contains Navratri. |
| How measured | `data/load_bigquery.sh evaluate` runs `data/bqml/evaluate.sql` (retrain on history minus 14 days, compare forecast with actuals per item, write `kirana.forecast_eval`). Written up in `data/bqml/results.md`; the headline row is copied to `backend/tests/eval/forecast_results.csv` (source column: `data/bqml/evaluate.sql -> kirana.forecast_eval`, queried 2026-10-18). |
| Reading it honestly | The headline for reorder decisions is the volume-weighted figure (11.0%), because a reorder is a total over many days and items. **Per-item MAPE is high** (median 43.9%, mean 47.3%) because many items sell 0 to 3 units a day (Pampers, Ketchup, Horlicks), where one unit of error is 50 to 100%. The festival uplift improved the volume-weighted error (19.6% to 11.0%) but did not improve mean per-item MAPE (45.7% to 47.3%, slightly worse). Top sellers are better: Parle-G 16%, Britannia Good Day 16%, Tata Salt 24%, Dairy Milk 25%, Lays 26% (system MAPE, `data/bqml/results.md`). |
| Caveat | **The data is synthetic and the uplift is circular.** `data/generate_sales.py` creates the history using the multipliers in `data/festival_uplift.csv`, and the forecast applies the same table (`data/README.md`: "Shared by the generator and `bqml/forecast.sql` so history and forecast tell the same story"). So the 19.6% to 11.0% gain shows the pipeline recovers an effect that was put into the data; it is not evidence that the multipliers are right for real shops. `HOLIDAY_REGION = 'IN'` is set on the model but `has_holiday_effect` is false for all 40 series (BigQuery only models holidays for series longer than a year), which is why the uplift is applied outside the model. One 14-day window with one festival is a single test; no cross-validation over several windows was run. |
| Date | 2026-10-18 |

## 4. Response time

| Path | p50 | p95 | Sample | Source / how measured | Date |
|---|---|---|---|---|---|
| Text entry `POST /chat` (Gemini 3.8 Flash) | **2.5 s** (2,549 ms) | 41.1 s (41,136 ms) | 26 requests | `backend/tests/eval/results.csv` row `20:45:37`, measured by `tests.eval.run` (wall clock per request). Server base URL is not recorded in the file. Earlier live run: p50 4.5 s, p95 41.8 s. | 2026-10-18 |
| Text entry, one call on Cloud Run | 4.1 s | n/a | 1 request | `infra/README.md` ("Verified on the first deploy"): `POST /chat` with live Gemini | 2026-10-18 |
| Shelf scan `POST /shelf-scan` | **9.0 s** (9,002 ms) | 113.3 s (113,337 ms; with 5 images this is the slowest one) | 5 images | `backend/tests/eval/shelf/results.csv` row `21:04:21`, measured by `tests.eval.shelf.run` | 2026-10-18 |
| BQML `CREATE MODEL` (40 series) | 5.3 s job, 8 to 9 s wall | n/a | 1 training | `data/bqml/results.md` | 2026-10-18 |
| BQML holdout evaluation job | 14.4 s | n/a | 1 run | `data/bqml/results.md` | 2026-10-18 |

| | |
|---|---|
| Caveat | **The tail is long.** With 26 requests the p95 is the second-slowest request, so at least two of 26 text requests took over 41 s, which is consistent with the 40 s per-call cap plus a retry in `backend/app/gemini.py` (cause not confirmed from logs). The typical request is fast (2.5 s), but a shopkeeper will sometimes wait close to a minute; the app shows a typing indicator and has a 60 s receive timeout. Shelf scans are the slowest path (the server allows 90 s per call, with one retry on transient errors). Latency to the `global` Gemini endpoint from India varies with load. Samples are small, were taken on one evening, and no voice-note, `/forecast` (apart from the notes below), `/summary` or `/reorder` timings were recorded in a results file. Not in the repo: a hand-over note from the backend session reports the first `/forecast` call at about 6 s (BigQuery `ML.FORECAST`) and about 30 ms afterwards while the 10-minute cache is warm (`CACHE_TTL_S = 600` in `backend/app/forecast.py`); that was not re-measured for this report. |

## Google Cloud services used

| Service | What it does here | Where |
|---|---|---|
| **Vertex AI, Gemini 3.8 Flash** (`gemini-3.8-flash`, `global` endpoint, `google-genai` SDK) | Turns typed text or inline audio into one structured entry (`response_schema=Extraction`); counts units on a shelf photo (`response_schema=ShelfScan`); narrates the evening hisaab. Low thinking level and a 40 s cap (90 s for vision) to keep latency down. | `backend/app/gemini.py` |
| **Cloud Run** | Hosts the FastAPI backend (service `kirana-mitra-api`, `asia-south1`, `--min-instances 0 --max-instances 2 --concurrency 20 --cpu 1 --memory 1Gi`, public). | `infra/deploy.sh`, `backend/Dockerfile` |
| **BigQuery** | Dataset `kirana` with sales, catalogue, festivals, uplift and evaluation tables and views. | `data/load_bigquery.sh`, `data/bqml/views.sql` |
| **BigQuery ML (`ARIMA_PLUS`)** | One time series per `(shop_id, item_id)`, 35-day horizon, queried with `ML.FORECAST`; the backend adds the festival uplift and buckets into 4 Monday-start weeks. | `data/bqml/train_arima.sql`, `backend/app/forecast.py` |
| **Cloud Build** | Builds the container from `backend/` during `gcloud run deploy --source`. | `infra/deploy.sh` |
| **Artifact Registry** | Docker repo `kirana-mitra` for the backend image. | `infra/setup.sh` |
| **Cloud Storage** | Media bucket `gs://kirana-mitra-app-media` (public access prevented) is provisioned, but the backend does not write to it yet. A second, public bucket is the target for the Flutter web build via `deploy_web.sh` (dry-run only so far). | `infra/setup.sh`, `infra/deploy_web.sh` |
| **IAM service account** | `kirana-mitra-api` runs Cloud Run with `roles/aiplatform.user`, `roles/bigquery.jobUser`, dataset READER and `roles/storage.objectUser` on the media bucket. | `infra/setup.sh` |
| Cloud SQL for PostgreSQL | **Not used.** Scripted behind `--with-cloudsql` (`db-f1-micro`, zonal, 10 GB) but never created; storage is in memory. | `infra/setup.sh`, `infra/README.md` |

## Cost note

From `data/bqml/results.md`, `data/README.md` and `infra/README.md` (prices checked by their authors on
2026-10-18; re-check before relying on them):

| Item | Cost |
|---|---|
| BigQuery loads and storage (about 1 MB) | free (batch loads are free; storage inside the 10 GiB/month free tier) |
| `ARIMA_PLUS` training | 10 MiB billed (the per-query minimum) at the training rate, **about $0.003** per training; `all` trains twice |
| One `evaluate` run | 104,857,600 bytes billed, about $0.0006 of query plus about $0.003 for the holdout model |
| One forecast query | about 60 MiB billed including setup, **under $0.001** per API call at on-demand rates (queries are inside the 1 TiB/month free tier) |
| All BigQuery work on 2026-10-18 (loads, 2 trainings, views, forecasts, evaluation, ad-hoc checks) | about 450 MiB billed, **under $0.01** |
| Cloud Run at `--min-instances 0` | free at demo traffic (scales to zero) |
| Cloud Build / first deploy | 120 free build minutes per day; the first deploy took about 4 minutes |
| Artifact Registry repo and Cloud Storage buckets | cents |
| Gemini on Vertex AI | billed per token; `infra/README.md` estimates **a few rupees for a demo day**. No token counts or per-request cost were recorded, so there is no per-entry figure. |
| Cloud SQL (if ever enabled with `--with-cloudsql`) | about **$10 to $17 per month** while running; **not running**, on hold |

Stopping the bill: `infra/teardown.sh` (add `--all` for Cloud Run, Artifact Registry and the dataset).
