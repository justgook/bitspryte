# Vendored SMGUI

This directory contains the backend-independent Odin packages required by
BitSpryte. Platform adapters, examples, tests, the Reference C submodule, and
SMGUI's duplicate Sokol dependency are intentionally excluded.

- Upstream: https://github.com/justgook/smgui
- Commit: `f10baa22b13fbdb508e34ce882c4e89322f4c4ea`
- License: MIT (`LICENSE`)
- Vendored packages: `smgui`, `psf2`

BitSpryte owns the Sokol application and graphics lifecycle. Do not add the
upstream `smgui/sokol` adapter without first removing that lifecycle ownership
from one side.
