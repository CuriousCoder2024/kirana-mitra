"""Fuzzy-match spoken/typed item names to the shop's catalogue (rapidfuzz)."""

from __future__ import annotations

import re

from rapidfuzz import fuzz, process

from app.store import ItemRecord

_PUNCT = re.compile(r"[^\w\sऀ-ॿ]+", re.UNICODE)


def normalise(text: str) -> str:
    text = text.lower().strip()
    text = _PUNCT.sub(" ", text)
    return re.sub(r"\s+", " ", text).strip()


def match_item(spoken: str, items: list[ItemRecord], threshold: int = 70) -> ItemRecord | None:
    """Return the best catalogue item for a spoken name, or None if nothing is close.

    Each item is indexed by its name, "name pack_size", and every alias, so
    "parle ji", "Parle G 70g" and "पारले जी" all resolve to Parle-G.
    """
    if not spoken or not items:
        return None
    query = normalise(spoken)
    choices: dict[str, ItemRecord] = {}
    for item in items:
        keys = [item.name, f"{item.name} {item.pack_size or ''}", *item.aliases]
        for key in keys:
            choices.setdefault(normalise(key), item)
    # token_set_ratio ignores word order and extra words ("3 carton parle g" vs "parle g").
    best = process.extractOne(query, list(choices.keys()), scorer=fuzz.token_set_ratio)
    if best is None:
        return None
    key, score, _ = best
    if score < threshold:
        # Second chance for short transliteration noise: partial ratio on the item name only.
        best2 = process.extractOne(
            query, [normalise(i.name) for i in items], scorer=fuzz.WRatio
        )
        if best2 and best2[1] >= threshold + 10:
            return next(i for i in items if normalise(i.name) == best2[0])
        return None
    return choices[key]


def match_customer(spoken: str, known: list[str], threshold: int = 88) -> str:
    """Merge a spoken customer name into an existing ledger customer when it is clearly
    the same person ("gupta ji" -> "Gupta ji", "Guptaji" -> "Gupta ji"); else keep as spoken."""
    spoken = spoken.strip()
    if not known:
        return spoken
    q = normalise(spoken).replace(" ", "")
    best, best_score = None, 0
    for name in known:
        score = fuzz.ratio(q, normalise(name).replace(" ", ""))
        if score > best_score:
            best, best_score = name, score
    return best if best is not None and best_score >= threshold else spoken
