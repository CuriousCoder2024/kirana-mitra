"""Demand forecast sources for GET /forecast, POST /reorder.

`ForecastSource.load(shop_id)` returns raw daily material (catalogue, daily
forecast points, daily sales history, festivals, uplift table). The shaping
into the contract's 4 Monday-start weekly buckets, festival uplift, on-hand
join and reorder maths is pure Python below, shared by both sources and unit
tested:

- `BigQueryForecastSource`: ML.FORECAST on `kirana.item_demand_arima` (trained
  by data/bqml/train_arima.sql) plus the `sales_daily`, `catalogue`,
  `festivals` and `festival_uplift` tables. Results are cached in memory for
  10 minutes per series so the forecast screen is instant on the second open.
- `LocalForecastSource`: data/sales_history.csv + data/catalogue.csv with a
  seasonal-naive forecast (same-weekday mean of the last 4 weeks), so
  MOCK_GEMINI=1 / FORECAST_SOURCE=local runs fully offline.

Festival uplift mirrors data/bqml/forecast.sql: a linear ramp over `pre_days`
up to the multiplier on the festival date, held through `post_days`; the
category-specific multiplier wins over the '*' default, strongest festival
wins when windows overlap.
"""

from __future__ import annotations

import csv
import logging
import math
import os
import statistics
import threading
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import date, timedelta

from app.matching import match_item_scored
from app.models import FestivalRef, ForecastItem
from app.store import ItemRecord

logger = logging.getLogger("kirana.forecast")

DEMO_SERIES = "shp_demo"
HORIZON_DAYS = 35  # enough to cover 4 Monday-start weeks from any start day
REORDER_COVER_WEEKS = 2  # reorder_qty covers this many of the 4 forecast weeks (owner decision)
CACHE_TTL_S = 600


# ---- raw material ------------------------------------------------------------


@dataclass
class CatalogueRow:
    item_id: str
    name: str
    pack_size: str | None
    unit: str
    category: str
    reorder_level: float
    mrp: int
    aliases: list[str] = field(default_factory=list)


@dataclass
class Festival:
    name: str
    date: date
    pre_days: int
    post_days: int
    profile: str


@dataclass
class DailyPoint:
    day: date
    fc: float
    lo: float
    hi: float


@dataclass
class RawForecast:
    series_shop_id: str
    last_date: date  # last day with actual sales
    catalogue: list[CatalogueRow]
    forecast: dict[str, list[DailyPoint]]  # item_id -> daily points from last_date + 1
    history: dict[str, dict[date, int]]  # item_id -> day -> qty
    festivals: list[Festival]
    uplift: dict[tuple[str, str], float]  # (profile, category | '*') -> multiplier


# ---- shaping (pure) -----------------------------------------------------------


def week_starts(start: date, n: int = 4) -> list[date]:
    """The first n Monday-start weeks beginning on or after `start`."""
    monday = start + timedelta(days=(7 - start.weekday()) % 7)
    return [monday + timedelta(days=7 * k) for k in range(n)]


def festival_multiplier(day: date, category: str, festivals: list[Festival],
                        uplift: dict[tuple[str, str], float]) -> tuple[float, str | None]:
    """(multiplier, festival name) for one day and category; (1.0, None) outside windows."""
    best, best_name = 1.0, None
    for f in festivals:
        peak = uplift.get((f.profile, category), uplift.get((f.profile, "*"), 1.0))
        d = (day - f.date).days
        if -f.pre_days <= d <= -1:
            m = 1 + (peak - 1) * (1 - (-d) / (f.pre_days + 1))
        elif 0 <= d <= f.post_days:
            m = peak
        else:
            continue
        if m > best:
            best, best_name = m, f.name
    return best, best_name


def festivals_in_window(festivals: list[Festival], weeks: list[date]) -> list[FestivalRef]:
    lo, hi = weeks[0], weeks[-1] + timedelta(days=6)
    return [FestivalRef(name=f.name, date=f.date.isoformat())
            for f in sorted(festivals, key=lambda f: f.date) if lo <= f.date <= hi]


def round_up_to_pack(qty: int, pack: int) -> int:
    if qty <= 0:
        return 0
    if pack and pack > 1:
        return int(math.ceil(qty / pack) * pack)
    return qty


def _localized(language: str, hi: str, en: str, hinglish: str) -> str:
    """Python-side strings exist for hi, en and hi-Latn; every other code gets English."""
    return {"hi": hi, "hi-Latn": hinglish}.get(language, en)


