"""Assemble docs/submission/video/kirana-mitra-demo.mp4 from the live recording, the rendered
explainer clips and the narration.

Per segment: video (live beat cut from the recording and composed on a phone backdrop, or a
rendered page), narration audio padded to the segment length, caption PNGs overlaid for each
sentence, 0.5 s fade in/out. Segments are concatenated and encoded once more at CRF 23.
Also writes build/storyboard.json (segment start times and sources) for storyboard.md.
"""
import asyncio, json, shutil, subprocess
from pathlib import Path

from render import Renderer
from script import SEGMENTS

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
BUILD = HERE / "build"
LIVE = BUILD / "live"
NARR = BUILD / "narration"
SEG = BUILD / "segments"
OUT_DIR = REPO / "docs" / "submission" / "video"
OUT = OUT_DIR / "kirana-mitra-demo.mp4"
FPS = 25
SCREEN = (150, 36, 300, 649)  # where the phone screen sits on backdrop.html
FADE = 0.5
MAX_WAIT_KEEP = 3.0


def run(cmd):
    subprocess.run(cmd, check=True)


def ffprobe_seconds(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)],
                         capture_output=True, text=True, check=True).stdout.strip()
    return float(out)


def beat_intervals(marks, cuts, start_name, end_name):
    """Kept [from, to] ranges of the recording for a beat, with long waits trimmed."""
    t = {m["name"]: m["t"] for m in marks}
    a, b = t[start_name], t[end_name]
    cuts = list(cuts)
    # idle time between a beat's start mark and its first tap (scroll hunting) is cut to 1 s
    for m1, m2 in zip(marks, marks[1:]):
        if m1["name"] == start_name and m2["name"].startswith("tap:") and m2["t"] - m1["t"] > 2.0:
            cuts.append({"from": m1["t"] + 1.0, "to": m2["t"] - 0.3, "why": "idle before " + m2["name"]})
    kept, cur = [], a
    for c in sorted(cuts, key=lambda c: c["from"]):
        if c["from"] >= a and c["to"] <= b:
            kept.append((cur, c["from"])); cur = c["to"]
    kept.append((cur, b))
    return [(x, y) for x, y in kept if y - x > 0.05]


BEATS = {  # beat id -> (start mark, end mark)
    "onboarding": ("onboarding:start", "onboarding:end"),
    "typed": ("typed:start", "typed:end"),
    "confirm": ("confirm:start", "confirm:end"),
    "stock+udhaar": ("stock:start", "udhaar:end"),
    "forecast": ("forecast:start", "forecast:end"),
    "hisaab": ("hisaab:start", "hisaab:end"),
}


async def build_live_clip(r, seg, rec, video, out_mp4):
    intervals = beat_intervals(rec["marks"], rec["cuts"], *BEATS[seg["beat"]])
    backdrop = SEG / f"{seg['id']}_backdrop.png"
    await r.render_still("backdrop.html", seg["panel"], backdrop)
    x, y, w, h = SCREEN
    parts, fc = [], []
    for i, (a, b) in enumerate(intervals):
        fc.append(f"[0:v]trim=start={a:.3f}:end={b:.3f},setpts=PTS-STARTPTS[p{i}]")
        parts.append(f"[p{i}]")
    fc.append("".join(parts) + f"concat=n={len(parts)}:v=1:a=0,scale={w}:{h}:flags=lanczos,fps={FPS}[phone]")
    fc.append(f"[1:v][phone]overlay={x}:{y}:format=auto:eof_action=endall[out]")
    run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(video), "-loop", "1", "-framerate", str(FPS), "-i", str(backdrop), "-filter_complex", ";".join(fc),
         "-map", "[out]", "-c:v", "libx264", "-preset", "veryfast", "-crf", "18", "-pix_fmt", "yuv420p", "-shortest", str(out_mp4)])
    return sum(b - a for a, b in intervals), intervals


