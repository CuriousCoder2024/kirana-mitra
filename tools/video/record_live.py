"""Record the live Kirana Mitra web app with Playwright (headless Chromium).

Drives the Flutter web build through its semantics tree (no DOM inputs on canvas),
records one 390x844 video of the whole session, and writes marks.json with the
time of every beat boundary plus "cut" ranges (long Gemini/BigQuery waits to trim).
Voice note and shelf scan cannot be driven in headless Chromium (no microphone; the
sample-shelf sheet does not open headless), so they are sent to the live API for the
same shop and their replies are saved for the animated cards.

Usage: uv run python record_live.py [--out build/live] [--url URL] [--api URL]
"""
import argparse, asyncio, json, os, subprocess, sys, time
from pathlib import Path

import requests
from playwright.async_api import async_playwright

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
DEFAULT_URL = "https://storage.googleapis.com/kirana-mitra-app-web/index.html"
DEFAULT_API = "https://kirana-mitra-api-396621755403.asia-south1.run.app"
VOICE_TEXT_HI = "कल पारले-जी के तीन कार्टन आए।"
VOICE_TEXT_LATN = "Kal Parle-G ke 3 carton aaye"
SHELVES = ["shelf_02", "shelf_07"]  # the bundled sample shelves Gemini could count on 2026-10-18

DUMP = """() => Array.from(document.querySelectorAll('flt-semantics, flt-semantics *'))
 .filter(e=>e.tagName==='INPUT'||e.tagName==='TEXTAREA'||e.getAttribute('role')||(e.childElementCount===0 && (e.textContent||'').trim()))
 .slice(0,200).map(e=>{const r=e.getBoundingClientRect();return [e.tagName, e.getAttribute('role'),
 ((e.getAttribute('aria-label')||e.value||e.textContent||'')).trim().slice(0,120), r.x, r.y, r.width, r.height]})
 .filter(n=>n[5]>0)"""


class Recorder:
    def __init__(self, page, out: Path):
        self.page, self.out = page, out
        self.t0 = time.monotonic()
        self.marks, self.cuts = [], []

    def now(self):
        return round(time.monotonic() - self.t0, 3)

    def mark(self, name):
        t = self.now(); self.marks.append({"name": name, "t": t}); print(f"[{t:7.2f}] {name}", flush=True)

    async def nodes(self):
        return await self.page.evaluate(DUMP)

    async def node(self, text, role=None):
        for n in await self.nodes():
            if n[2].startswith(text) and (role is None or n[1] == role):
                return n

    async def tap(self, text, role="button"):
        n = await self.node(text, role)
        if not n:
            raise RuntimeError(f"no semantics node starting with {text!r}")
        # Scroll the Flutter scrollable until the node is inside the viewport (the DOM node cannot be scrolled).
        for _ in range(8):
            cy = n[4] + n[6] / 2
            if 70 <= cy <= 836:
                break
            await self.page.mouse.move(195, 500)
            await self.page.mouse.wheel(0, 260 if cy > 790 else -260)
            await self.page.wait_for_timeout(500)
            n = await self.node(text, role) or n
        await self.page.mouse.click(n[3] + n[5] / 2, n[4] + n[6] / 2)
        self.mark(f"tap:{text}")

    async def wait_for(self, text, timeout=120, keep=3.0, role=None):
        """Wait for a node; if the wait is long, register a cut so the edit keeps `keep` s of it."""
        t_start = self.now(); deadline = time.time() + timeout
        while time.time() < deadline:
            n = await self.node(text, role)
            if n:
                t_end = self.now()
                if t_end - t_start > keep + 1.0:
                    self.cuts.append({"from": round(t_start + keep - 0.8, 3), "to": round(t_end - 0.4, 3), "why": text})
                self.mark(f"seen:{text}")
                return n
            await self.page.wait_for_timeout(250)
        raise RuntimeError(f"timeout waiting for {text!r}")

    async def type_into(self, locator, text, delay=55):
        await locator.click(); await self.page.wait_for_timeout(450)
        await self.page.keyboard.type(text, delay=delay)

    async def pause(self, s):
        await self.page.wait_for_timeout(int(s * 1000))


