-- Forecast accuracy on a 14-day holdout, for the "performance" slide.
--
-- Run via:  data/load_bigquery.sh evaluate
--
-- ML.EVALUATE on an ARIMA_PLUS model only reports in-sample fit, so we
-- retrain on history minus the last 14 days and compare ML.FORECAST with the
-- actual last 14 days, both raw (ARIMA only) and as the system serves it
-- (ARIMA x festival uplift from kirana.festival_multiplier_daily). Note the
-- demo holdout (2026-10-04..17) contains Navratri, so "raw" is a hard test.
--   * MAPE per item = mean(|actual - forecast| / actual) over days with sales
--   * WAPE per item = sum|actual - forecast| / sum(actual)  (robust to zero days)
--   * overall WAPE  = volume-weighted across all items (the headline number)
-- Results land in kirana.forecast_eval and are printed, followed by
-- ML.ARIMA_EVALUATE on the production model (AIC, seasonality, and
-- has_holiday_effect, which stays FALSE until >1 year of data).
--
-- Cost: one extra ARIMA_PLUS training (~$0.003, 10 MiB minimum billed) plus
-- small queries inside the free 1 TiB/month.

DECLARE cutoff DATE DEFAULT (
  SELECT DATE_SUB(MAX(date), INTERVAL 14 DAY) FROM `kirana.sales_daily`);

CREATE OR REPLACE MODEL `kirana.item_demand_arima_holdout`
OPTIONS (
  MODEL_TYPE             = 'ARIMA_PLUS',
  TIME_SERIES_TIMESTAMP_COL = 'date',
  TIME_SERIES_DATA_COL   = 'qty',
  TIME_SERIES_ID_COL     = ['shop_id', 'item_id'],
  DATA_FREQUENCY         = 'DAILY',
  HOLIDAY_REGION         = 'IN',
  DECOMPOSE_TIME_SERIES  = TRUE,
  HORIZON                = 14,
  AUTO_ARIMA_MAX_ORDER   = 2
) AS
SELECT date, shop_id, item_id, qty
FROM `kirana.sales_daily`
WHERE date <= cutoff;

CREATE OR REPLACE TABLE `kirana.forecast_eval` AS
WITH fc AS (
  SELECT
    shop_id,
    item_id,
    DATE(forecast_timestamp) AS day,
    GREATEST(0, forecast_value) AS forecast
  FROM ML.FORECAST(MODEL `kirana.item_demand_arima_holdout`,
                   STRUCT(14 AS horizon, 0.8 AS confidence_level))
),
mult AS (
  SELECT day, category, MAX(multiplier) AS multiplier
  FROM `kirana.festival_multiplier_daily`
  GROUP BY day, category
),
joined AS (
  SELECT
    a.shop_id,
    a.item_id,
    c.name,
    c.category,
    a.date,
    a.qty AS actual,
    f.forecast AS raw_fc,
    f.forecast * COALESCE(m.multiplier, 1.0) AS sys_fc
  FROM `kirana.sales_daily` a
  JOIN fc f ON f.shop_id = a.shop_id AND f.item_id = a.item_id AND f.day = a.date
  JOIN `kirana.catalogue` c ON c.item_id = a.item_id
  LEFT JOIN mult m ON m.day = a.date AND m.category = c.category
  WHERE a.date > cutoff
)
SELECT
  shop_id,
  item_id,
  name,
  category,
  COUNT(*) AS days,
  SUM(actual) AS actual_total,
  CAST(ROUND(SUM(raw_fc)) AS INT64) AS raw_forecast_total,
  CAST(ROUND(SUM(sys_fc)) AS INT64) AS sys_forecast_total,
  ROUND(100 * AVG(IF(actual > 0, ABS(actual - raw_fc) / actual, NULL)), 1) AS raw_mape_pct,
  ROUND(100 * AVG(IF(actual > 0, ABS(actual - sys_fc) / actual, NULL)), 1) AS sys_mape_pct,
  ROUND(100 * SAFE_DIVIDE(SUM(ABS(actual - raw_fc)), SUM(actual)), 1) AS raw_wape_pct,
  ROUND(100 * SAFE_DIVIDE(SUM(ABS(actual - sys_fc)), SUM(actual)), 1) AS sys_wape_pct,
  ROUND(100 * SAFE_DIVIDE(ABS(SUM(actual) - SUM(sys_fc)), SUM(actual)), 1) AS sys_total_error_pct
FROM joined
GROUP BY shop_id, item_id, name, category;

-- Per-item table (best first).
SELECT * FROM `kirana.forecast_eval` ORDER BY sys_wape_pct;

-- Headline numbers for the slide.
SELECT
  'overall' AS scope,
  COUNT(*) AS items,
  ROUND(100 * SAFE_DIVIDE(SUM(ABS(actual_total - raw_forecast_total)), SUM(actual_total)), 1) AS raw_wape_pct_all_items,
  ROUND(100 * SAFE_DIVIDE(SUM(ABS(actual_total - sys_forecast_total)), SUM(actual_total)), 1) AS sys_wape_pct_all_items,
  ROUND(AVG(raw_mape_pct), 1) AS raw_mean_item_mape_pct,
  ROUND(AVG(sys_mape_pct), 1) AS sys_mean_item_mape_pct,
  ROUND(APPROX_QUANTILES(sys_mape_pct, 2)[OFFSET(1)], 1) AS sys_median_item_mape_pct,
  ROUND(AVG(sys_wape_pct), 1) AS sys_mean_item_wape_pct
FROM `kirana.forecast_eval`;

-- In-sample diagnostics of the production model.
SELECT
  shop_id,
  item_id,
  non_seasonal_p, non_seasonal_d, non_seasonal_q, has_drift,
  ROUND(AIC, 1) AS aic,
  seasonal_periods,
  has_holiday_effect,
  has_spikes_and_dips,
  has_step_changes
FROM ML.ARIMA_EVALUATE(MODEL `kirana.item_demand_arima`)
ORDER BY item_id;
