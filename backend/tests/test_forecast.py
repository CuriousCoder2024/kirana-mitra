"""Local forecast source, weekly bucketing, festival uplift, reorder maths, summary, reorder."""

from datetime import date
from urllib.parse import unquote

import pytest

from app.config import Settings
from app.forecast import (
    REORDER_COVER_WEEKS,
    CatalogueRow,
    DailyPoint,
    Festival,
    LocalForecastSource,
    RawForecast,
    festival_multiplier,
    match_catalogue_to_shop,
    round_up_to_pack,
    shape_forecast,
    week_starts,
)
from app.service import summary_template
from app.store import InMemoryRepository

DATA_DIR = Settings().data_dir


def shop_items():
    repo = InMemoryRepository()
    shop = repo.create_shop("Gupta General Store", "Ramesh", "hi-Latn")
    return repo, shop, repo.list_items(shop.shop_id)


# ---- pure maths ---------------------------------------------------------------------


def test_weeks_start_on_monday_on_or_after_start():
    assert week_starts(date(2026, 10, 18)) == [date(2026, 10, 19), date(2026, 10, 26),
                                               date(2026, 11, 2), date(2026, 11, 9)]
    assert week_starts(date(2026, 10, 19))[0] == date(2026, 10, 19)  # a Monday stays
    assert week_starts(date(2026, 10, 20))[0] == date(2026, 10, 26)


def test_festival_multiplier_ramps_and_prefers_category():
    diwali = Festival("Diwali", date(2026, 11, 8), 5, 2, "diwali")
    uplift = {("diwali", "*"): 1.6, ("diwali", "dairy"): 2.6}
    assert festival_multiplier(date(2026, 10, 1), "dairy", [diwali], uplift) == (1.0, None)
    assert festival_multiplier(date(2026, 11, 8), "dairy", [diwali], uplift) == (2.6, "Diwali")
    assert festival_multiplier(date(2026, 11, 10), "biscuits", [diwali], uplift) == (1.6, "Diwali")
    m, _ = festival_multiplier(date(2026, 11, 5), "biscuits", [diwali], uplift)  # 3 days before
    assert 1.0 < m < 1.6 and abs(m - (1 + 0.6 * (1 - 3 / 6))) < 1e-9
    assert festival_multiplier(date(2026, 11, 11), "dairy", [diwali], uplift) == (1.0, None)


def test_round_up_to_pack():
    assert round_up_to_pack(0, 24) == 0
    assert round_up_to_pack(5, 24) == 24
    assert round_up_to_pack(24, 24) == 24
    assert round_up_to_pack(25, 24) == 48
    assert round_up_to_pack(7, 1) == 7


def test_shape_forecast_buckets_reorder_and_reason():
    repo, shop, items = shop_items()
    parle = next(i for i in items if i.name == "Parle-G")  # on_hand 42, carton 24
    cat = [CatalogueRow("itm_001", "Parle-G", "70g", "packet", "biscuits", 48, 10, ["parle ji"])]
    last = date(2026, 10, 17)
    start = date(2026, 10, 18)
    # 10 units a day for 35 days from Oct 18; Diwali (Nov 8, pre 5, post 2) in week 3
    points = [DailyPoint(date.fromordinal(start.toordinal() + k), 10, 8, 12) for k in range(35)]
    history = {date.fromordinal(last.toordinal() - k): 5 for k in range(35)}
    raw = RawForecast("shp_demo", last, cat, {"itm_001": points}, {"itm_001": history},
                      [Festival("Diwali", date(2026, 11, 8), 5, 2, "diwali")],
                      {("diwali", "*"): 1.6, ("diwali", "biscuits"): 2.0})
    weeks, fests, out = shape_forecast(raw, items, "en", today=date(2026, 10, 18))
    assert [w.isoformat() for w in weeks] == ["2026-10-19", "2026-10-26", "2026-11-02", "2026-11-09"]
    assert [f.model_dump() for f in fests] == [{"name": "Diwali", "date": "2026-11-08"}]
    assert len(out) == 1
    it = out[0]
    assert it.item_id == parle.item_id and it.name == "Parle-G" and it.unit == "packet"
    # Monday-start weeks; the last one (Oct 12-18) only has data through Oct 17
    assert it.history_weekly == [35, 35, 35, 30]
    assert it.forecast_weekly[0] == 70 and it.forecast_weekly[1] == 70
    assert it.forecast_weekly[2] > 70 and it.forecast_weekly[3] > 70  # Diwali ramp + peak
    assert it.lower[0] == 56 and it.upper[0] == 84
    assert it.on_hand == 42
    assert REORDER_COVER_WEEKS == 2
    need = sum(it.forecast_weekly[:2]) - 42  # 140 - 42 = 98 -> 120 (5 cartons of 24)
    assert it.reorder_qty == round_up_to_pack(need, 24) == 120
    # Diwali sits in weeks 3-4, outside the 2-week cover window, so it is not the reason
    assert it.reorder_reason == "Next 2 weeks need ~140, only 42 on hand"


