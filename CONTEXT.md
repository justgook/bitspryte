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

**UI Shell**:
The SMGUI form tree surrounding the Canvas Region, including toolbars, status areas, menus, and popups.
_Avoid_: Main canvas view

## Relationships

- The **UI Shell** reserves exactly one **Canvas Region**.
- The **Canvas View** places the **Document Canvas** within the **Canvas Region**.
- The **Preview Overlay** uses the same **Canvas View** as the **Document Canvas**.

## Example dialogue

> **Dev:** “Should Home center the Document Canvas in the window?”
> **Domain expert:** “Center it in the Canvas Region; the UI Shell owns the rest of the window.”

## Flagged ambiguities

- “canvas” previously meant both the persistent image and its available screen area; use **Document Canvas** and **Canvas Region** respectively.
