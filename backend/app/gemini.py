"""Gemini extraction via the official google-genai SDK against Vertex AI.

Env: GOOGLE_GENAI_USE_VERTEXAI=true, GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION,
GEMINI_MODEL (see .env.example). Set MOCK_GEMINI=1 to use the offline mock,
which runs the same extraction contract with regex heuristics so the app and
the eval can be exercised without credentials.
"""

from __future__ import annotations

import json
import re
from typing import Protocol

from pydantic import ValidationError

from app.config import Settings
from app.models import Entities, ExtractedItem, Extraction
from app.store import ItemRecord


class GeminiFailed(Exception):
    pass


SYSTEM_PROMPT = """You are Kirana Mitra, an assistant for small Indian grocery shops (kiranas).
The shopkeeper sends a short voice note or typed message in Hindi (Devanagari), Hinglish
(Hindi in Roman script) or English, often mixed. Extract ONE structured entry.

Return JSON matching the schema with these fields:
- intent: one of
  * stock_in     : goods arrived / were bought for the shop ("aaye", "aaya", "आए", "stock aaya", "received", "khareeda")
  * sale         : goods sold to a customer ("bik gaye", "becha", "बिके", "sold")
  * udhaar_given : a customer took goods/money on credit ("udhaar liya", "उधार लिया", "baaki", "credit")
  * udhaar_paid  : a customer paid back credit ("de diye", "wapas", "chuka", "चुकाया", "paid back", "jama")
  * question     : the user is asking something (stock level, who owes, totals); never writes
  * unclear      : cannot tell, or essential info is missing; never writes
- confidence: 0.0-1.0. Use >= 0.8 only when intent AND the key entities are unambiguous.
  Use < 0.7 when the item, quantity, customer or amount is uncertain or could be read two ways.
- language: "hi" (Devanagari script), "hi-Latn" (Hinglish in Roman script) or "en".
  If the text mixes Hindi words in Roman script with English, it is "hi-Latn".
- transcript: for audio input, exactly what you heard in the speaker's own script; null for text.
- entities:
  * items: list of {name, pack_size, quantity, unit, unit_price}. Keep the brand name as spoken
    (e.g. "Parle G", "Maggi"); the backend matches it to the catalogue. unit is one of
    carton | piece | kg | litre | packet | box. unit_price in integer rupees or null.
  * customer_name: as spoken, keep honorifics ("Gupta ji", "Sharma aunty"); null if none.
  * amount: integer rupees for udhaar/sale amounts; null otherwise.
  * date: ISO date if the user said one ("kal" = yesterday relative to today); else null.
  Fields not relevant to the intent are null (items is []).
- reply_text: one short sentence, in the SAME language and script mix as the user, that
  confirms what will be recorded: start with "Samjha:" / "समझा:" / "Got it:". Do not invent
  running totals; the backend appends them. For question: answer briefly if you can from
  the catalogue below, else say what you need. For unclear: ask one short clarifying question.

Catalogue of this shop (name | pack | unit | on hand):
{catalogue}
Today's date: {today}

Examples:
User: "Kal Parle-G ke 3 carton aaye"
→ {{"intent":"stock_in","confidence":0.92,"language":"hi-Latn","transcript":null,
   "entities":{{"items":[{{"name":"Parle-G","pack_size":null,"quantity":3,"unit":"carton","unit_price":null}}],
   "customer_name":null,"amount":null,"date":"{yesterday}"}},
   "reply_text":"Samjha: Parle-G, 3 carton stock mein add kiya."}}

User: "गुप्ता जी ने 350 रुपये उधार लिया"
→ {{"intent":"udhaar_given","confidence":0.93,"language":"hi","transcript":null,
   "entities":{{"items":[],"customer_name":"गुप्ता जी","amount":350,"date":null}},
   "reply_text":"समझा: गुप्ता जी, ₹350 उधार।"}}

User: "Sharma aunty paid back 200"
→ {{"intent":"udhaar_paid","confidence":0.9,"language":"en","transcript":null,
   "entities":{{"items":[],"customer_name":"Sharma aunty","amount":200,"date":null}},
   "reply_text":"Got it: Sharma aunty paid back ₹200."}}

User: "aaj 5 maggi bik gaye"
→ {{"intent":"sale","confidence":0.88,"language":"hi-Latn","transcript":null,
   "entities":{{"items":[{{"name":"Maggi","pack_size":null,"quantity":5,"unit":"packet","unit_price":null}}],
   "customer_name":null,"amount":null,"date":"{today}"}},
   "reply_text":"Samjha: Maggi, 5 packet bike."}}

User: "Tata salt kitna bacha hai?"
→ {{"intent":"question","confidence":0.9,"language":"hi-Latn","transcript":null,
   "entities":{{"items":[{{"name":"Tata Salt","pack_size":null,"quantity":null,"unit":null,"unit_price":null}}],
   "customer_name":null,"amount":null,"date":null}},
   "reply_text":"Tata Salt 1kg abhi 20 packet hai."}}

User: "wo wala do"
→ {{"intent":"unclear","confidence":0.3,"language":"hi-Latn","transcript":null,
   "entities":{{"items":[],"customer_name":null,"amount":null,"date":null}},
   "reply_text":"Kaunsa item, aur kitna? Thoda detail batao."}}
"""