def reorder_reason(language: str, festival: str | None, peak_mult: float, need_qty: int,
                   on_hand: int, weekly: list[int], cover_weeks: int = REORDER_COVER_WEEKS) -> str:
    """`festival`/`peak_mult` describe the strongest uplift inside the cover window;
    `need_qty` is the forecast demand over that window."""
    avg_week = max(1.0, sum(weekly) / max(1, len(weekly)))
    cover = int(on_hand / avg_week)
    if need_qty > on_hand and festival and peak_mult >= 1.3:
        return _localized(language,
                          f"{festival} के हफ़्ते में माँग ~{peak_mult:.1f}x",
                          f"{festival} week demand ~{peak_mult:.1f}x",
                          f"{festival} week demand ~{peak_mult:.1f}x")
    if need_qty > on_hand:
        return _localized(language,
                          f"{cover_weeks} हफ़्ते में ~{need_qty} चाहिए, सिर्फ़ {on_hand} हैं",
                          f"Next {cover_weeks} weeks need ~{need_qty}, only {on_hand} on hand",
                          f"{cover_weeks} hafte mein ~{need_qty} chahiye, sirf {on_hand} hain")
    return _localized(language,
                      f"ठीक है; {cover} हफ़्ते का स्टॉक",
                      f"Steady; {cover} weeks cover",
                      f"Steady; {cover} hafte ka stock")


def match_catalogue_to_shop(catalogue: list[CatalogueRow],
                            shop_items: list[ItemRecord]) -> dict[str, ItemRecord]:
    """Join data/ catalogue rows onto the shop's own items by name or alias.

    Each shop item is claimed by at most one catalogue row (the best-scoring
    one), so "Amul Taaza Milk" and "Amul Cow Ghee" cannot both land on the
    shop's "Amul Milk".
    """
    best: dict[str, tuple[int, str]] = {}  # shop item_id -> (score, catalogue item_id)
    for row in catalogue:
        for key in [row.name, *row.aliases]:
            hit = match_item_scored(key, shop_items, threshold=80)
            if hit is None:
                continue
            item, score = hit
            if key.lower() == row.name.lower():
                score += 1  # a name match beats an alias match at equal score
            if item.item_id not in best or score > best[item.item_id][0]:
                best[item.item_id] = (score, row.item_id)
    by_id = {i.item_id: i for i in shop_items}
    return {cat_id: by_id[shop_id] for shop_id, (_, cat_id) in best.items()}


def shape_forecast(raw: RawForecast, shop_items: list[ItemRecord], language: str,
                   today: date | None = None) -> tuple[list[date], list[FestivalRef], list[ForecastItem]]:
    """Bucket daily points into the contract's 4 weeks for the items this shop stocks.

    All 4 weeks are returned for the chart; reorder_qty only covers the first
    REORDER_COVER_WEEKS weeks. Items in the data catalogue that the shop does
    not carry are left out: on_hand and reorder_qty are only meaningful against
    the shop's own stock.
    """
    start = max(raw.last_date + timedelta(days=1), today or raw.last_date + timedelta(days=1))
    weeks = week_starts(start)
    hist_weeks = [weeks[0] - timedelta(days=7 * k) for k in (4, 3, 2, 1)]
    out: list[ForecastItem] = []
    joined = match_catalogue_to_shop(raw.catalogue, shop_items)
    for row in raw.catalogue:
        shop_item = joined.get(row.item_id)
        if shop_item is None:
            continue
        points = raw.forecast.get(row.item_id, [])
        fc = [0.0] * 4
        lo = [0.0] * 4
        hi = [0.0] * 4
        peak_mult, peak_name = 1.0, None
        for pt in points:
            k = (pt.day - weeks[0]).days // 7
            if not 0 <= k < 4 or pt.day < weeks[0]:
                continue
            m, name = festival_multiplier(pt.day, row.category, raw.festivals, raw.uplift)
            fc[k] += max(0.0, pt.fc) * m
            lo[k] += max(0.0, pt.lo) * m
            hi[k] += max(0.0, pt.hi) * m
            if k < REORDER_COVER_WEEKS and m > peak_mult:  # reason only for the cover window
                peak_mult, peak_name = m, name
        history = raw.history.get(row.item_id, {})
        hist = [sum(q for d, q in history.items() if ws <= d < ws + timedelta(days=7))
                for ws in hist_weeks]
        forecast_weekly = [int(round(x)) for x in fc]
        on_hand = int(round(shop_item.quantity))
        # Order enough to cover the next REORDER_COVER_WEEKS weeks, not the whole chart.
        cover_demand = int(round(sum(fc[:REORDER_COVER_WEEKS])))
        need = max(0, cover_demand - on_hand)
        out.append(ForecastItem(
            item_id=shop_item.item_id,
            name=shop_item.name,
            unit=shop_item.unit,  # type: ignore[arg-type]
            history_weekly=hist,
            forecast_weekly=forecast_weekly,
            lower=[int(round(x)) for x in lo],
            upper=[int(round(x)) for x in hi],
            on_hand=on_hand,
            reorder_qty=round_up_to_pack(need, shop_item.carton_size),
            reorder_reason=reorder_reason(language, peak_name, peak_mult, cover_demand, on_hand,
                                          forecast_weekly[:REORDER_COVER_WEEKS]),
        ))
    out.sort(key=lambda i: (-i.reorder_qty, i.name))
    return weeks, festivals_in_window(raw.festivals, weeks), out


