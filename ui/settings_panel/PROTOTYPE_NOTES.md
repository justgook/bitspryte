# Settings mock — prototype

**Question:** Does an Aseprite-style preferences window, with persistent category navigation and a large routed content pane, feel appropriate for BitSpryte?

The screenshot supplied in the conversation is the selected visual direction, so this prototype explores one structure rather than multiple variants.

Current scope:

- Files and Theme have interactive mock controls.
- Keyboard Shortcuts is a dedicated flat table screen with search, scrolling, key-cell selection, import/export/reset stubs, and no shortcut submenus. The Close Active Window binding is functional and configurable; other bindings remain mocks.
- Every category routes to a dedicated page procedure.
- Every mutation routes to a dedicated logging-only callback.
- No settings are persisted.

## Verdict

_Pending hands-on review._

When the structure is accepted, replace the logging callbacks with a settings model and persistence, then remove this prototype marker. If rejected, delete `ui/settings_panel/` and `resources/layouts/settings/` rather than evolving the mock indefinitely.
