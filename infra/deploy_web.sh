#!/usr/bin/env bash
# Build the Flutter web app against the Cloud Run API and publish it.
#
# Usage:  infra/deploy_web.sh [--firebase|--gcs] [--dry-run] [--yes] [--skip-build]
#   --firebase   (default) Firebase Hosting: https://kirana-mitra-app.web.app
#   --gcs        fallback: public GCS bucket, https://storage.googleapis.com/<bucket>/index.html
#
# Reads infra/.env. Needs PROJECT_ID and API_BASE_URL (the Cloud Run URL
# printed by infra/deploy.sh). GCS mode also uses WEB_BUCKET (default
# $PROJECT_ID-web).
#
# Firebase mode
#   1. flutter build web --release --dart-define API_BASE_URL=... --base-href /
#   2. firebase deploy --only hosting --project $PROJECT_ID
#      using the repo-root firebase.json (public app/build/web, SPA rewrite,
#      no-cache on index.html + service worker, long cache on hashed assets)
#      and .firebaserc (default project). Needs a logged-in firebase CLI:
#      `firebase login` (browser) once per machine, `firebase login --reauth`
#      when it says the credentials expired. Free tier (10 GB storage,
#      360 MB/day transfer) covers the demo: https://firebase.google.com/pricing
#
# GCS mode
#   builds with --base-href /$WEB_BUCKET/, creates the PUBLIC bucket after a
#   confirm, rsyncs app/build/web into it with no-cache headers on index.html
#   and the service worker. Cents per month.
#
# The backend allows CORS from any origin, so both hosts work unchanged.
set -euo pipefail
# shellcheck source=infra/common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
parse_common_flags "$@"
load_env
SKIP_BUILD=0
MODE="firebase"
for arg in "$@"; do
  case "$arg" in
    --skip-build) SKIP_BUILD=1 ;;
    --firebase) MODE="firebase" ;;
    --gcs) MODE="gcs" ;;
  esac
done

WEB_BUCKET="${WEB_BUCKET:-$PROJECT_ID-web}"
APP_DIR="$REPO_DIR/app"
BUILD_DIR="$APP_DIR/build/web"

if [[ "$DRY_RUN" != "1" && ( -z "${API_BASE_URL:-}" || "$API_BASE_URL" == http://localhost* ) ]]; then
  echo "API_BASE_URL in infra/.env must be the Cloud Run URL (run infra/deploy.sh first)" >&2
  exit 1
fi
API_BASE_URL="${API_BASE_URL:-<API_BASE_URL>}"

if [[ "$MODE" == "firebase" ]]; then
  BASE_HREF="/"
  TARGET="Firebase Hosting (https://$PROJECT_ID.web.app)"
else
  BASE_HREF="/$WEB_BUCKET/"
  TARGET="gs://$WEB_BUCKET"
fi
echo "project: $PROJECT_ID   target: $TARGET   api: $API_BASE_URL   dry-run: $DRY_RUN"

# 1. build
if [[ "$SKIP_BUILD" == "1" ]]; then
  echo "skipping flutter build (--skip-build); using $BUILD_DIR as is"
else
  run flutter --no-version-check build web --release \
    --dart-define "API_BASE_URL=$API_BASE_URL" \
    --base-href "$BASE_HREF" \
    --project-directory "$APP_DIR"
fi
if [[ "$DRY_RUN" != "1" && ! -f "$BUILD_DIR/index.html" ]]; then
  echo "$BUILD_DIR/index.html not found; the flutter build did not produce output" >&2
  exit 1
fi

# 2a. Firebase Hosting
if [[ "$MODE" == "firebase" ]]; then
  if [[ "$DRY_RUN" != "1" ]] && ! command -v firebase >/dev/null 2>&1; then
    echo "firebase CLI not found: npm install -g firebase-tools   (or use: npx firebase-tools deploy ...)" >&2
    exit 1
  fi
  ( cd "$REPO_DIR" && run firebase deploy --only hosting --project "$PROJECT_ID" --non-interactive )
  echo
  echo "web app: https://$PROJECT_ID.web.app  (also https://$PROJECT_ID.firebaseapp.com)"
  [[ "$DRY_RUN" == "1" ]] && echo "(dry run: nothing was executed)"
  exit 0
fi

# 2b. GCS public bucket (fallback)
if [[ "$DRY_RUN" != "1" ]] && gcloud storage buckets describe "gs://$WEB_BUCKET" \
     --project "$PROJECT_ID" >/dev/null 2>&1; then
  echo "bucket gs://$WEB_BUCKET exists, skipping create"
else
  if confirm "Create PUBLIC bucket gs://$WEB_BUCKET in $REGION for the web app.
  Est. cost: a few MB of Standard storage + egress, cents/month. Everything
  uploaded to it is readable by anyone on the internet."; then
    run gcloud storage buckets create "gs://$WEB_BUCKET" --project "$PROJECT_ID" \
      --location "$REGION" --uniform-bucket-level-access --no-public-access-prevention
  else
    echo "bucket not created; stopping"; exit 1
  fi
fi
run gcloud storage buckets add-iam-policy-binding "gs://$WEB_BUCKET" --project "$PROJECT_ID" \
  --member allUsers --role roles/storage.objectViewer
run gcloud storage buckets update "gs://$WEB_BUCKET" --project "$PROJECT_ID" \
  --web-main-page-suffix index.html --web-error-page index.html
run gcloud storage rsync --recursive --delete-unmatched-destination-objects \
  "$BUILD_DIR" "gs://$WEB_BUCKET"
run gcloud storage objects update "gs://$WEB_BUCKET/index.html" \
  --cache-control "no-cache, max-age=0"
if [[ "$DRY_RUN" == "1" ]] || [[ -f "$BUILD_DIR/flutter_service_worker.js" ]]; then
  run gcloud storage objects update "gs://$WEB_BUCKET/flutter_service_worker.js" \
    --cache-control "no-cache, max-age=0"
fi

echo
echo "web app: https://storage.googleapis.com/$WEB_BUCKET/index.html"
[[ "$DRY_RUN" == "1" ]] && echo "(dry run: nothing was executed)"
exit 0
