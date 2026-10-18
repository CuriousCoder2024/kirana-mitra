-- 4-week demand forecast, one row per item per week, for one shop.
-- This is the query the backend runs for GET /forecast/{shop_id}.
--
-- Parameters:
--   @shop_id     STRING  shop to forecast (the demo history is 'shp_demo')
--   @start_date  STRING  'YYYY-MM-DD' first day of week 0, or '' for the day
--                        after the shop's last recorded sale
-- Run via:  data/load_bigquery.sh forecast [--shop shp_demo] [--start 2026-10-19]
--   bq query --use_legacy_sql=false \
--     --parameter=shop_id:STRING:shp_demo --parameter=start_date:STRING:2026-10-19 \
--     < data/bqml/forecast.sql
--
-- Output columns (160 rows for 40 items):
--   shop_id, item_id, name, unit, category,
--   week_index          0..3
--   week_start          DATE, start_date + 7 * week_index
--   forecast            INT64, festival-adjusted expected units for the week
--   lower, upper        INT64, 80% prediction interval, same adjustment
--   baseline_forecast   INT64, raw ARIMA_PLUS forecast before the uplift
--   festival            STRING or NULL, festival driving the uplift that week
--   festival_multiplier FLOAT64, max daily multiplier in the week (1.0 = none)
--
-- The backend builds the contract response from this plus
-- kirana.item_history_weekly (history_weekly), its own on_hand, and
--   reorder_qty = max(0, sum(forecast over the 4 weeks) - on_hand)
--   festivals[] = SELECT name, date FROM kirana.festivals
--                 WHERE date BETWEEN @start AND DATE_ADD(@start, INTERVAL 27 DAY)
-- bqml/forecast_wide.sql does that aggregation in SQL for console demos.
--
-- Festival uplift: ARIMA_PLUS only models holidays once a series is longer
-- than a year (see train_arima.sql), so each forecast day is multiplied by
-- the category multiplier from kirana.festival_multiplier_daily. Set
-- apply_festival_uplift to FALSE once the model has >1 year of history.
--
-- Cost: ML.FORECAST + this aggregation is an ordinary on-demand query
-- (10 MiB minimum billed) inside the 1 TiB/month free tier.

DECLARE apply_festival_uplift BOOL DEFAULT TRUE;

WITH
bounds AS (
  SELECT
    COALESCE(SAFE.PARSE_DATE('%F', NULLIF(@start_date, '')),
             DATE_ADD(MAX(date), INTERVAL 1 DAY)) AS start_date
  FROM `kirana.sales_daily`
  WHERE shop_id = @shop_id
),
raw_fc AS (
  SELECT
    shop_id,
    item_id,
    DATE(forecast_timestamp) AS day,
    GREATEST(0, forecast_value) AS fc,
    GREATEST(0, prediction_interval_lower_bound) AS lo,
    GREATEST(0, prediction_interval_upper_bound) AS hi
  FROM ML.FORECAST(MODEL `kirana.item_demand_arima`,
                   STRUCT(35 AS horizon, 0.8 AS confidence_level))
  WHERE shop_id = @shop_id
),
mult AS (
  -- strongest festival per day and category
  SELECT
    day,
    category,
    ARRAY_AGG(festival ORDER BY multiplier DESC LIMIT 1)[OFFSET(0)] AS festival,
    MAX(multiplier) AS multiplier
  FROM `kirana.festival_multiplier_daily`
  GROUP BY day, category
),
daily AS (
  SELECT
    r.shop_id,
    r.item_id,
    r.day,
    c.name,
    c.unit,
    c.category,
    r.fc,
    r.lo,
    r.hi,
    IF(apply_festival_uplift, COALESCE(m.multiplier, 1.0), 1.0) AS multiplier,
    IF(apply_festival_uplift, m.festival, NULL) AS festival
  FROM raw_fc r
  JOIN `kirana.catalogue` c USING (item_id)
  LEFT JOIN mult m ON m.day = r.day AND m.category = c.category
)
SELECT
  d.shop_id,
  d.item_id,
  d.name,
  d.unit,
  d.category,
  DIV(DATE_DIFF(d.day, b.start_date, DAY), 7) AS week_index,
  DATE_ADD(b.start_date, INTERVAL 7 * DIV(DATE_DIFF(d.day, b.start_date, DAY), 7) DAY) AS week_start,
  CAST(ROUND(SUM(d.fc * d.multiplier)) AS INT64) AS forecast,
  CAST(ROUND(SUM(d.lo * d.multiplier)) AS INT64) AS lower,
  CAST(ROUND(SUM(d.hi * d.multiplier)) AS INT64) AS upper,
  CAST(ROUND(SUM(d.fc)) AS INT64) AS baseline_forecast,
  ARRAY_AGG(d.festival IGNORE NULLS ORDER BY d.multiplier DESC LIMIT 1)[SAFE_OFFSET(0)] AS festival,
  ROUND(MAX(d.multiplier), 2) AS festival_multiplier
FROM daily d
CROSS JOIN bounds b
WHERE DATE_DIFF(d.day, b.start_date, DAY) BETWEEN 0 AND 27
GROUP BY shop_id, item_id, name, unit, category, week_index, week_start
ORDER BY item_id, week_index;
