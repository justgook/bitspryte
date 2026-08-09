# Aseprite sprite-sheet fonts

This package implements SMGUI font hooks for Aseprite's proportional pixel-font
sprite-sheet format. The top-left pixel is the separator color, glyph slots are
scanned sequentially from U+0020, and a red first pixel marks an unavailable
slot.

```odin
font, error := spritesheet.aseprite_font(2)
if error != .None { /* handle error */ }
defer spritesheet.deinit(&font) // keep alive until the SMGUI context is done
error = spritesheet.configure(&ctx, &font)
```

`aseprite_mini_font` loads the smaller built-in face. `parse_png` and
`parse_rgba` can load other sheets in the same format. Scaling is nearest
neighbour and limited to integer factors 1–8. Unsupported codepoints use the
question-mark glyph because SMGUI currently has no chained font fallback.

The bundled, unmodified `aseprite_font.png` and `aseprite_mini.png` files are
from Aseprite commit `cac270cebca3b5d7d4b7893f9bbc69b14b704deb` and are licensed
under CC BY 4.0. See [`fonts/LICENSE.txt`](fonts/LICENSE.txt).
