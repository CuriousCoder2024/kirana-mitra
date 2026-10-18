-- Forecast accuracy on a 14-day holdout, for the "performance" slide.
--
-- Run via:  data/load_bigquery.sh evaluate
--
-- ML.EVALUATE on an ARIMA_PLUS model only reports in-sample fit (AIC, etc.),
-- so for a real accuracy number we retrain on history minus the last 14 days
-- and compare ML.FORECAST against the actual last 14 days:
--   * MAPE per item  = mean(|actual - forecast| / actual) over days with sales
--   * WAPE per item  = sum|actual - forecast| / sum(actual)   (robust to zero days)
--   * overall        = WAPE across all items, plus the median item MAPE
-- Results land in kirana.forecast_eval (per item) and are printed, followed
-- by ML.ARIMA_EVALUATE on the production model (AIC, seasonality and whether
-- a holiday effect was fitted: has_holiday_effect is FALSE until >1 year of data).
--
-- Cost: one extra ARIMA_PLUS training on ~0.2 MB (~2.5 MB billed, < 1 cent)
-- plus a few small queries inside the free 1 TiB/month.

DECLARE holdout_days INT64 DEFAULT 14;
DECLARE cutoff DATE DEFAULT (
  SELECT DATE_SUB(MAX(date), INTERVAL 14 DAY) FROM `kirana.sales_daily`);

CREATE OR REPLACE MODEL `kirana.item_demand_arima_holdout`
OPTIONS (
  MODEL_TYPE             = 'ARIMA_PLUS',
  TIME_SERIES_TIMESTAMP_COL = 'date',
  TIME_SERIES_DATA_COL   = 'qty',
  TIME_SERIES_ID_COL     = 'item_id',
  DATA_FREQUENCY         = 'DAILY',
  HOLIDAY_REGION         = 'IN',
  DECOMPOSE_TIME_SERIES  = TRUE,
  HORIZON                = 14,
  AUTO_ARIMA_MAX_ORDER   = 2
) AS
SELECT date, item_id, qty
FROM `kirana.sales_daily`
WHERE shop_id = 'shp_demo' AND date <= cutoff;

CREATE OR REPLACE TABLE `kirana.forecast_eval` AS
WITH fc AS (
  SELECT
    item_id,
    DATE(forecast_timestamp) AS day,
    GREATEST(0, forecast_value) AS forecast
  FROM ML.FORECAST(MODEL `kirana.item_demand_arima_holdout`,
                   STRUCT(14 AS horizon, 0.8 AS confidence_level))
),
joined AS (
  SELECT a.item_id, a.date, a.qty AS actual, f.forecast
  FROM `kirana.sales_daily` a
  JOIN fc f ON f.item_id = a.item_id AND f.day = a.date
  WHERE a.shop_id = 'shp_demo' AND a.date > cutoff
)
SELECT
  j.item_id,
  c.name,
  c.category,
  COUNT(*) AS days,
  SUM(actual) AS actual_total,
  CAST(ROUND(SUM(forecast)) AS INT64) AS forecast_total,
  ROUND(100 * AVG(IF(actual > 0, ABS(actual - forecast) / actual, NULL)), 1) AS mape_pct,
  ROUND(100 * SAFE_DIVIDE(SUM(ABS(actual - forecast)), SUM(actual)), 1) AS wape_pct,
  ROUND(100 * SAFE_DIVIDE(ABS(SUM(actual) - SUM(forecast)), SUM(actual)), 1) AS total_error_pct
FROM joined j
JOIN `kirana.catalogue` c USING (item_id)
GROUP BY item_id, name, category;

-- Per-item table (best first).
SELECT * FROM `kirana.forecast_eval` ORDER BY wape_pct;

-- Headline numbers for the slide.
SELECT
  'overall' AS scope,
  COUNT(*) AS items,
  ROUND(100 * SAFE_DIVIDE(SUM(ABS(actual_total - forecast_total)), SUM(actual_total)), 1) AS wape_pct_all_items,
  ROUND(AVG(mape_pct), 1) AS mean_item_mape_pct,
  ROUND(APPROX_QUANTILES(mape_pct, 2)[OFFSET(1)], 1) AS median_item_mape_pct,
  ROUND(AVG(wape_pct), 1) AS mean_item_wape_pct
FROM `kirana.forecast_eval`;

-- In-sample diagnostics of the production model: AIC, detected seasonality,
-- and has_holiday_effect (expected FALSE with <1 year of history).
SELECT
  item_id,
  non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift,
  ROUND(AIC, 1) AS aic,
  seasonal_periods,
  has_holiday_effect,
  has_spikes_and_dips,
  has_step_changes
FROM ML.ARIMA_EVALUATE(MODEL `kirana.item_demand_arima`)
ORDER BY item_id;
