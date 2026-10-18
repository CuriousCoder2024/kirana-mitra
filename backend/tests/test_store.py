"""Repository contract, run against every implementation the `repo` fixture offers
(memory always; Firestore with FIRESTORE_EMULATOR_HOST or FIRESTORE_INTEGRATION=1)."""

from app.store import AppliedMessage, BotMessageRecord, FeedbackRecord, OrderRecord, StockMove, now_iso


def make_shop(repo, language="hi-Latn"):
    return repo.create_shop("Gupta General Store", "Ramesh Gupta", language)


def test_create_shop_seeds_catalogue_and_defaults(repo):
    shop = make_shop(repo)
    assert shop.shop_id.startswith("shp_") and shop.auto_restock is False and shop.distributor_phone is None
    assert shop.created_at.endswith("+05:30")
    got = repo.get_shop(shop.shop_id)
    assert got is not None and got.shop_name == "Gupta General Store" and got.language == "hi-Latn"
    items = repo.list_items(shop.shop_id)
    assert len(items) == 40
    parle = next(i for i in items if i.name == "Parle-G")
    assert parle.quantity == 42 and parle.reorder_level == 24 and parle.carton_size == 24 and parle.price == 10
    assert "parle ji" in parle.aliases
    assert repo.get_item(shop.shop_id, parle.item_id).name == "Parle-G"
    assert repo.get_shop("shp_nope") is None
    assert any(s.shop_id == shop.shop_id for s in repo.list_shops())


def test_update_shop_settings(repo):
    shop = make_shop(repo)
    updated = repo.update_shop(shop.shop_id, auto_restock=True, distributor_phone="+919876543210")
    assert updated.auto_restock is True and updated.distributor_phone == "+919876543210"
    again = repo.get_shop(shop.shop_id)
    assert again.auto_restock is True and again.distributor_phone == "+919876543210"
    assert repo.update_shop(shop.shop_id, language="ta").language == "ta"


def test_stock_adjustments_clamp_at_zero_and_touch_updated_at(repo):
    shop = make_shop(repo)
    nescafe = next(i for i in repo.list_items(shop.shop_id) if i.name == "Nescafe")  # 6 on hand
    assert repo.adjust_stock(shop.shop_id, nescafe.item_id, 4).quantity == 10
    assert repo.adjust_stock(shop.shop_id, nescafe.item_id, -25).quantity == 0
    new = repo.add_item(shop.shop_id, "Kurkure", "90g", "packet", reorder_level=5)
    assert new.quantity == 0 and repo.get_item(shop.shop_id, new.item_id).name == "Kurkure"
    assert len(repo.list_items(shop.shop_id)) == 41


def test_ledger_balances_and_customer_names(repo):
    shop = make_shop(repo)
    e1 = repo.add_ledger_entry(shop.shop_id, "Gupta ji", 1200, "udhaar_given", "msg_1")
    repo.add_ledger_entry(shop.shop_id, "gupta ji", -350, "udhaar_paid", "msg_2")
    repo.add_ledger_entry(shop.shop_id, "Sharma aunty", 500, "udhaar_given", "msg_3")
    assert repo.customer_balance(shop.shop_id, "Gupta ji") == 850
    assert repo.customer_balance(shop.shop_id, "GUPTA JI") == 850
    assert sorted(repo.customer_names(shop.shop_id)) == ["Gupta ji", "Sharma aunty"]
    assert len(repo.list_ledger(shop.shop_id)) == 3
    repo.remove_ledger_entry(shop.shop_id, e1.entry_id)
    assert repo.customer_balance(shop.shop_id, "Gupta ji") == -350


def test_undo_window_keeps_last_ten_and_pops_once(repo):
    shop = make_shop(repo)
    ids = []
    for i in range(11):
        mid = f"msg_{i:02}"
        repo.record_applied(AppliedMessage(message_id=mid, shop_id=shop.shop_id, intent="udhaar_given",
                                           ledger_entry_ids=[f"led_{i}"], at=now_iso()))
        ids.append(mid)
    assert repo.pop_applied(shop.shop_id, ids[0]) is None  # fell out of the window of 10
    popped = repo.pop_applied(shop.shop_id, ids[5])
    assert popped is not None and popped.ledger_entry_ids == ["led_5"] and popped.intent == "udhaar_given"
    assert repo.pop_applied(shop.shop_id, ids[5]) is None  # second tap gets nothing
    assert repo.pop_applied(shop.shop_id, "msg_unknown") is None


