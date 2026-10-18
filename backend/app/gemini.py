"""Gemini extraction via the official google-genai SDK against Vertex AI.

Env: GOOGLE_GENAI_USE_VERTEXAI=true, GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION,
GEMINI_MODEL (see .env.example). Set MOCK_GEMINI=1 to use the offline mock,
which runs the same extraction contract with regex heuristics so the app and
the eval can be exercised without credentials.
"""

from __future__ import annotations

import logging
import time

import json
import re
from typing import Protocol

from pydantic import ValidationError

from app.config import Settings
from app.models import Entities, ExtractedItem, Extraction, ShelfItem, ShelfScan
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
  * items: list of {{name, pack_size, quantity, unit, unit_price}}. Keep the brand name as spoken
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


SHELF_PROMPT = """You are Kirana Mitra, counting stock on a shelf photo from a small Indian grocery
shop (kirana). Identify every packaged product you can see and count the units.

Rules:
- Count UNITS, not product types. Every visible front-facing packet, box, bottle, sachet or pouch
  is one unit (each "facing" on the shelf counts as one). If a product is stacked and you can see
  the stack, count each visible unit in the stack. Do not guess units hidden behind the front row.
- Match each product to the shop catalogue below when it is clearly the same product, and use the
  catalogue's exact name and pack_size. If the pack size is not readable, use the catalogue's.
  Products that are not in the catalogue get their brand name as printed on the pack.
- Group all units of the same product into ONE entry.
- confidence: 0.0-1.0 that both the identification and the count are right. Blurry, partly hidden
  or far-away products get a lower confidence.
- Ignore shelves, price tags, posters, people and empty space.
- reply_text: one short line in the shop's language listing what you saw, e.g.
  "Shelf pe dikha: Maggi 6, Parle-G 12, Tata Salt 3." / "शेल्फ पर दिखा: मैगी 6, पारले-जी 12." /
  "On the shelf: Maggi 6, Parle-G 12." Do not mention reorder levels; the backend adds them.

Catalogue (name | pack | unit | aliases):
{catalogue}
Shop's preferred language: {language}
"""


def build_shelf_prompt(catalogue: list[ItemRecord], language: str) -> str:
    lines = "\n".join(
        f"- {i.name} | {i.pack_size or '-'} | {i.unit} | {', '.join(i.aliases[:3]) or '-'}"
        for i in catalogue
    ) or "- (empty)"
    return SHELF_PROMPT.format(catalogue=lines, language=language)


class Extractor(Protocol):
    model: str

    def scan_shelf(
        self, image: tuple[bytes, str], catalogue: list[ItemRecord], shop_language: str
    ) -> ShelfScan: ...

    def summarize(self, facts: dict, shop_language: str) -> str:
        """One-paragraph evening 'hisaab' from the day's numbers. May raise GeminiFailed."""
        ...

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

logger = logging.getLogger("kirana.gemini")


def _is_transient(exc: Exception) -> bool:
    """Timeouts, 429s and 5xx are worth one retry; auth/permission/schema are not."""
    name = type(exc).__name__.lower()
    msg = str(exc).lower()
    if "timeout" in name or "timeout" in msg or "timed out" in msg:
        return True
    return any(code in msg for code in ("429", "500", "502", "503", "504", "resource_exhausted", "unavailable"))