class Extractor(Protocol):
    model: str

    def extract(
        self,
        text: str | None,
        audio: tuple[bytes, str] | None,
        catalogue: list[ItemRecord],
        shop_language: str,
    ) -> Extraction: ...


def _catalogue_lines(items: list[ItemRecord]) -> str:
    return "\n".join(
        f"- {i.name} | {i.pack_size or '-'} | {i.unit} | {i.quantity:g}" for i in items
    ) or "- (empty)"


def build_system_prompt(catalogue: list[ItemRecord]) -> str:
    from datetime import date, timedelta

    today = date.today()
    return SYSTEM_PROMPT.format(
        catalogue=_catalogue_lines(catalogue),
        today=today.isoformat(),
        yesterday=(today - timedelta(days=1)).isoformat(),
    )


# ---- live client ----------------------------------------------------------------


class GeminiExtractor:
    def __init__(self, settings: Settings) -> None:
        from google import genai

        if not settings.google_cloud_project:
            raise GeminiFailed(
                "GOOGLE_CLOUD_PROJECT is not set; export it (or set MOCK_GEMINI=1)."
            )
        self.model = settings.gemini_model
        self._client = genai.Client(
            vertexai=True,
            project=settings.google_cloud_project,
            location=settings.google_cloud_location,
        )

    def extract(
        self,
        text: str | None,
        audio: tuple[bytes, str] | None,
        catalogue: list[ItemRecord],
        shop_language: str,
    ) -> Extraction:
        from google.genai import types

        parts: list[types.Part] = []
        if audio:
            data, mime = audio
            parts.append(types.Part.from_bytes(data=data, mime_type=mime))
            parts.append(types.Part.from_text(
                text="Listen to this voice note from the shopkeeper and extract the entry. "
                     "Fill `transcript` with exactly what was said, in the speaker's script."
            ))
        if text:
            parts.append(types.Part.from_text(text=f'User: "{text}"'))
        if not parts:
            raise GeminiFailed("Nothing to extract: no text and no audio")

        config = types.GenerateContentConfig(
            system_instruction=build_system_prompt(catalogue)
            + f"\nShop's preferred language: {shop_language}.",
            response_mime_type="application/json",
            response_schema=Extraction,
            temperature=0.1,
        )
        try:
            response = self._client.models.generate_content(
                model=self.model,
                contents=[types.Content(role="user", parts=parts)],
                config=config,
            )
        except Exception as exc:  # network / auth / quota
            raise GeminiFailed(f"{type(exc).__name__}: {exc}") from exc
        parsed = getattr(response, "parsed", None)
        if isinstance(parsed, Extraction):
            return parsed
        raw = response.text or ""
        try:
            return Extraction.model_validate_json(raw)
        except ValidationError as exc:
            raise GeminiFailed(f"Gemini returned invalid JSON: {exc}") from exc


