# raygui 5.0 API Reference

Generated from [`src/raygui.h`](https://github.com/raysan5/raygui/blob/master/src/raygui.h) on the `master` branch.

- Header version: **raygui 5.0**
- Source blob SHA: `b25f704a1178ade2e5a459efa80ec5dc5a1c71d2`
- API style: immediate-mode GUI
- Language: C (also usable from C++ through `extern "C"`)

> This is an explanatory reference derived from the declarations and implementation in `raygui.h`; it is not an official upstream document.

## Basic setup

Define `RAYGUI_IMPLEMENTATION` in **exactly one** `.c` or `.cpp` file:

```c
#include "raylib.h"

#define RAYGUI_IMPLEMENTATION
#include "raygui.h"
```

Other source files may include the header without defining the implementation macro:

```c
#include "raygui.h"
```

Controls are called every frame, normally between `BeginDrawing()` and `EndDrawing()`:

```c
while (!WindowShouldClose())
{
    BeginDrawing();
    ClearBackground(RAYWHITE);

    if (GuiButton((Rectangle){ 20, 20, 120, 30 }, "Click"))
    {
        // Button was pressed.
    }

    EndDrawing();
}
```

## Common types and conventions

### `Rectangle bounds`

Most controls receive a raylib `Rectangle`:

```c
(Rectangle){ x, y, width, height }
```

It defines the control's position and size in screen coordinates.

### Text item separator

Controls that contain several choices usually receive one semicolon-separated string:

```c
"First;Second;Third"
```

### Mutable pointer arguments

Arguments such as `bool *active`, `int *value`, and `Color *color` point to application-owned state. The control reads and may update that value.

### Edit mode

Editable controls commonly receive `bool editMode`:

- `false`: normal/inactive mode.
- `true`: the control is actively accepting input or showing its expanded editor.

A common pattern is:

```c
if (GuiTextBox(bounds, text, sizeof(text), editMode))
{
    editMode = !editMode;
}
```

### Control return values

raygui 5.0 controls return an `int` result. Common values are:

- `0`: no noteworthy action.
- `1`: pressed/activated.
- `2`: value changed.
- Values greater than `2`: control-specific result.

For simple buttons, treating the result as a Boolean is appropriate:

```c
if (GuiButton(bounds, "Save")) Save();
```

For controls that distinguish events, inspect the integer result:

```c
int result = GuiSlider(bounds, NULL, NULL, &value, 0.0f, 1.0f);
if (result == 2)
{
    // value changed
}
```

### Labels and icons

When icons are enabled, text can begin with an icon marker:

```c
GuiButton(bounds, "#005#Open");
```

Using `GuiIconText()` is clearer:

```c
GuiButton(bounds, GuiIconText(ICON_FILE_OPEN, "Open"));
```

---

## API index

- [Global GUI state](#global-gui-state)
- [Font](#font)
- [Style](#style)
- [Tooltips](#tooltips)
- [Icons](#icons)
- [Utility](#utility)
- [Container and separator controls](#container-and-separator-controls)
- [Basic controls](#basic-controls)
- [Advanced controls](#advanced-controls)

---

## Global GUI state

### `GuiEnable`

```c
void GuiEnable(void);
```

Enables interaction with GUI controls globally.

**Arguments:** none.

**Minimal example**

```c
GuiEnable();
```

### `GuiDisable`

```c
void GuiDisable(void);
```

Disables GUI controls globally. Controls are still drawn but do not respond normally to input.

**Arguments:** none.

**Minimal example**

```c
GuiDisable();
GuiButton((Rectangle){ 20, 20, 120, 30 }, "Disabled");
GuiEnable();
```

### `GuiLock`

```c
void GuiLock(void);
```

Locks GUI interaction globally. Useful while a modal control is active.

**Arguments:** none.

**Minimal example**

```c
GuiLock();
// Draw controls that should not receive input.
GuiUnlock();
```

### `GuiUnlock`

```c
void GuiUnlock(void);
```

Removes the global GUI lock.

**Arguments:** none.

**Minimal example**

```c
if (dialogClosed) GuiUnlock();
```

### `GuiIsLocked`

```c
bool GuiIsLocked(void);
```

Reports whether the GUI is currently locked.

**Arguments:** none.

**Minimal example**

```c
if (GuiIsLocked())
{
    DrawText("GUI locked", 10, 10, 20, RED);
}
```

### `GuiSetAlpha`

```c
void GuiSetAlpha(float alpha);
```

Sets global opacity for raygui drawing.

**Arguments**

- **`alpha`** — `float`: Opacity from `0.0f` (transparent) to `1.0f` (opaque).

**Minimal example**

```c
GuiSetAlpha(0.75f);
```

### `GuiSetState`

```c
void GuiSetState(int state);
```

Sets the global visual/interaction state used by controls.

**Arguments**

- **`state`** — `int`: A `GuiState` value such as `STATE_NORMAL`, `STATE_FOCUSED`, `STATE_PRESSED`, or `STATE_DISABLED`.

**Minimal example**

```c
GuiSetState(STATE_DISABLED);
GuiButton((Rectangle){ 20, 20, 120, 30 }, "Disabled");
GuiSetState(STATE_NORMAL);
```

### `GuiGetState`

```c
int GuiGetState(void);
```

Returns the current global GUI state.

**Arguments:** none.

**Minimal example**

```c
int state = GuiGetState();
```

## Font

### `GuiSetFont`

```c
void GuiSetFont(Font font);
```

Sets the font used by raygui controls.

**Arguments**

- **`font`** — `Font`: A loaded raylib font. The caller remains responsible for its lifetime.

**Minimal example**

```c
Font font = LoadFont("resources/myfont.ttf");
GuiSetFont(font);
```

### `GuiGetFont`

```c
Font GuiGetFont(void);
```

Returns the current raygui font.

**Arguments:** none.

**Minimal example**

```c
Font guiFont = GuiGetFont();
```

## Style

### `GuiSetStyle`

```c
void GuiSetStyle(int control, int property, int value);
```

Sets one GUI style property.

**Arguments**

- **`control`** — `int`: Control type, such as `DEFAULT`, `BUTTON`, `TEXTBOX`, or `LISTVIEW`.
- **`property`** — `int`: Base or control-specific style property, such as `TEXT_SIZE`, `BORDER_WIDTH`, or `TEXT_COLOR_NORMAL`.
- **`value`** — `int`: Property value. Colors are stored as packed integer color values.

**Minimal example**

```c
GuiSetStyle(BUTTON, BORDER_WIDTH, 2);
GuiSetStyle(DEFAULT, TEXT_SIZE, 18);
```

### `GuiGetStyle`

```c
int GuiGetStyle(int control, int property);
```

Gets one GUI style property.

**Arguments**

- **`control`** — `int`: Control type whose style is queried.
- **`property`** — `int`: Style property to read.

**Minimal example**

```c
int textSize = GuiGetStyle(DEFAULT, TEXT_SIZE);
```

### `GuiLoadStyle`

```c
void GuiLoadStyle(const char *fileName);
```

Loads a binary `.rgs` style file over the current global style.

**Arguments**

- **`fileName`** — `const char *`: Path to the raygui style file.

**Minimal example**

```c
GuiLoadStyle("styles/style_cyber.rgs");
```

### `GuiLoadStyleFromMemory`

```c
void GuiLoadStyleFromMemory(const unsigned char *fileData, int dataSize);
```

Loads a binary `.rgs` style from memory.

**Arguments**

- **`fileData`** — `const unsigned char *`: Pointer to the complete style-file bytes.
- **`dataSize`** — `int`: Number of bytes in `fileData`.

**Minimal example**

```c
unsigned char *data = LoadFileData("style.rgs", &size);
GuiLoadStyleFromMemory(data, size);
UnloadFileData(data);
```

### `GuiLoadStyleDefault`

```c
void GuiLoadStyleDefault(void);
```

Restores the built-in default raygui style. It also replaces resources associated with a previously loaded style font.

**Arguments:** none.

**Minimal example**

```c
GuiLoadStyleDefault();
```

## Tooltips

### `GuiEnableTooltip`

```c
void GuiEnableTooltip(void);
```

Globally enables raygui tooltips.

**Arguments:** none.

**Minimal example**

```c
GuiEnableTooltip();
```

### `GuiDisableTooltip`

```c
void GuiDisableTooltip(void);
```

Globally disables raygui tooltips.

**Arguments:** none.

**Minimal example**

```c
GuiDisableTooltip();
```

### `GuiSetTooltip`

```c
void GuiSetTooltip(const char *tooltip);
```

Sets the tooltip associated with the next/current control according to raygui's immediate-mode tooltip handling.

**Arguments**

- **`tooltip`** — `const char *`: Tooltip text. Keep the string alive for the duration of the call/frame.

**Minimal example**

```c
GuiSetTooltip("Save the current document");
GuiButton((Rectangle){ 20, 20, 100, 30 }, "Save");
```

## Icons

### `GuiIconText`

```c
const char *GuiIconText(int iconId, const char *text);
```

Builds a temporary text string containing an icon marker followed by text.

**Arguments**

- **`iconId`** — `int`: Icon identifier, usually an `ICON_*` enum value.
- **`text`** — `const char *`: Optional text placed after the icon.

**Minimal example**

```c
GuiButton(bounds, GuiIconText(ICON_FILE_OPEN, "Open"));
```

### `GuiSetIconScale`

```c
void GuiSetIconScale(int scale);
```

Sets the scale used when raygui draws embedded icons.

**Arguments**

- **`scale`** — `int`: Integer icon scale. `1` uses the base icon size.

**Minimal example**

```c
GuiSetIconScale(2);
```

### `GuiGetIcons`

```c
unsigned int *GuiGetIcons(void);
```

Returns a writable pointer to raygui's internal packed icon data.

**Arguments:** none.

**Minimal example**

```c
unsigned int *icons = GuiGetIcons();
// Advanced use: inspect or modify packed icon bits.
```

### `GuiLoadIcons`

```c
char **GuiLoadIcons(const char *fileName, bool loadIconsName);
```

Loads a `.rgi` icon pack into raygui's internal icon storage.

**Arguments**

- **`fileName`** — `const char *`: Path to the icon-pack file.
- **`loadIconsName`** — `bool`: When true, also load and return the icon names.

**Minimal example**

```c
char **names = GuiLoadIcons("icons/custom.rgi", true);
// names may be NULL when names were not loaded or unavailable.
```

### `GuiLoadIconsFromMemory`

```c
char **GuiLoadIconsFromMemory(const unsigned char *fileData, int dataSize, bool loadIconsName);
```

Loads a `.rgi` icon pack from memory.

**Arguments**

- **`fileData`** — `const unsigned char *`: Pointer to icon-pack bytes.
- **`dataSize`** — `int`: Number of bytes in the buffer.
- **`loadIconsName`** — `bool`: Whether icon names should also be loaded and returned.

**Minimal example**

```c
int size = 0;
unsigned char *data = LoadFileData("custom.rgi", &size);
char **names = GuiLoadIconsFromMemory(data, size, true);
UnloadFileData(data);
```

### `GuiDrawIcon`

```c
void GuiDrawIcon(int iconId, int posX, int posY, int pixelSize, Color color);
```

Draws one embedded icon directly.

**Arguments**

- **`iconId`** — `int`: Icon identifier.
- **`posX`** — `int`: Left drawing coordinate.
- **`posY`** — `int`: Top drawing coordinate.
- **`pixelSize`** — `int`: Screen size of each source icon pixel.
- **`color`** — `Color`: Tint/drawing color.

**Minimal example**

```c
GuiDrawIcon(ICON_FILE_SAVE, 20, 20, 2, DARKGRAY);
```

## Utility

### `GuiGetTextWidth`

```c
int GuiGetTextWidth(const char *text);
```

Measures text width using the current GUI font, text style, spacing, and embedded icon markers.

**Arguments**

- **`text`** — `const char *`: Text to measure.

**Minimal example**

```c
int width = GuiGetTextWidth("Hello");
```

## Container and separator controls

### `GuiWindowBox`

```c
int GuiWindowBox(Rectangle bounds, const char *title);
```

Draws a framed window with a title bar and close button.

**Arguments**

- **`bounds`** — `Rectangle`: Window position and size.
- **`title`** — `const char *`: Title-bar text.

**Minimal example**

```c
if (GuiWindowBox((Rectangle){ 100, 80, 300, 200 }, "Settings"))
{
    showSettings = false;
}
```

### `GuiGroupBox`

```c
int GuiGroupBox(Rectangle bounds, const char *text);
```

Draws a labeled group outline for visually organizing controls.

**Arguments**

- **`bounds`** — `Rectangle`: Group outline position and size.
- **`text`** — `const char *`: Group caption; may be `NULL` or empty.

**Minimal example**

```c
GuiGroupBox((Rectangle){ 20, 20, 250, 140 }, "Audio");
```

### `GuiLine`

```c
int GuiLine(Rectangle bounds, const char *text);
```

Draws a separator line, optionally with a caption.

**Arguments**

- **`bounds`** — `Rectangle`: Area occupied by the line and caption.
- **`text`** — `const char *`: Optional caption.

**Minimal example**

```c
GuiLine((Rectangle){ 20, 80, 300, 20 }, "Advanced");
```

### `GuiPanel`

```c
int GuiPanel(Rectangle bounds, const char *text);
```

Draws a panel background/border used to group content.

**Arguments**

- **`bounds`** — `Rectangle`: Panel position and size.
- **`text`** — `const char *`: Optional panel caption.

**Minimal example**

```c
GuiPanel((Rectangle){ 10, 10, 300, 180 }, NULL);
```

### `GuiScrollPanel`

```c
int GuiScrollPanel(Rectangle bounds, const char *text, Rectangle content, Vector2 *scroll, Rectangle *view);
```

Draws a clipped, scrollable panel and updates its scroll offset.

**Arguments**

- **`bounds`** — `Rectangle`: Visible outer panel rectangle.
- **`text`** — `const char *`: Optional panel caption.
- **`content`** — `Rectangle`: Full virtual content rectangle; it may be larger than `bounds`.
- **`scroll`** — `Vector2 *`: Input/output scroll offset owned by the application.
- **`view`** — `Rectangle *`: Receives the visible clipped content rectangle; may be used with `BeginScissorMode()`.

**Minimal example**

```c
Vector2 scroll = { 0 };
Rectangle view = { 0 };

GuiScrollPanel(
    (Rectangle){ 20, 20, 250, 180 },
    NULL,
    (Rectangle){ 0, 0, 500, 600 },
    &scroll,
    &view);
```

## Basic controls

### `GuiLabel`

```c
int GuiLabel(Rectangle bounds, const char *text);
```

Draws non-interactive text using label styling.

**Arguments**

- **`bounds`** — `Rectangle`: Text layout rectangle.
- **`text`** — `const char *`: Label text.

**Minimal example**

```c
GuiLabel((Rectangle){ 20, 20, 200, 24 }, "Player name");
```

### `GuiButton`

```c
int GuiButton(Rectangle bounds, const char *text);
```

Draws a push button and reports activation.

**Arguments**

- **`bounds`** — `Rectangle`: Button position and size.
- **`text`** — `const char *`: Button label; icon markers are supported.

**Minimal example**

```c
if (GuiButton((Rectangle){ 20, 20, 100, 30 }, "Save"))
{
    SaveDocument();
}
```

### `GuiLabelButton`

```c
int GuiLabelButton(Rectangle bounds, const char *text);
```

Provides button interaction with a label-like visual style.

**Arguments**

- **`bounds`** — `Rectangle`: Clickable text rectangle.
- **`text`** — `const char *`: Displayed text.

**Minimal example**

```c
if (GuiLabelButton((Rectangle){ 20, 20, 120, 24 }, "Learn more"))
{
    OpenURL("https://example.com");
}
```

### `GuiToggle`

```c
int GuiToggle(Rectangle bounds, const char *text, bool *active);
```

Draws a two-state toggle button and updates its Boolean state.

**Arguments**

- **`bounds`** — `Rectangle`: Toggle position and size.
- **`text`** — `const char *`: Toggle label.
- **`active`** — `bool *`: Input/output selected state.

**Minimal example**

```c
bool enabled = false;
GuiToggle((Rectangle){ 20, 20, 120, 30 }, "Enabled", &enabled);
```

### `GuiToggleGroup`

```c
int GuiToggleGroup(Rectangle bounds, const char *text, int *active);
```

Draws a group of mutually exclusive toggles from semicolon-separated labels.

**Arguments**

- **`bounds`** — `Rectangle`: Area used by the group; its dimensions affect rows and columns.
- **`text`** — `const char *`: Semicolon-separated item labels.
- **`active`** — `int *`: Input/output zero-based selected item index.

**Minimal example**

```c
int selected = 0;
GuiToggleGroup(
    (Rectangle){ 20, 20, 100, 30 },
    "Small;Medium;Large",
    &selected);
```

### `GuiToggleSlider`

```c
int GuiToggleSlider(Rectangle bounds, const char *text, int *active);
```

Draws a segmented slider-like selector.

**Arguments**

- **`bounds`** — `Rectangle`: Control position and size.
- **`text`** — `const char *`: Semicolon-separated choices.
- **`active`** — `int *`: Input/output selected item index.

**Minimal example**

```c
int mode = 0;
GuiToggleSlider(
    (Rectangle){ 20, 20, 240, 30 },
    "Edit;Preview",
    &mode);
```

### `GuiCheckBox`

```c
int GuiCheckBox(Rectangle bounds, const char *text, bool *checked);
```

Draws a checkbox and updates its checked state.

**Arguments**

- **`bounds`** — `Rectangle`: Checkbox square rectangle. Text is laid out next to it.
- **`text`** — `const char *`: Checkbox label.
- **`checked`** — `bool *`: Input/output checked state.

**Minimal example**

```c
bool showGrid = true;
GuiCheckBox(
    (Rectangle){ 20, 20, 20, 20 },
    "Show grid",
    &showGrid);
```

### `GuiComboBox`

```c
int GuiComboBox(Rectangle bounds, const char *text, int *active);
```

Draws a compact choice control that cycles through items when activated.

**Arguments**

- **`bounds`** — `Rectangle`: Control rectangle.
- **`text`** — `const char *`: Semicolon-separated choices.
- **`active`** — `int *`: Input/output selected item index.

**Minimal example**

```c
int quality = 0;
GuiComboBox(
    (Rectangle){ 20, 20, 140, 30 },
    "Low;Medium;High",
    &quality);
```

### `GuiDropdownBox`

```c
int GuiDropdownBox(Rectangle bounds, const char *text, int *active, bool editMode);
```

Draws a drop-down selector. The caller owns whether it is collapsed or expanded.

**Arguments**

- **`bounds`** — `Rectangle`: Collapsed control rectangle; expanded items are drawn relative to it.
- **`text`** — `const char *`: Semicolon-separated choices.
- **`active`** — `int *`: Input/output selected item index.
- **`editMode`** — `bool`: False for collapsed mode; true to show and interact with the item list.

**Minimal example**

```c
int selected = 0;
bool open = false;

if (GuiDropdownBox(
        (Rectangle){ 20, 20, 160, 30 },
        "C;C++;Rust",
        &selected,
        open))
{
    open = !open;
}
```

### `GuiSpinner`

```c
int GuiSpinner(Rectangle bounds, const char *text, int *value, int minValue, int maxValue, bool editMode);
```

Draws an integer editor with decrement and increment buttons.

**Arguments**

- **`bounds`** — `Rectangle`: Complete spinner rectangle.
- **`text`** — `const char *`: Optional label.
- **`value`** — `int *`: Input/output integer value.
- **`minValue`** — `int`: Minimum permitted value.
- **`maxValue`** — `int`: Maximum permitted value.
- **`editMode`** — `bool`: Whether the numeric text field is actively editable.

**Minimal example**

```c
int count = 1;
bool editing = false;

if (GuiSpinner(
        (Rectangle){ 20, 20, 140, 30 },
        "Count",
        &count, 0, 99, editing))
{
    editing = !editing;
}
```

### `GuiValueBox`

```c
int GuiValueBox(Rectangle bounds, const char *text, int *value, int minValue, int maxValue, bool editMode);
```

Draws an editable integer value field.

**Arguments**

- **`bounds`** — `Rectangle`: Value-field rectangle.
- **`text`** — `const char *`: Optional adjacent label.
- **`value`** — `int *`: Input/output integer value.
- **`minValue`** — `int`: Minimum permitted value.
- **`maxValue`** — `int`: Maximum permitted value.
- **`editMode`** — `bool`: Whether keyboard editing is enabled.

**Minimal example**

```c
int age = 18;
bool editing = false;

if (GuiValueBox(
        (Rectangle){ 20, 20, 100, 30 },
        "Age", &age, 0, 130, editing))
{
    editing = !editing;
}
```

### `GuiValueBoxFloat`

```c
int GuiValueBoxFloat(Rectangle bounds, const char *text, char *textValue, float *value, bool editMode);
```

Draws an editable floating-point value field. It uses both a text buffer and parsed float value.

**Arguments**

- **`bounds`** — `Rectangle`: Value-field rectangle.
- **`text`** — `const char *`: Optional label.
- **`textValue`** — `char *`: Writable text buffer containing the formatted/editable number.
- **`value`** — `float *`: Input/output parsed floating-point value.
- **`editMode`** — `bool`: Whether keyboard editing is enabled.

**Minimal example**

```c
char valueText[32] = "1.25";
float value = 1.25f;
bool editing = false;

if (GuiValueBoxFloat(
        (Rectangle){ 20, 20, 120, 30 },
        "Scale", valueText, &value, editing))
{
    editing = !editing;
}
```

### `GuiTextBox`

```c
int GuiTextBox(Rectangle bounds, char *text, int textSize, bool editMode);
```

Draws a single-line editable text field.

**Arguments**

- **`bounds`** — `Rectangle`: Text-box rectangle.
- **`text`** — `char *`: Writable, NUL-terminated text buffer.
- **`textSize`** — `int`: Total buffer capacity in bytes, including the terminating NUL.
- **`editMode`** — `bool`: Whether the field accepts keyboard input.

**Minimal example**

```c
char name[64] = "";
bool editing = false;

if (GuiTextBox(
        (Rectangle){ 20, 20, 200, 30 },
        name, sizeof(name), editing))
{
    editing = !editing;
}
```

### `GuiSlider`

```c
int GuiSlider(Rectangle bounds, const char *textLeft, const char *textRight, float *value, float minValue, float maxValue);
```

Draws an interactive slider with a draggable knob.

**Arguments**

- **`bounds`** — `Rectangle`: Slider track rectangle.
- **`textLeft`** — `const char *`: Optional text drawn to the left.
- **`textRight`** — `const char *`: Optional text drawn to the right.
- **`value`** — `float *`: Input/output current value.
- **`minValue`** — `float`: Value at the start of the track.
- **`maxValue`** — `float`: Value at the end of the track.

**Minimal example**

```c
float volume = 0.5f;
GuiSlider(
    (Rectangle){ 80, 20, 180, 20 },
    "Volume", TextFormat("%.0f%%", volume*100),
    &volume, 0.0f, 1.0f);
```

### `GuiSliderBar`

```c
int GuiSliderBar(Rectangle bounds, const char *textLeft, const char *textRight, float *value, float minValue, float maxValue);
```

Draws an interactive slider represented by a filled bar rather than a separate knob.

**Arguments**

- **`bounds`** — `Rectangle`: Slider-bar rectangle.
- **`textLeft`** — `const char *`: Optional left label.
- **`textRight`** — `const char *`: Optional right label.
- **`value`** — `float *`: Input/output current value.
- **`minValue`** — `float`: Minimum value.
- **`maxValue`** — `float`: Maximum value.

**Minimal example**

```c
float zoom = 1.0f;
GuiSliderBar(
    (Rectangle){ 80, 20, 180, 20 },
    "Zoom", TextFormat("%.1fx", zoom),
    &zoom, 0.25f, 4.0f);
```

### `GuiProgressBar`

```c
int GuiProgressBar(Rectangle bounds, const char *textLeft, const char *textRight, float *value, float minValue, float maxValue);
```

Draws a progress indicator for a value within a range.

**Arguments**

- **`bounds`** — `Rectangle`: Progress-bar rectangle.
- **`textLeft`** — `const char *`: Optional text on the left.
- **`textRight`** — `const char *`: Optional text on the right.
- **`value`** — `float *`: Current progress value. The API uses a pointer for consistency and may clamp/update it.
- **`minValue`** — `float`: Minimum progress value.
- **`maxValue`** — `float`: Maximum progress value.

**Minimal example**

```c
float progress = 42.0f;
GuiProgressBar(
    (Rectangle){ 20, 20, 240, 24 },
    NULL, "42%",
    &progress, 0.0f, 100.0f);
```

### `GuiStatusBar`

```c
int GuiStatusBar(Rectangle bounds, const char *text);
```

Draws a status-bar-style rectangle containing informational text.

**Arguments**

- **`bounds`** — `Rectangle`: Status bar position and size.
- **`text`** — `const char *`: Status message.

**Minimal example**

```c
GuiStatusBar(
    (Rectangle){ 0, GetScreenHeight() - 24,
                 GetScreenWidth(), 24 },
    "Ready");
```

### `GuiDummyRec`

```c
int GuiDummyRec(Rectangle bounds, const char *text);
```

Draws a placeholder rectangle. It is useful while designing a manual layout.

**Arguments**

- **`bounds`** — `Rectangle`: Placeholder rectangle.
- **`text`** — `const char *`: Optional placeholder label.

**Minimal example**

```c
GuiDummyRec((Rectangle){ 20, 20, 200, 100 }, "Preview");
```

### `GuiGrid`

```c
int GuiGrid(Rectangle bounds, const char *text, float spacing, int subdivs, Vector2 *mouseCell);
```

Draws a coordinate grid and reports the cell under the mouse.

**Arguments**

- **`bounds`** — `Rectangle`: Grid drawing rectangle.
- **`text`** — `const char *`: Optional label.
- **`spacing`** — `float`: Distance in pixels between major grid divisions.
- **`subdivs`** — `int`: Number of subdivisions within each major division.
- **`mouseCell`** — `Vector2 *`: Receives the grid cell coordinate under the mouse.

**Minimal example**

```c
Vector2 cell = { -1, -1 };
GuiGrid(
    (Rectangle){ 20, 20, 300, 200 },
    NULL, 32.0f, 4, &cell);
```

## Advanced controls

### `GuiListView`

```c
int GuiListView(Rectangle bounds, const char *text, int *scrollIndex, int *active);
```

Draws a scrollable list from a semicolon-separated string.

**Arguments**

- **`bounds`** — `Rectangle`: Visible list rectangle.
- **`text`** — `const char *`: Semicolon-separated list items.
- **`scrollIndex`** — `int *`: Input/output index of the first visible/scrolled item.
- **`active`** — `int *`: Input/output selected item index; commonly `-1` means no selection.

**Minimal example**

```c
int scrollIndex = 0;
int active = -1;

GuiListView(
    (Rectangle){ 20, 20, 180, 140 },
    "Apple;Banana;Cherry;Date",
    &scrollIndex,
    &active);
```

### `GuiListViewEx`

```c
int GuiListViewEx(Rectangle bounds, char **text, int count, int *scrollIndex, int *active, int *focus);
```

Draws a list from an array of string pointers and also reports the focused item.

**Arguments**

- **`bounds`** — `Rectangle`: Visible list rectangle.
- **`text`** — `char **`: Array of item strings.
- **`count`** — `int`: Number of strings in the array.
- **`scrollIndex`** — `int *`: Input/output first visible/scrolled item index.
- **`active`** — `int *`: Input/output selected item index.
- **`focus`** — `int *`: Input/output focused/hovered item index.

**Minimal example**

```c
char *items[] = { "One", "Two", "Three" };
int scroll = 0, active = -1, focus = -1;

GuiListViewEx(
    (Rectangle){ 20, 20, 180, 120 },
    items, 3, &scroll, &active, &focus);
```

### `GuiTabBar`

```c
int GuiTabBar(Rectangle bounds, const char *text, int *hscroll, int *active);
```

Draws a horizontally scrollable tab bar from semicolon-separated titles.

**Arguments**

- **`bounds`** — `Rectangle`: Tab-bar rectangle.
- **`text`** — `const char *`: Semicolon-separated tab titles.
- **`hscroll`** — `int *`: Input/output horizontal tab scroll position/index.
- **`active`** — `int *`: Input/output active tab index.

**Minimal example**

```c
int tabScroll = 0;
int activeTab = 0;

GuiTabBar(
    (Rectangle){ 20, 20, 320, 30 },
    "Home;Scene;Assets;Settings",
    &tabScroll,
    &activeTab);
```

### `GuiTabBarEx`

```c
int GuiTabBarEx(Rectangle bounds, char **text, int count, int *hscroll, int *active, int *focus);
```

Draws a tab bar from an array of titles and reports the focused tab.

**Arguments**

- **`bounds`** — `Rectangle`: Tab-bar rectangle.
- **`text`** — `char **`: Array of tab-title strings.
- **`count`** — `int`: Number of tabs.
- **`hscroll`** — `int *`: Input/output horizontal scroll state.
- **`active`** — `int *`: Input/output active tab index.
- **`focus`** — `int *`: Input/output focused/hovered tab index.

**Minimal example**

```c
char *tabs[] = { "Home", "Scene", "Assets" };
int scroll = 0, active = 0, focus = -1;

GuiTabBarEx(
    (Rectangle){ 20, 20, 300, 30 },
    tabs, 3, &scroll, &active, &focus);
```

### `GuiMessageBox`

```c
int GuiMessageBox(Rectangle bounds, const char *title, const char *message, const char *btnText, int *btnActive);
```

Draws a modal-style message box with one or more buttons.

**Arguments**

- **`bounds`** — `Rectangle`: Complete message-box rectangle.
- **`title`** — `const char *`: Window title.
- **`message`** — `const char *`: Message body.
- **`btnText`** — `const char *`: Semicolon-separated button labels.
- **`btnActive`** — `int *`: Receives the activated button index; use `-1` while no button has been chosen.

**Minimal example**

```c
int button = -1;

GuiMessageBox(
    (Rectangle){ 100, 80, 280, 140 },
    "Delete file?",
    "This cannot be undone.",
    "Cancel;Delete",
    &button);

if (button == 1) DeleteFileNow();
```

### `GuiTextInputBox`

```c
int GuiTextInputBox(Rectangle bounds, const char *title, const char *message, char *text, int textSize, const char *btnText, int *btnActive, bool *secretViewActive);
```

Draws a modal-style text input dialog, optionally supporting hidden/secret text.

**Arguments**

- **`bounds`** — `Rectangle`: Complete dialog rectangle.
- **`title`** — `const char *`: Dialog title.
- **`message`** — `const char *`: Prompt or explanatory message.
- **`text`** — `char *`: Writable input buffer.
- **`textSize`** — `int`: Buffer capacity in bytes, including the NUL terminator.
- **`btnText`** — `const char *`: Semicolon-separated button labels.
- **`btnActive`** — `int *`: Receives the activated button index.
- **`secretViewActive`** — `bool *`: Input/output secret-text visibility. Pass `NULL` when secret mode is unnecessary.

**Minimal example**

```c
char name[64] = "";
int button = -1;

GuiTextInputBox(
    (Rectangle){ 100, 80, 300, 180 },
    "Rename",
    "Enter a new name:",
    name, sizeof(name),
    "Cancel;OK",
    &button,
    NULL);
```

### `GuiColorPicker`

```c
int GuiColorPicker(Rectangle bounds, const char *text, Color *color);
```

Draws a full RGBA color picker, including the color panel and hue controls.

**Arguments**

- **`bounds`** — `Rectangle`: Color-picker rectangle.
- **`text`** — `const char *`: Optional label.
- **`color`** — `Color *`: Input/output raylib color.

**Minimal example**

```c
Color tint = RED;
GuiColorPicker(
    (Rectangle){ 20, 20, 220, 180 },
    "Tint",
    &tint);
```

### `GuiColorPanel`

```c
int GuiColorPanel(Rectangle bounds, const char *text, Color *color);
```

Draws the two-dimensional saturation/value color panel.

**Arguments**

- **`bounds`** — `Rectangle`: Panel rectangle.
- **`text`** — `const char *`: Optional label.
- **`color`** — `Color *`: Input/output color. Hue is preserved while saturation/value are edited.

**Minimal example**

```c
Color color = BLUE;
GuiColorPanel(
    (Rectangle){ 20, 20, 180, 140 },
    NULL,
    &color);
```

### `GuiColorBarAlpha`

```c
int GuiColorBarAlpha(Rectangle bounds, const char *text, float *alpha);
```

Draws an alpha/transparency bar.

**Arguments**

- **`bounds`** — `Rectangle`: Bar rectangle.
- **`text`** — `const char *`: Optional label.
- **`alpha`** — `float *`: Input/output alpha, normally from `0.0f` to `1.0f`.

**Minimal example**

```c
float alpha = 1.0f;
GuiColorBarAlpha(
    (Rectangle){ 20, 20, 180, 20 },
    "Alpha",
    &alpha);
```

### `GuiColorBarHue`

```c
int GuiColorBarHue(Rectangle bounds, const char *text, float *value);
```

Draws a hue-selection bar.

**Arguments**

- **`bounds`** — `Rectangle`: Hue-bar rectangle.
- **`text`** — `const char *`: Optional label.
- **`value`** — `float *`: Input/output hue value in raygui's expected hue range.

**Minimal example**

```c
float hue = 180.0f;
GuiColorBarHue(
    (Rectangle){ 20, 20, 20, 160 },
    NULL,
    &hue);
```

### `GuiColorPickerHSV`

```c
int GuiColorPickerHSV(Rectangle bounds, const char *text, Vector3 *colorHsv);
```

Draws a full color picker using HSV values instead of a `Color` structure.

**Arguments**

- **`bounds`** — `Rectangle`: Color-picker rectangle.
- **`text`** — `const char *`: Optional label.
- **`colorHsv`** — `Vector3 *`: Input/output HSV vector: hue, saturation, and value using raygui/raylib HSV conventions.

**Minimal example**

```c
Vector3 hsv = { 210.0f, 0.8f, 0.9f };
GuiColorPickerHSV(
    (Rectangle){ 20, 20, 220, 180 },
    NULL,
    &hsv);
```

### `GuiColorPanelHSV`

```c
int GuiColorPanelHSV(Rectangle bounds, const char *text, Vector3 *colorHsv);
```

Draws the saturation/value panel using HSV data.

**Arguments**

- **`bounds`** — `Rectangle`: Panel rectangle.
- **`text`** — `const char *`: Optional label.
- **`colorHsv`** — `Vector3 *`: Input/output HSV vector.

**Minimal example**

```c
Vector3 hsv = { 30.0f, 1.0f, 1.0f };
GuiColorPanelHSV(
    (Rectangle){ 20, 20, 180, 140 },
    NULL,
    &hsv);
```

---

## Practical complete example

```c
#include "raylib.h"

#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

int main(void)
{
    InitWindow(640, 360, "raygui minimal application");
    SetTargetFPS(60);

    bool enabled = true;
    float amount = 0.5f;
    char name[64] = "raygui";
    bool nameEditMode = false;

    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(GetColor(GuiGetStyle(DEFAULT, BACKGROUND_COLOR)));

        GuiCheckBox(
            (Rectangle){ 20, 20, 20, 20 },
            "Enabled",
            &enabled);

        GuiSliderBar(
            (Rectangle){ 100, 65, 220, 20 },
            "Amount",
            TextFormat("%.2f", amount),
            &amount,
            0.0f,
            1.0f);

        if (GuiTextBox(
                (Rectangle){ 100, 105, 220, 30 },
                name,
                sizeof(name),
                nameEditMode))
        {
            nameEditMode = !nameEditMode;
        }

        if (GuiButton(
                (Rectangle){ 100, 150, 120, 30 },
                GuiIconText(ICON_FILE_SAVE, "Save")))
        {
            TraceLog(LOG_INFO, "Save: enabled=%d amount=%f name=%s",
                     enabled, amount, name);
        }

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
```

## Notes and caveats

- raygui does not provide automatic layout. Your program calculates and supplies every control rectangle.
- Immediate-mode calls do not create persistent widget objects. Persistent values such as selected indexes, edit modes, scroll positions, and text buffers belong to your application.
- Keep `RAYGUI_IMPLEMENTATION` in one compilation unit only.
- The `master` branch may change. Pin a release/tag or commit when reproducible API behavior is important.
- Functions guarded by `#if !defined(RAYGUI_NO_ICONS)` are unavailable when raygui is compiled with `RAYGUI_NO_ICONS`.
- Style and icon-loading functions can allocate resources. Review the notes in the exact header version you ship, particularly when repeatedly replacing fonts or style data.