async def finish_segment(r, seg, raw_mp4, timing, extra_audio=None, caption_style="wide"):
    """Pad video to the narration, add narration + captions + fades. Returns final length."""
    narr = timing[seg["id"]]
    vlen = ffprobe_seconds(raw_mp4)
    audio_lead = seg.get("audio_lead", 0.0)  # narration starts after this many seconds
    length = max(vlen, audio_lead + narr["seconds"] + 0.8)
    # captions
    caps = []
    for i, s in enumerate(narr["sentences"]):
        png = SEG / f"{seg['id']}_cap{i:02d}.png"
        await r.render_still("caption.html", {"text": s["text"], "style": caption_style}, png, transparent=True)
        caps.append((png, audio_lead + s["start"], audio_lead + s["end"] + 0.25))
    inputs = ["-i", str(raw_mp4), "-i", str(NARR / f"{seg['id']}.wav")]
    for png, _, _ in caps:
        inputs += ["-loop", "1", "-i", str(png)]
    fc = [f"[0:v]tpad=stop_mode=clone:stop_duration={max(0.0, length - vlen) + 0.5:.3f},trim=end={length:.3f},setpts=PTS-STARTPTS[v0]"]
    cur = "v0"
    for i, (png, a, b) in enumerate(caps):
        fc.append(f"[{cur}][{i + 2}:v]overlay=0:0:enable='between(t,{a:.3f},{b:.3f})':format=auto[v{i + 1}]"); cur = f"v{i + 1}"
    fc.append(f"[{cur}]fade=t=in:st=0:d={FADE},fade=t=out:st={length - FADE:.3f}:d={FADE}[vout]")
    if extra_audio:
        inputs += ["-i", str(extra_audio["file"])]
        fc.append(f"[1:a]adelay={int(audio_lead * 1000)}|{int(audio_lead * 1000)},apad[n]")
        fc.append(f"[{len(caps) + 2}:a]adelay={int(extra_audio['at'] * 1000)}|{int(extra_audio['at'] * 1000)},volume=1.0[x]")
        fc.append(f"[n][x]amix=inputs=2:duration=first:normalize=0,atrim=end={length:.3f},afade=t=out:st={length - FADE:.3f}:d={FADE}[aout]")
    else:
        fc.append(f"[1:a]adelay={int(audio_lead * 1000)}|{int(audio_lead * 1000)},apad,atrim=end={length:.3f},afade=t=out:st={length - FADE:.3f}:d={FADE}[aout]")
    final = SEG / f"{seg['id']}.mp4"
    run(["ffmpeg", "-y", "-loglevel", "error", *inputs, "-filter_complex", ";".join(fc), "-map", "[vout]", "-map", "[aout]",
         "-c:v", "libx264", "-preset", "veryfast", "-crf", "18", "-pix_fmt", "yuv420p", "-r", str(FPS),
         "-c:a", "aac", "-b:a", "160k", "-ar", "48000", "-ac", "2", "-t", f"{length:.3f}", str(final)])
    return final, length


async def main():
    SEG.mkdir(parents=True, exist_ok=True); OUT_DIR.mkdir(parents=True, exist_ok=True)
    rec = json.loads((LIVE / "marks.json").read_text())
    video = LIVE / rec["video"]
    timing = json.loads((NARR / "timing.json").read_text())
    voice = json.loads((LIVE / "voice_reply.json").read_text())
    shelf = json.loads((LIVE / "shelf_reply.json").read_text())
    story, finals, t_cursor = [], [], 0.0
    async with Renderer() as r:
        for seg in SEGMENTS:
            sid = seg["id"]
            raw = SEG / f"{sid}_raw.mp4"
            extra, style, source = None, "wide", ""
            if seg["kind"] == "live":
                vlen, intervals = await build_live_clip(r, seg, rec, video, raw)
                style = "right"
                source = f"live recording ({', '.join(f'{a:.1f}-{b:.1f}s' for a, b in intervals)} of the Playwright capture)"
            elif seg["kind"] == "anim":
                page_file = HERE / "pages" / seg["page"]
                if not (raw.exists() and raw.stat().st_mtime > max(page_file.stat().st_mtime, (HERE / "pages" / "common.css").stat().st_mtime)):
                    await r.render_animation(seg["page"], {}, seg["seconds"], raw)
                source = f"animation (pages/{seg['page']})"
            elif seg["kind"] == "card":
                if sid == "voice":
                    data = dict(voice, shop_id=rec["shop_id"], reply_at=round(3.6 + min(voice["seconds"], 4.0), 2))
                    extra = {"file": LIVE / "voice_note.wav", "at": 1.0}
                    seg["audio_lead"] = 3.4
                    source = f"animated card over the live POST /voice-note reply ({voice['seconds']} s, pages/{seg['page']})"
                else:
                    if not shelf:
                        print("no shelf scan reply; skipping the shelf card"); continue
                    data = dict(shelf, image_url=f"/app/assets/shelves/{shelf['shelf']}.jpg", reply_at=round(3.0 + min(shelf["seconds"], 5.0), 2),
                                caption=f"Sample shelf {shelf['shelf']}.jpg · Wikimedia Commons, CC BY-SA (see docs/design/assets/photos/ATTRIBUTION.md)")
                    source = f"animated card over the live POST /shelf-scan + /confirm replies ({shelf['seconds']} s, pages/{seg['page']})"
                await r.render_animation(seg["page"], data, seg["seconds"], raw)
            final, length = await finish_segment(r, seg, raw, timing, extra_audio=extra, caption_style=style)
            story.append({"id": sid, "title": seg["title"], "start": round(t_cursor, 2), "seconds": round(length, 2), "kind": seg["kind"], "source": source})
            print(f"{sid:12s} start {t_cursor:6.1f}  len {length:5.1f}  {source[:60]}")
            finals.append(final); t_cursor += length
    lst = SEG / "concat.txt"
    lst.write_text("".join(f"file '{f}'\n" for f in finals))
    run(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", str(lst),
         "-c:v", "libx264", "-preset", "medium", "-crf", "23", "-pix_fmt", "yuv420p", "-r", str(FPS), "-s", "1280x720",
         "-c:a", "aac", "-b:a", "160k", "-movflags", "+faststart", str(OUT)])
    total = ffprobe_seconds(OUT)
    (BUILD / "storyboard.json").write_text(json.dumps({"total": round(total, 2), "segments": story, "shop_id": rec["shop_id"],
                                                        "narration_engine": timing.get("_engine")}, indent=1))
    print(f"\nwrote {OUT}  {total:.1f} s  {OUT.stat().st_size / 1e6:.1f} MB")
    if total >= 240:
        print("WARNING: over 4 minutes")


if __name__ == "__main__":
    asyncio.run(main())
