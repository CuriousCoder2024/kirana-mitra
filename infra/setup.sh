#!/usr/bin/env bash
# One-time Google Cloud setup for Kirana Mitra. Idempotent: re-running skips
# anything that already exists. Every step that costs money asks first and
# prints the estimated monthly cost.
#
# Usage:  infra/setup.sh [--dry-run] [--yes] [--with-cloudsql]
#   --dry-run        print every gcloud command instead of running it (no PROJECT_ID needed)
#   --yes            skip the confirmation prompts (CI / you already read the costs)
#   --with-cloudsql  also create the Cloud SQL instance (ON HOLD: nothing Cloud SQL
#                    related runs without this flag; the backend uses BigQuery +
#                    its own store for now)
#
# Reads infra/.env (copy infra/.env.example). Requires PROJECT_ID.
#
# What it creates, in order:
#   1. APIs: aiplatform, run, cloudbuild, artifactregistry, sqladmin, bigquery, storage   (free)
#   2. Artifact Registry docker repo $AR_REPO in $REGION                                  (~free)
#   3. GCS bucket gs://$GCS_BUCKET in $REGION                                             (~free)
#   5. service account $CLOUD_RUN_SA with aiplatform.user, bigquery.jobUser,
#      READER+WRITER on the dataset and storage.objectUser on the bucket (free)
#   6. Cloud Scheduler job $SCHEDULER_JOB: POST $API_BASE_URL/auto-restock/run
#      daily 06:00 IST with X-Scheduler-Token (3 jobs free, then $0.10/job/month)
#   4. (only with --with-cloudsql) Cloud SQL for PostgreSQL instance $CLOUDSQL_INSTANCE,
#      db-f1-micro, + database + user (~$10-17/month)
# The BigQuery dataset is created by data/load_bigquery.sh.
set -euo pipefail
# shellcheck source=infra/common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
parse_common_flags "$@"
load_env
WITH_CLOUDSQL=0
for arg in "$@"; do [[ "$arg" == "--with-cloudsql" ]] && WITH_CLOUDSQL=1; done

echo "project: $PROJECT_ID   region: $REGION   dry-run: $DRY_RUN"

# 1. APIs (no cost to enable)
run gcloud services enable --project "$PROJECT_ID" \
  aiplatform.googleapis.com run.googleapis.com cloudbuild.googleapis.com \
  artifactregistry.googleapis.com sqladmin.googleapis.com \
  bigquery.googleapis.com storage.googleapis.com

# 2. Artifact Registry repo for the backend image
if [[ "$DRY_RUN" != "1" ]] && gcloud artifacts repositories describe "$AR_REPO" \
     --project "$PROJECT_ID" --location "$REGION" >/dev/null 2>&1; then
  echo "artifact registry repo $AR_REPO exists, skipping"
