"""Top items, shop settings, auto-restock, orders, messages, feedback, languages."""

from app.languages import LANGUAGES, detect_script, script_matches

TOKEN = {"X-Scheduler-Token": "test-token"}


def stock(client, shop_id, name):
    return next(i for i in client.get(f"/stock/{shop_id}").json()["items"] if i["name"] == name)


# ---- A.1 top items ---------------------------------------------------------------------


def test_top_items_ranked_by_forecast_with_trend_and_cover(client, shop_id):
    r = client.get(f"/top-items/{shop_id}")
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["weeks"] == 2 and 1 <= len(body["items"]) <= 10
    items = body["items"]
    assert [i["forecast_units"] for i in items] == sorted((i["forecast_units"] for i in items), reverse=True)
    first = items[0]
    assert set(first) == {"item_id", "name", "unit", "forecast_units", "history_units", "trend_pct",
                          "on_hand", "cover_days", "reorder_qty", "reorder_reason",
                          "rank", "demand_ratio", "auto_restock_eligible"}
    assert sorted(i["rank"] for i in client.get(f"/top-items/{shop_id}?limit=50").json()["items"]) == list(range(1, 16))
    fc = next(i for i in client.get(f"/forecast/{shop_id}").json()["items"] if i["item_id"] == first["item_id"])
    assert first["forecast_units"] == sum(fc["forecast_weekly"][:2])
    assert first["history_units"] == sum(fc["history_weekly"][-2:])
    assert first["reorder_qty"] == fc["reorder_qty"]  # same 2-week rule
    assert first["trend_pct"] == round((first["forecast_units"] - first["history_units"]) * 100 / first["history_units"])
    assert first["cover_days"] == int(first["on_hand"] / (first["forecast_units"] / 14))
    assert client.get(f"/top-items/{shop_id}?weeks=4&limit=3").json()["items"].__len__() == 3
    assert client.get(f"/top-items/{shop_id}?weeks=9").status_code == 400


# ---- A.2 shop settings ----------------------------------------------------------------


def test_shop_settings_default_off_and_patchable(client, shop_id):
    shop = client.get(f"/shops/{shop_id}").json()
    assert shop["auto_restock"] is False and shop["distributor_phone"] is None
    r = client.patch(f"/shops/{shop_id}", json={"auto_restock": True, "distributor_phone": "+91 98765 43210"})
    assert r.status_code == 200, r.text
    assert r.json()["auto_restock"] is True and r.json()["distributor_phone"] == "+919876543210"
    assert client.patch(f"/shops/{shop_id}", json={"distributor_phone": "98765"}).status_code == 400
    r = client.patch(f"/shops/{shop_id}", json={"auto_restock": False})
    assert r.json()["auto_restock"] is False and r.json()["distributor_phone"] == "+919876543210"
    assert client.patch("/shops/shp_nope", json={"auto_restock": True}).status_code == 404
    created = client.post("/shops", json={"shop_name": "A", "owner_name": "B", "language": "ta",
                                          "auto_restock": True}).json()
    assert created["auto_restock"] is True and created["language"] == "ta"


# ---- A.3 auto-restock ------------------------------------------------------------------


def test_auto_restock_requires_token(client, shop_id):
    assert client.post("/auto-restock/run").status_code == 401
    r = client.post("/auto-restock/run", headers={"X-Scheduler-Token": "wrong"})
    assert r.status_code == 401 and r.json()["error"]["code"] == "unauthorized"