# ---- CSV readers (shared by the local source and tests) ----------------------------


def read_catalogue_csv(path: str) -> list[CatalogueRow]:
    with open(path, encoding="utf-8", newline="") as fh:
        return [CatalogueRow(
            item_id=r["item_id"], name=r["name"], pack_size=r.get("pack_size") or None,
            unit=r["unit"], category=r["category"], reorder_level=float(r["reorder_level"]),
            mrp=int(float(r["mrp_rupees"])),
            aliases=[a for a in (r.get("aliases") or "").split("|") if a],
        ) for r in csv.DictReader(fh)]


def read_festivals_csv(path: str) -> list[Festival]:
    with open(path, encoding="utf-8", newline="") as fh:
        return [Festival(r["name"], date.fromisoformat(r["date"]), int(r["pre_days"]),
                         int(r["post_days"]), r["profile"]) for r in csv.DictReader(fh)]


def read_uplift_csv(path: str) -> dict[tuple[str, str], float]:
    with open(path, encoding="utf-8", newline="") as fh:
        return {(r["profile"], r["category"]): float(r["multiplier"]) for r in csv.DictReader(fh)}


def read_sales_csv(path: str, shop_id: str) -> dict[str, dict[date, int]]:
    hist: dict[str, dict[date, int]] = {}
    with open(path, encoding="utf-8", newline="") as fh:
        for r in csv.DictReader(fh):
            if r["shop_id"] != shop_id:
                continue
            hist.setdefault(r["item_id"], {})[date.fromisoformat(r["date"])] = int(float(r["qty"]))
    return hist


# ---- sources -------------------------------------------------------------------


class ForecastSource(ABC):
    name: str = "abstract"

    def __init__(self) -> None:
        self._cache: dict[str, tuple[float, RawForecast]] = {}
        self._lock = threading.Lock()

    @abstractmethod
    def series_for(self, shop_id: str) -> str:
        """Which series to use for a shop (unknown shops fall back to the demo series)."""

    @abstractmethod
    def _load(self, series_shop_id: str) -> RawForecast: ...

    def load(self, shop_id: str) -> RawForecast:
        series = self.series_for(shop_id)
        now = time.monotonic()
        with self._lock:
            hit = self._cache.get(series)
            if hit and hit[0] > now:
                return hit[1]
        raw = self._load(series)
        with self._lock:
            self._cache[series] = (now + CACHE_TTL_S, raw)
        return raw


class LocalForecastSource(ForecastSource):
    """Seasonal-naive forecast from data/*.csv; no network, no project."""

    name = "local"

    def __init__(self, data_dir: str) -> None:
        super().__init__()
        self.data_dir = data_dir

    def series_for(self, shop_id: str) -> str:
        return DEMO_SERIES  # the CSV only holds the demo shop

    def _load(self, series_shop_id: str) -> RawForecast:
        d = self.data_dir
        catalogue = read_catalogue_csv(os.path.join(d, "catalogue.csv"))
        history = read_sales_csv(os.path.join(d, "sales_history.csv"), series_shop_id)
        festivals = read_festivals_csv(os.path.join(d, "festivals.csv"))
        uplift = read_uplift_csv(os.path.join(d, "festival_uplift.csv"))
        last_date = max((day for h in history.values() for day in h), default=date.today())
        start = last_date + timedelta(days=1)
        forecast: dict[str, list[DailyPoint]] = {}
        for row in catalogue:
            h = history.get(row.item_id, {})
            points: list[DailyPoint] = []
            for k in range(HORIZON_DAYS):
                day = start + timedelta(days=k)
                same_weekday = [h.get(day - timedelta(days=7 * j), 0) for j in range(1, 5)
                                if day - timedelta(days=7 * j) <= last_date]
                base = statistics.mean(same_weekday) if same_weekday else 0.0
                spread = statistics.pstdev(same_weekday) if len(same_weekday) > 1 else base * 0.3
                points.append(DailyPoint(day, base, max(0.0, base - spread), base + spread))
            forecast[row.item_id] = points
        return RawForecast(series_shop_id, last_date, catalogue, forecast, history, festivals, uplift)


