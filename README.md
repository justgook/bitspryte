# BitSpryte

A small Odin playground for experimenting with **raylib** and **raygui** while growing the foundations of a pixel-art editor.

The first experiment includes:

- a 32×32 CPU-side image and nearest-neighbour GPU texture
- pencil and eraser tools
- zoom and pixel grid
- raygui toolbar, color picker, palette, and status bar
- a settings panel with runtime theme switching
- a native macOS application menu and `.app` bundle
- transparent checkerboard and PNG export

## Requirements

- A recent [Odin](https://odin-lang.org/) compiler
- The vendored raylib packages shipped with Odin

This experiment explicitly imports `vendor:raylib/v55`. That package includes the matching static raygui library on the currently tested macOS/ARM64 toolchain. It also keeps the experiment reproducible while Odin's raylib 6 vendor package is still changing.

## Build and run

The Makefile generates the Odin layout package and stages runtime resources:

```sh
make
make run
```

On macOS, `make` creates `build.nosync/BitSpryte.app` and `make run` opens it normally through Launch Services. To run the unbundled executable instead:

```sh
make run-bin
```

Override the build directory when needed:

```sh
make BUILD_DIR=/tmp/bitspryte-build
```

Controls:

- **Left drag:** use the selected tool
- **Right drag:** erase temporarily
- **Pencil / Eraser:** raygui toolbar toggles
- **Zoom:** raygui slider
- **Escape:** closes the active BitSpryte subwindow; it never exits the application
- **Export PNG:** writes `bitspryte.png` in the working directory

The main window is resizable with a 1000×700 minimum. Toolbars anchor to the window edge, the canvas viewport adapts to available space, and floating windows are kept on-screen.

## UI resource workflow

The application uses all three raygui companion formats:

- `resources/layouts/main.rgl` — main application layout
- `resources/layouts/settings/window.rgl` — draggable settings shell
- `resources/layouts/settings/<section>.rgl` — one independent content layout per settings section
- `resources/styles/*.rgs` — loaded at runtime and selectable from the Theme settings page
- `resources/icons/bitspryte.rgi` — loaded at runtime before drawing the UI

Open resources with the companion tools (override each executable path if it is not on `PATH`):

```sh
make layout-edit RGUI_LAYOUT=/path/to/rGuiLayout
make settings-layout-edit SETTINGS_SECTION=files RGUI_LAYOUT=/path/to/rGuiLayout
make style-edit STYLE_SOURCE=resources/styles/style_amber.rgs RGUI_STYLER=/path/to/rGuiStyler
make icons-edit RGUI_ICONS=/path/to/rGuiIcons
```

Optional C headers can be exported using the official tools:

```sh
make export-raygui-code
```

Check generated layout integration with:

```sh
make check
```

## macOS menu

The Cocoa bridge in `platform/native_menu/` installs shared application commands in the system menu bar:

- **BitSpryte → Settings…** (`⌘,`)
- **File → Export PNG…** (`⌘E`)
- **Edit → Clear Canvas**
- standard About, Hide, Quit, Minimize, Zoom, and Bring All to Front commands

Settings from the native menu and the in-window Settings button open the same draggable, modeless raygui window. Its Aseprite-inspired shell is defined in `resources/layouts/settings/window.rgl`; every category has a dedicated sibling layout such as `files.rgl`, `keyboard_shortcuts.rgl`, or `theme.rgl`. Routing lives in `ui/settings_panel/settings_panel.odin`.

Every category routes to a dedicated page procedure. Files and Theme have interactive controls. Keyboard Shortcuts provides a searchable, scrollable flat action/key/context table without submenus. **Close Active Window** can already be rebound by selecting its key cell and pressing another key; its default is Escape. Other key cells and Import, Export, and Reset remain logging stubs. Other unfinished pages expose a mock action. All mutations currently call dedicated logging-only callbacks—there is intentionally no persistence yet. See `ui/settings_panel/PROTOTYPE_NOTES.md` before promoting the mock. Non-macOS builds use a no-op native-menu implementation.

## Actions and events

Cross-subsystem requests use a typed action queue; completed facts use a separate event queue. Native menu commands and raygui controls already share this path for Settings, Export PNG, Clear Canvas, and theme changes.

Canonical identifiers are intentionally centralized for discovery:

- `app/actions/action_kinds.odin`
- `app/events/event_kinds.odin`

See `app/README.md` for the conventions.

## Next experiments

1. Move document state and rendering out of `main.odin`.
2. Add pan and canvas-space coordinate helpers.
3. Group a complete drag into one undo command.
4. Add project save/load before layers and animation.
