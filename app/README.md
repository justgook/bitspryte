# Application messages

BitSpryte separates requests from facts:

```text
input source → Action Bus → dispatcher/state owner → Event Bus → observers
```

## Canonical registries

These are the first files to inspect when adding or discovering application behavior:

- `actions/action_kinds.odin` — every application action and action source
- `events/event_kinds.odin` — every published application event

Keep identifiers centralized there. Payload constructors belong in `action.odin` or `event.odin`; queue behavior belongs in `bus.odin`.

Actions are requests and normally have one owning handler. Events describe something that already happened and may eventually have multiple observers. Pure helpers and private subsystem calls should remain direct function calls rather than going through a bus.

The first integration routes Settings, Close Active Window, Export PNG, Clear Canvas, and theme changes through the action dispatcher. Native menus and raygui controls now produce the same actions.

The raygui style registry is centralized in `themes/themes.odin`. Add a style there and to the settings `.rgl` selector when exposing another bundled `.rgs` resource.