# ---- mock client ------------------------------------------------------------------

_NUM_WORDS = {
    "ek": 1, "do": 2, "teen": 3, "char": 4, "chaar": 4, "paanch": 5, "panch": 5, "chhe": 6,
    "che": 6, "saat": 7, "aath": 8, "nau": 9, "das": 10, "one": 1, "two": 2, "three": 3,
    "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
    "एक": 1, "दो": 2, "तीन": 3, "चार": 4, "पांच": 5, "पाँच": 5, "छह": 6, "सात": 7, "आठ": 8,
    "नौ": 9, "दस": 10,
}
_UNITS = {
    "carton": "carton", "cartons": "carton", "kartan": "carton", "कार्टन": "carton", "peti": "box",
    "box": "box", "boxes": "box", "पेटी": "box", "packet": "packet", "packets": "packet",
    "pkt": "packet", "पैकेट": "packet", "kg": "kg", "kilo": "kg", "किलो": "kg", "litre": "litre",
    "liter": "litre", "litres": "litre", "लीटर": "litre", "piece": "piece", "pieces": "piece",
    "pcs": "piece", "पीस": "piece",
}
_DEVANAGARI = re.compile(r"[ऀ-ॿ]")
_HINDI_HINTS = re.compile(
    r"\b(aaye|aaya|aayi|bik|bike|becha|udhaar|udhar|liya|liye|diye|diya|wapas|chuka|kitna|"
    r"kitne|hai|ka|ke|ki|ne|ji|aaj|kal|wala|karo|batao|bacha|hisaab|rupaye|rupay|baaki)\b",
    re.I,
)


def _digits(text: str) -> int | None:
    m = re.search(r"\d+(?:[.,]\d+)?", text)
    return int(float(m.group().replace(",", ""))) if m else None


