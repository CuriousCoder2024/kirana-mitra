#!/usr/bin/env bash
# Load the Kirana Mitra demo data into BigQuery and run the BigQuery ML steps.
#
# Usage:
#   data/load_bigquery.sh [--dry-run] [load|train|forecast|evaluate|all]
#
#   load      create dataset `kirana` (asia-south1) and load the CSVs
#   train     bqml/train_arima.sql   -> model kirana.item_demand_arima
#   forecast  bqml/forecast.sql      -> 4-week forecast per item (prints rows)
#   evaluate  bqml/evaluate.sql      -> holdout MAPE table kirana.forecast_eval
#   all       load + train + forecast + evaluate   (default)
#
# PROJECT_ID is read from the environment or from infra/.env. Nothing runs
# without it. With --dry-run (or DRY_RUN=1) every bq command is printed
# instead of executed, and a missing PROJECT_ID is shown as <PROJECT_ID>.
#
# Cost (checked 2026-10-18, https://cloud.google.com/bigquery/pricing):
#   * batch loads are free; storage of ~1 MB is inside the 10 GiB free tier
#   * forecast/evaluate SELECTs are inside the 1 TiB/month on-demand free tier
#   * ARIMA_PLUS CREATE MODEL is NOT in the free tier: $312.50 per TiB of
#     input x 12 candidate models. With ~0.2 MB of input that is < $0.01 per
#     training run. Budget: well under 1 rupee per full run.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
DATASET="${BQ_DATASET:-kirana}"
LOCATION="${BQ_LOCATION:-asia-south1}"
DRY_RUN="${DRY_RUN:-0}"
STEP="all"

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    load|train|forecast|evaluate|all) STEP="$arg" ;;
    -h|--help) sed -n '2,24p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

# Pull PROJECT_ID (and friends) from infra/.env if the shell did not set it.
if [[ -z "${PROJECT_ID:-}" && -f "$REPO/infra/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  . "$REPO/infra/.env"
  set +a
fi

if [[ -z "${PROJECT_ID:-}" ]]; then
  if [[ "$DRY_RUN" == "1" ]]; then
    PROJECT_ID="<PROJECT_ID>"
  else
    cat >&2 <<MSG
PROJECT_ID is not set. Nothing was run.
  export PROJECT_ID=my-gcp-project   (or copy infra/.env.example to infra/.env)
  Re-run with --dry-run to see the commands without a project.
MSG
    exit 1
  fi
fi

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY RUN: $*"
  else
    echo "+ $*"
    "$@"
  fi
}

run_sql() {
  local file="$1"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY RUN: bq --project_id=$PROJECT_ID --location=$LOCATION query --use_legacy_sql=false --format=prettyjson < $file"
  else
    echo "+ bq query < $file"
    bq --project_id="$PROJECT_ID" --location="$LOCATION" query \
      --use_legacy_sql=false --format=prettyjson < "$file"
  fi
}

BQ=(bq --project_id="$PROJECT_ID" --location="$LOCATION")

do_load() {
  if [[ "$DRY_RUN" != "1" ]] && "${BQ[@]}" show --dataset "$DATASET" >/dev/null 2>&1; then
    echo "dataset $PROJECT_ID:$DATASET already exists"
  else
    run "${BQ[@]}" mk --dataset --description "Kirana Mitra sales history and forecasts" "$PROJECT_ID:$DATASET"
  fi

  [[ -f "$HERE/sales_history.csv" ]] || { echo "data/sales_history.csv missing: run 'uv run data/generate_sales.py' first" >&2; exit 1; }

  run "${BQ[@]}" load --replace --source_format=CSV --skip_leading_rows=1 \
    "$DATASET.sales_daily" "$HERE/sales_history.csv" \
    "date:DATE,shop_id:STRING,item_id:STRING,qty:INT64,revenue_rupees:INT64"

  run "${BQ[@]}" load --replace --source_format=CSV --skip_leading_rows=1 \
    "$DATASET.catalogue" "$HERE/catalogue.csv" \
    "item_id:STRING,name:STRING,brand:STRING,pack_size:STRING,unit:STRING,mrp_rupees:INT64,reorder_level:INT64,category:STRING,aliases:STRING"

  run "${BQ[@]}" load --replace --source_format=CSV --skip_leading_rows=1 \
    "$DATASET.festivals" "$HERE/festivals.csv" \
    "name:STRING,date:DATE,pre_days:INT64,post_days:INT64,profile:STRING"

  run "${BQ[@]}" load --replace --source_format=CSV --skip_leading_rows=1 \
    "$DATASET.festival_uplift" "$HERE/festival_uplift.csv" \
    "profile:STRING,category:STRING,multiplier:FLOAT64"

  # Seed stock_on_hand so forecast.sql works before the backend syncs real
  # stock from Cloud SQL. The backend overwrites this table.
  local seed_sql="CREATE TABLE IF NOT EXISTS \`$DATASET.stock_on_hand\` AS SELECT item_id, reorder_level * 2 AS on_hand, CURRENT_TIMESTAMP() AS updated_at FROM \`$DATASET.catalogue\`"
  run "${BQ[@]}" query --use_legacy_sql=false "$seed_sql"
}

case "$STEP" in
  load)     do_load ;;
  train)    run_sql "$HERE/bqml/train_arima.sql" ;;
  forecast) run_sql "$HERE/bqml/forecast.sql" ;;
  evaluate) run_sql "$HERE/bqml/evaluate.sql" ;;
  all)
    do_load
    run_sql "$HERE/bqml/train_arima.sql"
    run_sql "$HERE/bqml/forecast.sql"
    run_sql "$HERE/bqml/evaluate.sql"
    ;;
esac

[[ "$DRY_RUN" == "1" ]] && echo "(dry run: nothing was executed)"
exit 0
