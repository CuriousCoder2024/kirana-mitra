"""Render the HTML pages in tools/video/pages with Playwright.

- render_still(page, data, out_png): one PNG (backdrops, captions).
- render_animation(page, data, seconds, out_mp4): deterministic frame stepping. Every CSS animation
  on the page is paused and seeked to the frame time (Web Animations API), and pages may expose
  window.seek(t) for JS-driven values; each frame is screenshotted and ffmpeg encodes the sequence.
The pages are served over a local HTTP server rooted at the repo so they can use app/fonts and
docs/design photos with absolute paths.
"""
import asyncio, functools, http.server, json, shutil, socketserver, subprocess, tempfile, threading
from pathlib import Path

from playwright.async_api import async_playwright

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
FPS = 25


class _Quiet(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a):  # noqa: D102
        pass


class Server:
    def __init__(self):
        handler = functools.partial(_Quiet, directory=str(REPO))
        self.httpd = socketserver.TCPServer(("127.0.0.1", 0), handler)
        self.port = self.httpd.server_address[1]
        threading.Thread(target=self.httpd.serve_forever, daemon=True).start()

    def url(self, page):
        return f"http://127.0.0.1:{self.port}/tools/video/pages/{page}"

    def close(self):
        self.httpd.shutdown()


SEEK_JS = """(ms) => { document.getAnimations().forEach(a => { try { a.pause(); a.currentTime = ms; } catch (e) {} });
  if (window.seek) window.seek(ms / 1000); }"""


class Renderer:
    def __init__(self):
        self.server = Server()

    async def __aenter__(self):
        self.pw = await async_playwright().start()
        self.browser = await self.pw.chromium.launch()
        return self

    async def __aexit__(self, *exc):
        await self.browser.close(); await self.pw.stop(); self.server.close()

    async def _open(self, page_name, data, transparent=False):
        ctx = await self.browser.new_context(viewport={"width": 1280, "height": 720}, device_scale_factor=1)
        page = await ctx.new_page()
        await page.add_init_script(f"window.DATA = {json.dumps(data, ensure_ascii=False)};")
        await page.goto(self.server.url(page_name))
        await page.evaluate("document.fonts.ready")
        await page.wait_for_timeout(250)
        return ctx, page

    async def render_still(self, page_name, data, out_png, transparent=False, seek=None):
        ctx, page = await self._open(page_name, data)
        if seek is not None:
            await page.evaluate(SEEK_JS, int(seek * 1000))
        await page.screenshot(path=str(out_png), omit_background=transparent, animations="disabled" if seek is None else "allow")
        await ctx.close()

    async def render_animation(self, page_name, data, seconds, out_mp4, fps=FPS):
        ctx, page = await self._open(page_name, data)
        await page.evaluate(SEEK_JS, 0)
        tmp = Path(tempfile.mkdtemp(prefix="frames_"))
        n = int(round(seconds * fps))
        for i in range(n):
            await page.evaluate(SEEK_JS, int(i * 1000 / fps))
            await page.screenshot(path=str(tmp / f"f{i:05d}.png"), animations="allow")
        await ctx.close()
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", str(fps), "-i", str(tmp / "f%05d.png"),
                        "-c:v", "libx264", "-preset", "veryfast", "-crf", "18", "-pix_fmt", "yuv420p", str(out_mp4)], check=True)
        shutil.rmtree(tmp)
        return out_mp4


if __name__ == "__main__":  # quick visual check: stills of every page at a few times
    import sys
    out = HERE / "build" / "preview"; out.mkdir(parents=True, exist_ok=True)

    async def main():
        async with Renderer() as r:
            for name, ts in [("opener", [2, 8, 13, 19]), ("howitworks", [5, 12, 20, 24]), ("results", [6, 14])]:
                for t in ts:
                    await r.render_still(f"{name}.html", {}, out / f"{name}_{t:02d}.png", seek=t)
            await r.render_still("backdrop.html", {"title": "Typed entry, <span>Undo</span>", "step": "2 / 9", "bullets": ["Gemini returns structured JSON", "Written at once above 0.7 confidence", "One tap undoes it"]}, out / "backdrop.png")
            await r.render_still("caption.html", {"text": "Gemini returns structured data, not free text: intent, customer, amount, confidence.", "style": "right"}, out / "caption.png", transparent=True)
    asyncio.run(main())
