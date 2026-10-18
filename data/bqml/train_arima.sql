-- Train one ARIMA_PLUS model per (shop_id, item_id) on kirana.sales_daily.
--
-- Run via:  data/load_bigquery.sh train      (or: bq query --use_legacy_sql=false < data/bqml/train_arima.sql)
-- Verified 2026-10-18 on project kirana-mitra-app: 40 series train in ~5 s,
-- 10 MiB billed (the per-query minimum), HOLIDAY_REGION = 'IN' accepted.
--
-- HOLIDAY_REGION = 'IN' is the India code listed under "HOLIDAY_REGION ->
-- Countries" in the CREATE MODEL (ARIMA_PLUS) reference, checked 2026-10-18:
--   https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series
-- The same page says holiday-effect modelling is only applied when the series
-- is daily or weekly AND longer than a year. Our demo history is 120 days, so
-- BigQuery accepts the option but does not model holidays yet
-- (ML.ARIMA_EVALUATE reports has_holiday_effect = false). That is why
-- bqml/forecast.sql layers an explicit festival uplift (kirana.festivals +
-- kirana.festival_uplift) on top of the ARIMA baseline. Keep HOLIDAY_REGION:
-- once a shop has a year of history the model learns the effect itself and
-- the SQL uplift can be switched off.
--
-- HORIZON = 35 (not 28) so a forecast that starts up to a week after the last
-- sale still has 28 full days to bucket.
--
-- Cost: on-demand ARIMA_PLUS training is billed per byte of the input SELECT
-- times the number of candidate models (12 with AUTO_ARIMA_MAX_ORDER = 2),
-- with a 10 MiB minimum per query: ~$0.003 per run at $312.50/TiB.
--   https://cloud.google.com/bigquery/pricing  ("BigQuery ML pricing")

CREATE OR REPLACE MODEL `kirana.item_demand_arima`
OPTIONS (
  MODEL_TYPE             = 'ARIMA_PLUS',
  TIME_SERIES_TIMESTAMP_COL = 'date',
  TIME_SERIES_DATA_COL   = 'qty',
  TIME_SERIES_ID_COL     = ['shop_id', 'item_id'],
  DATA_FREQUENCY         = 'DAILY',
  HOLIDAY_REGION         = 'IN',
  DECOMPOSE_TIME_SERIES  = TRUE,
  HORIZON                = 35,
  AUTO_ARIMA_MAX_ORDER   = 2,
  -- Defaults kept on purpose: CLEAN_SPIKES_AND_DIPS = TRUE smooths the
  -- Navratri/Janmashtami spikes into a clean baseline, which forecast.sql
  -- then scales for the festivals that fall inside the horizon.
  CLEAN_SPIKES_AND_DIPS  = TRUE,
  ADJUST_STEP_CHANGES    = TRUE
) AS
SELECT
  date,
  shop_id,
  item_id,
  qty
FROM `kirana.sales_daily`;
