# BigQuery ML results (project kirana-mitra-app, dataset kirana, asia-south1)

Run on 2026-10-18 IST with `data/load_bigquery.sh` against the committed
`sales_history.csv` (shp_demo, 40 items, 2026-06-20 to 2026-10-17).

## Training

| | |
|---|---|
| Model | `kirana.item_demand_arima`, ARIMA_PLUS, `TIME_SERIES_ID_COL = ['shop_id','item_id']`, `HOLIDAY_REGION = 'IN'`, horizon 35 |
| Series trained | 40 |
| Training time | 5.3 s (job), 8-9 s wall with the bq client |
| Bytes billed | 10,485,760 (the 10 MiB per-query minimum) at the ARIMA_PLUS training rate: about $0.003 |
| `has_holiday_effect` | false for all 40 series, as the docs predict for a series shorter than a year |
| Seasonality detected | WEEKLY on the high-volume items, NO_SEASONALITY on the low-volume ones |

## 14-day holdout (2026-10-04 to 2026-10-17, which contains Navratri)

`evaluate.sql` retrains on history up to 2026-10-03 and scores the last 14
days two ways: **raw** = ARIMA_PLUS alone, **system** = ARIMA_PLUS x the
festival uplift the API actually serves.

| Metric | raw | system |
|---|---|---|
| WAPE over all items (volume-weighted, the headline) | 19.6% | **11.0%** |
| Mean per-item MAPE | 45.7% | 47.3% |
| Median per-item MAPE | | 43.9% |
| Mean per-item WAPE | 61.3% | 60.7% |

Per-item MAPE is dominated by items that sell 0-3 units a day (Pampers,
Ketchup, Horlicks), where a one-unit miss is a 50-100% error; the
volume-weighted number is the one that reflects reorder quantities. Top
sellers: Parle-G 16% / Britannia Good Day 16% / Tata Salt 24% / Dairy Milk
25% / Lays 26% system MAPE. Full per-item table: `SELECT * FROM kirana.forecast_eval ORDER BY sys_wape_pct`.

Evaluation job: 14.4 s, 104,857,600 bytes billed (10 statements x 10 MiB
minimum; ~$0.0006 of query plus ~$0.003 for the holdout model).

## Forecast sanity check (4 weeks from 2026-10-19)

`data/load_bigquery.sh forecast --start 2026-10-19`, rounded units/week.
`baseline` is the raw ARIMA forecast; `forecast` includes the festival uplift.

| Item | Week | baseline | forecast | lower | upper | festival |
|---|---|---|---|---|---|---|
| Parle-G | 10-19 | 142 | 156 | 117 | 195 | Dussehra x1.3 |
| Parle-G | 10-26 | 145 | 145 | 110 | 180 | |
| Parle-G | 11-02 | 148 | **214** | 166 | 262 | Diwali x1.8 |
| Parle-G | 11-09 | 150 | 180 | 137 | 222 | Diwali x1.8 |
| Maggi | 10-19 | 59 | 66 | 30 | 101 | Dussehra x1.3 |
| Maggi | 10-26 | 59 | 59 | 27 | 91 | |
| Maggi | 11-02 | 59 | 62 | 28 | 95 | Diwali x1.1 |
| Maggi | 11-09 | 59 | 61 | 28 | 93 | Diwali x1.1 |
| Aashirvaad atta | 10-19 | 12 | 14 | 0 | 30 | Navratri x1.5 |
| Aashirvaad atta | 10-26 | 12 | 12 | 0 | 26 | |
| Aashirvaad atta | 11-02 | 12 | **20** | 0 | 41 | Diwali x2.2 |
| Aashirvaad atta | 11-09 | 12 | 17 | 0 | 35 | Diwali x2.2 |

History for the same items (`kirana.item_history_weekly`, weeks from 09-20):
Parle-G 130 / 122 / 136 / 162, Maggi 41 / 78 / 66 / 55, atta 7 / 16 / 12 / 24.

The forecast query bills 10 MiB per statement (~60 MiB per run including
the DECLARE), i.e. under $0.001 per API call at on-demand rates.

## Running total

All BigQuery work on 2026-10-18 (loads, 2 trainings, views, forecasts,
evaluation, ad-hoc checks): about 450 MiB billed, under $0.01.
