# /// script
# requires-python = ">=3.11"
# dependencies = ["requests>=2.32", "pillow>=10", "google-genai>=1.0"]
# ///
"""Fetch licensed demo photos for the Kirana Mitra catalogue and shelf-scan demo.

Run from the repo root:

    uv run docs/design/assets/photos/fetch_photos.py            # items + shelves, generate only what is missing
    uv run docs/design/assets/photos/fetch_photos.py --no-generate
    uv run docs/design/assets/photos/fetch_photos.py --only itm_012,itm_028
    uv run docs/design/assets/photos/fetch_photos.py --attribution   # rewrite ATTRIBUTION.md from manifest.json only

Sources, in order:
  1. Open Food Facts (food), Open Beauty Facts / Open Products Facts (non-food): front image of the
     Indian pack. Photos are CC BY-SA 3.0, data ODbL. The product page URL and the photographer
     (image uploader) are recorded.
  2. Wikimedia Commons for shelf photos, from a fixed list of titles reviewed by hand (CC BY / CC BY-SA).
  3. Vertex AI image model (gemini-3.1-flash-lite-image) for anything still missing; those files are
     marked "generated" and never carry a real logo.

Outputs (relative to this file): items/<item_id>.jpg (512 px long side, JPEG q80, < 60 KB),
items/thumbs/<item_id>.jpg (120 x 120 centre crop), shelves/shelf_NN.jpg (1280 px, < 300 KB),
manifest.json (machine-readable provenance) and ATTRIBUTION.md (human-readable).
Existing files are kept unless --force is given, so re-runs only fill gaps.
"""
from __future__ import annotations

import argparse
import csv
import html
import io
import json
import os
import re
import sys
import time
from pathlib import Path

import requests
from PIL import Image, ImageOps

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
CATALOGUE = REPO / "data" / "catalogue.csv"
ITEMS_DIR = HERE / "items"
THUMBS_DIR = ITEMS_DIR / "thumbs"
SHELVES_DIR = HERE / "shelves"
MANIFEST = HERE / "manifest.json"
ATTRIBUTION = HERE / "ATTRIBUTION.md"

UA = "KiranaMitra/0.1 (https://github.com/vipindev-shambu/kirana-mitra; vipvipindev@gmail.com)"
S = requests.Session()
S.headers["User-Agent"] = UA

# Vertex AI image model. Chosen from the model lifecycle page on 2026-10-18:
# https://docs.cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions
# (gemini-3.1-flash-lite-image, GA 2026-06-23, 1,120 output tokens per 1K image, region "global").
# Imagen 3/4 endpoints are listed as discontinued there and on
# https://docs.cloud.google.com/vertex-ai/generative-ai/docs/image/overview
IMAGE_MODEL = "gemini-3.1-flash-lite-image"
GCP_PROJECT = os.environ.get("GOOGLE_CLOUD_PROJECT", "kirana-mitra-app")
GCP_LOCATION = os.environ.get("GOOGLE_CLOUD_LOCATION", "global")

