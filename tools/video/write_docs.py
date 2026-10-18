"""Write docs/submission/video/narration.md and storyboard.md from script.py and build/storyboard.json."""
import json
from pathlib import Path
from script import SEGMENTS

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
OUT = REPO / "docs" / "submission" / "video"


def mmss(t):
    return f"{int(t // 60)}:{int(t % 60):02d}"


def main():
    sb = json.loads((HERE / "build" / "storyboard.json").read_text())
    starts = {s["id"]: s for s in sb["segments"]}
    timing = json.loads((HERE / "build" / "narration" / "timing.json").read_text())
    live = HERE / "build" / "live"
    voice = json.loads((live / "voice_reply.json").read_text())
    shelf = json.loads((live / "shelf_reply.json").read_text()) or {}

    n = ["# Kirana Mitra demo video: narration", "",
         f"Spoken by Google Cloud Text-to-Speech ({sb.get('narration_engine')}), one call per sentence; the same sentences are burned in as captions.",
         "Hinglish lines are spoken as written. Total narration about "
         f"{sum(v['seconds'] for k, v in timing.items() if not k.startswith('_')):.0f} s inside a {sb['total']:.0f} s video.", ""]
    for seg in SEGMENTS:
        s = starts.get(seg["id"])
        if not s:
            continue
        n.append(f"## {mmss(s['start'])} · {seg['title']}")
        n.append("")
        for line in seg["lines"]:
            n.append(f"- {line}")
        n.append("")
    (OUT / "narration.md").write_text("\n".join(n))

    b = ["# Kirana Mitra demo video: storyboard", "",
         f"`kirana-mitra-demo.mp4`, 1280x720, H.264 + AAC, {sb['total']:.1f} s ({mmss(sb['total'])}). Built by `tools/video/build.py`",
         f"(see `tools/video/README.md`). Live beats were recorded headless against the web app and shop `{sb['shop_id']}` on Cloud Run on 2026-10-18;",
         "long Gemini/BigQuery waits inside a beat are trimmed to about 3 s (the storyboard says where). Nothing is mocked.", "",
         "| Start | Segment | Source | What it shows |", "|---|---|---|---|"]
    what = {
        "opener": "Ramesh and his shop (real shelf photo from docs/design), cartons in, packets out, udhaar, the \"Maggi khatam?\" moment, Bolo ho jayega.",
        "onboarding": "Shop name and owner typed, Hinglish selected, Shuru karo; POST /shops; the Namaste greeting.",
        "typed": "Typed \"Gupta ji ne 350 rupaye udhaar liya\" with visible typing, the live Samjha card (+₹350, total ₹350), Undo and \"Theek hai, hata diya\".",
        "confirm": "\"Verma ji ko shayad 120 ka udhaar diya\": confidence below 0.7, the Pakka nahi card, Haan add karo, then the Samjha card.",
        "voice": f"Synthesised voice note ({voice.get('audio_source')}) sent to POST /voice-note; Gemini transcript \"{voice['reply'].get('transcript')}\", reply \"{voice['reply'].get('reply_text')}\" in {voice['seconds']} s.",
        "shelf": (f"Sample shelf {shelf.get('shelf')}.jpg sent to POST /shelf-scan; counts {', '.join(f'{i['name']} {i['count']}' for i in shelf.get('reply', {}).get('items', []))}; Haan update karo = POST /confirm; \"{shelf.get('confirm', {}).get('reply', {}).get('reply_text')}\" ({shelf.get('seconds')} s)." if shelf else "skipped"),
        "stock": "Stock tab (low items first, Kam hai badges; Parle-G 114 after the voice note, scan counts applied) and the Udhaar bahi-khata with Verma ji.",
        "forecast": "Forecast tab: 4 past + 4 forecast weeks, Dussehra and Diwali markers, Parle-G chip, reason band, Order banao, the Order taiyaar sheet, WhatsApp pe bhejo (wa.me link opened, nothing sent).",
        "hisaab": "Chat menu > Aaj ka hisaab: sales, udhaar given/received, kul baaki, kam hai, next festival, Kal ka order banao.",
        "howitworks": "Animated architecture: Flutter app > Cloud Run (FastAPI) > Gemini 3.8 Flash (JSON with response schema) > Firestore / BigQuery ML > reply with Undo.",
        "results": "Metric tiles (intent 96.2%, entities 100%, shelf 25/26, WAPE 11.0% vs 19.6%, p50 2.5 s) with the synthetic-data caveat, then the closing card with team and links.",
    }
    for s in sb["segments"]:
        b.append(f"| {mmss(s['start'])} | {s['title']} | {s['source']} | {what.get(s['id'], '')} |")
    b += ["", "## Not captured live, and why", "",
          "- **Hold-to-talk voice**: headless Chromium has no microphone, so the voice beat sends a Cloud TTS clip to the same `POST /voice-note` and shows the request and the live reply in an animated card labelled as such.",
          "- **Shelf photo**: the app's Sample shelf sheet does not open under headless Chromium (the tap registers, the sheet never appears), so the same bundled photo is posted to `POST /shelf-scan` and `POST /confirm` for the recorded shop and shown in an animated card; the resulting counts are then visible live on the Stock tab.",
          "- Gemini and BigQuery waits longer than about 4 s are trimmed inside a beat (typing dots stay on screen for the first seconds). Reply latency is printed on the API cards.",
          ""]
    (OUT / "storyboard.md").write_text("\n".join(b))
    print("wrote narration.md and storyboard.md")


if __name__ == "__main__":
    main()
