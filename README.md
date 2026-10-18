# Kirana Mitra

A voice- and photo-first assistant for small Indian grocery shops (kiranas).
Built for the Google Cloud AI Builder Cup, Retail & Commerce track, by team singapuria_innovators.

The shopkeeper never types forms. They:

1. Snap a shelf photo. The app counts items and flags low stock.
2. Send a voice note in Hindi, Hinglish or English. It becomes a stock entry or an udhaar (credit) entry.
3. Get a festival-aware demand forecast and a one-tap reorder list.
4. Get an evening "hisaab" summary: sales, low stock, money owed.

Replies come back in the same language and mix the shopkeeper used.

## Layout

| Folder | What lives there |
|---|---|
| `app/` | Flutter app (Android first, web build for the demo) |
| `backend/` | Python + FastAPI service, Dockerfile, deployed on Cloud Run |
| `data/` | Seed scripts and the sample catalogue |
| `infra/` | gcloud setup scripts and env templates |

## Stack

Flutter, FastAPI on Cloud Run, Gemini on Vertex AI (google-genai SDK, structured JSON output),
Cloud SQL for PostgreSQL, BigQuery + BigQuery ML ARIMA_PLUS for forecasts, Cloud Storage for media.

## Status

Phase 1 (backend skeleton, `/chat` and `/voice-note` with Gemini, mock DB) is in progress.
Local run and deploy steps will be added as each phase lands.

Secrets and project IDs live in untracked `.env` files. See `infra/` for templates.
