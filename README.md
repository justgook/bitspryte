# BitSpryte

An Odin application using [Sokol](https://github.com/floooh/sokol) for windowing and rendering.

The starter opens a resizable native window and presents a CPU-backed 160×120 pixel canvas through `sokol_framebuffer`. Draw pink pixels with the **left mouse button** and erase with the **right mouse button**. Fast pointer movement is connected into continuous strokes.

Press **Shift** to preview a straight line from the previous stroke endpoint to the cursor. Click to commit that segment; while Shift remains held, a new preview immediately starts from the clicked endpoint, allowing chained lines. Releasing Shift removes the preview. **Escape** cancels an active preview; otherwise it quits.

## Requirements

- A recent [Odin](https://odin-lang.org/) compiler
- `make`, a C compiler, `ar`, `curl`, and `tar`
- macOS (Metal, ARM64 or x86_64) or Linux (OpenGL, x86_64)

On Linux, install the X11, Xi, Xcursor, OpenGL, pthread, and dl development libraries required by `sokol_app`.

## Build

```sh
make          # debug build
make run      # debug build and run
make release  # optimized build
make check    # type-check
make test     # test stroke rasterization
```

The first build downloads the Odin Sokol bindings and compiles the native Sokol libraries used by the application. Dependencies are kept in the ignored `sokol/` directory; outputs go to `build.nosync/`.

## CPU framebuffer package

`render/cpu_framebuffer` owns a CPU-side RGBA8 pixel array and its `sokol_framebuffer` handle. It deliberately separates update and presentation:

```odin
cpu_framebuffer.upload_if_dirty(&canvas) // outside a render pass

sg.begin_pass(pass)
cpu_framebuffer.render(&canvas)          // inside the chosen pass/viewport
sg.end_pass()
```

The package provides pixel access, dirty tracking, upload, and rendering while leaving pass ordering and viewport placement to the caller. It also exposes the resolved texture for custom composition.

## Preview overlay and compositor

The straight-line preview is transient editor state rather than part of the document canvas:

- `drawing/line_preview.odin` owns the testable preview and chained-commit lifecycle.
- `editor/overlay` rasterizes previews into a transparent CPU framebuffer.
- `render/compositor` alpha-blends that framebuffer after the document canvas.
- Preview and commit both use the same Bresenham rasterizer, so the committed line matches the preview.

The compositor shader source is `render/compositor/textured_quad.glsl`; its generated Odin binding is committed beside it.

## Checkerboard configuration

`editor/checkerboard` fills a CPU framebuffer from a reusable `checkerboard.Config`. The default uses 16×16 cells with `#808080` and `#c0c0c0`. The application keeps this config as mutable state so a future settings menu can change it and call `checkerboard.fill` again.

Run `make help` to list available targets.
