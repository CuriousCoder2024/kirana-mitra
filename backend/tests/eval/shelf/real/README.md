# Real shelf photos (eval set `real`)

The photos live in `docs/design/assets/photos/shelves/` (licensed by the design
session; see `ATTRIBUTION.md` there). They are referenced here by repo-relative
`path` and are not copied into `backend/`.

`labels.json` was filled by hand on 2026-10-18 at 2x crops. Only the backend's
15-item demo catalogue is labelled:

- `counts`: catalogue products identified with confidence, with a `tol` count
  tolerance (the photos are 1280 px wide and dense, so ±1 is honest even for a
  single visible facing);
- `maybe`: products that look like a catalogue brand but whose label is not
  readable at this resolution. Reported if Gemini returns them, never scored;
- `unmatched_expected`: brands that are clearly visible but outside the
  catalogue, which a good scan should list under `unmatched`.

Most of these photos show none of the 15 catalogue products at a readable size
(they are whole-shop or storefront views), so recall is measured over very few
labelled items; the synthetic set is the one that measures counting.

```bash
uv run python -m tests.eval.shelf.run --base http://localhost:8090 --set real
```
