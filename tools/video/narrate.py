"""Narration: one Cloud Text-to-Speech call per sentence (en-IN Neural2), so caption timing is exact.

Writes build/narration/<segment>.wav (sentences joined with short gaps) and build/narration/timing.json
with each sentence's start and end inside its segment. Falls back to macOS `say` when the API is unavailable.
The text itself lives in script.py (also exported to docs/submission/video/narration.md).
"""
import json, os, subprocess, wave
from pathlib import Path

from script import SEGMENTS

HERE = Path(__file__).resolve().parent
OUT = HERE / "build" / "narration"
VOICE = os.environ.get("KM_TTS_VOICE", "en-IN-Neural2-B")
GAP = 0.35  # seconds between sentences
RATE = 24000


def _tts_cloud(text, path: Path):
    from google.cloud import texttospeech as t
    c = _tts_cloud.client = getattr(_tts_cloud, "client", None) or t.TextToSpeechClient()
    r = c.synthesize_speech(input=t.SynthesisInput(text=text),
                            voice=t.VoiceSelectionParams(language_code=VOICE[:5], name=VOICE),
                            audio_config=t.AudioConfig(audio_encoding=t.AudioEncoding.LINEAR16, sample_rate_hertz=RATE, speaking_rate=1.04))
    path.write_bytes(r.audio_content)


def _tts_say(text, path: Path):
    aiff = path.with_suffix(".aiff")
    subprocess.run(["say", "-v", "Rishi", "-o", str(aiff), text], check=True)
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(aiff), "-ar", str(RATE), "-ac", "1", "-sample_fmt", "s16", str(path)], check=True)
    aiff.unlink()


def wav_seconds(path: Path):
    with wave.open(str(path)) as w:
        return w.getnframes() / w.getframerate()


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    timing, engine = {}, "cloud-tts " + VOICE
    for seg in SEGMENTS:
        parts, t = [], 0.0
        for i, sentence in enumerate(seg["lines"]):
            p = OUT / f"{seg['id']}_{i:02d}.wav"
            if not p.exists():
                try:
                    _tts_cloud(sentence, p)
                except Exception as exc:  # noqa: BLE001
                    print("Cloud TTS failed, using macOS say:", exc); engine = "macos say"; _tts_say(sentence, p)
            d = wav_seconds(p)
            parts.append({"text": sentence, "start": round(t, 3), "end": round(t + d, 3), "file": p.name})
            t += d + GAP
        # join with gaps
        inputs, filt = [], []
        for i, part in enumerate(parts):
            inputs += ["-i", str(OUT / part["file"])]
            filt.append(f"[{i}:a]apad=pad_dur={GAP}[a{i}]")
        joined = OUT / f"{seg['id']}.wav"
        fc = ";".join(filt) + ";" + "".join(f"[a{i}]" for i in range(len(parts))) + f"concat=n={len(parts)}:v=0:a=1[out]"
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", *inputs, "-filter_complex", fc, "-map", "[out]", "-ar", str(RATE), "-ac", "1", str(joined)], check=True)
        timing[seg["id"]] = {"seconds": round(wav_seconds(joined), 3), "sentences": parts}
        print(f"{seg['id']:12s} {timing[seg['id']]['seconds']:6.2f} s  {len(parts)} sentences")
    timing["_engine"] = engine
    (OUT / "timing.json").write_text(json.dumps(timing, ensure_ascii=False, indent=1))
    total = sum(v["seconds"] for k, v in timing.items() if not k.startswith("_"))
    print(f"narration total {total:.1f} s")


if __name__ == "__main__":
    main()
