"""Apply / confirm / undo and ledger totals, with Gemini scripted."""


def chat(client, shop_id, text="x"):
    r = client.post("/chat", json={"shop_id": shop_id, "text": text})
    assert r.status_code == 200, r.text
    return r.json()


def test_healthz(client):
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["ok"] is True
    assert r.json()["model"]


def test_shop_is_seeded_with_catalogue(client, shop_id):
    items = client.get(f"/stock/{shop_id}").json()["items"]
    assert len(items) == 15
    names = {i["name"] for i in items}
    assert {"Parle-G", "Maggi", "Tata Salt", "Dettol"} <= names
    assert all({"item_id", "quantity", "reorder_level", "low_stock", "updated_at"} <= i.keys()
               for i in items)


def test_udhaar_given_applies_and_quotes_total(client, scripted, shop_id):
    scripted.push(intent="udhaar_given", confidence=0.93,
                  entities={"customer_name": "Gupta ji", "amount": 350},
                  reply_text="Samjha: Gupta ji, ₹350 udhaar.")
    reply = chat(client, shop_id, "Gupta ji ne 350 rupaye udhaar liya")
    assert reply["intent"] == "udhaar_given"
    assert reply["applied"] is True
    assert reply["entities"]["customer_name"] == "Gupta ji"
    assert reply["entities"]["amount"] == 350
    assert reply["entities"]["items"] == []
    assert "₹350" in reply["reply_text"]
    assert reply["quick_actions"][0] == {"label": "Undo", "action": "undo",
                                         "payload": {"message_id": reply["message_id"]}}
    assert {a["action"] for a in reply["quick_actions"]} == {"undo", "open_udhaar"}

    ledger = client.get(f"/ledger/{shop_id}").json()
    assert ledger["total_outstanding"] == 350
    assert ledger["customers"][0]["customer_name"] == "Gupta ji"
    assert ledger["customers"][0]["balance"] == 350


def test_ledger_totals_across_customers_and_payments(client, scripted, shop_id):
    scripted.push(intent="udhaar_given", entities={"customer_name": "Gupta ji", "amount": 1200})
    scripted.push(intent="udhaar_given", entities={"customer_name": "Sharma aunty", "amount": 500})
    scripted.push(intent="udhaar_paid", entities={"customer_name": "gupta ji", "amount": 350})
    for _ in range(3):
        chat(client, shop_id)
    ledger = client.get(f"/ledger/{shop_id}").json()
    by = {c["customer_name"]: c["balance"] for c in ledger["customers"]}
    assert by == {"Gupta ji": 850, "Sharma aunty": 500}
    assert ledger["total_outstanding"] == 1350


def test_stock_in_fuzzy_matches_and_updates_stock(client, scripted, shop_id):
    scripted.push(intent="stock_in", confidence=0.9,
                  entities={"items": [{"name": "parle ji", "quantity": 3, "unit": "carton"}]},
                  reply_text="Samjha: Parle G, 3 carton add kiya.")
    reply = chat(client, shop_id, "parle ji ke 3 carton aaye")
    assert reply["applied"] is True
    assert reply["entities"]["items"][0]["name"] == "Parle-G"
    assert reply["entities"]["items"][0]["pack_size"] == "70g"
    parle = next(i for i in client.get(f"/stock/{shop_id}").json()["items"] if i["name"] == "Parle-G")
    assert parle["quantity"] == 42 + 3 * 24  # cartons converted to packets
    assert "114 packet" in reply["reply_text"]


def test_sale_reduces_stock_and_flags_low_stock(client, scripted, shop_id):
    scripted.push(intent="sale", entities={"items": [{"name": "Nescafe", "quantity": 5, "unit": "piece"}]})
    chat(client, shop_id)
    nescafe = next(i for i in client.get(f"/stock/{shop_id}").json()["items"] if i["name"] == "Nescafe")
    assert nescafe["quantity"] == 1
    assert nescafe["low_stock"] is True


def test_low_confidence_holds_until_confirm(client, scripted, shop_id):
    scripted.push(intent="stock_in", confidence=0.55,
                  entities={"items": [{"name": "Maggi", "quantity": 5, "unit": "packet"}]},
                  reply_text="Samjha: Maggi 5 packet?")
    reply = chat(client, shop_id, "shayad 5 maggi aaye")
    assert reply["applied"] is False
    assert reply["quick_actions"] == [{"label": "Haan, add karo", "action": "confirm",
                                       "payload": {"message_id": reply["message_id"]}}]
    maggi = next(i for i in client.get(f"/stock/{shop_id}").json()["items"] if i["name"] == "Maggi")
    assert maggi["quantity"] == 30  # untouched

    r = client.post("/confirm", json={"shop_id": shop_id, "message_id": reply["message_id"]})
    assert r.status_code == 200, r.text
    confirmed = r.json()
    assert confirmed["applied"] is True
    assert confirmed["message_id"] == reply["message_id"]
    assert confirmed["quick_actions"][0]["action"] == "undo"
    maggi = next(i for i in client.get(f"/stock/{shop_id}").json()["items"] if i["name"] == "Maggi")
    assert maggi["quantity"] == 35

    # confirming twice is a 404
    r = client.post("/confirm", json={"shop_id": shop_id, "message_id": reply["message_id"]})
    assert r.status_code == 404
    assert r.json()["error"]["code"] == "not_found"


