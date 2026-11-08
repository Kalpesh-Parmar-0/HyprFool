
#!/usr/bin/env python3

import argparse
import json
from pathlib import Path

from PIL import Image

from materialyoucolor.dislike.dislike_analyzer import DislikeAnalyzer
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.hct import Hct
from materialyoucolor.quantize import ImageQuantizeCelebi
from materialyoucolor.scheme.scheme_content import SchemeContent
from materialyoucolor.scheme.scheme_neutral import SchemeNeutral
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.utils.math_utils import sanitize_degrees_int


SCHEMES = {
    "neutral": SchemeNeutral,
    "content": SchemeContent,
    "tonalspot": SchemeTonalSpot,
}

TARGET_CHROMA = 48.0
WEIGHT_PROPORTION = 0.7
WEIGHT_CHROMA_ABOVE = 0.3
WEIGHT_CHROMA_BELOW = 0.1


def colorfulness(image: Image.Image) -> float:
    pixels = list(image.convert("RGB").get_flattened_data())

    rg = [abs(r - g) for r, g, b in pixels]
    yb = [abs(0.5 * (r + g) - b) for r, g, b in pixels]

    def mean(values):
        return sum(values) / len(values) if values else 0

    def stddev(values, average):
        if not values:
            return 0
        return (sum((v - average) ** 2 for v in values) / len(values)) ** 0.5

    mean_rg = mean(rg)
    mean_yb = mean(yb)

    std_rg = stddev(rg, mean_rg)
    std_yb = stddev(yb, mean_yb)

    return (
        (std_rg**2 + std_yb**2) ** 0.5
        + 0.3 * (mean_rg**2 + mean_yb**2) ** 0.5
    )


def choose_variant(image: Image.Image) -> str:
    score = colorfulness(image)

    if score < 10:
        return "neutral"
    if score < 20:
        return "content"
    return "tonalspot"


def choose_mode(image: Image.Image) -> str:
    average = image.copy()
    average.thumbnail((1, 1), Image.Resampling.LANCZOS)

    red, green, blue = average.convert("RGB").getpixel((0, 0))
    argb = 0xFF000000 | (red << 16) | (green << 8) | blue

    return "light" if Hct.from_int(argb).tone > 60 else "dark"


def score_primary(image_path: Path) -> Hct:
    colors_to_population = ImageQuantizeCelebi(
        str(image_path),
        1,
        128,
    )

    colors_hct = []
    hue_population = [0] * 360
    population_sum = 0

    for rgb, population in colors_to_population.items():
        hct = Hct.from_int(rgb)
        colors_hct.append(hct)

        hue = int(hct.hue)
        hue_population[hue] += population
        population_sum += population

    if population_sum == 0:
        raise ValueError("Wallpaper contains no quantizable colors")

    excited_proportions = [0.0] * 360

    for hue in range(360):
        proportion = hue_population[hue] / population_sum

        for neighbor in range(hue - 14, hue + 16):
            normalized = int(sanitize_degrees_int(neighbor))
            excited_proportions[normalized] += proportion

    scored = []

    for hct in colors_hct:
        hue = int(sanitize_degrees_int(round(hct.hue)))
        proportion = excited_proportions[hue]

        proportion_score = proportion * 100.0 * WEIGHT_PROPORTION

        chroma_weight = (
            WEIGHT_CHROMA_BELOW
            if hct.chroma < TARGET_CHROMA
            else WEIGHT_CHROMA_ABOVE
        )

        chroma_score = (hct.chroma - TARGET_CHROMA) * chroma_weight

        scored.append({
            "hct": hct,
            "score": proportion_score + chroma_score,
        })

    scored.sort(key=lambda item: item["score"], reverse=True)

    for cutoff in range(20, -1, -1):
        for item in scored:
            hct = item["hct"]

            if hct.chroma > cutoff and hct.tone > cutoff * 3:
                return DislikeAnalyzer.fix_if_disliked(hct)

    if scored:
        return DislikeAnalyzer.fix_if_disliked(scored[0]["hct"])

    raise ValueError("Could not determine a primary wallpaper color")


def generate_colors(primary: Hct, mode: str, variant: str) -> dict:
    scheme_class = SCHEMES[variant]

    dynamic_scheme = scheme_class(
        source_color_hct=primary,
        is_dark=(mode == "dark"),
        contrast_level=0.0,
    )

    dynamic_colors = MaterialDynamicColors()
    colors = {}

    if hasattr(dynamic_colors, "all_colors"):
        roles = [
            (role.name, role)
            for role in dynamic_colors.all_colors
        ]
    else:
        roles = [
            (name, getattr(MaterialDynamicColors, name))
            for name in vars(MaterialDynamicColors)
            if hasattr(getattr(MaterialDynamicColors, name), "get_hct")
        ]

    for name, role in roles:
        color = role.get_hct(dynamic_scheme).to_int()
        colors[name] = f"#{color & 0xFFFFFF:06X}"

    return colors


def generate(image_path: Path, output_path: Path, mode_override: str, variant_override: str):
    if not image_path.is_file():
        raise FileNotFoundError(f"Wallpaper not found: {image_path}")

    with Image.open(image_path) as original:
        image = original.convert("RGB")
        image.thumbnail((128, 128), Image.Resampling.NEAREST)

        mode = (
            choose_mode(image)
            if mode_override == "auto"
            else mode_override
        )

        variant = (
            choose_variant(image)
            if variant_override == "auto"
            else variant_override
        )

        primary = score_primary(image_path)
        colors = generate_colors(primary, mode, variant)

    result = {
        "wallpaper": str(image_path.resolve()),
        "mode": mode,
        "variant": variant,
        "sourceColor": f"#{primary.to_int() & 0xFFFFFF:06X}",
        "colors": colors,
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)

    temporary = output_path.with_suffix(".tmp")
    temporary.write_text(json.dumps(result, indent=2))
    temporary.replace(output_path)

    print(f"Wallpaper: {result['wallpaper']}")
    print(f"Mode:      {mode}")
    print(f"Variant:   {variant}")
    print(f"Primary:   {result['sourceColor']}")
    print(f"Roles:     {len(colors)}")
    print(f"Output:    {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate a Material You palette from a wallpaper."
    )

    parser.add_argument("image", type=Path)
    parser.add_argument(
        "--mode",
        choices=["auto", "light", "dark"],
        default="auto",
    )
    parser.add_argument(
        "--variant",
        choices=["auto", *SCHEMES.keys()],
        default="auto",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path.home() / ".local/state/hyprfool/theme/colors.json",
    )

    args = parser.parse_args()

    generate(
        args.image.expanduser().resolve(),
        args.output.expanduser(),
        args.mode,
        args.variant,
    )


if __name__ == "__main__":
    main()
