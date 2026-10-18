# infra/

gcloud scripts for Kirana Mitra. Every script reads `infra/.env`, refuses to
run without `PROJECT_ID`, and prints its commands with `--dry-run`. Paid
steps print an estimated monthly cost and ask before creating anything.

```bash
cp infra/.env.example infra/.env   # fill in PROJECT_ID, GCS_BUCKET, CLOUDSQL_PASSWORD, GEMINI_MODEL
```

`.env` is git-ignored. Never commit it.

## Order

| Step | Command | Costs money? |
|---|---|---|
| 1 | `infra/setup.sh --dry-run` then `infra/setup.sh` | APIs: no. Artifact Registry repo and GCS bucket: cents. Cloud SQL db-f1-micro: **~$10-17/month** while running (asks first). |
| 2 | `uv run data/generate_sales.py` | no |
| 3 | `data/load_bigquery.sh all` | under 1 cent per run (ARIMA_PLUS training); everything else inside the BigQuery free tier. See `data/README.md`. |
| 4 | `infra/deploy.sh --dry-run` then `infra/deploy.sh` | Cloud Build minutes (120 free/day) + Cloud Run with `min-instances 0`: free at demo traffic. |
| 5 | Put the printed URL in `API_BASE_URL` (infra/.env and the app) | no |

Gemini on Vertex AI is billed per token when the backend runs; a demo day is
a few rupees. `GEMINI_MODEL` is owned by `backend/.env.example`; copy the value.

## What setup.sh creates

- Enables: aiplatform, run, cloudbuild, artifactregistry, sqladmin, bigquery, storage.
- Artifact Registry docker repo `$AR_REPO` in asia-south1 (deploy.sh pushes the backend image there).
- GCS bucket `gs://$GCS_BUCKET` in asia-south1, uniform access, public access prevented.
- Cloud SQL for PostgreSQL 16, Enterprise edition, `db-f1-micro` (shared core,
  smallest tier on the [pricing page](https://cloud.google.com/sql/pricing);
  not SLA-covered, fine for a demo), zonal, 10 GB, backups off, plus database
  `kirana` and user `kirana` with `CLOUDSQL_PASSWORD`.

Each step is idempotent: it checks `describe` first and skips what exists.

## deploy.sh

`gcloud run deploy` from `backend/` source, region asia-south1,
`--allow-unauthenticated --min-instances 0 --max-instances 3 --timeout 120`,
Cloud SQL attached via `--add-cloudsql-instances`, and these env vars on the
service: `GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, GEMINI_MODEL, GCS_BUCKET,
BQ_DATASET, CLOUDSQL_INSTANCE` (connection name `project:region:instance`),
`DB_NAME, DB_USER, DB_PASSWORD`. If `backend/.env.example` uses different
names, change the `ENV_VARS` block in `deploy.sh` in the same commit.

The DB password is passed as a plain env var for the hackathon. For anything
longer-lived, put it in Secret Manager and use `--set-secrets`.

## Stopping the bill

- Between demos: `gcloud sql instances patch kirana-pg --activation-policy NEVER`
  (and `ALWAYS` to resume). Cloud Run at min-instances 0 costs nothing idle.
- For good: `infra/teardown.sh` deletes the Cloud SQL instance and the bucket
  after a confirmation each. `infra/teardown.sh --all` also removes the Cloud
  Run service, the Artifact Registry repo and the BigQuery dataset.

## Not verified

The scripts pass shellcheck and their dry runs print the expected commands,
but none has been executed against a project (owner's rule: ask before
creating paid resources). Flags were checked against the current gcloud docs;
if `gcloud sql instances create` rejects `--edition ENTERPRISE` with
`--tier db-f1-micro` on your gcloud version, run `gcloud components update`.