def test_question_and_unclear_never_write(client, scripted, shop_id):
    scripted.push(intent="question", entities={"items": [{"name": "Tata Salt"}]},
                  reply_text="Tata Salt 20 packet hai.")
    scripted.push(intent="unclear", confidence=0.3, reply_text="Kaunsa item?")
    q = chat(client, shop_id, "tata salt kitna hai?")
    u = chat(client, shop_id, "wo wala do")
    assert q["applied"] is False and q["quick_actions"] == []
    assert u["applied"] is False and u["quick_actions"] == []
    assert u["entities"] == {"items": [], "customer_name": None, "amount": None, "date": None}
    assert client.get(f"/ledger/{shop_id}").json()["total_outstanding"] == 0


def test_undo_reverses_ledger_and_stock_then_expires(client, scripted, shop_id):
    scripted.push(intent="udhaar_given", entities={"customer_name": "Gupta ji", "amount": 1200})
    scripted.push(intent="udhaar_given", entities={"customer_name": "Gupta ji", "amount": 350})
    chat(client, shop_id)
    second = chat(client, shop_id)
    r = client.post("/undo", json={"shop_id": shop_id, "message_id": second["message_id"]})
    assert r.status_code == 200, r.text
    assert r.json()["undone"] is True
    assert "₹1,200" in r.json()["reply_text"]
    assert client.get(f"/ledger/{shop_id}").json()["total_outstanding"] == 1200

    r = client.post("/undo", json={"shop_id": shop_id, "message_id": second["message_id"]})
    assert r.status_code == 409
    assert r.json()["error"]["code"] == "undo_expired"

    scripted.push(intent="stock_in", entities={"items": [{"name": "Dettol", "quantity": 4, "unit": "piece"}]})
    s = chat(client, shop_id)
    client.post("/undo", json={"shop_id": shop_id, "message_id": s["message_id"]})
    dettol = next(i for i in client.get(f"/stock/{shop_id}").json()["items"] if i["name"] == "Dettol")
    assert dettol["quantity"] == 11


def test_undo_window_is_last_ten(client, scripted, shop_id):
    ids = []
    for _ in range(11):
        scripted.push(intent="udhaar_given", entities={"customer_name": "X", "amount": 10})
        ids.append(chat(client, shop_id)["message_id"])
    assert client.post("/undo", json={"shop_id": shop_id, "message_id": ids[0]}).status_code == 409
    assert client.post("/undo", json={"shop_id": shop_id, "message_id": ids[1]}).status_code == 200


def test_voice_note_sends_bytes_inline(client, scripted, shop_id):
    scripted.push(intent="udhaar_given", transcript="Gupta ji ne 350 rupaye udhaar liya",
                  entities={"customer_name": "Gupta ji", "amount": 350})
    r = client.post("/voice-note", data={"shop_id": shop_id},
                    files={"audio": ("note.m4a", b"\x00\x00fake", "audio/m4a")})
    assert r.status_code == 200, r.text
    assert r.json()["transcript"] == "Gupta ji ne 350 rupaye udhaar liya"
    assert scripted.calls[-1] == (None, b"\x00\x00fake")

    r = client.post("/voice-note", data={"shop_id": shop_id},
                    files={"audio": ("x.txt", b"hi", "text/plain")})
    assert r.status_code == 400 and r.json()["error"]["code"] == "invalid"


def test_errors_follow_contract(client):
    assert client.get("/stock/shp_nope").json() == {
        "error": {"code": "not_found", "message": "shop shp_nope not found"}}
    assert client.post("/chat", json={"shop_id": "x"}).status_code == 400
    assert client.get("/forecast/shp_nope").status_code == 404
    assert client.post("/reorder/shp_nope").status_code == 404
    assert client.get("/summary/shp_nope?date=2026-10-18").status_code == 404


def test_mock_extractor_handles_the_demo_sentence(mock_client):
    sid = mock_client.post("/shops", json={"shop_name": "G", "owner_name": "R",
                                           "language": "hi-Latn"}).json()["shop_id"]
    r = mock_client.post("/chat", json={"shop_id": sid, "text": "Gupta ji ne 350 rupaye udhaar liya"})
    body = r.json()
    assert body["intent"] == "udhaar_given" and body["applied"] is True
    assert body["entities"] == {"items": [], "customer_name": "Gupta ji", "amount": 350, "date": None}
    assert body["language"] == "hi-Latn"