else
  if confirm "Create Artifact Registry repo '$AR_REPO' in $REGION.
  Est. cost: storage \$0.10/GB-month after the first 0.5 GB free; a few
  backend images ~ under \$1/month. (https://cloud.google.com/artifact-registry/pricing)"; then
    run gcloud artifacts repositories create "$AR_REPO" --project "$PROJECT_ID" \
      --location "$REGION" --repository-format docker \
      --description "Kirana Mitra backend images"
  else
    echo "skipped artifact registry repo"
  fi
fi

# 3. GCS bucket for voice notes and shelf photos
: "${GCS_BUCKET:?GCS_BUCKET must be set in infra/.env (globally unique bucket name)}"
if [[ "$DRY_RUN" != "1" ]] && gcloud storage buckets describe "gs://$GCS_BUCKET" \
     --project "$PROJECT_ID" >/dev/null 2>&1; then
  echo "bucket gs://$GCS_BUCKET exists, skipping"
else
  if confirm "Create bucket gs://$GCS_BUCKET in $REGION (Standard class).
  Est. cost: ~\$0.023/GB-month in asia-south1; demo media well under 1 GB,
  so a few cents/month. Note the always-free 5 GB applies to US regions only.
  (https://cloud.google.com/storage/pricing)"; then
    run gcloud storage buckets create "gs://$GCS_BUCKET" --project "$PROJECT_ID" \
      --location "$REGION" --uniform-bucket-level-access --public-access-prevention
  else
    echo "skipped bucket"
  fi
fi

# 4. Cloud SQL for PostgreSQL: smallest shared-core tier. ON HOLD: skipped
#    unless --with-cloudsql is given.
if [[ "$WITH_CLOUDSQL" != "1" ]]; then
  echo "cloud sql: skipped (on hold; pass --with-cloudsql to create it)"
else

#    db-f1-micro (shared vCPU, 0.6 GB) is the smallest machine type listed under
#    "Instance pricing" on https://cloud.google.com/sql/pricing (checked
#    2026-10-18; Iowa list price $0.0105/h ~ $7.70/month, Mumbai is a little
#    higher). It is Enterprise edition only and not covered by the SLA
#    (https://cloud.google.com/sql/docs/postgres/instance-settings), which is
#    fine for a demo. PostgreSQL 16+ defaults to Enterprise Plus, so the
#    edition is passed explicitly.
if [[ "$DRY_RUN" != "1" ]] && gcloud sql instances describe "$CLOUDSQL_INSTANCE" \
     --project "$PROJECT_ID" >/dev/null 2>&1; then
  echo "cloud sql instance $CLOUDSQL_INSTANCE exists, skipping"
else
  if confirm "Create Cloud SQL PostgreSQL 16 instance '$CLOUDSQL_INSTANCE' (db-f1-micro, zonal, 10 GB, no backups) in $REGION.
  Est. cost: instance ~\$8-10/month + 10 GB storage ~\$1-2/month + public IPv4
  ~\$7/month while idle  =>  roughly \$10-17/month, billed per second while
  running. Stop it between demos:  gcloud sql instances patch $CLOUDSQL_INSTANCE --activation-policy NEVER
  Delete it with infra/teardown.sh. (https://cloud.google.com/sql/pricing)"; then
    if [[ "$DRY_RUN" == "1" ]]; then
      CLOUDSQL_PASSWORD="${CLOUDSQL_PASSWORD:-<CLOUDSQL_PASSWORD>}"
    else
      : "${CLOUDSQL_PASSWORD:?CLOUDSQL_PASSWORD must be set in infra/.env before creating the instance}"
    fi
    run gcloud sql instances create "$CLOUDSQL_INSTANCE" --project "$PROJECT_ID" \
      --database-version POSTGRES_16 --edition ENTERPRISE --tier db-f1-micro \
      --region "$REGION" --availability-type zonal --storage-size 10GB \
      --no-backup --root-password "$CLOUDSQL_PASSWORD"
  else
    echo "skipped cloud sql instance (database and user skipped too)"
  fi
fi

if [[ "$DRY_RUN" == "1" ]] || gcloud sql instances describe "$CLOUDSQL_INSTANCE" \
     --project "$PROJECT_ID" >/dev/null 2>&1; then
  if [[ "$DRY_RUN" != "1" ]] && gcloud sql databases describe "$CLOUDSQL_DB" \
       --instance "$CLOUDSQL_INSTANCE" --project "$PROJECT_ID" >/dev/null 2>&1; then
    echo "database $CLOUDSQL_DB exists, skipping"
  else
    run gcloud sql databases create "$CLOUDSQL_DB" --instance "$CLOUDSQL_INSTANCE" --project "$PROJECT_ID"
  fi
  if [[ "$DRY_RUN" != "1" ]] && gcloud sql users list --instance "$CLOUDSQL_INSTANCE" \
       --project "$PROJECT_ID" --format 'value(name)' 2>/dev/null | grep -qx "$CLOUDSQL_USER"; then
    echo "user $CLOUDSQL_USER exists, skipping"
  else
    # password is read from the environment, never echoed by `run` in dry-run
    # beyond the placeholder; rotate it in the console if it ever leaks.
    run gcloud sql users create "$CLOUDSQL_USER" --instance "$CLOUDSQL_INSTANCE" \
      --project "$PROJECT_ID" --password "${CLOUDSQL_PASSWORD:-<CLOUDSQL_PASSWORD>}"
  fi
fi
fi  # WITH_CLOUDSQL

# 5. Runtime service account for Cloud Run (free). Least privilege: call
#    Gemini on Vertex AI, run BigQuery jobs, read the kirana dataset, and
#    read/write the media bucket.
SA_NAME="${CLOUD_RUN_SA:-kirana-mitra-api}"
SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
if [[ "$DRY_RUN" != "1" ]] && gcloud iam service-accounts describe "$SA_EMAIL" \
     --project "$PROJECT_ID" >/dev/null 2>&1; then
  echo "service account $SA_EMAIL exists, skipping create"
else
  run gcloud iam service-accounts create "$SA_NAME" --project "$PROJECT_ID" \
    --display-name "Kirana Mitra API (Cloud Run)"
fi
for role in roles/aiplatform.user roles/bigquery.jobUser; do
  run gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member "serviceAccount:$SA_EMAIL" --role "$role" --condition None --quiet
done
# Dataset-level access: READER (= bigquery.dataViewer) for the forecast and
# WRITER (= bigquery.dataEditor) so the API can stream rows into
# kirana.feedback. `bq add-iam-policy-binding` needs allowlisting, so patch
# the access list.
if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY RUN: bq update --source <access.json with READER+WRITER $SA_EMAIL> $PROJECT_ID:$BQ_DATASET"
elif bq --project_id="$PROJECT_ID" show --dataset "$BQ_DATASET" >/dev/null 2>&1; then
  ACCESS_JSON="$(mktemp)"
  bq --project_id="$PROJECT_ID" show --format=prettyjson "$PROJECT_ID:$BQ_DATASET" \
    | python3 -c '
import json, sys
sa = sys.argv[1]
ds = json.load(sys.stdin)
access = ds.get("access", [])
for role in ("READER", "WRITER"):
    if not any(a.get("userByEmail") == sa and a.get("role") == role for a in access):
        access.append({"role": role, "userByEmail": sa})
json.dump({"access": access}, sys.stdout)
' "$SA_EMAIL" > "$ACCESS_JSON"
  run bq --project_id="$PROJECT_ID" update --source "$ACCESS_JSON" "$PROJECT_ID:$BQ_DATASET"
  rm -f "$ACCESS_JSON"
else
  echo "dataset $BQ_DATASET not found yet; run data/load_bigquery.sh load, then re-run setup for the dataset grant"
fi
run gcloud storage buckets add-iam-policy-binding "gs://$GCS_BUCKET" --project "$PROJECT_ID" \
  --member "serviceAccount:$SA_EMAIL" --role roles/storage.objectUser

# 6. Cloud Scheduler: daily auto-restock at 06:00 IST. Needs API_BASE_URL (the
#    Cloud Run URL from deploy.sh) and SCHEDULER_TOKEN (openssl rand -hex 24)
#    in infra/.env; deploy.sh passes the same token to the service.
#    Idempotent: creates the job or updates it in place.
SCHEDULER_JOB="${SCHEDULER_JOB:-kirana-auto-restock}"
if [[ "$DRY_RUN" != "1" && ( -z "${API_BASE_URL:-}" || "$API_BASE_URL" == http://localhost* ) ]]; then
  echo "cloud scheduler: skipped (API_BASE_URL in infra/.env is not the Cloud Run URL yet; run infra/deploy.sh, then re-run setup)"
elif [[ "$DRY_RUN" != "1" && -z "${SCHEDULER_TOKEN:-}" ]]; then
  echo "cloud scheduler: skipped (SCHEDULER_TOKEN missing; add SCHEDULER_TOKEN=\$(openssl rand -hex 24) to infra/.env)"
else
  SCHED_URI="${API_BASE_URL:-<API_BASE_URL>}/auto-restock/run"
  SCHED_ARGS=(--location "$REGION" --schedule "0 6 * * *" --time-zone "Asia/Kolkata"
              --uri "$SCHED_URI" --http-method POST
              --headers "X-Scheduler-Token=${SCHEDULER_TOKEN:-<SCHEDULER_TOKEN>},Content-Type=application/json"
              --attempt-deadline 300s --max-retry-attempts 1
              --description "Kirana Mitra daily auto-restock (POST /auto-restock/run)")
  if [[ "$DRY_RUN" != "1" ]] && gcloud scheduler jobs describe "$SCHEDULER_JOB" \
       --project "$PROJECT_ID" --location "$REGION" >/dev/null 2>&1; then
    echo "scheduler job $SCHEDULER_JOB exists, updating in place"
    run gcloud scheduler jobs update http "$SCHEDULER_JOB" --project "$PROJECT_ID" "${SCHED_ARGS[@]}"
  elif confirm "Create Cloud Scheduler job '$SCHEDULER_JOB' in $REGION: POST $SCHED_URI daily at 06:00 IST.
  Est. cost: the first 3 jobs per billing account are free, then \$0.10/job/month.
  (https://cloud.google.com/scheduler/pricing)"; then
    run gcloud services enable cloudscheduler.googleapis.com --project "$PROJECT_ID"
    run gcloud scheduler jobs create http "$SCHEDULER_JOB" --project "$PROJECT_ID" "${SCHED_ARGS[@]}"
  else
    echo "skipped scheduler job"
  fi
fi

echo
echo "setup done. Next: uv run data/generate_sales.py && data/load_bigquery.sh all && infra/deploy.sh"
[[ "$DRY_RUN" == "1" ]] && echo "(dry run: nothing was executed)"
exit 0
