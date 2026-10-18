"""Generate synthetic kirana shelf photos with known per-brand counts.

`uv run python -m tests.eval.shelf.make_images` writes images/*.jpg and labels.json.
Each image is a few shelf rows of labelled packs; the brand colours and pack
shapes roughly follow the real products so the model has to read the labels.
Deterministic (seeded), each file well under 1 MB.
"""

from __future__ import annotations

import json
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).parent
OUT = HERE / "images"

# brand -> (pack colour, text colour, pack w, pack h, label lines)
BRANDS = {
    "Parle-G": ((245, 200, 60), (160, 30, 30), 70, 95, ["Parle-G", "70g"]),
    "Maggi": ((250, 210, 20), (200, 20, 20), 85, 60, ["MAGGI", "2-Minute", "70g"]),
    "Tata Salt": ((30, 80, 170), (255, 255, 255), 75, 110, ["TATA", "SALT", "1kg"]),
    "Surf Excel": ((40, 90, 200), (255, 255, 255), 80, 110, ["Surf", "excel", "1kg"]),
    "Colgate": ((210, 30, 40), (255, 255, 255), 120, 40, ["Colgate", "100g"]),
    "Lifebuoy": ((200, 30, 30), (255, 255, 255), 70, 45, ["Lifebuoy"]),
    "Red Label": ((190, 30, 40), (255, 230, 120), 75, 95, ["Red Label", "250g"]),
    "Dettol": ((60, 140, 80), (255, 255, 255), 50, 110, ["Dettol", "125g"]),
    "Nescafe": ((120, 40, 20), (255, 255, 255), 55, 85, ["NESCAFE", "50g"]),
    "Amul Butter": ((40, 70, 160), (255, 220, 80), 85, 50, ["Amul", "BUTTER", "100g"]),
}

SCENES = [
    # (file, rows of [(brand, count), ...], hardness)
    ("shelf_01_easy.jpg", [[("Maggi", 6)], [("Parle-G", 12)], [("Tata Salt", 3)]], 0.0),
    ("shelf_02_mixed.jpg", [[("Parle-G", 7), ("Red Label", 4)], [("Surf Excel", 5), ("Dettol", 6)],
                            [("Colgate", 4), ("Lifebuoy", 8)]], 0.1),
    ("shelf_03_crowded.jpg", [[("Maggi", 11), ("Nescafe", 5)], [("Parle-G", 14), ("Amul Butter", 4)],
                              [("Tata Salt", 6), ("Surf Excel", 3), ("Dettol", 4)]], 0.2),
    ("shelf_04_sparse.jpg", [[("Red Label", 2)], [("Colgate", 1), ("Nescafe", 2)], [("Lifebuoy", 3)]], 0.05),
    ("shelf_05_noisy.jpg", [[("Parle-G", 9), ("Maggi", 5)], [("Tata Salt", 4), ("Lifebuoy", 7)],
                            [("Dettol", 3), ("Surf Excel", 6)]], 0.35),
]


def _font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for path in ("/System/Library/Fonts/Supplemental/Arial Bold.ttf",
                 "/System/Library/Fonts/Supplemental/Arial.ttf",
                 "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"):
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def draw_pack(draw: ImageDraw.ImageDraw, x: int, y: int, brand: str, rng: random.Random,
              hardness: float) -> None:
    fill, text_colour, w, h, lines = BRANDS[brand]
    jitter = int(6 * hardness)
    x += rng.randint(-jitter, jitter)
    y += rng.randint(-jitter, jitter)
    shade = tuple(max(0, c - rng.randint(0, 25)) for c in fill)
    draw.rounded_rectangle([x, y, x + w, y + h], radius=6, fill=shade, outline=(40, 40, 40), width=2)
    # a lighter label band
    draw.rounded_rectangle([x + 4, y + 4, x + w - 4, y + h - 4], radius=4, outline=(255, 255, 255, 60))
    size = max(9, min(16, int(w / (max(len(l) for l in lines) * 0.62))))
    font = _font(size)
    ty = y + h / 2 - (len(lines) * (size + 2)) / 2
    for line in lines:
        tw = draw.textlength(line, font=font)
        draw.text((x + (w - tw) / 2, ty), line, fill=text_colour, font=font)
        ty += size + 2


def render(scene_rows, hardness: float, seed: int) -> Image.Image:
    rng = random.Random(seed)
    W, H = 1024, 768
    img = Image.new("RGB", (W, H), (120, 95, 70))
    draw = ImageDraw.Draw(img)
    n_rows = len(scene_rows)
    row_h = H // n_rows
    for r, row in enumerate(scene_rows):
        top = r * row_h
        # back panel + shelf board
        draw.rectangle([0, top, W, top + row_h], fill=(150 + r * 8, 125 + r * 6, 95 + r * 5))
        draw.rectangle([0, top + row_h - 18, W, top + row_h], fill=(80, 55, 35))
        x = 24
        base_y = top + row_h - 18
        for brand, count in row:
            _, _, w, h, _ = BRANDS[brand]
            for _ in range(count):
                if x + w > W - 16:  # wrap to a second tier on the same shelf
                    x = 24 + rng.randint(0, 10)
                    base_y -= h + 8
                draw_pack(draw, x, base_y - h, brand, rng, hardness)
                x += w + rng.randint(4, 10)
            x += 30  # gap between products
    if hardness > 0.3:
        img = img.filter(ImageFilter.GaussianBlur(0.8))
        px = img.load()
        for _ in range(int(W * H * 0.01)):
            xx, yy = rng.randrange(W), rng.randrange(H)
            px[xx, yy] = tuple(min(255, c + rng.randint(-40, 40)) for c in px[xx, yy])
    return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    labels = {}
    for i, (name, rows, hardness) in enumerate(SCENES):
        img = render(rows, hardness, seed=100 + i)
        img.save(OUT / name, "JPEG", quality=82, optimize=True)
        counts: dict[str, int] = {}
        for row in rows:
            for brand, count in row:
                counts[brand] = counts.get(brand, 0) + count
        labels[name] = {"counts": counts, "source": "synthetic (Pillow)", "hardness": hardness}
        print(name, (OUT / name).stat().st_size // 1024, "KB", counts)
    (HERE / "labels.json").write_text(json.dumps(labels, indent=2, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    main()
