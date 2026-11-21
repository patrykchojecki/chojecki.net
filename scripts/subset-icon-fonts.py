"""Regenerate the site icon fonts from the upstream Font Awesome webfonts directory."""

import argparse
import re
from pathlib import Path

from fontTools import subset

ROOT = Path(__file__).resolve().parent.parent


def subset_fonts(source):
    styles = (ROOT / "_sass/_icons.scss").read_text()
    for style, filename in (("solid", "fa-solid-900.woff2"),
                            ("brand", "fa-brands-400.woff2")):
        icon_map = styles.split(f"$site-{style}-icons: (", 1)[1].split(");", 1)[0]
        glyphs = {int(code, 16) for code in re.findall(r'"\\([\da-f]+)"', icon_map)}
        if not glyphs:
            raise ValueError(f"No glyphs configured for {style}")

        options = subset.Options(name_IDs=[0, 1, 2, 3, 4, 5, 6, 13, 14],
                                 flavor="woff2", ignore_missing_unicodes=False)
        font = subset.load_font(source / filename, options)
        family = "Chojecki Icons Solid" if style == "solid" else "Chojecki Icons Brands"
        for record in font["name"].names:
            if record.nameID in {1, 3, 4}:
                record.string = family
            elif record.nameID == 6:
                record.string = family.replace(" ", "")

        builder = subset.Subsetter(options=options)
        builder.populate(unicodes=glyphs)
        builder.subset(font)
        subset.save_font(font, ROOT / "assets/webfonts" / filename, options)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("webfonts", type=Path)
    subset_fonts(parser.parse_args().webfonts)
