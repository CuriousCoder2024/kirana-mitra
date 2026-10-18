"""Render the pure animations (no live data) ahead of assemble.py; assemble reuses them when fresh."""
import asyncio
from pathlib import Path
from render import Renderer
from script import SEGMENTS
HERE = Path(__file__).resolve().parent
SEG = HERE / "build" / "segments"

async def main():
    SEG.mkdir(parents=True, exist_ok=True)
    async with Renderer() as r:
        for seg in SEGMENTS:
            if seg["kind"] == "anim":
                out = SEG / f"{seg['id']}_raw.mp4"
                await r.render_animation(seg["page"], {}, seg["seconds"], out)
                print("rendered", out.name)
asyncio.run(main())
