# Catppuccin Mocha for SMGUI

Generated from the Catppuccin Aseprite theme at commit
`3113df487afbb564f20e6e9402ee077f002f926c`:

<https://github.com/catppuccin/aseprite/tree/3113df487afbb564f20e6e9402ee077f002f926c/themes/mocha/catppuccin-theme-mocha>

The package contains three independently generated resources:

- `skin.png`: the 67 images expected by `smgui.set_png_skin`;
- `icons.png` and `icons.odin`: 226 named, non-nine-slice theme parts;
- `styles.png` and `styles.odin`: all 92 named nine-slice styles, including focused variants. These remain separate from the fixed 67-slot SMGUI skin so no Aseprite style is discarded;
- `theme.odin`: SMGUI's 33 theme colors plus all original named colors and dimensions.

Apply the skin and colors together:

```odin
import mocha "../../themes/catppuccin_mocha"

if error := mocha.apply(&ctx); error != .None {
    // handle error
}
```

Load a named Panel style pair:

```odin
atlas, error := mocha.load_style_atlas()
defer mocha.style_atlas_deinit(&atlas)
// A selectable normal/focused pair from the complete Aseprite style atlas.
style, found := mocha.style_pair(&atlas, "editor_normal", "editor_selected")
panel := smgui.Form{kind = .Panel, panel_style = &style}
```

Load a named icon:

```odin
atlas, error := mocha.load_icon_atlas()
defer mocha.icon_atlas_deinit(&atlas)
index, found := mocha.find_icon("icon_save")
image, valid := mocha.icon(&atlas, index)
```

Scale pixel graphics at load time with a positive integer. Nearest-neighbor
scaling keeps pixels crisp and scales nine-slice insets with their artwork:

```odin
GRAPHICS_SCALE :: 3
if error := mocha.apply(&ctx, GRAPHICS_SCALE); error != .None {
    // handle error
}
styles, style_error := mocha.load_style_atlas(GRAPHICS_SCALE)
icons, icon_error := mocha.load_icon_atlas(GRAPHICS_SCALE)
```

All scale parameters default to `1`. Applications should normally use one
shared graphics scale for the fixed skin, named styles, and named icons. Font
and application-owned geometry remain independently configurable.

Regenerate from a checked-out source theme:

```sh
odin run scripts/aseprite-theme -- skin "$THEME" --output themes/catppuccin_mocha/skin.png
odin run scripts/aseprite-theme -- colors "$THEME" \
  --output themes/catppuccin_mocha/theme.odin --package catppuccin_mocha \
  --source-url https://github.com/catppuccin/aseprite \
  --source-commit 3113df487afbb564f20e6e9402ee077f002f926c
odin run scripts/aseprite-theme -- icons "$THEME" \
  --output-atlas themes/catppuccin_mocha/icons.png \
  --output-odin themes/catppuccin_mocha/icons.odin --package catppuccin_mocha \
  --source-url https://github.com/catppuccin/aseprite \
  --source-commit 3113df487afbb564f20e6e9402ee077f002f926c
odin run scripts/aseprite-theme -- styles "$THEME" \
  --output-atlas themes/catppuccin_mocha/styles.png \
  --output-odin themes/catppuccin_mocha/styles.odin --package catppuccin_mocha \
  --source-url https://github.com/catppuccin/aseprite \
  --source-commit 3113df487afbb564f20e6e9402ee077f002f926c
```

The upstream repository includes MIT and CC BY 4.0 licensing. Both notices are
included here.
