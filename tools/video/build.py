"""One command: record the live app, synthesise narration, render pages, assemble the MP4, write docs, extract frames.

  uv run python build.py            # everything
  uv run python build.py --skip-record   # reuse build/live from an earlier run
"""
import argparse, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
OUT = REPO / "docs" / "submission" / "video"


def step(name, *args):
    print(f"\n=== {name}", flush=True)
    subprocess.run([sys.executable, str(HERE / name), *args], check=True)


def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--skip-record", action="store_true"); a = ap.parse_args()
    if not a.skip_record:
        step("record_live.py")
    step("narrate.py")
    step("assemble.py")
    step("write_docs.py")
    frames = OUT / "frames"; frames.mkdir(exist_ok=True)
    mp4 = OUT / "kirana-mitra-demo.mp4"
    dur = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(mp4)], capture_output=True, text=True).stdout)
    for i in range(6):
        t = dur * (i + 0.5) / 6
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-ss", f"{t:.2f}", "-i", str(mp4), "-frames:v", "1", str(frames / f"frame_{i + 1}_{int(t):03d}s.jpg")], check=True)
    print(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "stream=codec_name,width,height:format=duration,size", "-of", "default=nw=1", str(mp4)], capture_output=True, text=True).stdout)


if __name__ == "__main__":
    main()
