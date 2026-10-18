# data/

Seed data and the BigQuery ML forecasting pipeline for Kirana Mitra.
Everything here is runnable without a Google Cloud project (`--dry-run`),
and nothing touches a project until `PROJECT_ID` is set.

## Files

| File | What it is |
|---|---|
| `catalogue.csv` | 40 common kirana SKUs: `item_id, name, brand, pack_size, unit, mrp_rupees, reorder_level, category, aliases`. `aliases` is `\|`-separated Hindi/Hinglish names ("parle ji", "पारले जी") for the voice/text matcher. |
| `festivals.csv` | 2026 festival dates with the pre/post window used for spikes. Dates checked against [timeanddate.com India 2026](https://www.timeanddate.com/holidays/india/2026) on 2026-10-18. |
| `festival_uplift.csv` | Demand multiplier per `(festival profile, category)`; `*` is the default for unlisted categories. Shared by the generator and `bqml/forecast.sql` so history and forecast tell the same story. |
| `generate_sales.py` | Generates 120 days of daily sales per item for shop `shp_demo`, ending yesterday (IST). Deterministic (seed 42). |
| `sales_history.csv` | Output of the generator, committed so the demo does not depend on re-running it: 4,800 rows, `date, shop_id, item_id, qty, revenue_rupees`. |
| `load_bigquery.sh` | Creates dataset `kirana` (asia-south1), loads the CSVs, creates the views, runs the SQL below. |
| `bqml/views.sql` | Views `kirana.festival_multiplier_daily` and `kirana.item_history_weekly`. |
| `bqml/train_arima.sql` | `CREATE MODEL kirana.item_demand_arima` (ARIMA_PLUS, one series per `(shop_id, item_id)`, `HOLIDAY_REGION = 'IN'`). |
| `bqml/forecast.sql` | **The backend query.** `ML.FORECAST` at 80% confidence, festival uplift, one row per item per week for `@shop_id`. |
| `bqml/forecast_wide.sql` | Console version: one row per item with the 4 weeks as arrays, `on_hand` and `reorder_qty`. |
| `bqml/evaluate.sql` | 14-day holdout retrain and MAPE/WAPE per item and overall, into `kirana.forecast_eval`. |
| `bqml/results.md` | Measured accuracy, timings and bytes billed from the real run on 2026-10-18. |

## Run order

```bash
# 1. regenerate history (optional, the CSV is committed). Needs uv.
uv run data/generate_sales.py

# 2. see what would happen, no project needed
data/load_bigquery.sh --dry-run all

# 3. for real: PROJECT_ID from the shell or infra/.env (copy infra/.env.example)
export PROJECT_ID=my-gcp-project
data/load_bigquery.sh load       # dataset + 5 tables + 2 views
data/load_bigquery.sh train      # ~5 s for 40 series
data/load_bigquery.sh forecast --shop shp_demo --start 2026-10-19   # 160 rows
data/load_bigquery.sh forecast-wide --start 2026-10-19              # 40 rows with arrays
data/load_bigquery.sh evaluate   # holdout accuracy for the slide (~15 s)
```

`all` runs load, train, forecast and evaluate in that order. Re-running
`load` replaces the tables (`--replace`), except `stock_on_hand`, which is
only seeded once. `GCLOUD_CONFIG=<name>` in `infra/.env` makes the scripts
use that named gcloud configuration without changing the active one.

## What the generated data contains

Per item: a category base rate scaled by price, a weekly pattern (Sunday
high, Tue/Wed low), a salary bump on the 1st to 7th, a summer uplift for
cold drinks, Poisson noise, and festival spikes with a 3-5 day ramp. The
default window (2026-06-20 to 2026-10-17) contains Independence Day, Onam,
Raksha Bandhan, Janmashtami, Ganesh Chaturthi, Navratri and the ramp into
Dussehra. Holi, both Eids and Diwali 2025 fall outside it. Diwali 2026
(8 Nov) sits inside the 4-week forecast horizon, which is the demo's point.

The generator prints the top 5 revenue days; in the committed file they are
Navratri day 1 (Sun 11 Oct) and the Janmashtami weekend.

## Tables created in BigQuery

| Table | Source | Used by |
|---|---|---|
| `kirana.sales_daily` | `sales_history.csv` | training, history_weekly, evaluation |
| `kirana.catalogue` | `catalogue.csv` | names/units in forecast, categories for uplift |
| `kirana.festivals`, `kirana.festival_uplift` | the two CSVs | festival uplift in `forecast.sql` |
| `kirana.stock_on_hand` | seeded at 2x `reorder_level` | `on_hand` and `reorder_qty`; the backend should overwrite it from Cloud SQL before calling the forecast |

## What the backend actually reads (keep these column names stable)

`backend/app/forecast.py` calls `ML.FORECAST(MODEL kirana.item_demand_arima, ...)`
directly and reads `kirana.sales_daily`, `kirana.catalogue`, `kirana.festivals`
and `kirana.festival_uplift` (last 42 days, `@shop_id`; unknown shops map to
`shp_demo`), then does the Monday-start week bucketing, festival ramp, on_hand
join and reorder maths in Python. Those four tables and the model name are
the contract; `forecast.sql`, `forecast_wide.sql`, `item_history_weekly`,
`festival_multiplier_daily` and `stock_on_hand` are reference queries for the
console and the slides and can change freely.

## Reference query (same maths in SQL)

**`bqml/forecast.sql`**, query parameters `@shop_id` (STRING) and
`@start_date` (STRING `YYYY-MM-DD`, or `''` for the day after the shop's last
sale). One row per item per week, 160 rows for the demo shop:

| column | type | meaning |
|---|---|---|
| `shop_id`, `item_id`, `name`, `unit`, `category` | STRING | from the catalogue |
| `week_index` | INT64 | 0..3 |
| `week_start` | DATE | `start_date + 7 * week_index` |
| `forecast` | INT64 | expected units that week, festival-adjusted |
| `lower`, `upper` | INT64 | 80% prediction interval, same adjustment, floored at 0 |
| `baseline_forecast` | INT64 | raw ARIMA_PLUS forecast before the uplift |
| `festival` | STRING or NULL | festival driving the uplift in that week |
| `festival_multiplier` | FLOAT64 | max daily multiplier inside the week, 1.0 = none |

**`kirana.item_history_weekly`** view, the last 4 complete weeks of actuals:

| column | type | meaning |
|---|---|---|
| `shop_id`, `item_id` | STRING | |
| `week_index` | INT64 | 0..3, week 3 ends on the shop's last sale date |
| `week_start` | DATE | lines up with the forecast when `@start_date` is `''` |
| `qty` | INT64 | units sold |

From those the backend builds the contract response:
`history_weekly` = the view's `qty` ordered by `week_index`;
`forecast_weekly`/`lower`/`upper` = `forecast.sql` ordered by `week_index`;
`reorder_qty = max(0, sum(forecast over the 4 weeks) - on_hand)` with
`on_hand` from its own stock table; `reorder_reason` from `festival` and
`festival_multiplier` of the peak week;
`festivals[] = SELECT name, date FROM kirana.festivals WHERE date BETWEEN @start AND DATE_ADD(@start, INTERVAL 27 DAY)`.

With `bq`: `--parameter=shop_id:STRING:shp_demo --parameter=start_date:STRING:2026-10-19`.
With the Python client: `QueryJobConfig(query_parameters=[ScalarQueryParameter("shop_id", "STRING", shop_id), ScalarQueryParameter("start_date", "STRING", start or "")])`.
The model is trained on `shp_demo` only; a new shop has no series until its
sales are appended to `kirana.sales_daily` and the model is retrained.

`bqml/forecast_wide.sql` does the same aggregation in SQL (arrays, `on_hand`
from `kirana.stock_on_hand`, `reorder_qty`, `reorder_reason`) for console demos.

## Holiday modelling caveat

`HOLIDAY_REGION = 'IN'` is the documented India code
([CREATE MODEL ARIMA_PLUS reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series)),
but the same page says holiday effects are only modelled when a daily series
is longer than one year. With 120 days the option is accepted and ignored
(`has_holiday_effect` in `evaluate.sql` shows FALSE on the real run). `forecast.sql`
therefore applies the festival uplift explicitly on top of the ARIMA
baseline; set `apply_festival_uplift` to FALSE once a shop has a year of
history and the model can learn it.

## Cost

Checked on [BigQuery pricing](https://cloud.google.com/bigquery/pricing), 2026-10-18:

- Batch loads are free. Storage (~1 MB) is inside the 10 GiB/month free tier.
- `forecast.sql`, `evaluate.sql` queries and `ML.FORECAST` are ordinary
  on-demand queries, inside the 1 TiB/month free tier.
- `CREATE MODEL` for ARIMA_PLUS is **not** covered by the free tier: it is
  billed at $312.50 per TiB of input multiplied by 12 candidate models
  (`AUTO_ARIMA_MAX_ORDER = 2`), with a 10 MiB minimum per query. Measured:
  10 MiB billed per training, about $0.003; `all` trains twice.
- Every statement bills at least 10 MiB, so a full `all` run is ~250 MiB of
  on-demand bytes: under a cent.

## Verified

All of `load_bigquery.sh all`, `forecast --start 2026-10-19`, `forecast-wide`
and `evaluate` ran on project `kirana-mitra-app` on 2026-10-18 without SQL
errors. Numbers, timings and bytes billed are in `bqml/results.md`.