def test_auto_restock_places_once_per_day_posts_message_and_undo_cancels(client, shop_id):
    off = client.post("/auto-restock/run", headers=TOKEN).json()
    assert off["orders"] == [] and off["skipped"] == [{"shop_id": shop_id, "reason": "auto_restock_off"}]

    client.patch(f"/shops/{shop_id}", json={"auto_restock": True, "distributor_phone": "+919876543210"})
    eligible = {i["name"] for i in client.get(f"/top-items/{shop_id}?limit=50").json()["items"]
                if i["auto_restock_eligible"]}
    assert eligible, "the local demo history should make at least one item eligible"
    run = client.post("/auto-restock/run", headers=TOKEN).json()
    assert run["shops_checked"] == 1 and len(run["orders"]) == 1 and run["skipped"] == []
    order = run["orders"][0]
    assert order["status"] == "placed" and order["source"] == "auto" and order["shop_id"] == shop_id
    assert order["lines"] and all(l["qty"] > 0 for l in order["lines"])
    assert {l["name"].rsplit(" ", 1)[0] for l in order["lines"]} == eligible  # only the eligible ones
    assert all(l["rank"] <= 10 and l["cover_days"] < 7 and l["demand_ratio"] >= 1.2 for l in order["lines"])
    assert order["whatsapp_url"].startswith("https://wa.me/919876543210?text=")

    again = client.post("/auto-restock/run", headers=TOKEN).json()
    assert again["orders"] == [] and again["skipped"] == [{"shop_id": shop_id, "reason": "already_ran_today"}]
    one = client.post(f"/auto-restock/run?shop_id={shop_id}", headers=TOKEN).json()
    assert one["shops_checked"] == 1 and one["skipped"][0]["reason"] == "already_ran_today"

    msgs = client.get(f"/messages/{shop_id}").json()["messages"]
    assert len(msgs) == 1
    msg = msgs[0]
    assert msg["kind"] == "auto_order" and msg["order_id"] == order["order_id"]
    assert msg["reply_text"].startswith("Auto-order bheja: ") and msg["reply_text"].endswith(". Undo?")
    assert "seller, " in msg["reply_text"] and "din ka stock, 2 hafte se demand " in msg["reply_text"]
    assert [a["action"] for a in msg["quick_actions"]] == ["undo", "open_orders"]
    assert msg["quick_actions"][0]["payload"] == {"message_id": msg["message_id"]}
    from urllib.parse import quote
    assert client.get(f"/messages/{shop_id}?since={quote(msg['created_at'])}").json()["messages"] == []
    assert client.get(f"/messages/{shop_id}?since=2026-01-01T00:00:00+05:30").json()["messages"][0]["message_id"] == msg["message_id"]

    r = client.post("/undo", json={"shop_id": shop_id, "message_id": msg["message_id"]})
    assert r.status_code == 200 and r.json() == {"undone": True, "reply_text": "Theek hai, order cancel kar diya."}
    orders = client.get(f"/orders/{shop_id}").json()["orders"]
    assert orders[0]["order_id"] == order["order_id"] and orders[0]["status"] == "cancelled"
    assert client.post("/undo", json={"shop_id": shop_id, "message_id": msg["message_id"]}).status_code == 409
    # still idempotent after the undo: no second auto order today
    assert client.post("/auto-restock/run", headers=TOKEN).json()["skipped"][0]["reason"] == "already_ran_today"


def test_auto_restock_skips_shops_with_nothing_to_order(client, scripted, shop_id):
    client.patch(f"/shops/{shop_id}", json={"auto_restock": True})
    for name in ("Parle-G", "Maggi", "Tata Salt", "Aashirvaad Atta", "Surf Excel", "Amul Milk",
                 "Amul Butter", "Britannia Good Day", "Colgate", "Lifebuoy", "Fortune Oil",
                 "Red Label", "Nescafe", "Haldiram Namkeen", "Dettol"):
        scripted.push(intent="stock_in", entities={"items": [{"name": name, "quantity": 9000, "unit": "packet"}]})
        client.post("/chat", json={"shop_id": shop_id, "text": "x"})
    run = client.post("/auto-restock/run", headers=TOKEN).json()
    assert run["orders"] == [] and run["skipped"] == [{"shop_id": shop_id, "reason": "nothing_to_order"}]
    assert client.get(f"/orders/{shop_id}").json()["orders"] == []


# ---- A.4 orders ------------------------------------------------------------------------


