"""POST /shelf-scan: hold → confirm sets absolute stock → undo restores."""


def qty(client, shop_id, *names):
    items = client.get(f"/stock/{shop_id}").json()["items"]
    return {i["name"]: i["quantity"] for i in items if i["name"] in names}


def scan(client, shop_id, mime="image/jpeg", data=b"\xff\xd8\xff fake"):
    return client.post("/shelf-scan", data={"shop_id": shop_id},
                       files={"image": ("shelf.jpg", data, mime)})


def test_shelf_scan_holds_then_confirm_sets_absolute_stock(client, scripted, shop_id):
    scripted.push_scan([("maggie", 6, 0.9), ("Parle G", 12, 0.85), ("tata namak", 3, 0.8)],
                       reply_text="Shelf pe dikha: Maggi 6, Parle-G 12, Tata Salt 3.")
    r = scan(client, shop_id)
    assert r.status_code == 200, r.text
    body = r.json()
    assert scripted.calls[-1] == (None, b"\xff\xd8\xff fake")  # bytes sent inline
    assert [i["name"] for i in body["items"]] == ["Maggi", "Parle-G", "Tata Salt"]
    assert body["items"][0] == {"name": "Maggi", "pack_size": "70g", "count": 6, "confidence": 0.9}
    assert body["low_stock"] == [
        {"name": "Maggi", "count": 6, "reorder_level": 12.0},
        {"name": "Parle-G", "count": 12, "reorder_level": 24.0},
        {"name": "Tata Salt", "count": 3, "reorder_level": 10.0},
    ]
    assert body["reply_text"].startswith("Shelf pe dikha: Maggi 6, Parle-G 12, Tata Salt 3.")
    assert "Maggi kam hai (reorder 12)" in body["reply_text"]
    assert body["reply_text"].endswith("Update karoon?")
    assert body["quick_actions"] == [{"label": "Haan, update karo", "action": "confirm",
                                      "payload": {"message_id": body["message_id"]}}]
    assert qty(client, shop_id, "Maggi", "Parle-G", "Tata Salt") == {
        "Maggi": 30, "Parle-G": 42, "Tata Salt": 20}  # nothing written yet

    r = client.post("/confirm", json={"shop_id": shop_id, "message_id": body["message_id"]})
    assert r.status_code == 200, r.text
    conf = r.json()
    assert conf["applied"] is True and conf["intent"] == "stock_in"
    assert conf["message_id"] == body["message_id"]
    assert conf["reply_text"] == "Stock update kiya: Maggi 6 packet, Parle-G 12 packet, Tata Salt 3 packet."
    assert conf["quick_actions"][0] == {"label": "Undo", "action": "undo",
                                        "payload": {"message_id": body["message_id"]}}
    assert {i["name"]: i["quantity"] for i in conf["entities"]["items"]} == {
        "Maggi": 6, "Parle-G": 12, "Tata Salt": 3}
    assert qty(client, shop_id, "Maggi", "Parle-G", "Tata Salt") == {
        "Maggi": 6, "Parle-G": 12, "Tata Salt": 3}  # absolute set, not an add

    r = client.post("/undo", json={"shop_id": shop_id, "message_id": body["message_id"]})
    assert r.status_code == 200, r.text
    assert r.json()["undone"] is True
    assert qty(client, shop_id, "Maggi", "Parle-G", "Tata Salt") == {
        "Maggi": 30, "Parle-G": 42, "Tata Salt": 20}  # previous quantities restored
    assert client.post("/confirm", json={"shop_id": shop_id,
                                         "message_id": body["message_id"]}).status_code == 404


def test_shelf_scan_merges_duplicates_and_reports_unknown_products_as_unmatched(client, scripted, shop_id):
    scripted.push_scan([("Maggi", 4, 0.9), ("maggi noodles", 2, 0.7), ("Kurkure", 5, 0.8)])
    body = scan(client, shop_id).json()
    by = {i["name"]: i for i in body["items"]}
    assert set(by) == {"Maggi"}
    assert by["Maggi"]["count"] == 6 and by["Maggi"]["confidence"] == 0.7
    assert body["unmatched"] == [{"name": "Kurkure", "count": 5}]  # extra data, never stock
    client.post("/confirm", json={"shop_id": shop_id, "message_id": body["message_id"]})
    stock = {i["name"]: i["quantity"] for i in client.get(f"/stock/{shop_id}").json()["items"]}
    assert stock["Maggi"] == 6 and "Kurkure" not in stock


def test_shelf_scan_with_nothing_seen_has_no_confirm(client, scripted, shop_id):
    scripted.push_scan([], reply_text="")
    body = scan(client, shop_id).json()
    assert body["items"] == [] and body["low_stock"] == [] and body["quick_actions"] == []
    assert body["reply_text"] == "Shelf pe koi item nahi dikha."


def test_shelf_scan_rejects_bad_images(client, scripted, shop_id):
    r = scan(client, shop_id, mime="image/gif")
    assert r.status_code == 400 and r.json()["error"]["code"] == "invalid"
    r = scan(client, shop_id, data=b"")
    assert r.status_code == 400
    r = scan(client, shop_id, data=b"x" * (8 * 1024 * 1024 + 1))
    assert r.status_code == 400 and "8 MB" in r.json()["error"]["message"]
    assert scripted.calls == []


def test_mock_extractor_shelf_scan(mock_client):
    sid = mock_client.post("/shops", json={"shop_name": "G", "owner_name": "R",
                                           "language": "hi"}).json()["shop_id"]
    body = mock_client.post("/shelf-scan", data={"shop_id": sid},
                            files={"image": ("s.png", b"\x89PNG", "image/png")}).json()
    assert [i["count"] for i in body["items"]] == [6, 12, 3]
    assert body["unmatched"] == [{"name": "Kurkure", "count": 4}]
    assert body["reply_text"].startswith("शेल्फ पर दिखा:")
    assert body["quick_actions"][0]["label"] == "हाँ, अपडेट करो"