# ---------------------------------------------------------------------------
# Item search terms. key = item_id; value = (db, query, extra words that must appear in the name)
# db: "food" -> Open Food Facts, "beauty" -> Open Beauty Facts, "products" -> Open Products Facts.
# A barcode in PREFERRED pins a specific product when the automatic pick is wrong.
# ---------------------------------------------------------------------------
SEARCH: dict[str, tuple[str, str, list[str]]] = {
    "itm_001": ("food", "parle-g", ["parle"]),
    "itm_002": ("food", "maggi masala noodles", ["maggi"]),
    "itm_003": ("food", "tata salt", ["tata", "salt"]),
    "itm_004": ("food", "aashirvaad atta", ["aashirvaad"]),
    "itm_005": ("products", "surf excel", ["surf"]),
    "itm_006": ("food", "amul taaza", ["amul"]),
    "itm_007": ("food", "amul butter", ["amul", "butter"]),
    "itm_008": ("food", "britannia good day", ["good day"]),
    "itm_009": ("beauty", "colgate strong teeth", ["colgate"]),
    "itm_010": ("beauty", None, ["lifebuoy"]),  # every Indian Lifebuoy entry is handwash or bodywash; the bar is generated
    "itm_011": ("food", "fortune sunflower oil", ["fortune"]),
    "itm_012": ("food", "red label tea", ["red label"]),
    "itm_013": ("food", "nescafe classic", ["nescafe"]),
    "itm_014": ("food", "haldiram aloo bhujia", ["bhujia"]),
    "itm_015": ("beauty", "dettol antiseptic liquid", ["dettol"]),
    "itm_016": ("products", "vim dishwash bar", ["vim"]),
    "itm_017": ("beauty", "clinic plus shampoo", ["clinic"]),
    "itm_018": ("food", "kurkure masala munch", ["kurkure"]),
    "itm_019": ("food", "lays magic masala", ["magic masala"]),
    "itm_020": ("food", "thums up", ["thums"]),
    "itm_021": ("food", "frooti", ["frooti"]),
    "itm_022": ("food", "cadbury dairy milk", ["dairy milk"]),
    "itm_023": ("food", "kissan tomato ketchup", ["kissan"]),
    "itm_024": ("food", "mdh garam masala", ["mdh"]),
    "itm_025": ("food", "everest chhole masala", ["everest"]),
    "itm_026": ("food", "toor dal", ["toor"]),
    "itm_027": ("food", "india gate basmati rice", ["india gate"]),
    "itm_028": ("food", None, ["sugar"]),  # loose sugar: no branded pack, always generated
    "itm_029": ("products", "rin detergent bar", ["rin"]),
    "itm_030": ("products", "harpic toilet cleaner", ["harpic"]),
    "itm_031": ("products", "good knight refill", ["good knight"]),
    "itm_032": ("beauty", "dove cream beauty bar", ["dove"]),
    "itm_033": ("products", "pampers baby dry pants", ["pampers"]),
    "itm_034": ("beauty", "whisper ultra clean", ["whisper"]),
    "itm_035": ("food", "bisleri", ["bisleri"]),
    "itm_036": ("food", "bournvita", ["bournvita"]),
    "itm_037": ("food", "horlicks classic", ["horlicks"]),
    "itm_038": ("food", "amul cow ghee", ["amul", "ghee"]),
    "itm_039": ("food", "besan gram flour", ["besan"]),
    "itm_040": ("products", "cycle agarbatti", ["cycle"]),
}
# Barcodes whose front photo is unusable for a tile (back of pack, barcode label, wrong product).
BLOCKED: set[str] = {
    "8901030686030",  # itm_010 bodywash
    "8901725121112",  # itm_004
    "8901030813252",  # itm_010
    "8901030984709",  # itm_017
    "7622201443290",  # itm_022
    "8901030534898",  # itm_023
    "8901030968266",  # itm_029
    "8901030807190",  # itm_037
}
PREFERRED: dict[str, str] = {  # item_id -> barcode, pinned by hand after reviewing the contact sheet
    "itm_003": "8904043901015",  # Tata Salt 1 kg (the automatic pick was Tata rock salt)
}

DB_HOST = {
    "food": "https://world.openfoodfacts.org",
    "beauty": "https://world.openbeautyfacts.org",
    "products": "https://world.openproductsfacts.org",
}
DB_LICENCE = "Photos CC BY-SA 3.0 (https://creativecommons.org/licenses/by-sa/3.0/), data ODbL"
DB_NAME = {"food": "Open Food Facts", "beauty": "Open Beauty Facts", "products": "Open Products Facts"}

# Shelf photos: reviewed by hand on 2026-10-18 for visible, countable packs. All CC BY or CC BY-SA.
SHELF_TITLES = [
    "File:Maligaiadai.jpg",
    "File:Grocery Shop in a small Town in South India (1).JPG",
    "File:Inside of a grocery store in West Bengal.jpg",
    "File:Provisions Shop Simsa Manali Himachal May24 A7CR 00124.jpg",
    "File:Taliparamba grocery.jpg",
    "File:Grocery Shop in a small Town in South India (2).JPG",
    "File:Retail grocery shopping in Corona pandemic India.jpg",
    "File:Grocery store, Kendriya Vihar.jpg",
]
SHELF_GENERATED_PROMPT = (
    "Photograph of a crowded Indian kirana (small grocery) shop shelf, natural daylight, eye level, "
    "sharp focus: strips of shampoo sachets hanging from the top rail, stacked biscuit packets, "
    "instant noodle packs, salt packets, 5 kg atta bags, small handwritten Hinglish price tags "
    "like 'Rs 10' and '5 ka 2'. Every pack is a plain generic design with invented brand names, "
    "no real logos. Realistic, slightly worn shelves, no people."
)

