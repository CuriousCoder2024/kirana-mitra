-- 4-week demand forecast per item, shaped for GET /forecast/{shop_id}
-- (docs/api-contract.md): weeks, history_weekly, forecast_weekly, lower,
-- upper, on_hand, reorder_qty, reorder_reason.
--
-- Run via:  data/load_bigquery.sh forecast
-- Requires: kirana.item_demand_arima (bqml/train_arima.sql), kirana.catalogue,
--           kirana.festivals, kirana.festival_uplift, kirana.stock_on_hand.
--
-- How it works
--   1. ML.FORECAST gives 28 daily points per item with an 80% prediction
--      interval (confidence_level 0.8 -> lower/upper bounds).
--   2. Festival uplift: ARIMA_PLUS only models holidays once a series is
--      longer than a year (see train_arima.sql), so for the demo we multiply
--      each forecast day by the category multiplier from kirana.festival_uplift
--      with the same 3-5 day ramp the sales generator used. Set
--      apply_festival_uplift to FALSE once the model has >1 year of history.
--   3. Days are bucketed into 4 weeks counted from the day after the last
--      sale (week k covers start_date + 7k .. +6). history_weekly is the last
--      4 complete weeks of actual qty on the same alignment.
--   4. Reorder rule:  reorder_qty = max(0, round(sum of the 4 forecast weeks) - on_hand)
--      i.e. "order enough to cover the next 28 days of expected demand given
--      what is already on the shelf". on_hand comes from kirana.stock_on_hand
--      (the backend keeps it in sync from Cloud SQL; the load script seeds it
--      at 2x reorder_level so the query works before the backend writes it).
--
-- Cost: ML.FORECAST + this aggregation scan a few MB; prediction queries are
-- billed as ordinary on-demand queries and sit inside the 1 TiB/month free tier.

DECLARE apply_festival_uplift BOOL DEFAULT TRUE;

WITH
bounds AS (
  SELECT
    MAX(date) AS last_date,
    DATE_ADD(MAX(date), INTERVAL 1 DAY) AS start_date
  FROM `kirana.sales_daily`
),
weeks AS (
  SELECT wk, DATE_ADD(b.start_date, INTERVAL 7 * wk DAY) AS week_start
  FROM bounds b, UNNEST([0, 1, 2, 3]) AS wk
),
raw_fc AS (
  SELECT
    item_id,
    DATE(forecast_timestamp) AS day,
    GREATEST(0, forecast_value) AS fc,
    GREATEST(0, prediction_interval_lower_bound) AS lo,
    GREATEST(0, prediction_interval_upper_bound) AS hi
  FROM ML.FORECAST(MODEL `kirana.item_demand_arima`,
                   STRUCT(28 AS horizon, 0.8 AS confidence_level))
),
-- Festival multiplier per (day, category): linear ramp over pre_days up to
-- the peak on the festival date, peak held through post_days. Strongest
-- festival wins when windows overlap (mirrors data/generate_sales.py).
fest_days AS (
  SELECT
    d AS day,
    u.category,
    f.name,
    MAX(
      CASE
        WHEN DATE_DIFF(d, f.date, DAY) BETWEEN -f.pre_days AND -1
          THEN 1 + (u.multiplier - 1) * (1 - (-DATE_DIFF(d, f.date, DAY)) / (f.pre_days + 1))
        WHEN DATE_DIFF(d, f.date, DAY) BETWEEN 0 AND f.post_days
          THEN u.multiplier
        ELSE 1
      END) AS multiplier
  FROM `kirana.festivals` f
  JOIN `kirana.festival_uplift` u ON u.profile = f.profile
  CROSS JOIN UNNEST(GENERATE_DATE_ARRAY(DATE_SUB(f.date, INTERVAL f.pre_days DAY),
                                        DATE_ADD(f.date, INTERVAL f.post_days DAY))) AS d
  GROUP BY day, category, name
),
fc AS (
  SELECT
    r.item_id,
    r.day,
    c.category,
    COALESCE(m.multiplier, 1.0) AS multiplier,
    m.name AS festival,
    r.fc * COALESCE(m.multiplier, 1.0) AS fc,
    r.lo * COALESCE(m.multiplier, 1.0) AS lo,
    r.hi * COALESCE(m.multiplier, 1.0) AS hi
  FROM raw_fc r
  JOIN `kirana.catalogue` c USING (item_id)
  LEFT JOIN (
    -- pick the category-specific row, else the '*' default, per day/festival
    SELECT day, name, category, multiplier FROM fest_days
    WHERE apply_festival_uplift
  ) m
    ON m.day = r.day
   AND m.category IN (c.category, '*')
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY r.item_id, r.day
    ORDER BY CASE WHEN m.category = c.category THEN 0 ELSE 1 END, m.multiplier DESC) = 1
),
fc_weekly AS (
  SELECT
    f.item_id,
    DIV(DATE_DIFF(f.day, b.start_date, DAY), 7) AS wk,
    SUM(f.fc) AS forecast,
    SUM(f.lo) AS lower,
    SUM(f.hi) AS upper,
    MAX(f.multiplier) AS max_multiplier,
    ARRAY_AGG(f.festival IGNORE NULLS ORDER BY f.multiplier DESC LIMIT 1)[SAFE_OFFSET(0)] AS festival
  FROM fc f, bounds b
  WHERE DATE_DIFF(f.day, b.start_date, DAY) BETWEEN 0 AND 27
  GROUP BY item_id, wk
),
hist_weekly AS (
  SELECT
    s.item_id,
    3 - DIV(DATE_DIFF(b.last_date, s.date, DAY), 7) AS wk,
    SUM(s.qty) AS qty
  FROM `kirana.sales_daily` s, bounds b
  WHERE s.shop_id = 'shp_demo'
    AND DATE_DIFF(b.last_date, s.date, DAY) BETWEEN 0 AND 27
  GROUP BY item_id, wk
),
grid AS (
  -- one row per item x week so every array below has exactly 4 entries
  SELECT
    c.item_id,
    w.wk,
    w.week_start,
    COALESCE(h.qty, 0) AS hist,
    COALESCE(f.forecast, 0) AS forecast,
    COALESCE(f.lower, 0) AS lower,
    COALESCE(f.upper, 0) AS upper,
    f.festival,
    COALESCE(f.max_multiplier, 1.0) AS max_multiplier
  FROM `kirana.catalogue` c
  CROSS JOIN weeks w
  LEFT JOIN hist_weekly h ON h.item_id = c.item_id AND h.wk = w.wk
  LEFT JOIN fc_weekly f ON f.item_id = c.item_id AND f.wk = w.wk
),
per_item AS (
  SELECT
    item_id,
    ARRAY_AGG(week_start ORDER BY wk) AS weeks,
    ARRAY_AGG(CAST(ROUND(hist) AS INT64) ORDER BY wk) AS history_weekly,
    ARRAY_AGG(CAST(ROUND(forecast) AS INT64) ORDER BY wk) AS forecast_weekly,
    ARRAY_AGG(CAST(ROUND(lower) AS INT64) ORDER BY wk) AS lower,
    ARRAY_AGG(CAST(ROUND(upper) AS INT64) ORDER BY wk) AS upper,
    CAST(ROUND(SUM(forecast)) AS INT64) AS forecast_28d,
    ARRAY_AGG(STRUCT(festival, max_multiplier)
              ORDER BY max_multiplier DESC LIMIT 1)[OFFSET(0)] AS peak
  FROM grid
  GROUP BY item_id
)
SELECT
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