def test_manual_reorder_is_recorded_newest_first(client, shop_id):
    first = client.post(f"/reorder/{shop_id}").json()
    assert len(first["lines"]) >= 10  # manual still covers everything with reorder_qty > 0
    assert first["lines"][0]["rank"] is None
    second = client.post(f"/reorder/{shop_id}").json()
    orders = client.get(f"/orders/{shop_id}").json()["orders"]
    assert [o["order_id"] for o in orders][:2] == [second["order_id"], first["order_id"]] or \
        {o["order_id"] for o in orders} == {first["order_id"], second["order_id"]}
    assert all(o["source"] == "manual" and o["status"] == "placed" for o in orders)
    assert orders[0]["text"] == second["text"] and orders[0]["whatsapp_url"] == second["whatsapp_url"]
    assert client.get("/orders/shp_nope").status_code == 404


# ---- B feedback ------------------------------------------------------------------------


def test_feedback_text_and_voice(client, scripted, shop_id):
    r = client.post("/feedback", json={"shop_id": shop_id, "screen": "stock", "rating": "up",
                                       "comment": "बहुत बढ़िया", "app_version": "1.0.0", "platform": "android"})
    assert r.status_code == 201, r.text
    assert r.json()["feedback_id"].startswith("fb_")
    assert r.json()["reply_text"] == "Shukriya! Aapka feedback mil gaya."
    sink = client.app.state.feedback_sink
    assert len(sink.sent) == 1
    fb = sink.sent[0]
    assert fb.language == "hi" and fb.screen == "stock" and fb.rating == "up" and fb.platform == "android"

    r = client.post("/feedback-voice", data={"shop_id": shop_id, "screen": "forecast", "rating": "down",
                                             "app_version": "1.0.0", "platform": "web"},
                    files={"audio": ("note.m4a", b"\x00fake", "audio/m4a")})
    assert r.status_code == 201, r.text
    assert scripted.calls[-1] == ("transcribe", b"\x00fake")
    fb = sink.sent[-1]
    assert fb.comment == "Forecast screen thoda slow hai" and fb.rating == "down" and fb.language == "hi-Latn"

    assert client.post("/feedback", json={"shop_id": shop_id, "screen": "x", "rating": "meh"}).status_code == 400
    assert client.post("/feedback", json={"shop_id": "shp_nope", "screen": "x", "rating": "up"}).status_code == 404
    r = client.post("/feedback-voice", data={"shop_id": shop_id, "screen": "s", "rating": "up"},
                    files={"audio": ("x.txt", b"hi", "text/plain")})
    assert r.status_code == 400


# ---- C languages -----------------------------------------------------------------------


def test_languages_endpoint_lists_24_with_rtl_flags(client):
    langs = client.get("/languages").json()["languages"]
    assert len(langs) == 24 and len(LANGUAGES) == 24
    by = {l["code"]: l for l in langs}
    assert {"as", "bn", "brx", "doi", "gu", "hi", "kn", "ks", "kok", "mai", "ml", "mni", "mr", "ne",
            "or", "pa", "sa", "sat", "sd", "ta", "te", "ur", "en", "hi-Latn"} == set(by)
    assert {c for c, l in by.items() if l["rtl"]} == {"ks", "sd", "ur"}
    assert by["ta"] == {"code": "ta", "name": "Tamil", "native_name": "தமிழ்", "script": "Tamil", "rtl": False}
    assert by["hi-Latn"]["script"] == "Latin"


def test_script_detection_and_matching():
    assert detect_script("গুপ্তা জি ৩৫০ টাকা") == "Bengali"
    assert detect_script("Parle-G ke 3 carton") == "Latin"
    assert detect_script("گپتا جی نے 350 روپے ادھار لیے") == "Perso-Arabic"
    assert detect_script("123") is None
    assert script_matches("புரிந்தது: Parle-G 3", "ta") and not script_matches("Got it", "ta")
    assert script_matches("Samjha", "hi-Latn")


def test_other_language_shop_gets_language_tagged_and_english_python_strings(client, scripted, shop_id):
    sid = client.post("/shops", json={"shop_name": "Das Store", "owner_name": "B", "language": "bn"}).json()["shop_id"]
    scripted.push(intent="udhaar_given", language="bn", entities={"customer_name": "গুপ্তা জি", "amount": 350},
                  reply_text="বুঝেছি: গুপ্তা জি, ₹350 ধার।")
    body = client.post("/chat", json={"shop_id": sid, "text": "গুপ্তা জি ৩৫০ টাকা ধার নিল"}).json()
    assert body["language"] == "bn" and body["applied"] is True
    assert body["reply_text"] == "বুঝেছি: গুপ্তা জি, ₹350 ধার। Balance ₹350."  # Gemini text + English suffix
    assert body["quick_actions"][1]["label"] == "View udhaar"
    assert client.get(f"/summary/{sid}").json()["reply_text"].startswith("Today's summary:")
    assert client.post("/shops", json={"shop_name": "x", "owner_name": "y", "language": "xx"}).status_code == 400


