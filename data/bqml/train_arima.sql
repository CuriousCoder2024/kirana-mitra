-- Train one ARIMA_PLUS model per item on kirana.sales_daily.
--
-- Run via:  data/load_bigquery.sh train      (or: bq query --use_legacy_sql=false < data/bqml/train_arima.sql)
--
-- HOLIDAY_REGION = 'IN' is the India code listed under "HOLIDAY_REGION ->
-- Countries" in the CREATE MODEL (ARIMA_PLUS) reference, checked 2026-10-18:
--   https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series
-- The same page says holiday-effect modelling is only applied when the series
-- is daily or weekly AND longer than a year. Our demo history is 120 days, so
-- BigQuery will accept the option but will not actually model holidays until
-- the shop has >365 days of sales. That is why bqml/forecast.sql layers an
-- explicit festival uplift (from kirana.festivals + kirana.festival_uplift)
-- on top of the ARIMA baseline for the forecast horizon. Keep HOLIDAY_REGION
-- here anyway: once the shop has a year of history the model learns the
-- holiday effect itself and the SQL uplift can be switched off.
--
-- Cost: on-demand ARIMA_PLUS training is billed per byte of the input SELECT
-- times the number of candidate models (12 with AUTO_ARIMA_MAX_ORDER = 2).
-- 4,800 rows is ~0.2 MB, so training processes ~2.5 MB: well under a cent.
--   https://cloud.google.com/bigquery/pricing  ("BigQuery ML pricing")

CREATE OR REPLACE MODEL `kirana.item_demand_arima`
OPTIONS (
  MODEL_TYPE             = 'ARIMA_PLUS',
  TIME_SERIES_TIMESTAMP_COL = 'date',
  TIME_SERIES_DATA_COL   = 'qty',
  TIME_SERIES_ID_COL     = 'item_id',
  DATA_FREQUENCY         = 'DAILY',
  HOLIDAY_REGION         = 'IN',
  DECOMPOSE_TIME_SERIES  = TRUE,
  HORIZON                = 28,
  AUTO_ARIMA_MAX_ORDER   = 2,
  -- Defaults kept on purpose: CLEAN_SPIKES_AND_DIPS = TRUE smooths the
  -- Navratri/Janmashtami spikes into a clean baseline, which forecast.sql
  -- then scales for the festivals that fall inside the horizon.
  CLEAN_SPIKES_AND_DIPS  = TRUE,
  ADJUST_STEP_CHANGES    = TRUE
) AS
SELECT
  date,
  item_id,
  qty
FROM `kirana.sales_daily`
WHERE shop_id = 'shp_demo';
