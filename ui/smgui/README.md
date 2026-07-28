# SMGUI host adapter

This module vendors SMGUI's `ui.h` and default PSF2 font module from commit
`d2ce0c288a93d366a33b42f766f1b9391c516b5a` of
<https://gitlab.com/bztsrc/smgui>.

SMGUI normally creates its own GLFW, SDL, or native window. The C bridge
provides a windowless backend instead:

1. Odin forwards raylib mouse, wheel, keyboard, and UTF-8 text input.
2. SMGUI renders into its CPU-side RGBA buffer.
3. Odin uploads that buffer to a raylib texture.
4. The texture is composited in the raylib window.

The host also implements font hooks for Aseprite-format PNG sprite sheets.
Raylib decodes the PNG, then the bridge discovers sequential proportional glyph
rectangles beginning at U+0020 and renders them at an integer nearest-neighbor
scale. SMGUI's embedded PSF2 font remains the fallback if loading fails.

## Ownership

- C owns the SMGUI context, form memory, localized strings, and transient widget
  mechanics. It never retains pointers into Odin memory.
- Odin owns application state and the typed action/event buses.
- State enters C as copied snapshots through `sync_settings`.
- User intent leaves C as semantic events such as `Page_Selected`,
  `Theme_Selected`, `Accepted`, and `Cancelled`.

The complete Settings window has migrated to SMGUI. The shell lives in the
bridge and each page owns its forms and copied widget state in a dedicated C
module under `settings/`. Pages emit semantic field events; Odin remains the
authoritative owner of settings values. No raygui settings-content seam remains.

SMGUI is MIT licensed; see `resources/LICENSE.smgui`.
