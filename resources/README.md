# UI resources

- `layouts/main.rgl` defines the main application UI.
- `layouts/settings.rgl` independently defines local content for the draggable settings window.
- `styles/*.rgs` are binary raygui 4.0 styles edited with **rGuiStyler**.
- `icons/bitspryte.rgi` is a binary raygui icon set edited with **rGuiIcons**.

The initial styles and icons are derived from the raygui 4.0 repository and use its zlib/libpng license. They are intentionally kept as runtime resources so UI changes do not require recompiling Odin code. The Makefile copies them beside the executable.

Each `.rgl` file is converted into its own Odin package because raygui itself does not load layout files at runtime. Run `make generate` after changing one; normal `make` builds do this automatically.
