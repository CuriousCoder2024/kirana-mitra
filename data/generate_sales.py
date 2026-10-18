# /// script
# requires-python = ">=3.12"
# dependencies = ["numpy>=1.26", "pandas>=2.2"]
# ///
"""Generate 120 days of synthetic daily sales for the Kirana Mitra demo shop.

Run with uv (dependencies are declared inline, PEP 723):

    uv run data/generate_sales.py              # ends yesterday, Asia/Kolkata
    uv run data/generate_sales.py --end 2026-10-17 --days 120

Writes data/sales_history.csv with columns
    date, shop_id, item_id, qty, revenue_rupees
for one shop ("shp_demo") and every item in data/catalogue.csv, and prints a
short summary (row count, top 5 revenue days, per-festival uplift).

Signal in the data (all deterministic, seed 42):
  * per-item base rate by category, scaled by price (cheap items sell more)
  * weekly pattern: Sunday high, mid-week low
  * month-start salary bump on the 1st-7th
  * summer uplift for cold drinks (June/July high, fading by October)
  * festival spikes with a 3-5 day ramp before the day, read from
    data/festivals.csv (dates) and data/festival_uplift.csv (per-category
    multipliers), so the same tables feed bqml/forecast.sql.

Festival dates for 2026 were checked against timeanddate.com's India
holiday calendar on 2026-10-18:
    https://www.timeanddate.com/holidays/india/2026
    Holi 4 Mar (Holika Dahan 3 Mar), Ramzan Id 21 Mar, Bakrid 28 May,
    Independence Day 15 Aug, Onam 26 Aug, Raksha Bandhan 28 Aug,
    Janmashtami 4 Sep, Ganesh Chaturthi 14 Sep, Sharad Navratri starts 11 Oct,
    Dussehra 20 Oct, Diwali 8 Nov.
Only festivals whose ramp window overlaps the generated date range have any
effect; with the default 120-day window ending 2026-10-17 that is Independence
Day, Onam, Raksha Bandhan, Janmashtami, Ganesh Chaturthi, Navratri and the
ramp-up to Dussehra. Holi, both Eids and Diwali 2025 (20 Oct 2025) fall
outside the window. Diwali 2026 is in the forecast horizon, not the history.
"""

from __future__ import annotations

import argparse
import sys
from datetime import date, datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent
SHOP_ID = "shp_demo"
SEED = 42

# Mean units sold per day for a "typical" item in the category, before the
# price scaling below. Tuned so a small kirana clears ~₹8-12k/day.
BASE_DAILY_BY_CATEGORY = {
    "biscuits": 14.0,
    "noodles": 9.0,
    "staples": 4.0,
    "household": 3.0,
    "dairy": 8.0,
    "personal_care": 2.5,
    "beverages": 1.6,
    "snacks": 7.0,
    "cold_drinks": 6.0,
    "confectionery": 12.0,
    "condiments": 0.8,
    "spices": 1.4,
    "baby_care": 0.7,
    "pooja": 2.0,
}

# Sunday is the big shopping day for a kirana; Tue/Wed are the slowest.
WEEKDAY_FACTOR = {0: 0.95, 1: 0.85, 2: 0.80, 3: 0.90, 4: 1.00, 5: 1.15, 6: 1.30}

# Cold drinks: hot pre-monsoon/monsoon months, cooling off by October.
SUMMER_FACTOR_BY_MONTH = {5: 1.5, 6: 1.4, 7: 1.3, 8: 1.1, 9: 1.0, 10: 0.9, 11: 0.8}


def month_start_factor(d: date) -> float:
    """Salary-day bump: strongest on the 1st-5th, tapering by the 7th."""
    if d.day <= 5:
        return 1.25
    if d.day <= 7:
        return 1.10
    return 1.0


def price_scale(mrp: float) -> float:
    """Cheaper items move more units. ₹10 -> 1.0, ₹100 -> ~0.5, ₹500 -> ~0.3."""
    return float(np.clip(1.0 / (mrp / 10.0) ** 0.3, 0.25, 1.0))


def load_tables() -> tuple[pd.DataFrame, pd.DataFrame, dict[tuple[str, str], float]]:
    catalogue = pd.read_csv(HERE / "catalogue.csv", encoding="utf-8")
    festivals = pd.read_csv(HERE / "festivals.csv", parse_dates=["date"])
    festivals["date"] = festivals["date"].dt.date
    uplift_rows = pd.read_csv(HERE / "festival_uplift.csv")
    uplift = {(r.profile, r.category): float(r.multiplier) for r in uplift_rows.itertuples()}
    return catalogue, festivals, uplift