def tts_voice_note(path: Path):
    """Synthesise the Hinglish voice note with Cloud TTS (hi-IN); fall back to macOS say."""
    try:
        from google.cloud import texttospeech as t
        c = t.TextToSpeechClient()
        r = c.synthesize_speech(input=t.SynthesisInput(text=VOICE_TEXT_HI),
                                voice=t.VoiceSelectionParams(language_code="hi-IN", name="hi-IN-Neural2-B"),
                                audio_config=t.AudioConfig(audio_encoding=t.AudioEncoding.LINEAR16, sample_rate_hertz=24000))
        path.write_bytes(r.audio_content); return "cloud-tts hi-IN-Neural2-B"
    except Exception as exc:  # noqa: BLE001
        print("Cloud TTS failed, using macOS say:", exc)
        aiff = path.with_suffix(".aiff")
        subprocess.run(["say", "-v", "Lekha", "-o", str(aiff), VOICE_TEXT_HI], check=True)
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(aiff), "-ar", "24000", "-ac", "1", str(path)], check=True)
        return "macos say Lekha"


def api_voice_note(api, shop_id, wav: Path):
    t0 = time.time()
    with wav.open("rb") as f:
        r = requests.post(f"{api}/voice-note", data={"shop_id": shop_id}, files={"audio": ("note.wav", f, "audio/wav")}, timeout=120)
    return {"status": r.status_code, "seconds": round(time.time() - t0, 2), "reply": r.json()}


