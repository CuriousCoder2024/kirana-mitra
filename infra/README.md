# infra/

gcloud scripts for Kirana Mitra. Every script reads `infra/.env`, refuses to
run without `PROJECT_ID`, and prints its commands with `--dry-run`. Paid
steps print an estimated monthly cost and ask before creating anything.

```bash
cp infra/.env.example infra/.env   # fill in PROJECT_ID, GCS_BUCKET, CLOUDSQL_PASSWORD, GEMINI_MODEL
```

`.env` is git-ignored. Never commit it.

## Status (2026-10-18)

Done for real on project `kirana-mitra-app` with the `kirana` gcloud
configuration: APIs enabled, Artifact Registry repo `kirana-mitra`, bucket
`gs://kirana-mitra-app-media`, service account `kirana-mitra-api@...` with
its roles, BigQuery dataset loaded and trained, and the backend deployed:

    https://kirana-mitra-api-hm57brg65q-el.a.run.app

Cloud SQL is **on hold**: nothing Cloud SQL related runs unless you pass
`--with-cloudsql` to `setup.sh` / `deploy.sh`. The web app is not published
yet (`deploy_web.sh` is ready, the app is mid-redesign).

## Order

| Step | Command | Costs money? |
|---|---|---|
| 1 | `infra/setup.sh --dry-run` then `infra/setup.sh` | APIs: no. Artifact Registry repo and GCS bucket: cents. Service account + IAM: no. Cloud SQL (only with `--with-cloudsql`): **~$10-17/month** while running, asks first. |
| 2 | `uv run data/generate_sales.py` | no |
| 3 | `data/load_bigquery.sh all` | under 1 cent per run (ARIMA_PLUS training); everything else inside the BigQuery free tier. See `data/README.md`. |
| 4 | `infra/deploy.sh --dry-run` then `infra/deploy.sh` | Cloud Build minutes (120 free/day) + Cloud Run with `min-instances 0`: free at demo traffic. First deploy took ~4 min. |
| 5 | Put the printed URL in `API_BASE_URL` (infra/.env and the app) | no |
| 6 | `firebase login --reauth` once, then `infra/deploy_web.sh` | Firebase Hosting free tier. Not run yet; owner runs it. |

Gemini on Vertex AI is billed per token when the backend runs; a demo day is
a few rupees. `GEMINI_MODEL` is owned by `backend/.env.example`; copy the value.

## What setup.sh creates

- Enables: aiplatform, run, cloudbuild, artifactregistry, sqladmin, bigquery, storage.
- Artifact Registry docker repo `$AR_REPO` in asia-south1 (deploy.sh pushes the backend image there).
- GCS bucket `gs://$GCS_BUCKET` in asia-south1, uniform access, public access prevented.
- Service account `$CLOUD_RUN_SA` (default `kirana-mitra-api`) with
  `roles/aiplatform.user` and `roles/bigquery.jobUser` on the project, READER
  (= dataViewer) on the `kirana` dataset, `roles/storage.objectUser` on the
  media bucket. Cloud Run runs as this account.
