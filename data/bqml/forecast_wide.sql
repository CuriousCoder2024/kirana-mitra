-- Console/demo version of forecast.sql: one row per item with the four weeks
-- as arrays, on_hand from kirana.stock_on_hand and the reorder rule applied,
-- i.e. the items[] shape of GET /forecast/{shop_id} straight from BigQuery.
-- The backend uses bqml/forecast.sql (long format) and applies on_hand itself.
--
-- Parameters: @shop_id STRING, @start_date STRING ('' = day after last sale).
-- Run via:  data/load_bigquery.sh forecast-wide [--shop ...] [--start ...]
--
-- Reorder rule:  reorder_qty = max(0, round(sum of the 4 forecast weeks) - on_hand)
-- "order enough to cover the next 28 days of expected demand given what is
-- already on the shelf". kirana.stock_on_hand is seeded at 2x reorder_level
-- by the load script; the backend should overwrite it from its own stock.

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
    r.item_id,
    r.day,
    c.category,
    r.fc, r.lo, r.hi,
    IF(apply_festival_uplift, COALESCE(m.multiplier, 1.0), 1.0) AS multiplier,
    IF(apply_festival_uplift, m.festival, NULL) AS festival
  FROM raw_fc r
  JOIN `kirana.catalogue` c USING (item_id)
  LEFT JOIN mult m ON m.day = r.day AND m.category = c.category
),
weekly AS (
  SELECT
    d.item_id,
    DIV(DATE_DIFF(d.day, b.start_date, DAY), 7) AS wk,
    SUM(d.fc * d.multiplier) AS forecast,
    SUM(d.lo * d.multiplier) AS lower,
    SUM(d.hi * d.multiplier) AS upper,
    MAX(d.multiplier) AS max_multiplier,
    ARRAY_AGG(d.festival IGNORE NULLS ORDER BY d.multiplier DESC LIMIT 1)[SAFE_OFFSET(0)] AS festival
  FROM daily d, bounds b
  WHERE DATE_DIFF(d.day, b.start_date, DAY) BETWEEN 0 AND 27
  GROUP BY item_id, wk
),
hist AS (
  -- last 4 weeks of actuals, re-aligned to start_date (same buckets as the forecast)
  SELECT
    s.item_id,
    3 - DIV(DATE_DIFF(DATE_SUB(b.start_date, INTERVAL 1 DAY), s.date, DAY), 7) AS wk,
    SUM(s.qty) AS qty
  FROM `kirana.sales_daily` s, bounds b
  WHERE s.shop_id = @shop_id
    AND DATE_DIFF(DATE_SUB(b.start_date, INTERVAL 1 DAY), s.date, DAY) BETWEEN 0 AND 27
  GROUP BY item_id, wk
),
grid AS (
  SELECT
    c.item_id,
    wk,
    DATE_ADD(b.start_date, INTERVAL 7 * wk DAY) AS week_start,
    COALESCE(h.qty, 0) AS hist_qty,
    COALESCE(w.forecast, 0) AS forecast,
    COALESCE(w.lower, 0) AS lower,
    COALESCE(w.upper, 0) AS upper,
    w.festival,
    COALESCE(w.max_multiplier, 1.0) AS max_multiplier
  FROM `kirana.catalogue` c
  CROSS JOIN bounds b
  CROSS JOIN UNNEST([0, 1, 2, 3]) AS wk
  LEFT JOIN hist h ON h.item_id = c.item_id AND h.wk = wk
  LEFT JOIN weekly w ON w.item_id = c.item_id AND w.wk = wk
),
per_item AS (
  SELECT
    item_id,
    ARRAY_AGG(week_start ORDER BY wk) AS weeks,
    ARRAY_AGG(CAST(ROUND(hist_qty) AS INT64) ORDER BY wk) AS history_weekly,
    ARRAY_AGG(CAST(ROUND(forecast) AS INT64) ORDER BY wk) AS forecast_weekly,
    ARRAY_AGG(CAST(ROUND(lower) AS INT64) ORDER BY wk) AS lower,
    ARRAY_AGG(CAST(ROUND(upper) AS INT64) ORDER BY wk) AS upper,
    CAST(ROUND(SUM(forecast)) AS INT64) AS forecast_28d,
    ARRAY_AGG(STRUCT(festival, max_multiplier) ORDER BY max_multiplier DESC LIMIT 1)[OFFSET(0)] AS peak
  FROM grid
  GROUP BY item_id
)
SELECT
  @shop_id AS shop_id,
  p.item_id,
  c.name,
  c.unit,
  c.category,
  p.weeks,
  p.history_weekly,
  p.forecast_weekly,
  p.lower,
  p.upper,
  COALESCE(st.on_hand, 0) AS on_hand,
  GREATEST(0, p.forecast_28d - COALESCE(st.on_hand, 0)) AS reorder_qty,
  CASE
    WHEN p.peak.festival IS NOT NULL AND p.peak.max_multiplier >= 1.3
      THEN FORMAT('%s week demand ~%.1fx', p.peak.festival, p.peak.max_multiplier)
    WHEN p.forecast_28d > COALESCE(st.on_hand, 0)
      THEN FORMAT('Next 4 weeks need ~%d, only %d on hand', p.forecast_28d, COALESCE(st.on_hand, 0))
    ELSE 'Stock covers the next 4 weeks'
  END AS reorder_reason
FROM per_item p
JOIN `kirana.catalogue` c USING (item_id)
LEFT JOIN `kirana.stock_on_hand` st USING (item_id)
ORDER BY reorder_qty DESC, p.item_id;
