#!/usr/bin/env bash
# Build the Flutter web app against the Cloud Run API and publish it as a
# public static site on a GCS bucket (HTTPS via storage.googleapis.com).
#
# Usage:  infra/deploy_web.sh [--dry-run] [--yes] [--skip-build]
# Reads infra/.env. Needs PROJECT_ID, API_BASE_URL (the Cloud Run URL printed
# by infra/deploy.sh) and WEB_BUCKET (defaults to $PROJECT_ID-web).
#
# What it does
#   1. flutter build web --release --dart-define API_BASE_URL=$API_BASE_URL
#      --base-href /$WEB_BUCKET/   (the site is served under the bucket path)
#   2. creates the bucket (asia-south1, Standard) with public reads for
#      allUsers and index.html as both main page and 404 page (SPA routing)
#   3. rsyncs app/build/web into it with no-cache headers on index.html and
#      the service worker so users never keep an old build
#
# The site URL is https://storage.googleapis.com/$WEB_BUCKET/index.html
# Cost: a few MB of Standard storage and egress, cents per month. A custom
# domain would need a load balancer (~$18/month) and is not done here.
#
# Note for the backend: browsers call the API from origin
# https://storage.googleapis.com, so CORS must allow it (or "*" for the demo).
set -euo pipefail
# shellcheck source=infra/common.sh
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
parse_common_flags "$@"
load_env
SKIP_BUILD=0
for arg in "$@"; do [[ "$arg" == "--skip-build" ]] && SKIP_BUILD=1; done

WEB_BUCKET="${WEB_BUCKET:-$PROJECT_ID-web}"
APP_DIR="$REPO_DIR/app"
BUILD_DIR="$APP_DIR/build/web"

if [[ "$DRY_RUN" != "1" && ( -z "${API_BASE_URL:-}" || "$API_BASE_URL" == http://localhost* ) ]]; then
  echo "API_BASE_URL in infra/.env must be the Cloud Run URL (run infra/deploy.sh first)" >&2
  exit 1
fi
API_BASE_URL="${API_BASE_URL:-<API_BASE_URL>}"

echo "project: $PROJECT_ID   bucket: gs://$WEB_BUCKET   api: $API_BASE_URL   dry-run: $DRY_RUN"

# 1. build
if [[ "$SKIP_BUILD" == "1" ]]; then
  echo "skipping flutter build (--skip-build); using $BUILD_DIR as is"
else
  run flutter --no-version-check build web --release \
    --dart-define "API_BASE_URL=$API_BASE_URL" \
    --base-href "/$WEB_BUCKET/" \
    --project-directory "$APP_DIR"
fi

# 2. bucket (public static site)
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

# 3. upload
if [[ "$DRY_RUN" != "1" && ! -f "$BUILD_DIR/index.html" ]]; then
  echo "$BUILD_DIR/index.html not found; the flutter build did not produce output" >&2
  exit 1
fi
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
