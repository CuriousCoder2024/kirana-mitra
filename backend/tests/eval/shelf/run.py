"""Shelf-scan eval: `uv run python -m tests.eval.shelf.run --base http://localhost:8090`.

Posts every image in images/ to /shelf-scan and compares the returned counts
with labels.json. Reports, per image and overall: detection recall (labelled
products that came back), precision (returned products that were labelled),
exact-count rate (detected products whose count is exactly right), mean absolute
count error, and latency. Appends a row to results.csv with the date and model.
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

HERE = Path(__file__).parent


def _norm(s: str) -> str:
    return " ".join(s.lower().replace("-", " ").split())


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="http://localhost:8090")
    ap.add_argument("--labels", default=str(HERE / "labels.json"))
    ap.add_argument("--results", default=str(HERE / "results.csv"))
    args = ap.parse_args(argv)

    labels: dict = json.loads(Path(args.labels).read_text(encoding="utf-8"))
    rows = []
    with httpx.Client(base_url=args.base, timeout=120) as c:
        model = c.get("/health").json().get("model", "?")
        shop_id = c.post("/shops", json={"shop_name": "Shelf Eval", "owner_name": "Eval",
                                         "language": "hi-Latn"}).json()["shop_id"]
        for fname, meta in labels.items():
            path = HERE / "images" / fname
            truth = {_norm(k): v for k, v in meta["counts"].items()}
            mime = "image/png" if path.suffix.lower() == ".png" else "image/jpeg"
            t0 = time.perf_counter()
            r = c.post("/shelf-scan", data={"shop_id": shop_id},
                       files={"image": (fname, path.read_bytes(), mime)})
            ms = (time.perf_counter() - t0) * 1000
            if r.status_code != 200:
                rows.append({"image": fname, "ok": False, "status": r.status_code, "ms": ms,
                             "truth": truth, "got": {}, "reply": r.text[:200]})
                continue
            body = r.json()
            got = {}
            for it in body["items"]:
                got[_norm(it["name"])] = got.get(_norm(it["name"]), 0) + int(it["count"])
            rows.append({"image": fname, "ok": True, "status": 200, "ms": ms, "truth": truth,
                         "got": got, "reply": body["reply_text"]})

    # ---- scoring ----
    tp = fp = fn = 0
    exact = 0
    abs_errors: list[float] = []
    per_image = []
    for row in rows:
        truth, got = row["truth"], row["got"]
        detected = [k for k in truth if k in got]
        missed = [k for k in truth if k not in got]
        extra = [k for k in got if k not in truth]
        errs = [abs(got[k] - truth[k]) for k in detected]
        ex = sum(1 for k in detected if got[k] == truth[k])
        tp += len(detected); fn += len(missed); fp += len(extra)
        exact += ex
        abs_errors.extend(errs)
        per_image.append((row, detected, missed, extra, ex, errs))

    lat = sorted(r["ms"] for r in rows)
    p50 = statistics.median(lat) if lat else 0.0
    p95 = lat[min(len(lat) - 1, max(0, int(round(0.95 * len(lat))) - 1))] if lat else 0.0
    recall = tp / (tp + fn) if (tp + fn) else 0.0
    precision = tp / (tp + fp) if (tp + fp) else 0.0
    exact_rate = exact / tp if tp else 0.0
    mae = statistics.mean(abs_errors) if abs_errors else 0.0
    failures = sum(1 for r in rows if not r["ok"])

    print(f"\nmodel={model}  base={args.base}  images={len(rows)}\n")
    for row, detected, missed, extra, ex, errs in per_image:
        print(f"{row['image']:22} {row['ms']:7.0f} ms  "
              f"detected {len(detected)}/{len(row['truth'])}  exact {ex}/{len(detected) or 0}  "
              f"MAE {statistics.mean(errs) if errs else 0:.2f}")
        for k in row["truth"]:
            mark = "✓" if row["got"].get(k) == row["truth"][k] else "✗"
            print(f"    {mark} {k:14} true {row['truth'][k]:3}  got {row['got'].get(k, '-'):>3}")
        for k in extra:
            print(f"    + {k:14} extra     got {row['got'][k]:>3}")
        if not row["ok"]:
            print(f"    HTTP {row['status']}: {row['reply']}")
    print()
    print(f"detection recall : {recall:6.1%}   ({tp}/{tp + fn} labelled products found)")
    print(f"precision        : {precision:6.1%}   ({fp} unexpected products)")
    print(f"exact-count rate : {exact_rate:6.1%}   ({exact}/{tp} detected products counted exactly)")
    print(f"count MAE        : {mae:6.2f} units")
    print(f"latency p50/p95  : {p50:6.0f} / {p95:.0f} ms")
    print(f"http failures    : {failures}")

    results = Path(args.results)
    new = not results.exists()
    with results.open("a", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        if new:
            w.writerow(["date", "model", "images", "recall", "precision", "exact_count_rate",
                        "count_mae", "p50_ms", "p95_ms", "http_failures"])
        w.writerow([datetime.now().isoformat(timespec="seconds"), model, len(rows),
                    f"{recall:.3f}", f"{precision:.3f}", f"{exact_rate:.3f}", f"{mae:.2f}",
                    f"{p50:.0f}", f"{p95:.0f}", failures])
    print(f"\nappended to {results}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
