# BitSpryte editor

BitSpryte is a pixel editor whose document canvas is presented inside an SMGUI-owned editor layout.

## Language

**Document Canvas**:
The persistent pixel image being edited.
_Avoid_: Framebuffer, surface

**Canvas Region**:
The layout-computed rectangular space reserved for presenting and interacting with the Document Canvas.
_Avoid_: Clip-space, window, viewport

**Canvas View**:
The pan and pixel-perfect zoom state that places the Document Canvas within the Canvas Region.
_Avoid_: Camera

**Preview Overlay**:
Transient editor graphics displayed over the Document Canvas without modifying it.
_Avoid_: Preview canvas

**Panel**:
A framed SMGUI container in the UI Shell that contains one editor workspace, such as the Canvas Region, Palette, or Color Wheel. A Panel can be focused independently of its children.
_Avoid_: Component, popup, box

**Panel Style**:
A pair of normal and focused nine-slices imported by name from the active Aseprite theme. Each workspace Panel selects its own Panel Style independently. Workspace Panels share four-sided padding; only the Canvas Panel uses transparent content.
_Avoid_: Popup skin, hard-coded border

**UI Shell**:
The SMGUI form tree surrounding the Canvas Region, including Panels, toolbars, status areas, menus, and popups.
_Avoid_: Main canvas view

## Relationships

- The **UI Shell** reserves exactly one **Canvas Region** inside a **Panel**.
- Workspace Panels currently select the `editor_normal`/`editor_selected` **Panel Style**, but Canvas, Palette, and Color Wheel expose independent style settings for easy replacement. They retain identical four-sided padding and use `#1E1E2D` beneath the nine-slice border; the active Panel selects its focused nine-slice. Panel background paint is renderer-owned, does not participate in child measurement, and reaches the frame independently of content padding.
- The Canvas Region Panel is the initial active Panel.
- The footer reports the zero-indexed Canvas cursor coordinate and Canvas pixel dimensions; coordinates are unavailable while the pointer is outside the Canvas.
- `UI_GRAPHICS_SCALE` selects a positive integer nearest-neighbor scale for the fixed SMGUI skin and named Panel style atlas. Font scale and application geometry remain independent.
- The Canvas Region Panel has transparent content so the BitSpryte-owned GPU canvas remains visible beneath SMGUI. SMGUI clears the full framed center independently of content padding; the Canvas child exists only to publish Canvas Region geometry.
- The workspace parent owns and clips the Canvas Panel and the resizable left-side parent.
- The resizable left-side parent starts at 96px and owns Palette and Color Wheel **Panels** separated by a draggable horizontal splitter.
- Parent containers compute geometry and render before their child Panels.
- The **Canvas View** places the **Document Canvas** within the **Canvas Region**.
- The **Preview Overlay** uses the same **Canvas View** as the **Document Canvas**.

## Example dialogue

> **Dev:** “Should Home center the Document Canvas in the window?”
> **Domain expert:** “Center it in the Canvas Region; the UI Shell owns the rest of the window.”

## Flagged ambiguities

- “canvas” previously meant both the persistent image and its available screen area; use **Document Canvas** and **Canvas Region** respectively.
