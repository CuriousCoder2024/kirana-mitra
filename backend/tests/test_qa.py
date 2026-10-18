"""Fixes from docs/qa/e2e-report-2026-10-18.md, items 2 to 5."""

import re

from app.service import busy_text, entry_sentence, unit_word
from app.models import Entities, ExtractedItem


def chat(client, shop_id, text="x"):
    r = client.post("/chat", json={"shop_id": shop_id, "text": text})
    assert r.status_code == 200, r.text
    return r.json()


def new_shop(client, language):
    return client.post("/shops", json={"shop_name": "QA", "owner_name": "Q", "language": language}).json()["shop_id"]


# ---- (2) latency cap and the 502 reply ---------------------------------------------------


def test_gemini_deadline_is_25s_with_one_retry():
    import inspect
    from app import gemini

    src = inspect.getsource(gemini)
    assert "timeout=25_000" in src and "timeout=40_000" not in src and "timeout=90_000" not in src
    assert "for attempt in range(2)" in src


def test_gemini_failure_returns_502_with_a_shop_language_sentence(client, scripted, shop_id):
    class Boom:
        model = "x"

        def extract(self, *a, **k):
            from app.gemini import GeminiFailed
            raise GeminiFailed("ServerError: 504 DEADLINE_EXCEEDED")

    client.app.state.extractor = Boom()
    r = client.post("/chat", json={"shop_id": shop_id, "text": "1 colgate bika"})
    assert r.status_code == 502
    body = r.json()["error"]
    assert body["code"] == "gemini_failed" and "DEADLINE" in body["message"]
    assert body["reply_text"] == "Server thoda busy hai, 10 second baad phir bolo."
    assert busy_text("hi") == "सर्वर थोड़ा व्यस्त है, 10 सेकंड बाद फिर बोलें।"
    assert busy_text("en") == "Server is a bit busy, please try again in 10 seconds."
    client.app.state.extractor = scripted


# ---- (3) reply follows the shop language and script ------------------------------------------


def test_hinglish_shop_gets_roman_reply_for_devanagari_voice(client, scripted, shop_id):
    scripted.push(intent="udhaar_given", language="hi", transcript="गुप्ता जी ने 350 रुपये उधार लिया",
                  entities={"customer_name": "Gupta ji", "amount": 350},
                  reply_text="समझा: गुप्ता जी, ₹350 उधार।")  # Gemini answered in Devanagari
    r = client.post("/voice-note", data={"shop_id": shop_id},
                    files={"audio": ("n.m4a", b"\x00x", "audio/m4a")}).json()
    assert r["language"] == "hi" and r["transcript"].startswith("गुप्ता")
    assert r["reply_text"] == "Samjha: Gupta ji, ₹350 udhaar. Total ₹350."
    assert not re.search(r"[\u0900-\u097F]", r["reply_text"])


def test_hindi_shop_gets_devanagari_units_and_no_roman_sentence(client, scripted):
    sid = new_shop(client, "hi")
    scripted.push(intent="stock_in", language="hi",
                  entities={"items": [{"name": "Parle-G", "quantity": 2, "unit": "carton"}]},
                  reply_text="समझा: Parle-G, 2 कार्टन स्टॉक में जोड़े गए।")
    r = chat(client, sid, "कल पारले जी के 2 कार्टन आए")
    assert r["reply_text"] == ("समझा: Parle-G, 2 कार्टन स्टॉक में जोड़े गए। "
                               "अब स्टॉक: Parle-G 90 पैकेट (2 कार्टन = 48 पैकेट).")
    assert "packet" not in r["reply_text"] and "carton" not in r["reply_text"]
    # Gemini answered in Roman for the Hindi shop: template replaces it, one script only
    scripted.push(intent="sale", language="hi-Latn",
                  entities={"items": [{"name": "Maggi", "quantity": 4, "unit": "packet"}]},
                  reply_text="Samjha: Maggi, 4 packet bike.")
    r = chat(client, sid, "4 maggi bike")
    assert r["reply_text"] == "समझा: Maggi 70g, 4 पैकेट बिके। अब स्टॉक: Maggi 26 पैकेट."
    assert unit_word("piece", "hi") == "पीस" and unit_word("kg", "hi") == "किलो" and unit_word("packet", "en", 3) == "packets"


def test_english_shop_template_when_gemini_slips_into_hinglish(client, scripted):
    sid = new_shop(client, "en")
    scripted.push(intent="udhaar_paid", entities={"customer_name": "Mehta", "amount": 100},
                  reply_text="Samjha: Mehta ne ₹100 wapas diye.")
    scripted.push(intent="udhaar_given", entities={"customer_name": "Mehta", "amount": 300},
                  reply_text="Got it: Mehta, ₹300 on credit.")
    assert chat(client, sid)["reply_text"] == "No udhaar is recorded for Mehta."  # nothing to repay yet
    assert chat(client, sid)["reply_text"] == "Got it: Mehta, ₹300 on credit. Balance ₹300."


# ---- (4) contradictory replies ----------------------------------------------------------------