def festival_multiplier(
    d: date, category: str, festivals: pd.DataFrame, uplift: dict[tuple[str, str], float]
) -> tuple[float, str | None]:
    """Return (multiplier, festival name) for the strongest festival effect on day d.

    Effect shape: linear ramp from 1.0 at (date - pre_days) up to the peak on
    the festival date, peak held through post_days, then back to normal.
    """
    best, best_name = 1.0, None
    for f in festivals.itertuples():
        peak = uplift.get((f.profile, category), uplift.get((f.profile, "*"), 1.0))
        if peak == 1.0:
            continue
        delta = (d - f.date).days  # negative before the festival
        if -f.pre_days <= delta < 0:
            frac = 1.0 - (-delta / (f.pre_days + 1))
            m = 1.0 + (peak - 1.0) * frac
        elif 0 <= delta <= f.post_days:
            m = peak
        else:
            continue
        if m > best:
            best, best_name = m, f.name
    return best, best_name


def generate(end: date, days: int) -> tuple[pd.DataFrame, pd.DataFrame]:
    rng = np.random.default_rng(SEED)
    catalogue, festivals, uplift = load_tables()
    start = end - timedelta(days=days - 1)
    dates = [start + timedelta(days=i) for i in range(days)]

    # Small fixed per-item jitter so two items in one category don't move in lockstep.
    item_jitter = {
        item_id: float(j) for item_id, j in zip(catalogue["item_id"], rng.uniform(0.8, 1.2, len(catalogue)))
    }

    records = []
    for d in dates:
        wd = WEEKDAY_FACTOR[d.weekday()]
        ms = month_start_factor(d)
        for item in catalogue.itertuples():
            base = BASE_DAILY_BY_CATEGORY[item.category] * price_scale(item.mrp_rupees) * item_jitter[item.item_id]
            expected = base * wd * ms
            if item.category == "cold_drinks":
                expected *= SUMMER_FACTOR_BY_MONTH.get(d.month, 1.0)
            fest_m, fest_name = festival_multiplier(d, item.category, festivals, uplift)
            expected *= fest_m
            # Poisson noise, floored so "shop was closed" days don't appear.
            qty = int(rng.poisson(max(expected, 0.15)))
            records.append(
                {
                    "date": d.isoformat(),
                    "shop_id": SHOP_ID,
                    "item_id": item.item_id,
                    "qty": qty,
                    "revenue_rupees": int(qty * item.mrp_rupees),
                    "_festival": fest_name,
                    "_category": item.category,
                }
            )
    df = pd.DataFrame.from_records(records)
    return df, festivals


def summarise(df: pd.DataFrame, festivals: pd.DataFrame) -> None:
    daily = df.groupby("date", as_index=False)["revenue_rupees"].sum()
    fest_by_day = df.groupby("date")["_festival"].agg(lambda s: next((x for x in s if isinstance(x, str)), "-"))
    daily["festival_effect"] = daily["date"].map(fest_by_day)
    print(f"rows: {len(df):,}  items: {df['item_id'].nunique()}  days: {df['date'].nunique()}")
    print(f"range: {df['date'].min()} .. {df['date'].max()}")
    print(f"total revenue: ₹{df['revenue_rupees'].sum():,}  avg/day: ₹{daily['revenue_rupees'].mean():,.0f}")
    print("\ntop 5 days by revenue:")
    top = daily.sort_values("revenue_rupees", ascending=False).head(5)
    for r in top.itertuples():
        dow = datetime.fromisoformat(r.date).strftime("%a")
        print(f"  {r.date} {dow}  ₹{r.revenue_rupees:>7,}  {r.festival_effect}")
    print("\nfestival windows inside the range (avg daily revenue vs baseline):")
    baseline = daily.loc[daily["festival_effect"] == "-", "revenue_rupees"].mean()
    for name, grp in daily[daily["festival_effect"] != "-"].groupby("festival_effect"):
        print(f"  {name:<18} {len(grp):>2} days  ₹{grp['revenue_rupees'].mean():,.0f}  ({grp['revenue_rupees'].mean() / baseline:.2f}x)")
    lo, hi = date.fromisoformat(df["date"].min()), date.fromisoformat(df["date"].max())
    skipped = [
        f.name
        for f in festivals.itertuples()
        if f.date + timedelta(days=f.post_days) < lo or f.date - timedelta(days=f.pre_days) > hi
    ]
    print(f"\nfestivals outside the range (no effect): {', '.join(skipped)}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--end", type=date.fromisoformat, default=None, help="last day of history (default: yesterday IST)")
    parser.add_argument("--days", type=int, default=120)
    parser.add_argument("--out", type=Path, default=HERE / "sales_history.csv")
    args = parser.parse_args()
    end = args.end or (datetime.now(ZoneInfo("Asia/Kolkata")).date() - timedelta(days=1))

    df, festivals = generate(end, args.days)
    out_cols = ["date", "shop_id", "item_id", "qty", "revenue_rupees"]
    df[out_cols].to_csv(args.out, index=False)
    print(f"wrote {args.out.relative_to(Path.cwd()) if args.out.is_relative_to(Path.cwd()) else args.out}\n")
    summarise(df, festivals)
    return 0


if __name__ == "__main__":
    sys.exit(main())