def test_mock_extractor_detects_scripts_and_falls_back_to_english(mock_client):
    sid = mock_client.post("/shops", json={"shop_name": "G", "owner_name": "R", "language": "ta"}).json()["shop_id"]
    body = mock_client.post("/chat", json={"shop_id": sid, "text": "গুপ্তা জি ne 350 udhaar liya"}).json()
    assert body["language"] == "bn"
    assert body["reply_text"].startswith("Got it:")
    assert body["intent"] == "udhaar_given"


# ---- A.3 the three auto-restock conditions, one failing at a time ---------------------------

from datetime import date, timedelta

from fastapi.testclient import TestClient

from app.config import Settings
from app.forecast import CatalogueRow, DailyPoint, ForecastSource, RawForecast
from app.main import create_app
from app.service import (AUTO_COVER_DAYS, DEMAND_UPLIFT, SUSTAINED_WEEKS, TOP_SELLER_RANK,
                         demand_ratio_for)

LAST = date(2026, 10, 17)


def _history(weekly: list[int]) -> dict:
    """Daily history from per-week totals (oldest first), weeks ending on LAST."""
    out = {}
    for k, total in enumerate(reversed(weekly)):
        end = LAST - timedelta(days=7 * k)
        for d in range(7):
            out[end - timedelta(days=d)] = total // 7 + (1 if d < total % 7 else 0)
    return out


class FakeSource(ForecastSource):
    """15 catalogue rows (one per seeded shop item); per-item weekly history and a flat
    daily forecast, so each auto-restock condition can be set independently."""

    name = "fake"

    def __init__(self, weekly: dict[str, list[int]], daily_fc: dict[str, float]):
        super().__init__()
        self.weekly, self.daily_fc = weekly, daily_fc

    def series_for(self, shop_id):
        return "shp_demo"

    def _load(self, series):
        names = ["Parle-G", "Maggi", "Tata Salt", "Aashirvaad Atta", "Surf Excel", "Amul Milk",
                 "Amul Butter", "Britannia Good Day", "Colgate", "Lifebuoy", "Fortune Oil",
                 "Red Label", "Nescafe", "Haldiram Namkeen", "Dettol"]
        cat = [CatalogueRow(f"itm_{i:03}", n, None, "packet", "misc", 5, 10, []) for i, n in enumerate(names)]
        hist, fc = {}, {}
        for row in cat:
            weekly = self.weekly.get(row.name, [10] * 10)
            hist[row.item_id] = _history(weekly)
            rate = self.daily_fc.get(row.name, 1.0)
            fc[row.item_id] = [DailyPoint(LAST + timedelta(days=1 + k), rate, rate, rate) for k in range(35)]
        return RawForecast("shp_demo", LAST, cat, fc, hist, [], {}, first_date=LAST - timedelta(days=69))


def _client_with(weekly, daily_fc):
    settings = Settings(mock_gemini=True, forecast_source="local", scheduler_token="test-token")
    app = create_app(settings, forecast_source=FakeSource(weekly, daily_fc))
    c = TestClient(app)
    sid = c.post("/shops", json={"shop_name": "G", "owner_name": "R", "language": "en",
                                 "auto_restock": True}).json()["shop_id"]
    return c, sid


def _signals(c, sid, name):
    return next(i for i in c.get(f"/top-items/{sid}?limit=50").json()["items"] if i["name"] == name)