def test_festival_inside_cover_window_drives_reason_and_quantity():
    repo, shop, items = shop_items()
    cat = [CatalogueRow("itm_001", "Parle-G", "70g", "packet", "biscuits", 48, 10, [])]
    start = date(2026, 10, 19)
    points = [DailyPoint(date.fromordinal(start.toordinal() + k), 10, 8, 12) for k in range(28)]
    raw = RawForecast("shp_demo", date(2026, 10, 18), cat, {"itm_001": points}, {},
                      [Festival("Dussehra", date(2026, 10, 20), 3, 1, "dussehra")],
                      {("dussehra", "*"): 1.3, ("dussehra", "biscuits"): 2.0})
    _, _, out = shape_forecast(raw, items, "hi-Latn", today=start)
    it = out[0]
    assert it.forecast_weekly[0] > 70 and it.forecast_weekly[1] == 70
    assert it.reorder_reason == "Dussehra week demand ~2.0x"
    assert it.reorder_qty == round_up_to_pack(sum(it.forecast_weekly[:2]) - 42, 24)


def test_stock_above_two_week_need_gives_zero_reorder_and_no_order_line(client, scripted, shop_id):
    # Push Parle-G stock far above anything 2 weeks can need, then check both endpoints.
    scripted.push(intent="stock_in", entities={"items": [{"name": "Parle-G", "quantity": 5000,
                                                           "unit": "packet"}]})
    client.post("/chat", json={"shop_id": shop_id, "text": "x"})
    items = client.get(f"/forecast/{shop_id}").json()["items"]
    parle = next(i for i in items if i["name"] == "Parle-G")
    assert parle["on_hand"] == 5042 and parle["reorder_qty"] == 0
    assert parle["reorder_reason"].startswith("Steady;")
    assert sum(parle["forecast_weekly"][:2]) < parle["on_hand"]
    lines = client.post(f"/reorder/{shop_id}").json()["lines"]
    assert all(not l["name"].startswith("Parle-G") for l in lines)
    assert all(l["qty"] > 0 for l in lines)


def test_shape_forecast_steady_reason_when_stock_covers():
    repo, shop, items = shop_items()
    cat = [CatalogueRow("itm_013", "Nescafe Classic", "50g", "piece", "beverages", 6, 195, ["coffee"])]
    start = date(2026, 10, 19)
    points = [DailyPoint(date.fromordinal(start.toordinal() + k), 0.1, 0, 0.3) for k in range(28)]
    raw = RawForecast("shp_demo", date(2026, 10, 18), cat, {"itm_013": points}, {}, [], {})
    _, _, out = shape_forecast(raw, items, "hi-Latn", today=start)
    assert out[0].name == "Nescafe" and out[0].reorder_qty == 0
    assert out[0].reorder_reason.startswith("Steady;")


def test_catalogue_join_claims_each_shop_item_once():
    repo, shop, items = shop_items()
    src = LocalForecastSource(DATA_DIR)
    raw = src.load("shp_whatever")
    joined = match_catalogue_to_shop(raw.catalogue, items)
    shop_ids = [i.item_id for i in joined.values()]
    assert len(shop_ids) == len(set(shop_ids))
    names = {r.item_id: r.name for r in raw.catalogue}
    got = {names[c]: i.name for c, i in joined.items()}
    assert got["Parle-G"] == "Parle-G"
    assert got["Maggi Masala Noodles"] == "Maggi"
    assert got["Amul Taaza Milk"] == "Amul Milk"
    assert got["Amul Cow Ghee"] == "Amul Cow Ghee"  # seeded from the full catalogue now
    assert len(joined) == 40


def test_local_source_reads_csvs_and_caches():
    src = LocalForecastSource(DATA_DIR)
    raw = src.load("shp_new")
    assert raw.series_shop_id == "shp_demo"
    assert raw.last_date == date(2026, 10, 17)
    assert len(raw.catalogue) == 40 and len(raw.forecast) == 40
    assert len(raw.forecast["itm_001"]) == 35
    assert raw.forecast["itm_001"][0].day == date(2026, 10, 18)
    assert any(f.name == "Diwali" for f in raw.festivals)
    assert src.load("shp_other") is raw  # cached by series


# ---- endpoints -----------------------------------------------------------------------


def test_forecast_endpoint_shape(client, shop_id):
    r = client.get(f"/forecast/{shop_id}")
    assert r.status_code == 200, r.text
    body = r.json()
    assert len(body["weeks"]) == 4 and all(date.fromisoformat(w).weekday() == 0 for w in body["weeks"])
    assert {"name", "date"} == set(body["festivals"][0].keys())
    assert body["items"], "the seeded shop should match catalogue items"
    first = body["items"][0]
    assert set(first) == {"item_id", "name", "unit", "history_weekly", "forecast_weekly", "lower",
                          "upper", "on_hand", "reorder_qty", "reorder_reason"}
    for k in ("history_weekly", "forecast_weekly", "lower", "upper"):
        assert len(first[k]) == 4
    assert first["reorder_qty"] >= body["items"][-1]["reorder_qty"]  # sorted by need
    stock_ids = {i["item_id"] for i in client.get(f"/stock/{shop_id}").json()["items"]}
    assert {i["item_id"] for i in body["items"]} <= stock_ids
    assert client.get("/forecast/shp_nope").status_code == 404


