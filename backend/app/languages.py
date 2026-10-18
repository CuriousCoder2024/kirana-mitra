"""The 22 scheduled languages of India plus English and Hinglish.

`LANGUAGES` drives GET /languages, the `language` enum in every contract model,
the script Gemini is told to reply in, and the mock extractor's script-based
detection. Unknown codes fall back to English everywhere.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class LanguageInfo:
    code: str
    name: str  # English name
    native_name: str
    script: str
    rtl: bool = False


LANGUAGES: list[LanguageInfo] = [
    LanguageInfo("as", "Assamese", "অসমীয়া", "Bengali"),
    LanguageInfo("bn", "Bengali", "বাংলা", "Bengali"),
    LanguageInfo("brx", "Bodo", "बड़ो", "Devanagari"),
    LanguageInfo("doi", "Dogri", "डोगरी", "Devanagari"),
    LanguageInfo("gu", "Gujarati", "ગુજરાતી", "Gujarati"),
    LanguageInfo("hi", "Hindi", "हिन्दी", "Devanagari"),
    LanguageInfo("kn", "Kannada", "ಕನ್ನಡ", "Kannada"),
    LanguageInfo("ks", "Kashmiri", "کٲشُر", "Perso-Arabic", rtl=True),
    LanguageInfo("kok", "Konkani", "कोंकणी", "Devanagari"),
    LanguageInfo("mai", "Maithili", "मैथिली", "Devanagari"),
    LanguageInfo("ml", "Malayalam", "മലയാളം", "Malayalam"),
    LanguageInfo("mni", "Manipuri", "ꯃꯤꯇꯩꯂꯣꯟ", "Meitei Mayek"),
    LanguageInfo("mr", "Marathi", "मराठी", "Devanagari"),
    LanguageInfo("ne", "Nepali", "नेपाली", "Devanagari"),
    LanguageInfo("or", "Odia", "ଓଡ଼ିଆ", "Odia"),
    LanguageInfo("pa", "Punjabi", "ਪੰਜਾਬੀ", "Gurmukhi"),
    LanguageInfo("sa", "Sanskrit", "संस्कृतम्", "Devanagari"),
    LanguageInfo("sat", "Santali", "ᱥᱟᱱᱛᱟᱲᱤ", "Ol Chiki"),
    LanguageInfo("sd", "Sindhi", "سنڌي", "Perso-Arabic", rtl=True),
    LanguageInfo("ta", "Tamil", "தமிழ்", "Tamil"),
    LanguageInfo("te", "Telugu", "తెలుగు", "Telugu"),
    LanguageInfo("ur", "Urdu", "اردو", "Perso-Arabic", rtl=True),
    LanguageInfo("en", "English", "English", "Latin"),
    LanguageInfo("hi-Latn", "Hinglish", "Hinglish", "Latin"),
]

BY_CODE: dict[str, LanguageInfo] = {lang.code: lang for lang in LANGUAGES}
LANGUAGE_CODES: tuple[str, ...] = tuple(lang.code for lang in LANGUAGES)

# Unicode block per script, used to detect which script a text is written in
# (mock extractor, feedback language, eval "replied in script" check).
SCRIPT_RANGES: dict[str, list[tuple[int, int]]] = {
    "Devanagari": [(0x0900, 0x097F), (0xA8E0, 0xA8FF)],
    "Bengali": [(0x0980, 0x09FF)],
    "Gurmukhi": [(0x0A00, 0x0A7F)],
    "Gujarati": [(0x0A80, 0x0AFF)],
    "Odia": [(0x0B00, 0x0B7F)],
    "Tamil": [(0x0B80, 0x0BFF)],
    "Telugu": [(0x0C00, 0x0C7F)],
    "Kannada": [(0x0C80, 0x0CFF)],
    "Malayalam": [(0x0D00, 0x0D7F)],
    "Perso-Arabic": [(0x0600, 0x06FF), (0x0750, 0x077F), (0xFB50, 0xFDFF), (0xFE70, 0xFEFF)],
    "Ol Chiki": [(0x1C50, 0x1C7F)],
    "Meitei Mayek": [(0xABC0, 0xABFF), (0xAAE0, 0xAAFF)],
    "Latin": [(0x0041, 0x005A), (0x0061, 0x007A)],
}

# The language a script most likely means when nothing else is known.
DEFAULT_LANGUAGE_FOR_SCRIPT: dict[str, str] = {
    "Devanagari": "hi", "Bengali": "bn", "Gurmukhi": "pa", "Gujarati": "gu", "Odia": "or",
    "Tamil": "ta", "Telugu": "te", "Kannada": "kn", "Malayalam": "ml", "Perso-Arabic": "ur",
    "Ol Chiki": "sat", "Meitei Mayek": "mni", "Latin": "en",
}


def normalise_code(code: str | None) -> str:
    """A known code, else 'en'."""
    return code if code in BY_CODE else "en"


def detect_script(text: str) -> str | None:
    """The non-Latin script with the most letters in `text`, else 'Latin', else None."""
    counts: dict[str, int] = {}
    for ch in text:
        cp = ord(ch)
        for script, ranges in SCRIPT_RANGES.items():
            if any(lo <= cp <= hi for lo, hi in ranges):
                counts[script] = counts.get(script, 0) + 1
                break
    if not counts:
        return None
    non_latin = {k: v for k, v in counts.items() if k != "Latin"}
    if non_latin:
        return max(non_latin, key=non_latin.get)
    return "Latin"


def script_matches(text: str, code: str) -> bool:
    """Does `text` contain letters of the script `code` is written in?"""
    info = BY_CODE.get(code)
    if info is None:
        return False
    ranges = SCRIPT_RANGES[info.script]
    return any(any(lo <= ord(ch) <= hi for lo, hi in ranges) for ch in text)


def reply_instruction(code: str) -> str:
    """One sentence for the prompts: which language and script to reply in."""
    info = BY_CODE.get(code) or BY_CODE["en"]
    if code == "hi-Latn":
        return "Reply in Hinglish: Hindi words written in Roman (Latin) letters, never Devanagari."
    return (f"Reply in {info.name} ({info.native_name}) written in the {info.script} script"
            + (", right-to-left" if info.rtl else "") + ".")