def test_repayment_never_goes_negative(client, scripted, shop_id):
    scripted.push(intent="udhaar_paid", entities={"customer_name": "Sharma ji", "amount": 200},
                  reply_text="Samjha: Sharma ji ne ₹200 wapas kiye.")
    r = chat(client, shop_id, "Sharma ji ne 200 wapas kiye")
    assert r["applied"] is False and r["intent"] == "udhaar_paid" and r["quick_actions"] == []
    assert r["reply_text"] == "Sharma ji ka koi udhaar likha nahi hai."
    assert client.get(f"/ledger/{shop_id}").json()["customers"] == []

    scripted.push(intent="udhaar_given", entities={"customer_name": "Gupta ji", "amount": 350})
    scripted.push(intent="udhaar_paid", entities={"customer_name": "Gupta ji", "amount": 500},
                  reply_text="Samjha: Gupta ji ne ₹500 wapas diye.")
    chat(client, shop_id)
    r = chat(client, shop_id, "Gupta ji ne 500 wapas diye")
    assert r["applied"] is True and r["entities"]["amount"] == 350  # clamped to the outstanding balance
    assert r["reply_text"] == "Samjha: Gupta ji ne ₹500 wapas diye. Gupta ji ka poora udhaar chukta, ₹0 baaki."
    ledger = client.get(f"/ledger/{shop_id}").json()
    assert ledger["customers"][0]["balance"] == 0 and ledger["total_outstanding"] == 0
    assert "-" not in r["reply_text"]


def test_questions_are_answered_from_the_store(client, scripted, shop_id):
    scripted.push(intent="udhaar_given", entities={"customer_name": "Gupta ji", "amount": 350})
    chat(client, shop_id)
    scripted.push(intent="question", entities={"customer_name": "Gupta ji"},
                  reply_text="Gupta ji ka udhaar khata check kar raha hoon.")
    r = chat(client, shop_id, "Gupta ji ka kitna udhaar hai?")
    assert r["reply_text"] == "Gupta ji ka udhaar ₹350 baaki hai." and r["applied"] is False
    scripted.push(intent="question", entities={"customer_name": "Verma ji"},
                  reply_text="Verma ji ka udhaar khata check karke batata hoon.")
    assert chat(client, shop_id)["reply_text"] == "Verma ji ka koi udhaar likha nahi hai."
    scripted.push(intent="question", entities={"items": [{"name": "parle ji"}]},
                  reply_text="Parle-G check kar raha hoon.")
    assert chat(client, shop_id)["reply_text"] == "Parle-G 70g abhi 42 packet hai."
    scripted.push(intent="question", reply_text="Stock dekh kar batata hoon.")
    assert chat(client, shop_id)["reply_text"] == "Kis item ya kis customer ke baare mein pooch rahe ho?"


def test_unclear_never_claims_to_have_noted(client, scripted, shop_id):
    scripted.push(intent="unclear", confidence=0.7, reply_text="Samjha: Nescafe stock khatam note kar liya.")
    r = chat(client, shop_id, "nescafe khatam ho gaya")
    assert r["applied"] is False and r["quick_actions"] == []
    assert r["reply_text"] == "Samajh nahi aaya. Kaunsa item, kitna, ya kiska udhaar?"
    scripted.push(intent="unclear", confidence=0.5, reply_text="Maggi 5 packet aaye ya 6?")
    assert chat(client, shop_id)["reply_text"] == "Maggi 5 packet aaye ya 6?"  # a real question is kept
    assert next(i for i in client.get(f"/stock/{shop_id}").json()["items"] if i["name"] == "Nescafe")["quantity"] == 6


# ---- (5) fixed templates -------------------------------------------------------------------


def test_entry_templates_in_three_languages():
    ent = Entities(items=[ExtractedItem(name="Maggi", pack_size="70g", quantity=5, unit="packet")])
    assert entry_sentence("stock_in", ent, "hi-Latn") == "Samjha: Maggi 70g, 5 packet stock mein add kiya."
    assert entry_sentence("stock_in", ent, "hi") == "समझा: Maggi 70g, 5 पैकेट स्टॉक में जोड़े।"
    assert entry_sentence("stock_in", ent, "en") == "Got it: added Maggi 70g, 5 packets to stock."
    assert entry_sentence("sale", ent, "hi-Latn", held=True) == "Confirm karo: Maggi 70g, 5 packet bike likhoon?"
    cust = Entities(customer_name="Gupta ji", amount=350)
    assert entry_sentence("udhaar_given", cust, "hi") == "समझा: Gupta ji, ₹350 उधार।"
    assert entry_sentence("udhaar_paid", cust, "en", held=True) == "Please confirm: Gupta ji paid back ₹350?"


def test_undo_and_shelf_echoes_are_templates_in_hindi(client, scripted):
    sid = new_shop(client, "hi")
    scripted.push(intent="sale", entities={"items": [{"name": "Maggi", "quantity": 4, "unit": "packet"}]})
    mid = chat(client, sid)["message_id"]
    assert client.post("/undo", json={"shop_id": sid, "message_id": mid}).json()["reply_text"] == \
        "ठीक है, हटा दिया. Maggi 30 पैकेट."
    scripted.push_scan([("Maggi", 6, 0.9)], reply_text="Shelf pe dikha: Maggi 6.")
    body = client.post("/shelf-scan", data={"shop_id": sid}, files={"image": ("s.jpg", b"\xff\xd8x", "image/jpeg")}).json()
    r = client.post("/confirm", json={"shop_id": sid, "message_id": body["message_id"]}).json()
    assert r["reply_text"] == "स्टॉक अपडेट किया: Maggi 6 पैकेट."
    scripted.push_scan([], reply_text="A / B / C / D")
    body = client.post("/shelf-scan", data={"shop_id": sid}, files={"image": ("s.jpg", b"\xff\xd8x", "image/jpeg")}).json()
    assert body["reply_text"] == "शेल्फ पर कोई प्रोडक्ट समझ नहीं आया, थोड़ा पास से फ़ोटो लें।" and body["quick_actions"] == []
