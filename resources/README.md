# UI resources

- `layouts/main.rgl` defines the main application UI.
- `styles/*.rgs` are binary raygui 4.0 styles edited with **rGuiStyler**.
- `icons/bitspryte.rgi` is a binary raygui icon set edited with **rGuiIcons**.
- `fonts/aseprite_font.png` and `fonts/aseprite_mini.png` are proportional
  pixel-font sprite sheets consumed by the SMGUI font adapter. They are
  distributed under CC BY 4.0; see `fonts/LICENSE.aseprite-font`.

The initial styles and icons are derived from the raygui 4.0 repository and use its zlib/libpng license. They are intentionally kept as runtime resources so UI changes do not require recompiling Odin code. The Makefile copies them beside the executable.

The remaining main-window `.rgl` file is converted into an Odin package because raygui does not load layout files at runtime. Run `make generate` after changing it; normal builds do this automatically. Settings no longer use raygui layout resources.
