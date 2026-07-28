# Settings prototype status

The preferences window is now fully rendered by SMGUI:

- SMGUI owns the shell, navigation, footer actions, and all 18 page forms.
- Each page has its own C module under `ui/smgui/settings/`.
- Odin owns the settings values and shortcut binding; C receives copied
  snapshots and emits semantic field-change events.
- Files retains its interactive prototype controls.
- Keyboard Shortcuts retains the flat action/key/context screen. Close Active
  Window is functional; other bindings and import/export/reset remain mocks.
- The unfinished categories retain their explicit mock actions.
- No settings are persisted yet.

The former raygui content seam, generated settings packages, and settings `.rgl`
resources have been removed. The next model-level step is to define draft,
Apply/Cancel, validation, defaults, and persistence semantics.
