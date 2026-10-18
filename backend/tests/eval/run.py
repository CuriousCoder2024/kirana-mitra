"""Eval harness: `uv run python -m tests.eval.run [--base URL] [--samples PATH]`.

Calls the live /chat endpoint for every utterance in samples.jsonl, scores
intent / entity accuracy and latency, prints a table and appends a row to
tests/eval/results.csv tagged with the date and the model id from /health.
"""

from __future__ import annotations

import argparse
import csv
import json
import statistics
import sys
import time
from datetime import datetime
from pathlib import Path

import httpx

from app.languages import script_matches

HERE = Path(__file__).parent


def _norm(s) -> str:
    return " ".join(str(s or "").lower().replace("-", " ").split())


def score(sample: dict, reply: dict) -> dict:
    exp = sample["expected"]
    ent = reply.get("entities") or {}
    items = ent.get("items") or []
    intent_ok = reply.get("intent") == exp["intent"] or reply.get("intent") == exp.get("alt_intent")
    checks: dict[str, bool] = {}
    if "item" in exp:
        checks["item"] = any(_norm(i.get("name")) == _norm(exp["item"]) for i in items)
    if "quantity" in exp:
        checks["quantity"] = any(
            (i.get("quantity") is not None and float(i["quantity"]) == float(exp["quantity"]))
            for i in items)
    if "customer" in exp:
        got, want = _norm(ent.get("customer_name")), _norm(exp["customer"])
        checks["customer"] = bool(got) and (got == want or want.split()[0] in got)
    if "amount" in exp:
        checks["amount"] = ent.get("amount") == exp["amount"]
    if "max_confidence" in exp:
        checks["held"] = (reply.get("confidence", 1.0) < exp["max_confidence"]
                          and reply.get("applied") is False)
    lang_ok = reply.get("language") == exp.get("language", reply.get("language"))
    # Did Gemini answer in the expected language's own script (Hinglish/English: Latin)?
    script_ok = script_matches(reply.get("reply_text") or "", exp.get("language", "en"))
    return {"intent": intent_ok, "language": lang_ok, "script": script_ok, "checks": checks,
            "entities": all(checks.values()) if checks else True}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="http://localhost:8080")
    ap.add_argument("--samples", default=str(HERE / "samples.jsonl"))
    ap.add_argument("--results", default=str(HERE / "results.csv"))
    args = ap.parse_args(argv)

    samples = [json.loads(l) for l in Path(args.samples).read_text(encoding="utf-8").splitlines() if l.strip()]
    with httpx.Client(base_url=args.base, timeout=120) as c:
        health = c.get("/health").json()
        model = health.get("model", "?")
        # one shop per expected language, so the "reply in the shop's language" rule and the
        # "mirror the user's language" rule agree and the script check is meaningful
        shops: dict[str, str] = {}

        def shop_for(lang: str) -> str:
            if lang not in shops:
                shops[lang] = c.post("/shops", json={"shop_name": "Eval Store", "owner_name": "Eval",
                                                     "language": lang}).json()["shop_id"]
            return shops[lang]

        rows, latencies, failures = [], [], 0
        for s in samples:
            lang = s["expected"].get("language", "hi-Latn")
            t0 = time.perf_counter()
            try:
                r = c.post("/chat", json={"shop_id": shop_for(lang), "text": s["text"]})
                status = r.status_code
            except httpx.HTTPError as exc:  # timeout / connection: count, don't crash
                r, status = None, f"{type(exc).__name__}"
            ms = (time.perf_counter() - t0) * 1000
            latencies.append(ms)
            if r is None or status != 200:
                failures += 1
                label = f"HTTP {status}" if r is not None else str(status)
                detail = ""
                if r is not None:
                    try:
                        detail = r.json().get("error", {}).get("message", "")[:120]
                    except Exception:
                        detail = ""
                print(f"  [{s['id']}] {label} {detail}")
                rows.append((s["id"], s["expected"]["intent"], label, "-", "-", ms, {},
                             lang, False, False, ""))
                continue
            rep = r.json()
            sc = score(s, rep)
            rows.append((s["id"], s["expected"]["intent"], rep["intent"],
                         "✓" if sc["intent"] else "✗",
                         "✓" if sc["entities"] else "✗", ms, sc["checks"],
                         lang, sc["language"], sc["script"], rep.get("reply_text", "")))

    n = len(samples)
    intent_acc = sum(1 for r in rows if r[3] == "✓") / n
    entity_acc = sum(1 for r in rows if r[4] == "✓") / n
    field_hits = {}
    for r in rows:
        for k, v in r[6].items():
            field_hits.setdefault(k, [0, 0])
            field_hits[k][0] += int(v)
            field_hits[k][1] += 1
    lat_sorted = sorted(latencies)
    p50 = statistics.median(lat_sorted)
    p95 = lat_sorted[min(len(lat_sorted) - 1, int(round(0.95 * len(lat_sorted))) - 1)]

    print(f"\nmodel={model}  base={args.base}  samples={n}\n")
    print(f"{'id':12} {'expected':13} {'got':13} {'int':3} {'ent':3} {'lng':3} {'scr':3} {'ms':>7}  detail")
    for r in rows:
        detail = " ".join(f"{k}={'✓' if v else '✗'}" for k, v in r[6].items())
        print(f"{r[0]:12} {r[1]:13} {r[2]:13} {r[3]:3} {r[4]:3} "
              f"{'✓' if r[8] else '✗':3} {'✓' if r[9] else '✗':3} {r[5]:7.0f}  {detail}")
    print()
    # per-language table
    by_lang: dict[str, list] = {}
    for r in rows:
        by_lang.setdefault(r[7], []).append(r)
    print(f"{'lang':8} {'n':>2} {'intent':>7} {'entity':>7} {'lang':>6} {'script':>7}  bad-script reply (first)")
    for lang, rs in sorted(by_lang.items()):
        k = len(rs)
        bad = next((r[10] for r in rs if not str(r[2]).startswith("HTTP") and not r[9]), "")
        print(f"{lang:8} {k:2} {sum(r[3] == '✓' for r in rs) / k:7.0%} {sum(r[4] == '✓' for r in rs) / k:7.0%} "
              f"{sum(bool(r[8]) for r in rs) / k:6.0%} {sum(bool(r[9]) for r in rs) / k:7.0%}  {bad[:60]}")
    print()
    script_acc = sum(1 for r in rows if r[9]) / n
    lang_acc = sum(1 for r in rows if r[8]) / n
    print(f"intent accuracy : {intent_acc:6.1%}")
    print(f"language detect : {lang_acc:6.1%}")
    print(f"reply in script : {script_acc:6.1%}")
    print(f"entity accuracy : {entity_acc:6.1%}   "
          + "  ".join(f"{k} {a}/{b}" for k, (a, b) in field_hits.items()))
    print(f"latency p50     : {p50:6.0f} ms")
    print(f"latency p95     : {p95:6.0f} ms")
    print(f"http failures   : {failures}")

    results = Path(args.results)
    new = not results.exists()
    with results.open("a", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        if new:
            w.writerow(["date", "model", "samples", "intent_acc", "entity_acc",
                        "p50_ms", "p95_ms", "http_failures", "language_acc", "script_acc"])
        w.writerow([datetime.now().isoformat(timespec="seconds"), model, n,
                    f"{intent_acc:.3f}", f"{entity_acc:.3f}", f"{p50:.0f}", f"{p95:.0f}", failures,
                    f"{lang_acc:.3f}", f"{script_acc:.3f}"])
    print(f"\nappended to {results}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
