# Kirana Mitra: 5-minute pitch outline

Team singapuria_innovators. Google Cloud AI Builder Cup, Retail & Commerce track.
Seven slides, at most three bullets each, drawn only from this repo. Time budget: 5:00 including the 2-minute demo.
Source for each claim is in brackets. Numbers are synthetic-data results from 2026-10-18; say so on the results slide.

## 1. The problem (0:00 to 0:30)

- A kirana tracks stock, sales and customer credit (udhaar) by hand: stock arrives in cartons and sells by the packet, and the app's ledger is styled as the familiar bahi-khata. [`README.md`, `backend/app/service.py` carton conversion, `docs/design/handoff.md`]
- Existing tools ask the owner to fill forms; the shopkeeper speaks Hindi, Hinglish or English and works with one hand free. [`docs/api-contract.md` languages; design rules in `docs/design/handoff.md`]
- The gaps the product targets: running short before a festival, udhaar that is hard to total, no end-of-day number. (This is the product's framing; no market-size or survey figure is in the repo, so do not quote one.)

## 2. The user (0:30 to 0:50)

- Ramesh Gupta, Gupta General Store: 15 everyday items on his shelf, a handful of regular credit customers. [`backend/app/store.py` seed items; demo persona in `docs/submission/demo-script.md`]
- He picks his own language at sign-up (हिंदी, Hinglish or English) and every reply comes back in that mix. [`app/lib/screens/onboarding_screen.dart`, `docs/api-contract.md`]
- Design rules for him: 56 dp primary buttons, 18 sp text, a word beside every icon, Undo always a labelled button. [`docs/design/handoff.md`]

## 3. Demo (0:50 to 2:50)

- Voice note "Kal Parle-G ke 3 carton aaye" becomes a stock entry; typed "Gupta ji ne 350 rupaye udhaar liya" becomes an udhaar entry, both with Undo. [`docs/submission/demo-script.md` steps 2 and 3]
- Shelf photo counted by Gemini, held until he taps "Haan, update karo". [step 4]
- Forecast with the Diwali bump, one tap to a WhatsApp order, then the evening hisaab card. [steps 5 and 6]

## 4. Architecture (2:50 to 3:20)

- Flutter app (Android and web) calls a FastAPI service on Cloud Run; the app falls back to a built-in mock so the demo never dies on a bad network. [`README.md` architecture, `app/lib/api/api_provider.dart`]
- Gemini 3.8 Flash on Vertex AI for text, audio and image; BigQuery ML `ARIMA_PLUS` for demand; Cloud Storage and Artifact Registry around them. [`backend/app/gemini.py`, `data/bqml/train_arima.sql`, `infra/setup.sh`]
- One `Repository` interface hides storage (in-memory today), so Cloud SQL can drop in without touching the service layer. [`backend/app/store.py`]

## 5. AI approach (3:20 to 4:00)

- **Structured output, not free text:** one system prompt with few-shot examples in Devanagari, Hinglish and English plus `response_schema` makes Gemini return valid JSON (intent, confidence, language, transcript, entities, reply). Audio goes in as inline bytes, with no separate speech-to-text step. [`backend/app/gemini.py`, `docs/api-contract.md`]
- **Safe by construction:** below confidence 0.7 nothing is written until the owner confirms; `question` and `unclear` never write; every applied entry has Undo; the shelf scan is only applied after "Haan". Fuzzy matching ("parle ji" to Parle-G) snaps spoken names to the catalogue. [`backend/app/service.py`, `backend/app/matching.py`]
- **Festival-aware forecast:** ARIMA_PLUS per item, plus an explicit festival uplift table (Dussehra, Diwali and others) because BigQuery only learns holidays from more than a year of history; reorder covers the next 2 weeks and is rounded up to the carton. [`data/bqml/results.md`, `data/README.md`, `backend/app/forecast.py`]

## 6. Results (4:00 to 4:30)

- Shelf counts: 25 of 26 exact, recall 100%, on 5 synthetic images. Entry extraction: intent 96.2%, entities 100% on 26 typed utterances. [`backend/tests/eval/shelf/results.csv`, `backend/tests/eval/results.csv`]
- Forecast: 11.0% volume-weighted error with the festival uplift against 19.6% for raw ARIMA, 14-day holdout over 40 items (per-item MAPE is higher, median 43.9%). [`data/bqml/results.md`]
- Speed and cost: text entry p50 2.5 s, shelf scan p50 9 s; BigQuery work for the whole build under $0.01. State the caveats: synthetic data, small samples, long tail (p95 over 40 s). [`docs/submission/performance-report.md`]

## 7. What is next (4:30 to 5:00)

- Cloud SQL behind the existing `Repository` interface so stock and udhaar survive restarts (scripts exist behind `--with-cloudsql`, about $10 to $17 per month, not yet created). [`infra/README.md`, `backend/app/store.py`]
- Vertex AI Search is planned as a next step; it is not built and nothing in the repo uses it yet, so confirm the intended use with the team before presenting it. [coordinator brief only; no repo source]
- Real data and real shelves: evaluate on real shop sales and photos, recorded-audio accuracy, per-shop forecasts (a new shop currently sees the demo series), per-customer history endpoint, and the 21:30 evening notification from the design handoff. [`data/README.md`, `docs/design/handoff.md`, `README.md`]
