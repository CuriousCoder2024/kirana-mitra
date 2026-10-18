#!/usr/bin/env bash
# Shared helpers for infra/*.sh. Source, don't run.
#   load_env      : reads infra/.env (if present) and requires PROJECT_ID
#   run CMD...    : runs CMD, or prints it when DRY_RUN=1
#   confirm MSG   : prints MSG (cost estimate) and asks y/N; --yes skips the
#                   prompt, dry-run only prints. Returns 1 when declined.

INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034  # used by deploy.sh
REPO_DIR="$(cd "$INFRA_DIR/.." && pwd)"
DRY_RUN="${DRY_RUN:-0}"
ASSUME_YES="${ASSUME_YES:-0}"

load_env() {
  if [[ -f "$INFRA_DIR/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    . "$INFRA_DIR/.env"
    set +a
  fi
  # Use a named gcloud configuration without touching the active one.
  if [[ -n "${GCLOUD_CONFIG:-}" ]]; then
    export CLOUDSDK_ACTIVE_CONFIG_NAME="$GCLOUD_CONFIG"
  fi
  REGION="${REGION:-asia-south1}"
  BQ_DATASET="${BQ_DATASET:-kirana}"
  CLOUD_RUN_SERVICE="${CLOUD_RUN_SERVICE:-kirana-mitra-api}"
  AR_REPO="${AR_REPO:-kirana-mitra}"
  CLOUDSQL_INSTANCE="${CLOUDSQL_INSTANCE:-kirana-pg}"
  CLOUDSQL_DB="${CLOUDSQL_DB:-kirana}"
  CLOUDSQL_USER="${CLOUDSQL_USER:-kirana}"
  if [[ -z "${PROJECT_ID:-}" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      PROJECT_ID="<PROJECT_ID>"
      GCS_BUCKET="${GCS_BUCKET:-<GCS_BUCKET>}"
    else
      cat >&2 <<MSG
PROJECT_ID is not set. Nothing was run.
  cp infra/.env.example infra/.env   # then fill in PROJECT_ID etc.
  or: export PROJECT_ID=my-gcp-project
  Re-run with --dry-run to see the commands without a project.
MSG
      exit 1
    fi
  fi
}

run() {
  # echo the command with the DB password masked, then run it
  local shown="$*"
  if [[ -n "${CLOUDSQL_PASSWORD:-}" ]]; then
    shown="${shown//"$CLOUDSQL_PASSWORD"/***}"
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY RUN: $shown"
  else
    echo "+ $shown"
    "$@"
  fi
}

confirm() {
  echo
  echo "$1"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "(dry run: would ask for confirmation here)"
    return 0
  fi
  if [[ "$ASSUME_YES" == "1" ]]; then
    echo "--yes given, continuing"
    return 0
  fi
  read -r -p "Proceed? [y/N] " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

parse_common_flags() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run|-n) DRY_RUN=1 ;;
      --yes|-y) ASSUME_YES=1 ;;
    esac
  done
}
