#!/usr/bin/env bash
# One-time Google Cloud setup for Kirana Mitra. Idempotent: re-running skips
# anything that already exists. Every step that costs money asks first and
# prints the estimated monthly cost.
#
# Usage:  infra/setup.sh [--dry-run] [--yes]
#   --dry-run  print every gcloud command instead of running it (no PROJECT_ID needed)
#   --yes      skip the confirmation prompts (CI / you already read the costs)
#
# Reads infra/.env (copy infra/.env.example). Requires PROJECT_ID.
#
# What it creates, in order:
#   1. APIs: aiplatform, run, cloudbuild, artifactregistry, sqladmin, bigquery, storage   (free)
#   2. Artifact Registry docker repo $AR_REPO in $REGION                                  (~free)
#   3. GCS bucket gs://$GCS_BUCKET in $REGION                                             (~free)
#   4. Cloud SQL for PostgreSQL instance $CLOUDSQL_INSTANCE, db-f1-micro, + database + user (~$10-17/month)
# The BigQuery dataset is created by data/load_bigquery.sh.
set -euo pipefail
# shellcheck source=infra/common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
parse_common_flags "$@"
load_env

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

# 4. Cloud SQL for PostgreSQL: smallest shared-core tier.
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

echo
echo "setup done. Next: uv run data/generate_sales.py && data/load_bigquery.sh all && infra/deploy.sh"
[[ "$DRY_RUN" == "1" ]] && echo "(dry run: nothing was executed)"
exit 0