class GeminiExtractor:
    def __init__(self, settings: Settings) -> None:
        from google import genai

        if not settings.google_cloud_project:
            raise GeminiFailed(
                "GOOGLE_CLOUD_PROJECT is not set; export it (or set MOCK_GEMINI=1)."
            )
        self.model = settings.gemini_model
        from google.genai import types as _types

        # A stuck call must not hang the shopkeeper: cap each request at 40 s
        # (wall clock), then retry once on a transient failure.
        self._client = genai.Client(
            vertexai=True,
            project=settings.google_cloud_project,
            location=settings.google_cloud_location,
            http_options=_types.HttpOptions(timeout=40_000),
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

        system = build_system_prompt(catalogue) + f"\nShop's preferred language: {shop_language}."
        return self._generate(parts, system, Extraction)

    def scan_shelf(
        self, image: tuple[bytes, str], catalogue: list[ItemRecord], shop_language: str
    ) -> ShelfScan:
        from google.genai import types

        data, mime = image
        parts = [
            types.Part.from_bytes(data=data, mime_type=mime),
            types.Part.from_text(
                text="Count the units of each product visible on this shelf and return the JSON."
            ),
        ]
        # Vision over a full shelf takes longer than a one-line extraction; the 40 s
        # chat deadline produced 504 DEADLINE_EXCEEDED on busier images.
        return self._generate(parts, build_shelf_prompt(catalogue, shop_language), ShelfScan,
                              timeout_ms=90_000)

    def summarize(self, facts: dict, shop_language: str) -> str:
        from google.genai import types

        lang = {"hi": "Hindi in Devanagari script", "en": "English",
                "hi-Latn": "Hinglish (Hindi in Roman script)"}.get(shop_language, "Hinglish")
        prompt = (
            "Write the evening 'hisaab' (day summary) for a kirana shopkeeper in "
            f"{lang}: 2 to 3 short sentences, warm and plain, no bullet points, no emojis. "
            "Mention today's sales total, how many entries were recorded, udhaar given and "
            "received, total outstanding udhaar, and name the low-stock items (say 'none' if "
            "empty). Use ₹ with Indian digit grouping. Facts (JSON):\n" + json.dumps(facts, ensure_ascii=False)
        )
        config = types.GenerateContentConfig(
            temperature=0.4,
            thinking_config=types.ThinkingConfig(thinking_level=types.ThinkingLevel.LOW),
            http_options=types.HttpOptions(timeout=20_000),
        )
        try:
            response = self._client.models.generate_content(
                model=self.model, contents=prompt, config=config)
        except Exception as exc:
            raise GeminiFailed(f"{type(exc).__name__}: {exc}") from exc
        text = (response.text or "").strip()
        if not text:
            raise GeminiFailed("empty summary")
        return text

    def _generate(self, parts, system_instruction: str, schema, timeout_ms: int | None = None):
        """One structured-output call with the shared timeout / retry / thinking settings."""
        from google.genai import types

        config = types.GenerateContentConfig(
            system_instruction=system_instruction,
            response_mime_type="application/json",
            response_schema=schema,
            temperature=0.1,
            # Extraction needs no deliberation; the default thinking budget pushed
            # p95 past 40 s and caused 504 DEADLINE_EXCEEDED on the global endpoint.
            thinking_config=types.ThinkingConfig(thinking_level=types.ThinkingLevel.LOW),
            http_options=types.HttpOptions(timeout=timeout_ms) if timeout_ms else None,
        )
        response = None
        last_exc: Exception | None = None
        for attempt in range(2):
            try:
                response = self._client.models.generate_content(
                    model=self.model,
                    contents=[types.Content(role="user", parts=parts)],
                    config=config,
                )
                break
            except Exception as exc:  # network / auth / quota / timeout
                last_exc = exc
                logger.warning("gemini attempt %d failed: %s: %s", attempt + 1,
                               type(exc).__name__, str(exc)[:300])
                if not _is_transient(exc):
                    break
                time.sleep(1.5)
        if response is None:
            raise GeminiFailed(f"{type(last_exc).__name__}: {last_exc}") from last_exc
        parsed = getattr(response, "parsed", None)
        if isinstance(parsed, schema):
            return parsed
        raw = response.text or ""
        try:
            return schema.model_validate_json(raw)
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

    def scan_shelf(
        self, image: tuple[bytes, str], catalogue: list[ItemRecord], shop_language: str
    ) -> ShelfScan:
        """Canned shelf: Maggi 6, Parle-G 12, Tata Salt 3 (Maggi sits below its reorder level)."""
        canned = [("Maggi", 6, 0.9), ("Parle-G", 12, 0.85), ("Tata Salt", 3, 0.8)]
        by_name = {c.name: c for c in catalogue}
        items = [ShelfItem(name=n, pack_size=by_name[n].pack_size if n in by_name else None,
                           count=k, confidence=conf) for n, k, conf in canned]
        head = {"hi": "शेल्फ पर दिखा:", "en": "On the shelf:", "hi-Latn": "Shelf pe dikha:"}.get(
            shop_language, "Shelf pe dikha:")
        return ShelfScan(items=items,
                         reply_text=f"{head} " + ", ".join(f"{i.name} {i.count}" for i in items) + ".")

    def summarize(self, facts: dict, shop_language: str) -> str:
        from app.service import summary_template

        return summary_template(facts, shop_language)

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
