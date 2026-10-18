#!/usr/bin/env python3
"""Machine-translate lib/l10n/app_en.arb into the 22 scheduled languages.

Run from app/:
    uv run --with google-genai python tool/translate_arb.py [--only ta,te] [--model gemini-3.8-flash]

Uses Vertex AI through google-genai with the same env as the backend
(GOOGLE_GENAI_USE_VERTEXAI=true, GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION), read
from the environment or from ../backend/.env. app_en.arb and app_hi.arb stay
hand-written; every other app_<code>.arb is generated here and marked
"@@x-machine-translated". Placeholders like {name} and ICU plural syntax are preserved;
the script validates them and retries once per language on a mismatch.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import sys
import time
from collections import OrderedDict
from pathlib import Path

HERE = Path(__file__).resolve().parent
L10N = HERE.parent / "lib" / "l10n"
ENV_FILE = HERE.parent.parent / "backend" / ".env"

# code -> (English name, native name, script, notes for the model)
LANGUAGES = {
    "hi-Latn": ("Hinglish", "Hinglish", "Latin", "Hindi written in Roman script, the everyday Hinglish a Delhi shopkeeper types on WhatsApp; keep English brand and tech words as they are"),
    "as": ("Assamese", "অসমীয়া", "Bengali", ""),
    "bn": ("Bengali", "বাংলা", "Bengali", ""),
    "brx": ("Bodo", "बड़ो", "Devanagari", ""),
    "doi": ("Dogri", "डोगरी", "Devanagari", ""),
    "gu": ("Gujarati", "ગુજરાતી", "Gujarati", ""),
    "kn": ("Kannada", "ಕನ್ನಡ", "Kannada", ""),
    "ks": ("Kashmiri", "کٲشُر", "Perso-Arabic", "right-to-left script"),
    "kok": ("Konkani", "कोंकणी", "Devanagari", ""),
    "mai": ("Maithili", "मैथिली", "Devanagari", ""),
    "ml": ("Malayalam", "മലയാളം", "Malayalam", ""),
    "mni": ("Manipuri (Meitei)", "মৈতৈলোন্", "Bengali", "use the Bengali script, not Meetei Mayek"),
    "mr": ("Marathi", "मराठी", "Devanagari", ""),
    "ne": ("Nepali", "नेपाली", "Devanagari", ""),
    "or": ("Odia", "ଓଡ଼ିଆ", "Odia", ""),
    "pa": ("Punjabi", "ਪੰਜਾਬੀ", "Gurmukhi", ""),
    "sa": ("Sanskrit", "संस्कृतम्", "Devanagari", ""),
    "sat": ("Santali", "ᱥᱟᱱᱛᱟᱲᱤ", "Ol Chiki", "use the Ol Chiki script"),
    "sd": ("Sindhi", "سنڌي", "Perso-Arabic", "right-to-left script"),
    "ta": ("Tamil", "தமிழ்", "Tamil", ""),
    "te": ("Telugu", "తెలుగు", "Telugu", ""),
    "ur": ("Urdu", "اردو", "Perso-Arabic (Nastaliq)", "right-to-left script"),
}

PLACEHOLDER = re.compile(r"\{[a-zA-Z_][a-zA-Z0-9_]*\}")


def load_env() -> None:
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))
    os.environ.setdefault("GOOGLE_GENAI_USE_VERTEXAI", "true")
    os.environ.setdefault("GOOGLE_CLOUD_LOCATION", "global")


def translatable(arb: dict) -> OrderedDict:
    """Keys whose value is a user-visible string (no @ metadata, no @@ header)."""
    out = OrderedDict()
    for k, v in arb.items():
        if k.startswith("@") or not isinstance(v, str):
            continue
        out[k] = v
    return out


def icu_shape(s: str) -> tuple:
    """Placeholders plus plural/select keywords, order-independent, for validation."""
    ph = sorted(set(PLACEHOLDER.findall(s)))
    plural = sorted(set(re.findall(r"(=\d+|other|zero|one|two|few|many)\{", s)))
    return (tuple(ph), tuple(plural))


def validate(src: OrderedDict, out: dict) -> list[str]:
    problems = []
    for k, v in src.items():
        t = out.get(k)
        if not isinstance(t, str) or not t.strip():
            problems.append(f"{k}: missing")
            continue
        if icu_shape(v) != icu_shape(t):
            problems.append(f"{k}: placeholder/plural mismatch")
    return problems


def prompt_for(code: str, src: OrderedDict, redo: list[str] | None) -> str:
    name, native, script, notes = LANGUAGES[code]
    rules = f"""You translate UI strings for Kirana Mitra, a voice-first assistant for small Indian
grocery shops (kiranas). Translate every value from the English/Hinglish source into {name}
({native}), written in the {script} script. {notes}