- Only with `--with-cloudsql`: Cloud SQL for PostgreSQL 16, Enterprise
  edition, `db-f1-micro` (shared core, smallest tier on the
  [pricing page](https://cloud.google.com/sql/pricing); not SLA-covered, fine
  for a demo), zonal, 10 GB, backups off, plus database `kirana` and user
  `kirana` with `CLOUDSQL_PASSWORD`. Not created; on hold.

Each step is idempotent: it checks `describe` first and skips what exists.

## deploy.sh

`gcloud run deploy` from `backend/` source (Cloud Build, image pushed to the
Artifact Registry repo), region asia-south1, service account
`kirana-mitra-api`, `--allow-unauthenticated --min-instances 1
--max-instances 1 --concurrency 20 --cpu 1 --memory 1Gi --timeout 120`, and
these env vars on the service: `GOOGLE_CLOUD_PROJECT,
GOOGLE_GENAI_USE_VERTEXAI=true, GOOGLE_CLOUD_LOCATION=global` (where Gemini
3.x Flash is served), `GEMINI_MODEL, MOCK_GEMINI, CONFIRM_THRESHOLD,
GCS_BUCKET, BQ_DATASET, FORECAST_SOURCE=bigquery`. With `--with-cloudsql` it
also attaches the instance and adds `CLOUDSQL_INSTANCE, DB_NAME, DB_USER,
DB_PASSWORD` (plain env var; use Secret Manager for anything longer-lived).
If `backend/.env.example` changes names, change the `ENV_VARS` block in the
same commit.

Verified on the first deploy: `POST /shops`, `POST /chat` (live Gemini,
4.1 s) and `GET /forecast` (BigQuery, with the Diwali bump) all work.
**Known quirk:** `GET /healthz` returns a Google 404 page without reaching
the container, while `GET /healthz/` reaches FastAPI; the exact path
`/healthz` is intercepted by the run.app frontend. The backend exposes
`GET /health` with the same JSON (verified on revision 00002); use that for
uptime checks and the app.

## Firestore: the backend's store

Owner's decision (2026-10-18): persistence is Firestore, not Cloud SQL.
`setup.sh` enables `firestore.googleapis.com`, creates the `(default)`
database in Native mode in asia-south1 (a project has exactly one, so the
step is idempotent) and grants the Cloud Run service account
`roles/datastore.user`. `deploy.sh` sets `STORE=firestore` and
`FIRESTORE_DATABASE=(default)` on the service. Cost: free tier covers 1 GiB
stored and 50k reads / 20k writes per day
([pricing](https://cloud.google.com/firestore/pricing)), far above demo
traffic. The Cloud SQL step stays in the scripts behind `--with-cloudsql`
and is not used.

## Cloud Scheduler: daily auto-restock

`setup.sh` creates (or updates) job `kirana-auto-restock` in asia-south1:
`POST $API_BASE_URL/auto-restock/run` daily at 06:00 Asia/Kolkata with
header `X-Scheduler-Token`. The token is a shared secret: generate it once
with `openssl rand -hex 24`, put it in the untracked `infra/.env` as
`SCHEDULER_TOKEN`, and `deploy.sh` passes the same value to Cloud Run as the
`SCHEDULER_TOKEN` env var. Rotate it by changing `.env`, then running
`infra/deploy.sh` and `infra/setup.sh` again. Cost: the first 3 scheduler
jobs per billing account are free, then $0.10/job/month.

Verified 2026-10-18 on revision `kirana-mitra-api-00003-jql`: a manual
`gcloud scheduler jobs run` reached the service as `Google-Cloud-Scheduler`
and got HTTP 200; a POST without the header gets 401.

Trigger it by hand and read the result:

```bash
CLOUDSDK_ACTIVE_CONFIG_NAME=kirana gcloud scheduler jobs run kirana-auto-restock --project kirana-mitra-app --location asia-south1
```

```bash
CLOUDSDK_ACTIVE_CONFIG_NAME=kirana gcloud logging read 'resource.type="cloud_run_revision" AND httpRequest.requestUrl:"auto-restock"' --project kirana-mitra-app --limit 3 --format='value(timestamp,httpRequest.status,httpRequest.userAgent)'
```

**Instances and cost.** Min 1 / max 1 is the owner's decision (2026-10-18):
the backend keeps shops in memory, so one always-warm instance keeps them
alive between requests and the 06:00 scheduler run sees them. An idle
1 vCPU / 1 GiB instance bills roughly $5-10 per month on top of the free
tier. Every deploy still replaces that instance and wipes the shops, so
redeploy only on the owner's go. Override per run with
`CLOUD_RUN_MIN_INSTANCES` / `CLOUD_RUN_MAX_INSTANCES` in `infra/.env`.

## deploy_web.sh: the web demo on Firebase Hosting

Firebase was added to project `kirana-mitra-app` on 2026-10-18 through the
Firebase Management API (state ACTIVE, default Hosting site
`kirana-mitra-app`). Hosting config lives at the repo root: `firebase.json`
(public `app/build/web`, SPA rewrite to `/index.html`, no-cache on
`index.html`, `flutter_service_worker.js`, `flutter_bootstrap.js` and
`version.json`, one-year immutable cache on hashed assets) and `.firebaserc`
(default project). Free tier: 10 GB stored, 360 MB/day transfer
([pricing](https://firebase.google.com/pricing)).

`infra/deploy_web.sh` (default `--firebase`) builds the Flutter web app with
`--dart-define API_BASE_URL=<Cloud Run URL> --base-href /` and runs
`firebase deploy --only hosting --project kirana-mitra-app`. Result:
**https://kirana-mitra-app.web.app** (also `kirana-mitra-app.firebaseapp.com`).
`--gcs` keeps the public-bucket fallback at
`https://storage.googleapis.com/<bucket>/index.html` (asks before creating
the bucket).

The owner runs it from a terminal; the firebase CLI (15.x is installed via
nvm) needs a one-time browser login on this machine:

```bash
firebase login --reauth
```

```bash
infra/deploy_web.sh
```

Nothing in `app/` is touched by the scripts. The backend allows CORS from
any origin, so no API change is needed for the new host.

## Not verified

- `setup.sh --with-cloudsql` (the Cloud SQL block) and `teardown.sh` have only
  been dry-run. If `gcloud sql instances create` rejects `--edition ENTERPRISE`
  with `--tier db-f1-micro` on your gcloud version, run `gcloud components update`.
- `deploy_web.sh` has only been dry-run in both modes. The firebase CLI on
  this machine has expired credentials, so the first `firebase deploy` needs
  `firebase login --reauth`. In `--gcs` mode a
  `constraints/storage.publicAccessPrevention` org policy would block the bucket.
