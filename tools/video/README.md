# tools/video: builds the submission demo video

Produces `docs/submission/video/kirana-mitra-demo.mp4` (1280x720, H.264 + AAC, under 4 minutes) from the
**live** web app plus animated explainer pages, with Cloud Text-to-Speech narration and burned-in captions.

## One command

```bash
cd tools/video && uv sync && uv run playwright install chromium && \
GOOGLE_CLOUD_QUOTA_PROJECT=kirana-mitra-app uv run python build.py
```

Needs `ffmpeg` (`brew install ffmpeg`), `uv`, and application-default gcloud credentials for project
`kirana-mitra-app` with `texttospeech.googleapis.com` enabled (narration falls back to macOS `say` without it).
`--skip-record` reuses the last live recording in `build/live/`. The whole build takes about 12 minutes
(5 of them driving the live app, 5 rendering frames).

## Pipeline

| Step | Script | What it does |
|---|---|---|
| 1 | `record_live.py` | Playwright, headless Chromium at 390x844, records one video of the live web app. The Flutter canvas has no DOM inputs, so it enables Flutter's semantics tree and taps nodes by label with visible typing. Writes `marks.json` (beat boundaries, long-wait cuts). The voice note (Cloud TTS clip, `POST /voice-note`) and the shelf scan (`POST /shelf-scan` + `/confirm`) go to the live API for the same shop, replies saved as JSON. |
| 2 | `narrate.py` | One Cloud TTS call per sentence from `script.py` (voice `KM_TTS_VOICE`, default `en-IN-Neural2-B`), joined with 0.35 s gaps; `timing.json` gives exact caption times. |
| 3 | `render.py` | Serves `pages/` over a local HTTP server (fonts from `app/fonts`, photos from `docs/design`) and renders pages to PNG or to video by stepping every CSS animation frame by frame (deterministic, 25 fps). |
| 4 | `assemble.py` | Cuts each live beat from the recording, composes it on the phone backdrop, pads to the narration, overlays caption PNGs, fades, concatenates, encodes at CRF 23. Writes `build/storyboard.json`. |
| 5 | `write_docs.py` | `narration.md` and `storyboard.md` next to the MP4. `build.py` then extracts six frames to `frames/`. |

`script.py` is the single source for segment order, narration sentences and the side-panel text of live beats.
Pages: `opener.html` (Ramesh's problem), `howitworks.html` (architecture animation), `results.html` (metrics +
closing card), `voicecard.html` and `shelfcard.html` (live API replies rendered as cards), `backdrop.html`,
`caption.html`. Palette and type follow `docs/design/handoff.md`; the logo mark mirrors `app/lib/widgets/logo_mark.dart`.

## Known limits

- Hold-to-talk cannot be driven headless (no microphone) and the Sample shelf sheet does not open under headless
  Chromium, so those two beats show the live API reply in a card and say so on screen.
- The live app is a moving target: if a redeploy changes labels, `record_live.py` fails fast with the missing label.
- No background music (nothing CC0 at hand); add one in `assemble.py` only with attribution.