def api_shelf_scan(api, shop_id):
    for attempt in range(4):
        shelf = SHELVES[min(attempt // 2, len(SHELVES) - 1)]
        img = REPO / "app" / "assets" / "shelves" / f"{shelf}.jpg"
        t0 = time.time()
        with img.open("rb") as f:
            r = requests.post(f"{api}/shelf-scan", data={"shop_id": shop_id}, files={"image": (f"{shelf}.jpg", f, "image/jpeg")}, timeout=150)
        body = r.json()
        print("shelf-scan", shelf, r.status_code, round(time.time() - t0, 1), str(body)[:160])
        if r.status_code == 200 and body.get("items"):
            scan = {"shelf": shelf, "status": r.status_code, "seconds": round(time.time() - t0, 2), "reply": body}
            mid = body["message_id"]
            c = requests.post(f"{api}/confirm", json={"shop_id": shop_id, "message_id": mid}, timeout=60)
            scan["confirm"] = {"status": c.status_code, "reply": c.json()}
            print("confirm", c.status_code, str(c.json())[:160])
            return scan
    return None


async def main(args):
    out = Path(args.out); out.mkdir(parents=True, exist_ok=True)
    voice_wav = out / "voice_note.wav"
    voice_src = tts_voice_note(voice_wav)
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        ctx = await browser.new_context(viewport={"width": 390, "height": 844}, device_scale_factor=2,
                                        record_video_dir=str(out), record_video_size={"width": 390, "height": 844})
        page = await ctx.new_page()
        R = Recorder(page, out)
        shop = {}
        page.on("response", lambda r: shop.update(id=None) if False else None)

        async def on_response(resp):
            if resp.url.endswith("/shops") and resp.request.method == "POST" and resp.ok:
                try:
                    shop.update(await resp.json())
                except Exception:  # noqa: BLE001
                    pass
        page.on("response", on_response)

        await page.goto(args.url)
        await page.wait_for_timeout(7000)
        await page.locator("flt-semantics-placeholder").dispatch_event("click")
        await R.wait_for("Dukaan ka naam", timeout=60)
        await R.pause(1.0)
        R.mark("onboarding:start")
        inputs = page.locator("flt-semantics input, flt-semantics textarea")
        await R.type_into(inputs.nth(0), "Gupta General Store", 65)
        await R.type_into(inputs.nth(1), "Ramesh Gupta", 65)
        await R.pause(0.8)
        await R.tap("Shuru karo")
        await R.wait_for("Namaste", keep=3.0)
        await R.pause(3.0)
        R.mark("onboarding:end")

        R.mark("typed:start")
        await R.tap("Likho"); await R.pause(0.7)
        await R.type_into(page.locator("flt-semantics textarea").first, "Gupta ji ne 350 rupaye udhaar liya", 55)
        await R.pause(0.5); await page.keyboard.press("Enter"); R.mark("send:udhaar")
        await R.wait_for("Undo", keep=4.0)
        await R.pause(4.0)
        await R.tap("Undo")
        await R.wait_for("Theek hai", keep=3.0)
        await R.pause(3.0)
        R.mark("typed:end")

        R.mark("confirm:start")
        await R.tap("Likho"); await R.pause(0.7)
        await R.type_into(page.locator("flt-semantics textarea").first, "Verma ji ko shayad 120 ka udhaar diya", 55)
        await R.pause(0.5); await page.keyboard.press("Enter"); R.mark("send:ambiguous")
        await R.wait_for("Haan, add karo", keep=4.0)
        await R.pause(3.5)
        await R.tap("Haan, add karo")
        await R.wait_for("Samjha · likh diya\nVerma", keep=3.0)
        await R.pause(2.5)
        R.mark("confirm:end")

        # Off-screen: voice note + shelf scan through the live API for the same shop.
        shop_id = shop.get("shop_id")
        if not shop_id:
            raise RuntimeError("shop_id not captured from POST /shops")
        R.mark("api:voice:start")
        voice = api_voice_note(args.api, shop_id, voice_wav); voice["audio_source"] = voice_src; voice["text"] = VOICE_TEXT_LATN
        (out / "voice_reply.json").write_text(json.dumps(voice, ensure_ascii=False, indent=1))
        print("voice-note", voice["status"], voice["seconds"], str(voice["reply"])[:200])
        R.mark("api:shelf:start")
        scan = api_shelf_scan(args.api, shop_id)
        (out / "shelf_reply.json").write_text(json.dumps(scan, ensure_ascii=False, indent=1))
        R.mark("api:end")

        R.mark("stock:start")
        await R.tap("Stock")
        await R.wait_for("Stock\n", keep=2.0, role=None)
        await R.pause(5.0)
        await page.mouse.move(195, 500); await page.mouse.wheel(0, 260); await R.pause(2.5)
        R.mark("stock:end")
        R.mark("udhaar:start")
        await R.tap("Udhaar"); await R.pause(5.0)
        R.mark("udhaar:end")

        R.mark("forecast:start")
        await R.tap("Forecast")
        await R.wait_for("Order banao", keep=3.0)
        await R.pause(2.0)
        await R.tap("Parle-G"); await R.pause(4.0)
        await R.tap("Order banao")
        await R.wait_for("WhatsApp pe bhejo", keep=3.0)
        await R.pause(3.5)
        try:
            async with page.expect_popup(timeout=4000) as pop:
                await R.tap("WhatsApp pe bhejo")
            popup = await pop.value
            R.mark("whatsapp:popup")
            await popup.wait_for_timeout(300)
            (out / "whatsapp_url.txt").write_text(popup.url)
            await popup.close()
        except Exception as exc:  # noqa: BLE001
            print("whatsapp popup:", exc)
        await R.pause(2.0)
        await page.keyboard.press("Escape"); await R.pause(0.8)
        R.mark("forecast:end")

        R.mark("hisaab:start")
        await R.tap("Baat"); await R.pause(1.0)
        await page.mouse.click(350, 32); await R.pause(1.2)
        await R.tap("Aaj ka hisaab", role="menuitem")
        await R.wait_for("Aaj ka hisaab\n", keep=3.0)
        await R.pause(5.0)
        R.mark("hisaab:end")

        video_path = await page.video.path()
        await ctx.close(); await browser.close()
        (out / "marks.json").write_text(json.dumps({"video": os.path.basename(video_path), "shop_id": shop_id,
                                                    "marks": R.marks, "cuts": R.cuts}, ensure_ascii=False, indent=1))
        print("video", video_path)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(HERE / "build" / "live"))
    ap.add_argument("--url", default=DEFAULT_URL)
    ap.add_argument("--api", default=DEFAULT_API)
    asyncio.run(main(ap.parse_args()))
