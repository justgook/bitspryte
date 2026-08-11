# Vendored SMGUI

This directory contains the backend-independent Odin packages required by
BitSpryte. Platform adapters, examples, tests, the Reference C submodule, and
SMGUI's duplicate Sokol dependency are intentionally excluded.

- Upstream: https://github.com/justgook/smgui
- Commit: `a716c0944b84c113236eff5776e8f79968180eaf`
- License: MIT (`LICENSE`); bundled font and theme notices live beside their assets
- Vendored packages: `smgui`, `psf2`, `spritesheet`, `themes/catppuccin_mocha`
- Downstream SMGUI additions: native Panel Forms with per-side padding, renderer-owned backgrounds, and transparent content, fixed-size/padded Button controls with per-Button nine-slice overrides, reusable normal/focused nine-slices, the generated Catppuccin named style atlas, and positive integer nearest-neighbor loading scales for skin/style/icon graphics

BitSpryte owns the Sokol application and graphics lifecycle. Do not add the
upstream `smgui/sokol` adapter without first removing that lifecycle ownership
from one side.
