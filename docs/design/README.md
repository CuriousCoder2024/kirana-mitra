# Kirana Mitra design

- **Design board (v2.1, October 2026):** https://claude.ai/artifact/Cv8J8Uh37PWCLuMfFFT1N2
  Twelve annotated phone frames at 360 × 780, the v2.1 friendliness audit, the Barni logo,
  colour and type tokens, the component kit, and a side-by-side of what changes versus the
  current Flutter build. Self-contained HTML; fonts
  from Google Fonts (Baloo 2, Noto Sans, Noto Sans Devanagari).
- **Flutter handoff:** [handoff.md](handoff.md). Tokens, type scale, spacing, every component
  with sizes, per-screen layout notes, and the full list of new and changed strings in
  Hinglish, Hindi and English.

- **Demo photos:** [assets/photos/](assets/photos/). Licensed pack photos for all 40 catalogue
  items (`items/<item_id>.jpg`, 512 px, with 120 px thumbs in `items/thumbs/`), eight real Indian
  shop shelves for the scan demo (`shelves/shelf_NN.jpg`, 1280 px), and
  [ATTRIBUTION.md](assets/photos/ATTRIBUTION.md) with source, author, licence and edits for every
  file. Rebuild with `uv run docs/design/assets/photos/fetch_photos.py` (Open Food Facts,
  Wikimedia Commons, then Vertex AI for gaps).
- **Pack illustrations:** [assets/items/](assets/items/), brand-colour SVG tiles used as the
  fallback when no photo exists.

The board is a private Claude artifact; share it from its Share menu before sending the link
outside the team.
