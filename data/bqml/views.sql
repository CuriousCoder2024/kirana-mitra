-- Helper views, created by `data/load_bigquery.sh load` (free: views store no data).
--
-- kirana.festival_multiplier_daily (day, category, festival, multiplier)
--   Demand multiplier for every day inside a festival window, per catalogue
--   category: linear ramp over pre_days up to the peak on the festival date,
--   peak held through post_days. The category-specific row in
--   festival_uplift wins, else the '*' default. Same rule as
--   data/generate_sales.py, so history and forecast agree.
--
-- kirana.item_history_weekly (shop_id, item_id, week_index, week_start, qty)
--   Actual sales for the last 4 complete 7-day weeks per shop, aligned so
--   that week 3 ends on the shop's last sale date. week_index 0..3 and
--   week_start line up with bqml/forecast.sql when @start_date is left
--   empty (forecast week 0 starts the day after history week 3 ends).

CREATE OR REPLACE VIEW `kirana.festival_multiplier_daily` AS
WITH cats AS (
  SELECT DISTINCT category FROM `kirana.catalogue`
),
resolved AS (
  SELECT
    f.name AS festival,
    f.date,
    f.pre_days,
    f.post_days,
    c.category,
    COALESCE(
      MAX(IF(u.category = c.category, u.multiplier, NULL)),
      MAX(IF(u.category = '*', u.multiplier, NULL)),
      1.0) AS peak
  FROM `kirana.festivals` f
  JOIN `kirana.festival_uplift` u ON u.profile = f.profile
  CROSS JOIN cats c
  GROUP BY festival, f.date, f.pre_days, f.post_days, c.category
)
SELECT
  d AS day,
  category,
  festival,
  CASE
    WHEN DATE_DIFF(d, date, DAY) < 0
      THEN 1 + (peak - 1) * (1 - (-DATE_DIFF(d, date, DAY)) / (pre_days + 1))
    ELSE peak
  END AS multiplier
FROM resolved,
  UNNEST(GENERATE_DATE_ARRAY(DATE_SUB(date, INTERVAL pre_days DAY),
                             DATE_ADD(date, INTERVAL post_days DAY))) AS d
WHERE peak <> 1.0;

CREATE OR REPLACE VIEW `kirana.item_history_weekly` AS
WITH last AS (
  SELECT shop_id, MAX(date) AS last_date
  FROM `kirana.sales_daily`
  GROUP BY shop_id
),
tagged AS (
  SELECT
    s.shop_id,
    s.item_id,
    s.qty,
    3 - DIV(DATE_DIFF(l.last_date, s.date, DAY), 7) AS week_index,
    l.last_date
  FROM `kirana.sales_daily` s
  JOIN last l USING (shop_id)
  WHERE DATE_DIFF(l.last_date, s.date, DAY) BETWEEN 0 AND 27
)
SELECT
  shop_id,
  item_id,
  week_index,
  DATE_SUB(DATE_ADD(last_date, INTERVAL 1 DAY), INTERVAL 7 * (4 - week_index) DAY) AS week_start,
  SUM(qty) AS qty
FROM tagged
GROUP BY shop_id, item_id, week_index, last_date;