class BigQueryForecastSource(ForecastSource):
    """ML.FORECAST on the ARIMA_PLUS model the data/ pipeline trains, plus its tables."""

    name = "bigquery"

    def __init__(self, project: str, dataset: str, location: str, model: str = "item_demand_arima") -> None:
        super().__init__()
        from google.cloud import bigquery

        self.dataset = f"{project}.{dataset}"
        self.model = model
        self._client = bigquery.Client(project=project, location=location)
        self._known_shops: tuple[float, set[str]] | None = None

    def _query(self, sql: str, **params):
        from google.cloud import bigquery

        job_config = bigquery.QueryJobConfig(query_parameters=[
            bigquery.ScalarQueryParameter(k, "STRING" if isinstance(v, str) else "INT64", v)
            for k, v in params.items()])
        return list(self._client.query(sql, job_config=job_config).result())

    def series_for(self, shop_id: str) -> str:
        # Only the demo shop has sales history in BigQuery. A shop created in the app
        # gets its own shop_id but no history yet, so every unknown shop is served the
        # demo series; its own on_hand still comes from the repository.
        now = time.monotonic()
        if self._known_shops is None or self._known_shops[0] < now:
            try:
                rows = self._query(f"SELECT DISTINCT shop_id FROM `{self.dataset}.sales_daily`")
                self._known_shops = (now + CACHE_TTL_S, {r["shop_id"] for r in rows})
            except Exception as exc:  # keep serving the demo series if the table is missing
                logger.warning("could not list shops in BigQuery: %s", exc)
                self._known_shops = (now + 60, {DEMO_SERIES})
        return shop_id if shop_id in self._known_shops[1] else DEMO_SERIES

    def _load(self, series_shop_id: str) -> RawForecast:
        ds = self.dataset
        catalogue = [CatalogueRow(
            item_id=r["item_id"], name=r["name"], pack_size=r["pack_size"], unit=r["unit"],
            category=r["category"], reorder_level=float(r["reorder_level"]),
            mrp=int(r["mrp_rupees"]), aliases=[a for a in (r["aliases"] or "").split("|") if a],
        ) for r in self._query(
            f"SELECT item_id, name, pack_size, unit, category, reorder_level, mrp_rupees, aliases "
            f"FROM `{ds}.catalogue`")]
        festivals = [Festival(r["name"], r["date"], int(r["pre_days"]), int(r["post_days"]),
                              r["profile"])
                     for r in self._query(f"SELECT name, date, pre_days, post_days, profile "
                                          f"FROM `{ds}.festivals`")]
        uplift = {(r["profile"], r["category"]): float(r["multiplier"])
                  for r in self._query(f"SELECT profile, category, multiplier "
                                       f"FROM `{ds}.festival_uplift`")}
        history: dict[str, dict[date, int]] = {}
        for r in self._query(
            f"SELECT item_id, date, qty FROM `{ds}.sales_daily` "
            f"WHERE shop_id = @shop_id "
            f"AND date >= DATE_SUB((SELECT MAX(date) FROM `{ds}.sales_daily`), INTERVAL 42 DAY)",
            shop_id=series_shop_id,
        ):
            history.setdefault(r["item_id"], {})[r["date"]] = int(r["qty"])
        last_date = max((day for h in history.values() for day in h), default=date.today())
        forecast: dict[str, list[DailyPoint]] = {}
        for r in self._query(
            f"SELECT item_id, DATE(forecast_timestamp) AS day, forecast_value AS fc, "
            f"prediction_interval_lower_bound AS lo, prediction_interval_upper_bound AS hi "
            # ML.FORECAST's settings struct must be literal constants, so the horizon
            # is formatted in (it is a module constant, never user input).
            f"FROM ML.FORECAST(MODEL `{ds}.{self.model}`, "
            f"STRUCT({int(HORIZON_DAYS)} AS horizon, 0.8 AS confidence_level))",
        ):
            forecast.setdefault(r["item_id"], []).append(
                DailyPoint(r["day"], float(r["fc"]), float(r["lo"]), float(r["hi"])))
        return RawForecast(series_shop_id, last_date, catalogue, forecast, history, festivals, uplift)


def make_forecast_source(settings) -> ForecastSource:
    if settings.forecast_source == "bigquery" and settings.google_cloud_project:
        return BigQueryForecastSource(settings.google_cloud_project, settings.bq_dataset,
                                      settings.bq_location)
    return LocalForecastSource(settings.data_dir)
