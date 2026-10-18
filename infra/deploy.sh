#!/usr/bin/env bash
# Deploy the FastAPI backend to Cloud Run from source (Cloud Build builds the
# image from backend/Dockerfile and pushes it to the Artifact Registry repo).
#
# Usage:  infra/deploy.sh [--dry-run]
# Reads infra/.env. Requires PROJECT_ID; GEMINI_MODEL, GCS_BUCKET and the
# Cloud SQL settings are passed to the service as environment variables.
#
# Cost: Cloud Run with min-instances 0 bills only while requests run (free
# tier: 2 million requests/month); Cloud Build has 120 free build-minutes/day.
# Each deploy is a 2-4 minute build.
set -euo pipefail
# shellcheck source=infra/common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
parse_common_flags "$@"
load_env

IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$AR_REPO/$CLOUD_RUN_SERVICE"
CONNECTION_NAME="$PROJECT_ID:$REGION:$CLOUDSQL_INSTANCE"

# Environment variables the backend reads. Names mirror backend/.env.example;
# if that file changes, change this list in the same commit.
ENV_VARS="GOOGLE_CLOUD_PROJECT=$PROJECT_ID"
ENV_VARS+=",GOOGLE_CLOUD_LOCATION=${GOOGLE_CLOUD_LOCATION:-$REGION}"
ENV_VARS+=",GEMINI_MODEL=${GEMINI_MODEL:-}"
ENV_VARS+=",GCS_BUCKET=${GCS_BUCKET:-}"
ENV_VARS+=",BQ_DATASET=$BQ_DATASET"
ENV_VARS+=",CLOUDSQL_INSTANCE=$CONNECTION_NAME"
ENV_VARS+=",DB_NAME=$CLOUDSQL_DB"
ENV_VARS+=",DB_USER=$CLOUDSQL_USER"
# Demo shortcut: the DB password rides along as a plain env var. For anything
# beyond the hackathon, store it in Secret Manager and use --set-secrets.
ENV_VARS+=",DB_PASSWORD=${CLOUDSQL_PASSWORD:-}"

if [[ "$DRY_RUN" != "1" && -z "${GEMINI_MODEL:-}" ]]; then
  echo "GEMINI_MODEL is empty in infra/.env; copy the value from backend/.env.example" >&2
  exit 1
fi

run gcloud run deploy "$CLOUD_RUN_SERVICE" \
  --project "$PROJECT_ID" \
  --region "$REGION" \
  --source "$REPO_DIR/backend" \
  --image "$IMAGE" \
  --allow-unauthenticated \
  --min-instances 0 \
  --max-instances 3 \
  --cpu 1 \
  --memory 1Gi \
  --timeout 120 \
  --add-cloudsql-instances "$CONNECTION_NAME" \
  --set-env-vars "$ENV_VARS"

if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY RUN: gcloud run services describe $CLOUD_RUN_SERVICE --project $PROJECT_ID --region $REGION --format value(status.url)"
  echo "(dry run: nothing was executed)"
else
  URL="$(gcloud run services describe "$CLOUD_RUN_SERVICE" --project "$PROJECT_ID" \
         --region "$REGION" --format 'value(status.url)')"
  echo
  echo "deployed: $URL"
  echo "set API_BASE_URL=$URL in infra/.env and in the app's env, then: curl $URL/healthz"
fi
