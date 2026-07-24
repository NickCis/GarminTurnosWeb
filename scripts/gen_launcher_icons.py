#!/usr/bin/env python3
"""Generate purple TW launcher icons per device (sizes from compiler.json)."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
PURPLE = (128, 0, 82, 255)

# Non-default launcherIcon sizes from Devices/*/compiler.json.
# int => square N×N; (w, h) => rectangular.
IconSize = int | tuple[int, int]
DEVICE_ICON_SIZE: dict[str, IconSize] = {
    "vivoactive4s": 30,
    "fr55": 35,
    "vivoactive4": 35,
    "venusq": 36,
    "venusqm": 36,
    "vivoactive3": (40, 33),
    "vivoactive3m": (40, 33),
    "vivoactive5": 56,
    "epix2": 60,
    "epix2pro42mm": 60,
    "epix2pro47mm": 60,
    "epix2pro51mm": 60,
    "fr265": 60,
    "fr265s": 60,
    "fenix843mm": 60,
    "venu": 60,
    "venu2s": 61,
    "fr965": 65,
    "fenix847mm": 65,
    "venu2": 70,
    "venu2plus": 70,
    "venu3": 70,
    "venu3s": 70,
}

DRAWABLES_XML = """\
<drawables>
  <bitmap id="LauncherIcon" filename="launcher_icon.png"/>
</drawables>
"""


def as_wh(size: IconSize) -> tuple[int, int]:
    if isinstance(size, tuple):
        return size
    return (size, size)


def size_key(size: IconSize) -> str:
    w, h = as_wh(size)
    return f"{w}x{h}"


def font_for(height: int) -> ImageFont.ImageFont:
    px = max(9, int(round(height * 0.48)))
    for path in (
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/liberation/LiberationSans-Bold.ttf",
    ):
        try:
            return ImageFont.truetype(path, px)
        except OSError:
            pass
    return ImageFont.load_default()


def render(size: IconSize) -> Image.Image:
    w, h = as_wh(size)
    img = Image.new("RGBA", (w, h), PURPLE)
    draw = ImageDraw.Draw(img)
    font = font_for(h)
    text = "TW"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = (w - tw) / 2 - bbox[0]
    y = (h - th) / 2 - bbox[1]
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    return img


def write_icon(dir_path: Path, img: Image.Image) -> None:
    drawables = dir_path / "drawables"
    drawables.mkdir(parents=True, exist_ok=True)
    img.save(drawables / "launcher_icon.png")
    (drawables / "drawables.xml").write_text(DRAWABLES_XML)
    print(f"wrote {drawables / 'launcher_icon.png'} ({img.size[0]}x{img.size[1]})")


def main() -> None:
    cache: dict[str, Image.Image] = {}
    write_icon(ROOT / "resources", cache.setdefault("40x40", render(40)))

    unique_sizes = sorted({as_wh(s) for s in DEVICE_ICON_SIZE.values()})
    for wh in unique_sizes:
        key = size_key(wh)
        write_icon(ROOT / f"resources-icon-{key}", cache.setdefault(key, render(wh)))

    for device, size in sorted(DEVICE_ICON_SIZE.items()):
        key = size_key(size)
        write_icon(ROOT / f"resources-{device}", cache.setdefault(key, render(size)))


if __name__ == "__main__":
    main()
