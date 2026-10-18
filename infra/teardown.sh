#!/usr/bin/env bash
# Delete the paid resources so the project stops billing.
#
# Usage:  infra/teardown.sh [--dry-run] [--yes] [--all]
#   default   deletes the Cloud SQL instance and the GCS bucket (the two things
#             that cost money while idle), each after a confirmation
#   --all     also deletes the Cloud Run service, the Artifact Registry repo
#             and the BigQuery dataset (free when idle, but tidy)
set -euo pipefail
# shellcheck source=infra/common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
parse_common_flags "$@"
load_env
ALL=0
for arg in "$@"; do [[ "$arg" == "--all" ]] && ALL=1; done

echo "project: $PROJECT_ID   region: $REGION   dry-run: $DRY_RUN"

if confirm "DELETE Cloud SQL instance '$CLOUDSQL_INSTANCE' and all its data. This cannot be undone (no backups were configured)."; then
  run gcloud sql instances delete "$CLOUDSQL_INSTANCE" --project "$PROJECT_ID" --quiet
else
  echo "kept cloud sql instance"
fi

if confirm "DELETE bucket gs://${GCS_BUCKET:-<GCS_BUCKET>} and every object in it."; then
  run gcloud storage rm --recursive "gs://${GCS_BUCKET:-<GCS_BUCKET>}"
else
  echo "kept bucket"
fi

if [[ "$ALL" == "1" ]]; then
  if confirm "DELETE Cloud Run service '$CLOUD_RUN_SERVICE', Artifact Registry repo '$AR_REPO' and BigQuery dataset '$BQ_DATASET'."; then
    run gcloud run services delete "$CLOUD_RUN_SERVICE" --project "$PROJECT_ID" --region "$REGION" --quiet
    run gcloud artifacts repositories delete "$AR_REPO" --project "$PROJECT_ID" --location "$REGION" --quiet
    run bq --project_id="$PROJECT_ID" rm -r -f -d "$PROJECT_ID:$BQ_DATASET"
  else
    echo "kept cloud run service, repo and dataset"
  fi
fi

echo "teardown done"
[[ "$DRY_RUN" == "1" ]] && echo "(dry run: nothing was executed)"
exit 0