class MockExtractor:
    """Offline stand-in that follows the same contract with crude heuristics."""

    model = "mock-gemini"

    def extract(
        self,
        text: str | None,
        audio: tuple[bytes, str] | None,
        catalogue: list[ItemRecord],
        shop_language: str,
    ) -> Extraction:
        transcript = None
        if audio and not text:
            transcript = "Gupta ji ne 350 rupaye udhaar liya"
            text = transcript
        text = (text or "").strip()
        low = text.lower()
        language = (
            "hi" if _DEVANAGARI.search(text) else "hi-Latn" if _HINDI_HINTS.search(low) else "en"
        )

        if re.search(r"\?|kitna|kitne|कितना|कितने|how much|how many|balance|baaki hai|kya hai", low):
            intent = "question"
        elif re.search(r"wapas|chuka|चुका|paid back|de diye|दे दिए|jama|जमा|lauta|लौटा|returned", low):
            intent = "udhaar_paid"
        elif re.search(r"udhaar|udhar|उधार|credit|baaki|बाकी|on account|owes", low):
            intent = "udhaar_given"
        elif re.search(r"bik|बिक|becha|बेचा|sold|sale|bech", low):
            intent = "sale"
        elif re.search(r"aaye|aaya|aayi|आए|आया|आई|received|arrived|came|stock|khareed|खरीद|mangaya|मंगाया", low):
            intent = "stock_in"
        else:
            intent = "unclear"

        qty: float | None = _digits(text)
        if qty is None:
            for w, n in _NUM_WORDS.items():
                if re.search(rf"(^|\s){re.escape(w)}(\s|$)", low):
                    qty = n
                    break
        unit = next((u for w, u in _UNITS.items() if re.search(rf"\b{re.escape(w)}\b", low)), None)

        items: list[ExtractedItem] = []
        customer = None
        amount = None
        confidence = 0.85

        if intent in {"stock_in", "sale", "question"}:
            from app.matching import match_item

            hit = match_item(text, catalogue, threshold=60)
            if hit:
                items.append(ExtractedItem(name=hit.name, pack_size=hit.pack_size,
                                           quantity=qty if intent != "question" else None,
                                           unit=unit or hit.unit))
            elif intent != "question":
                intent, confidence = "unclear", 0.4
            if intent in {"stock_in", "sale"} and qty is None:
                confidence = 0.5
        if intent in {"udhaar_given", "udhaar_paid"}:
            amount = _digits(text)
            m = re.search(
                r"([A-Za-zऀ-ॿ]+(?:\s+(?:ji|जी|aunty|uncle|bhai|sahab|साहब|भाई|आंटी|अंकल))?)"
                r"\s*(?:ne|ने|ko|को|paid|returned|gave|took)",
                text, re.I,
            )
            customer = m.group(1).strip() if m else None
            if customer is None:
                m2 = re.search(r"\b([A-Z][a-z]+(?:\s+(?:ji|aunty|uncle|bhai))?)\b", text)
                customer = m2.group(1) if m2 else None
            if amount is None or customer is None:
                confidence = 0.55
        if intent == "unclear":
            confidence = min(confidence, 0.4)
        if re.search(r"shayad|शायद|maybe|i think|probably|lagta hai|लगता है|ya\s|या ", low):
            confidence = min(confidence, 0.6)

        reply = self._reply(intent, language, items, customer, amount, catalogue)
        return Extraction(
            intent=intent, confidence=confidence, language=language, transcript=transcript,
            entities=Entities(items=items, customer_name=customer, amount=amount, date=None),
            reply_text=reply,
        )

    @staticmethod
    def _reply(intent, language, items, customer, amount, catalogue) -> str:
        head = {"hi": "समझा:", "en": "Got it:", "hi-Latn": "Samjha:"}[language]
        item_txt = ", ".join(
            f"{i.name}{' ' + i.pack_size if i.pack_size else ''}"
            f"{', ' + str(i.quantity).rstrip('0').rstrip('.') + ' ' + (i.unit or '') if i.quantity else ''}"
            for i in items
        )
        if intent == "stock_in":
            return f"{head} {item_txt} " + {"hi": "स्टॉक में जोड़ा।", "en": "added to stock.",
                                            "hi-Latn": "stock mein add kiya."}[language]
        if intent == "sale":
            return f"{head} {item_txt} " + {"hi": "बिके।", "en": "sold.", "hi-Latn": "bike."}[language]
        if intent == "udhaar_given":
            return f"{head} {customer or ''}, ₹{amount or 0} " + {
                "hi": "उधार।", "en": "on credit.", "hi-Latn": "udhaar."}[language]
        if intent == "udhaar_paid":
            return f"{head} {customer or ''} " + {"hi": f"ने ₹{amount or 0} चुकाए।",
                                                   "en": f"paid back ₹{amount or 0}.",
                                                   "hi-Latn": f"ne ₹{amount or 0} wapas diye."}[language]
        if intent == "question":
            if items:
                rec = next((c for c in catalogue if c.name == items[0].name), None)
                if rec:
                    return {"hi": f"{rec.name} अभी {rec.quantity:g} {rec.unit} है।",
                            "en": f"{rec.name} is at {rec.quantity:g} {rec.unit}.",
                            "hi-Latn": f"{rec.name} abhi {rec.quantity:g} {rec.unit} hai."}[language]
            return {"hi": "किस चीज़ के बारे में पूछ रहे हैं?", "en": "What would you like to know?",
                    "hi-Latn": "Kis cheez ke baare mein pooch rahe ho?"}[language]
        return {"hi": "कौन सा सामान, और कितना? थोड़ा बताइए।",
                "en": "Which item, and how many? Please add a little detail.",
                "hi-Latn": "Kaunsa item, aur kitna? Thoda detail batao."}[language]


def make_extractor(settings: Settings) -> Extractor:
    if settings.mock_gemini:
        return MockExtractor()
    return GeminiExtractor(settings)