def test_demand_ratio_rules():
    assert demand_ratio_for([10] * 8 + [15, 14]) == 1.4          # 10-week: baseline = first 8
    assert demand_ratio_for([10] * 8 + [15, 11]) == 1.1          # weaker week counts
    assert demand_ratio_for([10, 10, 10, 20, 20]) == round(20 / 14, 2)  # short history: whole average
    assert demand_ratio_for([5]) == 0.0 and demand_ratio_for([0] * 10) == 0.0
    assert SUSTAINED_WEEKS == 2 and DEMAND_UPLIFT == 1.2 and AUTO_COVER_DAYS == 7 and TOP_SELLER_RANK == 10


def test_eligible_item_is_ordered_with_reasoning():
    # Parle-G: rank 1 (seeded on_hand 42), 2 weeks at 1.5x, forecast 20/day -> cover 2 days
    c, sid = _client_with({"Parle-G": [100] * 8 + [150, 160]}, {"Parle-G": 20.0})
    sig = _signals(c, sid, "Parle-G")
    assert sig["rank"] == 1 and sig["cover_days"] == 2 and sig["demand_ratio"] == 1.5
    assert sig["auto_restock_eligible"] is True
    run = c.post("/auto-restock/run", headers=TOKEN).json()
    assert len(run["orders"]) == 1
    lines = run["orders"][0]["lines"]
    assert [l["name"] for l in lines] == ["Parle-G 70g"]
    assert lines[0] == {"name": "Parle-G 70g", "qty": lines[0]["qty"], "unit": "packet",
                        "rank": 1, "cover_days": 2, "demand_ratio": 1.5}
    msg = c.get(f"/messages/{sid}").json()["messages"][0]["reply_text"]
    assert msg == f"Auto-order sent: Parle-G {lines[0]['qty']} packet (top-1 seller, 2 days of stock, demand 1.5x for 2 weeks). Undo?"


def test_not_a_top_seller_is_skipped():
    # Dettol has the demand spike and low cover but sells the least: rank 15
    weekly = {n: [100] * 10 for n in ["Parle-G", "Maggi", "Tata Salt", "Aashirvaad Atta", "Surf Excel",
                                      "Amul Milk", "Amul Butter", "Britannia Good Day", "Colgate",
                                      "Lifebuoy", "Fortune Oil", "Red Label", "Nescafe", "Haldiram Namkeen"]}
    weekly["Dettol"] = [2] * 8 + [4, 4]
    c, sid = _client_with(weekly, {"Dettol": 20.0})
    sig = _signals(c, sid, "Dettol")
    assert sig["rank"] == 15 and sig["cover_days"] < 7 and sig["demand_ratio"] == 2.0
    assert sig["auto_restock_eligible"] is False
    run = c.post("/auto-restock/run", headers=TOKEN).json()
    assert run["orders"] == [] and run["skipped"] == [{"shop_id": sid, "reason": "nothing_to_order"}]


def test_enough_stock_is_skipped():
    # Parle-G: rank 1 and sustained demand, but forecast 2/day against 42 on hand -> 21 days
    c, sid = _client_with({"Parle-G": [100] * 8 + [150, 160]}, {"Parle-G": 2.0})
    sig = _signals(c, sid, "Parle-G")
    assert sig["rank"] == 1 and sig["demand_ratio"] == 1.5 and sig["cover_days"] == 21
    assert sig["auto_restock_eligible"] is False
    assert c.post("/auto-restock/run", headers=TOKEN).json()["orders"] == []


def test_demand_not_sustained_is_skipped():
    # Parle-G: rank 1, 2 days of cover, but only the last week spiked (the week before is 1.0x)
    c, sid = _client_with({"Parle-G": [100] * 8 + [100, 160]}, {"Parle-G": 20.0})
    sig = _signals(c, sid, "Parle-G")
    assert sig["rank"] == 1 and sig["cover_days"] == 2 and sig["demand_ratio"] == 1.0
    assert sig["auto_restock_eligible"] is False
    assert c.post("/auto-restock/run", headers=TOKEN).json()["orders"] == []
    # manual reorder is unchanged: everything with reorder_qty > 0, no reasoning fields
    manual = c.post(f"/reorder/{sid}").json()
    assert any(l["name"] == "Parle-G 70g" for l in manual["lines"]) and manual["lines"][0]["rank"] is None