def test_reorder_endpoint_builds_text_and_whatsapp_url(client, shop_id):
    r = client.post(f"/reorder/{shop_id}")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["order_id"].startswith("ord_")
    assert body["lines"] and all(l["qty"] > 0 for l in body["lines"])
    assert body["lines"][0]["name"].startswith(body["lines"][0]["name"].split()[0])
    assert body["text"].startswith("Gupta General Store ke liye order:")
    assert f"- {body['lines'][0]['name']}: {body['lines'][0]['qty']} {body['lines'][0]['unit']}" in body["text"]
    assert body["whatsapp_url"].startswith("https://wa.me/?text=")
    assert unquote(body["whatsapp_url"].split("text=", 1)[1]) == body["text"]


def test_summary_counts_the_day_and_falls_back_to_template(client, scripted, shop_id):
    scripted.push(intent="sale", entities={"items": [{"name": "Parle-G", "quantity": 5, "unit": "packet"}]})
    scripted.push(intent="sale", entities={"items": [{"name": "Maggi", "quantity": 2, "unit": "packet"}],
                                            "amount": 30})
    scripted.push(intent="udhaar_given", entities={"customer_name": "Gupta ji", "amount": 350})
    scripted.push(intent="udhaar_paid", entities={"customer_name": "Gupta ji", "amount": 100})
    scripted.push(intent="sale", entities={"items": [{"name": "Nescafe", "quantity": 5, "unit": "piece"}]})
    ids = [client.post("/chat", json={"shop_id": shop_id, "text": "x"}).json()["message_id"]
           for _ in range(5)]
    client.post("/undo", json={"shop_id": shop_id, "message_id": ids[-1]})  # undone: not counted

    r = client.get(f"/summary/{shop_id}")
    assert r.status_code == 200, r.text
    body = r.json()
    from app.service import today_ist
    assert body["date"] == today_ist()
    assert body["sales_total"] == 5 * 10 + 30  # MRP for Parle-G, quoted amount for Maggi
    assert body["entries"] == 4  # two sales + udhaar given + udhaar paid; the undone one is out
    assert body["udhaar_given"] == 350 and body["udhaar_received"] == 100
    assert body["total_outstanding"] == 250
    assert body["low_stock"] == []  # nothing dipped below reorder level
    assert body["reply_text"] == (
        "Aaj ka hisaab: bikri ₹80, 4 entries. Udhaar diya ₹350, wapas aaya ₹100; "
        "total baaki ₹250. Koi item kam nahi hai.")

    scripted.summary_text = "Aaj achha din tha."
    assert client.get(f"/summary/{shop_id}").json()["reply_text"] == "Aaj achha din tha."
    facts = scripted.calls[-1][1]
    assert facts["sales_total"] == 80 and facts["shop_name"] == "Gupta General Store"

    empty = client.get(f"/summary/{shop_id}?date=2026-01-01").json()
    assert empty["sales_total"] == 0 and empty["entries"] == 0
    assert client.get(f"/summary/{shop_id}?date=yesterday").status_code == 400


def test_summary_template_languages():
    facts = {"sales_total": 8450, "entries": 23, "udhaar_given": 350, "udhaar_received": 500,
             "total_outstanding": 4350,
             "low_stock": [{"name": "Maggi", "quantity": "6", "unit": "packet", "reorder_level": "12"}]}
    hi = summary_template(facts, "hi")
    assert hi.startswith("आज का हिसाब: बिक्री ₹8,450, 23 एंट्री।") and "Maggi (6 packet)" in hi
    en = summary_template(facts, "en")
    assert en.startswith("Today's summary: sales ₹8,450 across 23 entries.") and "Low stock: Maggi" in en
    assert summary_template(facts, "hi-Latn").startswith("Aaj ka hisaab: bikri ₹8,450, 23 entries.")


# ---- BigQuery (slow, opt-in) -----------------------------------------------------------


@pytest.mark.slow
def test_bigquery_source_live():
    from app.config import get_settings

    settings = get_settings()  # honours backend/.env
    if settings.forecast_source != "bigquery" or not settings.google_cloud_project:
        pytest.skip("FORECAST_SOURCE=bigquery and GOOGLE_CLOUD_PROJECT needed")
    from app.forecast import BigQueryForecastSource

    src = BigQueryForecastSource(settings.google_cloud_project, settings.bq_dataset,
                                 settings.bq_location)
    try:
        raw = src.load("shp_created_in_app")
    except Exception as exc:
        if "Not found" in str(exc) or "notFound" in str(exc):  # dataset or model not there yet
            pytest.skip(f"BigQuery not ready: {exc}")
        raise
    assert raw.series_shop_id == "shp_demo"
    assert len(raw.catalogue) == 40
    assert raw.forecast and all(len(v) == 35 for v in raw.forecast.values())
    repo, shop, items = shop_items()
    weeks, fests, out = shape_forecast(raw, items, "en")
    assert len(out) == 40 and all(len(i.forecast_weekly) == 4 for i in out)