Rules:
- Keep it short, warm and spoken, as a friendly helper talking to a shopkeeper. Body text must fit
  a phone button or chip, so prefer the shortest natural phrasing.
- Keep placeholders exactly as they are, e.g. {{name}}, {{count}}, {{amount}}, {{date}}. Do not
  translate, reorder letters, or add spaces inside braces.
- ICU plural strings look like "{{count, plural, =1{{...}} other{{...}}}}". Keep the same keywords
  (=0, =1, other) and braces; translate only the text inside the inner braces.
- Keep brand and product words (WhatsApp, Parle-G, Gupta General Store, Kirana Mitra) unchanged.
- "Udhaar" means shop credit the customer owes; "Hisaab" means the day's accounts; "Kam hai"
  means low stock. Use the natural local word, not a transliteration, unless the local
  shopkeeper word really is the Hindi one.
- Keep "₹" and digits as they are.
- Return ONLY a JSON object with exactly the same keys as the input and translated string values.
"""
    if redo:
        rules += f"\nThese keys failed validation last time; be extra careful with their placeholders: {', '.join(redo)}\n"
    return rules + "\nInput JSON:\n" + json.dumps(src, ensure_ascii=False, indent=1)


def translate(client, model: str, code: str, src: OrderedDict) -> dict:
    from google.genai import types

    redo: list[str] | None = None
    result: dict = {}
    for attempt in range(2):
        resp = _generate_with_backoff(
            client,
            model=model,
            contents=prompt_for(code, src, redo),
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.2,
            ),
        )
        text = resp.text or "{}"
        try:
            result = json.loads(text)
        except json.JSONDecodeError:
            m = re.search(r"\{.*\}", text, re.S)
            result = json.loads(m.group(0)) if m else {}
        problems = validate(src, result)
        if not problems:
            return result
        redo = [p.split(":")[0] for p in problems]
        print(f"  {code}: attempt {attempt + 1} had {len(problems)} problems: {problems[:5]}", file=sys.stderr)
    # Keep source for any key that still fails so the app never shows an empty string.
    for k in redo or []:
        result[k] = src[k]
    return result


def _generate_with_backoff(client, **kwargs):
    """Vertex AI returns 429 RESOURCE_EXHAUSTED under shared quota; back off and retry."""
    delay = 15
    for attempt in range(6):
        try:
            return client.models.generate_content(**kwargs)
        except Exception as e:  # noqa: BLE001 - the SDK raises several error types
            code = getattr(e, "code", None) or getattr(e, "status_code", None)
            if code not in (429, 500, 503) and "429" not in str(e) and "503" not in str(e):
                raise
            if attempt == 5:
                raise
            print(f"  quota/transient error ({code}); retrying in {delay}s", file=sys.stderr)
            time.sleep(delay)
            delay = min(delay * 2, 120)
    raise RuntimeError("unreachable")


def write_arb(code: str, src_arb: dict, translated: dict, model: str) -> Path:
    locale = "hi_Latn" if code == "hi-Latn" else code
    out = OrderedDict()
    out["@@locale"] = locale
    out["@@x-machine-translated"] = f"{model}, {dt.date.today().isoformat()}, unreviewed"
    for k, v in src_arb.items():
        if k.startswith("@@"):
            continue
        if k.startswith("@"):
            out[k] = v  # placeholder metadata is copied verbatim
        else:
            out[k] = translated.get(k, v)
    path = L10N / f"app_{locale}.arb"
    path.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", help="comma-separated language codes")
    ap.add_argument("--model", default=os.environ.get("GEMINI_MODEL", "gemini-3.8-flash"))
    ap.add_argument("--dry-run", action="store_true", help="copy English values instead of calling Gemini")
    ap.add_argument("--force", action="store_true", help="regenerate files that already exist")
    args = ap.parse_args()
    load_env()
    codes = args.only.split(",") if args.only else list(LANGUAGES)
    src_arb = json.loads((L10N / "app_en.arb").read_text(encoding="utf-8"), object_pairs_hook=OrderedDict)
    src = translatable(src_arb)
    model = args.model
    client = None
    if not args.dry_run:
        from google import genai

        client = genai.Client()
    for code in codes:
        if code not in LANGUAGES:
            print(f"unknown code {code}", file=sys.stderr)
            return 2
        locale = "hi_Latn" if code == "hi-Latn" else code
        if not args.force and (L10N / f"app_{locale}.arb").exists():
            print(f"{code}: exists, skipping (use --force to redo)", file=sys.stderr)
            continue
        print(f"{code} ({LANGUAGES[code][0]}): {len(src)} strings", file=sys.stderr)
        translated = dict(src) if args.dry_run else translate(client, model, code, src)
        path = write_arb(code, src_arb, translated, "dry-run" if args.dry_run else model)
        print(f"  wrote {path.relative_to(HERE.parent)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