# ---------------------------------------------------------------------------
def log(*a):
    print(*a, file=sys.stderr, flush=True)


def load_catalogue() -> list[dict]:
    with CATALOGUE.open(encoding="utf-8") as f:
        return list(csv.DictReader(f))


def load_manifest() -> dict:
    if MANIFEST.exists():
        return json.loads(MANIFEST.read_text(encoding="utf-8"))
    return {"items": {}, "shelves": {}, "generated_count": 0}


def save_manifest(m: dict):
    MANIFEST.write_text(json.dumps(m, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")


def get_json(url, params=None, tries=3):
    for i in range(tries):
        try:
            r = S.get(url, params=params, timeout=30)
            if r.status_code == 200 and r.headers.get("content-type", "").startswith("application/json"):
                return r.json()
            log(f"  {url} -> {r.status_code}")
        except requests.RequestException as e:
            log(f"  {url} -> {e}")
        time.sleep(2 * (i + 1))
    return None


def get_bytes(url, tries=3):
    for i in range(tries):
        try:
            r = S.get(url, timeout=60)
            if r.status_code == 200:
                return r.content
            log(f"  {url} -> {r.status_code}")
        except requests.RequestException as e:
            log(f"  {url} -> {e}")
        time.sleep(2 * (i + 1))
    return None


def save_jpeg(im: Image.Image, path: Path, long_side: int, max_bytes: int, start_q=80):
    im = ImageOps.exif_transpose(im).convert("RGB")
    im.thumbnail((long_side, long_side), Image.LANCZOS)
    q = start_q
    while True:
        buf = io.BytesIO()
        im.save(buf, "JPEG", quality=q, optimize=True, progressive=True)
        if buf.tell() <= max_bytes or q <= 40:
            break
        q -= 5
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(buf.getvalue())
    return im.size, buf.tell(), q


def save_thumb(src: Path, dst: Path, size=120):
    im = ImageOps.exif_transpose(Image.open(src)).convert("RGB")
    im = ImageOps.fit(im, (size, size), Image.LANCZOS, centering=(0.5, 0.5))
    dst.parent.mkdir(parents=True, exist_ok=True)
    im.save(dst, "JPEG", quality=82, optimize=True)


# ---------------------------------------------------------------------------
# Open *Facts
# ---------------------------------------------------------------------------
FIELDS = "code,product_name,brands,countries_tags,image_front_url,images,selected_images"


def search_products(db: str, query: str, must: list[str]) -> list[dict]:
    hits: list[dict] = []
    if db == "food":
        # search-a-licious stays up when the main site is overloaded
        d = get_json("https://search.openfoodfacts.org/search", {"q": query, "page_size": 20, "fields": FIELDS})
        if d:
            hits = d.get("hits", [])
    if not hits:
        d = get_json(f"{DB_HOST[db]}/api/v2/search", {"search_terms": query, "page_size": 20, "fields": FIELDS})
        if d:
            hits = d.get("products", [])
    if not hits or not any(score(h, must) > 0 for h in hits):
        d = get_json(f"{DB_HOST[db]}/cgi/search.pl",
                     {"search_terms": query, "search_simple": 1, "action": "process", "json": 1, "page_size": 20, "fields": FIELDS})
        if d:
            hits = hits + d.get("products", [])
    return hits


def score(p: dict, must: list[str]) -> int:
    name = p.get("product_name") or ""
    brands = p.get("brands") or ""
    if isinstance(name, list):
        name = " ".join(name)
    if isinstance(brands, list):
        brands = " ".join(brands)
    name, brands = name.lower(), brands.lower()
    s = 0
    if not p.get("image_front_url") or not name.strip():
        return -99
    if not all(w in name or w in brands for w in must):
        return -99
    if "en:india" in (p.get("countries_tags") or []):
        s += 3
    s += 2 * len(must)
    if len(name) > 60:
        s -= 1
    return s


def front_image_meta(db: str, code: str) -> tuple[str | None, str | None, str | None]:
    """Returns (full image url, uploader, language key) for the front image of a product."""
    d = get_json(f"{DB_HOST[db]}/api/v2/product/{code}", {"fields": "images,image_front_url,product_name"})
    if not d or d.get("status") == 0:
        return None, None, None
    prod = d.get("product", {})
    images = prod.get("images", {}) or {}
    front_key = next((k for k in images if k.startswith("front_")), None) or ("front" if "front" in images else None)
    uploader = None
    if front_key:
        imgid = str(images[front_key].get("imgid", ""))
        uploader = (images.get(imgid) or {}).get("uploader")
    url = prod.get("image_front_url")
    if url:
        url = re.sub(r"\.(\d+)\.jpg$", ".full.jpg", url)
    return url, uploader, front_key


def fetch_item(item: dict, manifest: dict, force=False) -> bool:
    iid = item["item_id"]
    out = ITEMS_DIR / f"{iid}.jpg"
    if out.exists() and not force and iid in manifest["items"]:
        return True
    db, query, must = SEARCH[iid]
    if query is None:
        log(f"{iid} {item['name']}: loose item, left for generation")
        return False
    log(f"{iid} {item['name']}: searching {DB_NAME[db]} for '{query}'")
    if PREFERRED.get(iid):
        d = get_json(f"{DB_HOST[db]}/api/v2/product/{PREFERRED[iid]}", {"fields": FIELDS})
        hits = [d["product"]] if d and d.get("product") else []
        must = []  # pinned by hand, no name check
    else:
        hits = search_products(db, query, must)
    hits = [h for h in hits if h.get("code") not in BLOCKED]
    ranked = sorted(hits, key=lambda p: score(p, must), reverse=True)
    for p in ranked[:5]:
        if score(p, must) < 2:
            break
        code = p.get("code")
        url, uploader, _ = front_image_meta(db, code)
        url = url or p.get("image_front_url")
        if not url:
            continue
        data = get_bytes(url)
        if not data:
            continue
        try:
            im = Image.open(io.BytesIO(data))
        except Exception as e:
            log(f"  bad image for {code}: {e}")
            continue
        if min(im.size) < 200:
            continue
        size, nbytes, q = save_jpeg(im, out, 512, 60_000)
        save_thumb(out, THUMBS_DIR / f"{iid}.jpg")
        manifest["items"][iid] = {
            "name": item["name"], "file": f"items/{iid}.jpg", "thumb": f"items/thumbs/{iid}.jpg",
            "source": DB_NAME[db], "product_name": " ".join(p["product_name"]) if isinstance(p.get("product_name"), list) else p.get("product_name"), "barcode": code,
            "source_url": f"{DB_HOST[db]}/product/{code}", "image_url": url,
            "author": uploader or "unknown (Open Facts contributor)", "licence": DB_LICENCE,
            "edits": f"downscaled to {size[0]}x{size[1]}, JPEG q{q}, {nbytes} bytes; 120 px centre-crop thumb",
            "generated": False,
        }
        save_manifest(manifest)
        log(f"  ok: {manifest['items'][iid]['product_name']} [{code}] by {uploader} -> {size} {nbytes}B")
        return True
    log(f"  no usable photo for {iid}")
    return False


# ---------------------------------------------------------------------------
# Wikimedia Commons shelves
# ---------------------------------------------------------------------------
def strip_html(s: str | None) -> str:
    return html.unescape(re.sub(r"<[^>]+>", "", s or "")).strip()


def fetch_shelves(manifest: dict, force=False):
    api = "https://commons.wikimedia.org/w/api.php"
    d = get_json(api, {"action": "query", "titles": "|".join(SHELF_TITLES), "prop": "imageinfo",
                       "iiprop": "url|extmetadata|size", "iiurlwidth": 1600, "format": "json"})
    if not d:
        log("Commons query failed")
        return
    pages = {p["title"]: p for p in d["query"]["pages"].values() if "imageinfo" in p}
    for n, title in enumerate(SHELF_TITLES, start=1):
        key = f"shelf_{n:02d}"
        out = SHELVES_DIR / f"{key}.jpg"
        if out.exists() and not force and key in manifest["shelves"]:
            continue
        p = pages.get(title)
        if not p:
            log(f"{key}: {title} not found")
            continue
        ii = p["imageinfo"][0]
        em = ii.get("extmetadata", {})
        licence = em.get("LicenseShortName", {}).get("value", "")
        if not re.match(r"^(CC0|CC BY(-SA)? \d(\.\d)?|Public domain)", licence):
            log(f"{key}: skipping {title}, licence {licence}")
            continue
        data = get_bytes(ii.get("thumburl") or ii["url"])
        if not data:
            continue
        size, nbytes, q = save_jpeg(Image.open(io.BytesIO(data)), out, 1280, 300_000)
        manifest["shelves"][key] = {
            "file": f"shelves/{key}.jpg", "source": "Wikimedia Commons", "title": title,
            "source_url": ii["descriptionurl"], "author": strip_html(em.get("Artist", {}).get("value")),
            "licence": licence, "licence_url": em.get("LicenseUrl", {}).get("value", ""),
            "edits": f"downscaled to {size[0]}x{size[1]}, JPEG q{q}, {nbytes} bytes", "generated": False,
        }
        save_manifest(manifest)
        log(f"{key}: {title} ({licence}) -> {size} {nbytes}B")


# ---------------------------------------------------------------------------
# Vertex AI generation
# ---------------------------------------------------------------------------
_client = None


def genai_client():
    global _client
    if _client is None:
        from google import genai
        _client = genai.Client(vertexai=True, project=GCP_PROJECT, location=GCP_LOCATION)
    return _client


def generate_image(prompt: str, aspect: str = "1:1") -> Image.Image | None:
    client = genai_client()
    resp = None
    for attempt in range(5):
        try:
            resp = _generate(client, prompt, aspect)
            break
        except Exception as e:  # 429 RESOURCE_EXHAUSTED: per-minute quota on the image model
            if "429" in str(e) or "RESOURCE_EXHAUSTED" in str(e):
                wait = 30 * (attempt + 1)
                log(f"  quota hit, waiting {wait}s")
                time.sleep(wait)
                continue
            raise
    if resp is None:
        raise RuntimeError("image generation kept returning 429")
    for cand in resp.candidates or []:
        for part in cand.content.parts or []:
            if getattr(part, "inline_data", None) and part.inline_data.data:
                return Image.open(io.BytesIO(part.inline_data.data))
    return None


def _generate(client, prompt: str, aspect: str):
    from google.genai import types
    return client.models.generate_content(
        model=IMAGE_MODEL, contents=prompt,
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE"],
            image_config=types.ImageConfig(aspect_ratio=aspect),
        ),
    )


def item_prompt(item: dict) -> str:
    generic = {
        "Parle-G": ("glucose biscuits", "yellow and white striped wrapper with red accents"),
        "Maggi Masala Noodles": ("instant masala noodles", "bright yellow pouch with a red band"),
        "Tata Salt": ("iodised salt", "deep blue pouch with a white panel"),
        "Aashirvaad Atta": ("whole wheat atta flour, 5 kg", "orange and red bag with a cream label"),
        "Surf Excel Detergent Powder": ("detergent powder", "royal blue pouch with a white swoosh"),
        "Amul Taaza Milk": ("toned milk pouch, 500 ml", "white pouch with a blue band"),
        "Amul Butter": ("salted butter, 100 g", "yellow block with a blue wrapper band"),
        "Britannia Good Day": ("butter cookies", "green and yellow wrapper"),
        "Colgate Strong Teeth": ("toothpaste", "red carton with a white band"),
        "Lifebuoy Soap": ("bar soap", "red wrapper with a white shield"),
        "Fortune Sunflower Oil": ("sunflower oil, 1 litre bottle", "yellow bottle with a green label"),
        "Red Label Tea": ("tea leaves, 250 g", "red carton with a gold band"),
        "Nescafe Classic": ("instant coffee jar, 50 g", "brown glass jar with a red cap and label"),
        "Haldiram Aloo Bhujia": ("aloo bhujia namkeen", "orange pouch with a yellow band"),
        "Dettol Antiseptic Liquid": ("antiseptic liquid, 110 ml", "green and brown bottle"),
        "Vim Dishwash Bar": ("dishwash bar", "green and yellow wrapper with a lemon"),
        "Clinic Plus Shampoo": ("shampoo bottle, 80 ml", "white bottle with green and red accents"),
        "Kurkure Masala Munch": ("crunchy corn snack", "orange and green pouch"),
        "Lays Magic Masala": ("potato chips", "blue pouch with a sun mark"),
        "Thums Up": ("cola, 750 ml PET bottle", "black bottle with a red label"),
        "Frooti Mango": ("mango drink, 160 ml tetra pack", "green and yellow pack with a mango"),
        "Cadbury Dairy Milk": ("milk chocolate bar, 24 g", "purple wrapper"),
        "Kissan Tomato Ketchup": ("tomato ketchup, 500 g", "red squeeze bottle"),
        "MDH Garam Masala": ("garam masala spice carton, 100 g", "red carton with a white band"),
        "Everest Chhole Masala": ("chhole masala spice carton, 100 g", "red and yellow carton"),
        "Toor Dal": ("toor dal (split pigeon peas), loose, 1 kg", "clear bag of yellow lentils"),
        "India Gate Basmati Rice": ("basmati rice, 5 kg", "white and green bag with a gate mark"),
        "Sugar": ("white sugar, loose, 1 kg", "clear bag of sugar"),
        "Rin Detergent Bar": ("detergent bar", "blue wrapper with white lettering"),
        "Harpic Toilet Cleaner": ("toilet cleaner, 500 ml", "blue angled bottle"),
        "Good Knight Refill": ("mosquito repellent liquid refill, 45 ml", "small red and white carton"),
        "Dove Cream Beauty Bar": ("beauty soap bar", "white carton with a gold dove silhouette"),
        "Pampers Baby Dry Pants M": ("baby diaper pants, pack of 10", "green and white pack"),
        "Whisper Ultra Clean XL": ("sanitary pads, pack of 7", "green and purple pack"),
        "Bisleri Water": ("mineral water, 1 litre bottle", "clear bottle with a green and blue label"),
        "Bournvita": ("chocolate malt drink jar, 500 g", "brown jar with a green cap"),
        "Horlicks Classic": ("malted milk drink jar, 500 g", "blue jar with a white cap"),
        "Amul Cow Ghee": ("cow ghee, 500 ml carton", "yellow and white carton"),
        "Besan": ("besan (gram flour), 500 g", "yellow pouch with gram flour"),
        "Cycle Pure Agarbatti": ("incense sticks, 100 sticks", "maroon and gold box"),
    }
    kind, look = generic.get(item["name"], (item["name"].lower(), "plain pack in brand colours"))
    return (
        f"Product photo of a single {kind} pack as sold in an Indian kirana shop, front-facing, "
        f"centred, on a plain white background, soft studio light, sharp focus. Pack design: {look}. "
        f"The pack carries a simple invented wordmark describing the product (for example "
        f"'{kind.split(',')[0].title()}') in a generic typeface. Do not reproduce any real brand logo, "
        f"mascot or trademarked lettering. No hands, no shadows other than a soft contact shadow."
    )


def generate_missing_items(items: list[dict], manifest: dict, budget: int):
    n = 0
    for item in items:
        iid = item["item_id"]
        if iid in manifest["items"]:
            continue
        if n >= budget:
            log("generation budget reached")
            break
        log(f"{iid} {item['name']}: generating with {IMAGE_MODEL}")
        try:
            im = generate_image(item_prompt(item), "1:1")
        except Exception as e:
            log(f"  generation failed: {e}")
            continue
        if im is None:
            log("  no image returned")
            continue
        out = ITEMS_DIR / f"{iid}.jpg"
        size, nbytes, q = save_jpeg(im, out, 512, 60_000)
        save_thumb(out, THUMBS_DIR / f"{iid}.jpg")
        manifest["items"][iid] = {
            "name": item["name"], "file": f"items/{iid}.jpg", "thumb": f"items/thumbs/{iid}.jpg",
            "source": f"generated with Vertex AI {IMAGE_MODEL}", "source_url": "https://docs.cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions",
            "author": "AI-generated (team singapuria_innovators prompt)", "licence": "Generated image; no third-party rights claimed. Generic pack, no real logo.",
            "edits": f"downscaled to {size[0]}x{size[1]}, JPEG q{q}, {nbytes} bytes; 120 px centre-crop thumb",
            "generated": True, "prompt": item_prompt(item),
        }
        manifest["generated_count"] = manifest.get("generated_count", 0) + 1
        n += 1
        save_manifest(manifest)
        log(f"  ok -> {size} {nbytes}B")


def generate_missing_shelves(manifest: dict, want: int, budget: int):
    n = 0
    idx = len(SHELF_TITLES) + 1
    while len(manifest["shelves"]) < want and n < budget:
        key = f"shelf_{idx:02d}"
        idx += 1
        if key in manifest["shelves"]:
            continue
        log(f"{key}: generating with {IMAGE_MODEL}")
        try:
            im = generate_image(SHELF_GENERATED_PROMPT, "4:3")
        except Exception as e:
            log(f"  generation failed: {e}")
            break
        if im is None:
            break
        out = SHELVES_DIR / f"{key}.jpg"
        size, nbytes, q = save_jpeg(im, out, 1280, 300_000)
        manifest["shelves"][key] = {
            "file": f"shelves/{key}.jpg", "source": f"generated with Vertex AI {IMAGE_MODEL}",
            "source_url": "https://docs.cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions",
            "author": "AI-generated (team singapuria_innovators prompt)", "licence": "Generated image; no third-party rights claimed.",
            "edits": f"downscaled to {size[0]}x{size[1]}, JPEG q{q}, {nbytes} bytes", "generated": True, "prompt": SHELF_GENERATED_PROMPT,
        }
        manifest["generated_count"] = manifest.get("generated_count", 0) + 1
        n += 1
        save_manifest(manifest)


# ---------------------------------------------------------------------------
def write_attribution(manifest: dict, items: list[dict]):
    names = {i["item_id"]: i for i in items}
    lines = [
        "# Photo attribution",
        "",
        "Every file under `docs/design/assets/photos/` with its source, author, licence and edits.",
        "Generated by `fetch_photos.py` from `manifest.json`; edit the manifest, not this file.",
        "",
        "Open Food Facts / Open Beauty Facts / Open Products Facts photos are licensed",
        "[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) (data under the ODbL);",
        "the author is the contributor who uploaded the front image. Wikimedia Commons photos carry the",
        "licence shown on their file page. Files marked **generated** were made with Vertex AI",
        f"`{IMAGE_MODEL}` from a prompt that asks for a generic pack without any real logo; they are",
        "demo placeholders, not photographs of real products.",
        "",
        "## Items",
        "",
        "| File | Item | Source | Author | Licence | Edits |",
        "|---|---|---|---|---|---|",
    ]
    for iid in sorted(names):
        m = manifest["items"].get(iid)
        if not m:
            lines.append(f"| `items/{iid}.jpg` | {names[iid]['name']} | (missing) | | | |")
            continue
        src = f"**generated** ([model]({m['source_url']}))" if m["generated"] else f"[{m['source']}: {m.get('product_name') or ''} ({m.get('barcode')})]({m['source_url']})"
        lines.append(f"| `{m['file']}` + `{m['thumb']}` | {m['name']} | {src} | {m['author']} | {m['licence']} | {m['edits']} |")
    lines += ["", "## Shelves", "", "| File | Source | Author | Licence | Edits |", "|---|---|---|---|---|"]
    for key in sorted(manifest["shelves"]):
        m = manifest["shelves"][key]
        src = f"**generated** ([model]({m['source_url']}))" if m["generated"] else f"[{m['title']}]({m['source_url']})"
        lic = f"[{m['licence']}]({m['licence_url']})" if m.get("licence_url") else m["licence"]
        lines.append(f"| `{m['file']}` | {src} | {m['author']} | {lic} | {m['edits']} |")
    gen = manifest.get("generated_count", 0)
    lines += ["", f"Generated images in total: {gen}.", ""]
    ATTRIBUTION.write_text("\n".join(lines), encoding="utf-8")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--no-generate", action="store_true")
    ap.add_argument("--only", help="comma-separated item ids")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--attribution", action="store_true", help="only rewrite ATTRIBUTION.md")
    ap.add_argument("--skip-shelves", action="store_true")
    ap.add_argument("--shelves-wanted", type=int, default=8)
    ap.add_argument("--budget", type=int, default=40, help="max generated images this run")
    a = ap.parse_args()

    items = load_catalogue()
    manifest = load_manifest()
    if a.attribution:
        write_attribution(manifest, items)
        return
    if a.only:
        want = set(a.only.split(","))
        items_run = [i for i in items if i["item_id"] in want]
    else:
        items_run = items
    for item in items_run:
        fetch_item(item, manifest, a.force)
        time.sleep(0.5)
    if not a.skip_shelves:
        fetch_shelves(manifest, a.force)
    if not a.no_generate:
        generate_missing_items(items_run, manifest, a.budget)
        used = manifest.get("generated_count", 0)
        if not a.skip_shelves:
            generate_missing_shelves(manifest, a.shelves_wanted, max(0, a.budget - used))
    write_attribution(manifest, items)
    found = sum(1 for m in manifest["items"].values() if not m["generated"])
    gen = sum(1 for m in manifest["items"].values() if m["generated"])
    log(f"items: {found} from Open Facts, {gen} generated, {len(items) - found - gen} missing; shelves: {len(manifest['shelves'])}")


if __name__ == "__main__":
    main()
