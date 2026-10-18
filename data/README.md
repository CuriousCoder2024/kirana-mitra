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
| `load_bigquery.sh` | Creates dataset `kirana` (asia-south1), loads the CSVs, runs the SQL below. |
| `bqml/train_arima.sql` | `CREATE MODEL kirana.item_demand_arima` (ARIMA_PLUS, one series per `item_id`, `HOLIDAY_REGION = 'IN'`). |
| `bqml/forecast.sql` | `ML.FORECAST` 28 days at 80% confidence, aggregated to the 4 weekly buckets of `GET /forecast` plus `reorder_qty`. |
| `bqml/evaluate.sql` | 14-day holdout retrain and MAPE/WAPE per item and overall, into `kirana.forecast_eval`. |

## Run order

```bash
# 1. regenerate history (optional, the CSV is committed). Needs uv.
uv run data/generate_sales.py

# 2. see what would happen, no project needed
data/load_bigquery.sh --dry-run all

# 3. for real: PROJECT_ID from the shell or infra/.env (copy infra/.env.example)
export PROJECT_ID=my-gcp-project
data/load_bigquery.sh load       # dataset + 5 tables
data/load_bigquery.sh train      # ~1-2 min for 40 series
data/load_bigquery.sh forecast   # prints one JSON row per item
data/load_bigquery.sh evaluate   # holdout accuracy for the slide
```

`all` runs the four steps in that order. Re-running `load` replaces the
tables (`--replace`), except `stock_on_hand`, which is only seeded once.

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

`forecast.sql` returns one row per item with `weeks`, `history_weekly`,
`forecast_weekly`, `lower`, `upper`, `on_hand`, `reorder_qty`, `reorder_reason`,
which maps 1:1 onto `items[]` in `GET /forecast/{shop_id}`. Weeks are 7-day
buckets starting the day after the last sale. `festivals[]` for the response
comes from `kirana.festivals` filtered to the horizon.

Reorder rule: `reorder_qty = max(0, round(sum of the 4 forecast weeks) - on_hand)`.

## Holiday modelling caveat

`HOLIDAY_REGION = 'IN'` is the documented India code
([CREATE MODEL ARIMA_PLUS reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series)),
but the same page says holiday effects are only modelled when a daily series
is longer than one year. With 120 days the option is accepted and ignored
(`has_holiday_effect` in `evaluate.sql` will show FALSE). `forecast.sql`
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
  (`AUTO_ARIMA_MAX_ORDER = 2`). The input here is ~0.2 MB, so each training
  run costs well under one cent; `all` trains twice (production + holdout).

## Not verified

The SQL was parsed locally with sqlglot (BigQuery dialect): `train_arima.sql`
and `forecast.sql` parse; `evaluate.sql` only fails on `ML.ARIMA_EVALUATE`,
which sqlglot does not know but which is documented BigQuery syntax. None of
it has been run against a project, by the owner's rule. First real run:
`data/load_bigquery.sh all` and fix anything BigQuery complains about.