def test_applied_journal_by_day_excludes_undone(repo):
    shop = make_shop(repo)
    today = now_iso()[:10]
    parle = next(i for i in repo.list_items(shop.shop_id) if i.name == "Parle-G")
    repo.record_applied(AppliedMessage(message_id="msg_a", shop_id=shop.shop_id, intent="sale",
                                       stock_moves=[StockMove(parle.item_id, -5)], sale_amount=None))
    repo.record_applied(AppliedMessage(message_id="msg_b", shop_id=shop.shop_id, intent="sale",
                                       stock_moves=[StockMove(parle.item_id, -2)], sale_amount=30))
    repo.record_applied(AppliedMessage(message_id="msg_c", shop_id=shop.shop_id, intent="udhaar_given",
                                       ledger_entry_ids=["led_x"], order_id=None))
    assert {m.message_id for m in repo.list_applied_on(shop.shop_id, today)} == {"msg_a", "msg_b", "msg_c"}
    got_b = next(m for m in repo.list_applied_on(shop.shop_id, today) if m.message_id == "msg_b")
    assert got_b.sale_amount == 30 and got_b.stock_moves[0].item_id == parle.item_id and got_b.stock_moves[0].delta == -2
    repo.pop_applied(shop.shop_id, "msg_b")
    assert {m.message_id for m in repo.list_applied_on(shop.shop_id, today)} == {"msg_a", "msg_c"}
    assert repo.list_applied_on(shop.shop_id, "2020-01-01") == []


def test_pending_is_taken_once(repo):
    shop = make_shop(repo)
    payload = {"intent": "stock_in", "confidence": 0.5, "language": "hi-Latn", "reply_text": "x",
               "entities": {"items": [{"name": "Maggi", "quantity": 5, "unit": "packet"}],
                            "customer_name": None, "amount": None, "date": None}}
    repo.put_pending(shop.shop_id, "msg_p", payload)
    assert repo.pop_pending(shop.shop_id, "msg_p") == payload
    assert repo.pop_pending(shop.shop_id, "msg_p") is None
    repo.put_pending(shop.shop_id, "msg_s", {"kind": "shelf_scan", "scan": {"items": [], "unmatched": [],
                                                                            "reply_text": ""}})
    assert repo.pop_pending(shop.shop_id, "msg_s")["kind"] == "shelf_scan"


def test_orders_newest_first_and_status(repo):
    shop = make_shop(repo)
    first = OrderRecord("ord_1", shop.shop_id, "2026-10-18T09:00:00+05:30", "placed", "manual",
                        [{"name": "Parle-G 70g", "qty": 24, "unit": "packet"}], "t1", "https://wa.me/?text=t1")
    second = OrderRecord("ord_2", shop.shop_id, "2026-10-18T10:00:00+05:30", "placed", "auto",
                         [{"name": "Maggi 70g", "qty": 48, "unit": "packet", "rank": 1, "cover_days": 2,
                           "demand_ratio": 1.4}], "t2", "https://wa.me/?text=t2")
    repo.add_order(first)
    repo.add_order(second)
    orders = repo.list_orders(shop.shop_id)
    assert [o.order_id for o in orders] == ["ord_2", "ord_1"]
    assert orders[0].lines[0]["rank"] == 1 and orders[0].created_at == "2026-10-18T10:00:00+05:30"
    assert repo.set_order_status(shop.shop_id, "ord_2", "cancelled").status == "cancelled"
    assert repo.get_order(shop.shop_id, "ord_2").status == "cancelled"
    assert repo.get_order(shop.shop_id, "ord_nope") is None


def test_bot_messages_since_and_limit(repo):
    shop = make_shop(repo)
    for i in range(3):
        repo.add_bot_message(BotMessageRecord(message_id=f"msg_bot{i}", shop_id=shop.shop_id,
                                              created_at=f"2026-10-18T1{i}:00:00+05:30", kind="auto_order",
                                              reply_text=f"order {i}",
                                              quick_actions=[{"label": "Undo", "action": "undo",
                                                              "payload": {"message_id": f"msg_bot{i}"}}],
                                              order_id=f"ord_{i}"))
    msgs = repo.list_bot_messages(shop.shop_id)
    assert [m.message_id for m in msgs] == ["msg_bot2", "msg_bot1", "msg_bot0"]
    assert msgs[0].quick_actions[0]["payload"] == {"message_id": "msg_bot2"} and msgs[0].order_id == "ord_2"
    assert [m.message_id for m in repo.list_bot_messages(shop.shop_id, since="2026-10-18T10:00:00+05:30")] == ["msg_bot2", "msg_bot1"]
    assert len(repo.list_bot_messages(shop.shop_id, limit=1)) == 1


def test_feedback_round_trip(repo):
    shop = make_shop(repo)
    repo.add_feedback(FeedbackRecord("fb_1", shop.shop_id, "stock", "up", "badhiya", "hi-Latn", "1.0.0",
                                     "android", now_iso()))
    fbs = repo.list_feedback(shop.shop_id)
    assert len(fbs) == 1 and fbs[0].feedback_id == "fb_1" and fbs[0].comment == "badhiya" and fbs[0].platform == "android"
