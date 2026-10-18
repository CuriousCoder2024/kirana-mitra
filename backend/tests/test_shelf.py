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


def test_shelf_scan_merges_duplicates_and_snaps_to_the_full_catalogue(client, scripted, shop_id):
    scripted.push_scan([("Maggi", 4, 0.9), ("maggi noodles", 2, 0.7), ("Kurkure", 5, 0.8)])
    body = scan(client, shop_id).json()
    by = {i["name"]: i for i in body["items"]}
    assert set(by) == {"Maggi", "Kurkure Masala Munch"}  # Kurkure is in the 40-item catalogue
    assert by["Maggi"]["count"] == 6 and by["Maggi"]["confidence"] == 0.7
    assert body["unmatched"] == []
    assert [a["action"] for a in body["quick_actions"]] == ["confirm"]
    client.post("/confirm", json={"shop_id": shop_id, "message_id": body["message_id"]})
    stock = {i["name"]: i["quantity"] for i in client.get(f"/stock/{shop_id}").json()["items"]}
    assert stock["Maggi"] == 6 and stock["Kurkure Masala Munch"] == 5


def test_shelf_scan_offers_to_add_unmatched_products_and_confirm_creates_them(client, scripted, shop_id):
    from app.models import UnmatchedProduct
    s = scripted.push_scan([], reply_text="No catalogue items found on the shelf.")
    s.unmatched = [UnmatchedProduct(name="Complan", count=14), UnmatchedProduct(name="Boost", count=5)]
    body = scan(client, shop_id).json()
    assert body["items"] == [] and body["unmatched"] == [{"name": "Complan", "count": 14}, {"name": "Boost", "count": 5}]
    assert body["reply_text"] == ("Shelf pe dikha: Complan 14, Boost 5. Ye catalogue mein nahi hain. "
                                  "Naye item add karke stock set karoon?")
    assert body["quick_actions"] == [
        {"label": "Haan, add karo", "action": "confirm", "payload": {"message_id": body["message_id"]}},
        {"label": "Nahi", "action": "dismiss", "payload": {"message_id": body["message_id"]}},
    ]
    before = len(client.get(f"/stock/{shop_id}").json()["items"])
    r = client.post("/confirm", json={"shop_id": shop_id, "message_id": body["message_id"]})
    assert r.status_code == 200, r.text
    assert r.json()["applied"] is True
    assert {i["name"]: i["quantity"] for i in r.json()["entities"]["items"]} == {"Complan": 14, "Boost": 5}
    stock = {i["name"]: i for i in client.get(f"/stock/{shop_id}").json()["items"]}
    assert len(stock) == before + 2
    assert stock["Complan"]["quantity"] == 14 and stock["Complan"]["unit"] == "packet" and stock["Complan"]["reorder_level"] == 6
    assert stock["Boost"]["quantity"] == 5
    # undoable: quantities go back to 0
    client.post("/undo", json={"shop_id": shop_id, "message_id": body["message_id"]})
    stock = {i["name"]: i["quantity"] for i in client.get(f"/stock/{shop_id}").json()["items"]}
    assert stock["Complan"] == 0 and stock["Boost"] == 0


def test_shelf_scan_mixed_matched_and_unmatched_in_english(client, scripted):
    from app.models import UnmatchedProduct
    sid = client.post("/shops", json={"shop_name": "S", "owner_name": "O", "language": "en"}).json()["shop_id"]
    s = scripted.push_scan([("Maggi", 6, 0.9)], reply_text="On the shelf: Maggi 6.")
    s.unmatched = [UnmatchedProduct(name="Pringles", count=3)]
    body = scan(client, sid).json()
    assert body["reply_text"] == ("On the shelf: Maggi 6. Maggi is low (reorder 12). Pringles 3: "
                                  "These are not in your catalogue yet. Add them and set stock?")
    assert [a["label"] for a in body["quick_actions"]] == ["Yes, add", "No"]
    client.post("/confirm", json={"shop_id": sid, "message_id": body["message_id"]})
    stock = {i["name"]: i["quantity"] for i in client.get(f"/stock/{sid}").json()["items"]}
    assert stock["Maggi"] == 6 and stock["Pringles"] == 3


def test_shelf_scan_with_nothing_seen_asks_for_a_closer_photo(client, scripted, shop_id):
    scripted.push_scan([], reply_text="")
    body = scan(client, shop_id).json()
    assert body["items"] == [] and body["low_stock"] == [] and body["quick_actions"] == [] and body["unmatched"] == []
    assert body["reply_text"] == "Shelf pe koi product samajh nahi aaya, thoda paas se photo lo."
    assert client.post("/confirm", json={"shop_id": shop_id, "message_id": body["message_id"]}).status_code == 404


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
    assert [i["count"] for i in body["items"]] == [6, 12, 3, 4]  # mock's "Kurkure" snaps to the catalogue
    assert body["items"][3]["name"] == "Kurkure Masala Munch" and body["unmatched"] == []
    assert [a["action"] for a in body["quick_actions"]] == ["confirm"]
    assert body["reply_text"].startswith("शेल्फ पर दिखा:")
    assert body["quick_actions"][0]["label"] == "हाँ, अपडेट करो"
