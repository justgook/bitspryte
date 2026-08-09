package catppuccin_mocha

import smgui "../../smgui"
import "core:c"
import stbi "vendor:stb/image"

SKIN_PNG :: #load("skin.png")

Icon_Atlas :: struct {
	pixels: []u8,
	width:  int,
	height: int,
	scale:  int,
}

@(require_results)
apply :: proc(ctx: ^smgui.Context, scale: int = 1) -> smgui.Error {
	if error := smgui.set_png_skin(ctx, SKIN_PNG, scale); error != .None {
		return error
	}
	return smgui.set_theme(ctx, THEME[:])
}

@(require_results)
load_icon_atlas :: proc(scale: int = 1) -> (Icon_Atlas, smgui.Error) {
	width, height, channels: c.int
	decoded := stbi.load_from_memory(
		raw_data(ICON_ATLAS_PNG),
		c.int(len(ICON_ATLAS_PNG)),
		&width,
		&height,
		&channels,
		4,
	)
	if decoded == nil || width < 1 || height < 1 || int(width) > max(int) / int(height) / 4 {
		return {}, .Invalid_Input
	}
	defer stbi.image_free(decoded)
	source_count := int(width) * int(height) * 4
	pixels, scaled_width, scaled_height, error := smgui.scale_rgba_nearest(
		decoded[:source_count],
		int(width),
		int(height),
		scale,
	)
	if error != .None {
		return {}, error
	}
	return {pixels = pixels, width = scaled_width, height = scaled_height, scale = scale}, .None
}

icon_atlas_deinit :: proc(atlas: ^Icon_Atlas) {
	if atlas == nil {
		return
	}
	if atlas.pixels != nil {
		delete(atlas.pixels)
	}
	atlas^ = {}
}

icon :: proc(atlas: ^Icon_Atlas, index: int) -> (smgui.Image, bool) {
	if atlas == nil ||
	   index < 0 ||
	   index >= ICON_COUNT ||
	   len(atlas.pixels) == 0 ||
	   atlas.width < 1 ||
	   atlas.height < 1 ||
	   atlas.width > max(int) / atlas.height / 4 ||
	   len(atlas.pixels) < atlas.width * atlas.height * 4 {
		return {}, false
	}
	rect := ICON_RECTS[index]
	x := rect.x * atlas.scale
	y := rect.y * atlas.scale
	width := rect.width * atlas.scale
	height := rect.height * atlas.scale
	if atlas.scale < 1 ||
	   x < 0 ||
	   y < 0 ||
	   width < 1 ||
	   height < 1 ||
	   width > atlas.width ||
	   height > atlas.height ||
	   x > atlas.width - width ||
	   y > atlas.height - height {
		return {}, false
	}
	offset := (y * atlas.width + x) * 4
	return smgui.Image {
			width = width,
			height = height,
			pitch = atlas.width * 4,
			pixels = atlas.pixels[offset:],
		},
		true
}

find_icon :: proc(name: string) -> (int, bool) {
	for candidate, index in ICON_NAMES {
		if candidate == name {
			return index, true
		}
	}
	return 0, false
}
