package spritesheet

/*
Aseprite-compatible proportional sprite-sheet fonts for SMGUI.

The sheet's top-left pixel is the separator color. Glyph rectangles are
scanned sequentially from U+0020; a red first pixel marks an unavailable
codepoint. This is the format used by Aseprite's built-in pixel fonts.
*/

import smgui "../smgui"
import "core:c"
import stbi "vendor:stb/image"

ASEPRITE_FONT_DATA :: #load("fonts/aseprite_font.png")
ASEPRITE_MINI_DATA :: #load("fonts/aseprite_mini.png")

MAX_SCALE :: 8
MAX_DIMENSION :: 65535

Glyph :: struct {
	x:     int,
	y:     int,
	width: int,
	valid: bool,
}

Font :: struct {
	pixels:       []u8,
	glyphs:       [dynamic]Glyph,
	width:        int,
	height:       int,
	glyph_height: int,
	descent:      int,
	scale:        int,
}

@(require_results)
aseprite_font :: proc(scale: int = 1) -> (Font, smgui.Error) {
	return parse_png(ASEPRITE_FONT_DATA, scale, 2)
}

@(require_results)
aseprite_mini_font :: proc(scale: int = 1) -> (Font, smgui.Error) {
	return parse_png(ASEPRITE_MINI_DATA, scale, 1)
}

@(require_results)
parse_png :: proc(data: []u8, scale: int = 1, descent: int = 0) -> (Font, smgui.Error) {
	if len(data) < 16 {
		return {}, .Invalid_Input
	}
	width, height, channels: c.int
	decoded := stbi.load_from_memory(raw_data(data), c.int(len(data)), &width, &height, &channels, 4)
	if decoded == nil || width < 1 || height < 1 {
		if decoded != nil {
			stbi.image_free(decoded)
		}
		return {}, .Invalid_Input
	}
	defer stbi.image_free(decoded)
	pixels := decoded[:int(width) * int(height) * 4]
	return parse_rgba(pixels, int(width), int(height), scale, descent)
}

@(require_results)
parse_rgba :: proc(
	rgba: []u8,
	width, height: int,
	scale: int = 1,
	descent: int = 0,
) -> (Font, smgui.Error) {
	if width < 2 || height < 2 || width > MAX_DIMENSION || height > MAX_DIMENSION ||
	   scale < 1 || scale > MAX_SCALE || descent < 0 || len(rgba) < width * height * 4 {
		return {}, .Invalid_Input
	}

	glyphs := make([dynamic]Glyph, 0, 256) or_else nil
	if glyphs == nil {
		return {}, .Out_Of_Memory
	}
	x, y := 0, 0
	row_height := 1
	glyph_height := 0
	for y < height {
		for y < height && pixels_equal(rgba, width, x, y, 0, 0) {
			x += 1
			if x >= width {
				x = 0
				y += row_height
				row_height = 1
			}
		}
		if y >= height {
			break
		}

		glyph_width := 0
		for x + glyph_width < width && !pixels_equal(rgba, width, x + glyph_width, y, 0, 0) {
			glyph_width += 1
		}
		current_height := 0
		for y + current_height < height && !pixels_equal(rgba, width, x, y + current_height, 0, 0) {
			current_height += 1
		}
		if glyph_width < 1 || current_height < 1 ||
		   (glyph_height > 0 && current_height != glyph_height) {
			delete(glyphs)
			return {}, .Invalid_Input
		}
		glyph_height = current_height
		pixel := ((y * width) + x) * 4
		valid := !(rgba[pixel] == 255 && rgba[pixel + 1] == 0 &&
		           rgba[pixel + 2] == 0 && rgba[pixel + 3] == 255)
		if (append(&glyphs, Glyph{x = x, y = y, width = glyph_width, valid = valid}) or_else -1) < 0 {
			delete(glyphs)
			return {}, .Out_Of_Memory
		}
		x += glyph_width
		row_height = current_height
	}
	if len(glyphs) == 0 || descent > glyph_height {
		delete(glyphs)
		return {}, .Invalid_Input
	}

	pixels := make([]u8, width * height * 4) or_else nil
	if pixels == nil {
		delete(glyphs)
		return {}, .Out_Of_Memory
	}
	copy(pixels, rgba[:len(pixels)])
	return Font {
		pixels       = pixels,
		glyphs       = glyphs,
		width        = width,
		height       = height,
		glyph_height = glyph_height,
		descent      = descent,
		scale        = scale,
	}, .None
}

deinit :: proc(font: ^Font) {
	if font == nil {
		return
	}
	if font.pixels != nil {
		delete(font.pixels)
	}
	if font.glyphs != nil {
		delete(font.glyphs)
	}
	font^ = {}
}

@(require_results)
configure :: proc(ctx: ^smgui.Context, font: ^Font) -> smgui.Error {
	if font == nil || len(font.pixels) == 0 || len(font.glyphs) == 0 {
		return .Invalid_Input
	}
	if error := smgui.set_font_hooks(ctx, bounds, draw); error != .None {
		return error
	}
	return smgui.set_font(ctx, font)
}

pixels_equal :: proc(data: []u8, width, ax, ay, bx, by: int) -> bool {
	a := (ay * width + ax) * 4
	b := (by * width + bx) * 4
	return data[a] == data[b] && data[a + 1] == data[b + 1] &&
	       data[a + 2] == data[b + 2] && data[a + 3] == data[b + 3]
}

glyph_for :: proc(font: ^Font, codepoint: rune) -> (Glyph, bool) {
	index := int(codepoint) - int(' ')
	if index >= 0 && index < len(font.glyphs) && font.glyphs[index].valid {
		return font.glyphs[index], true
	}
	fallback := int('?') - int(' ')
	if fallback >= 0 && fallback < len(font.glyphs) && font.glyphs[fallback].valid {
		return font.glyphs[fallback], true
	}
	return {}, false
}

bounds :: proc(
	font_data: rawptr,
	text: string,
	width: ^int,
	height: ^int,
	left: ^int,
	top: ^int,
) -> smgui.Error {
	if font_data == nil || width == nil || height == nil {
		return .Invalid_Input
	}
	font := (^Font)(font_data)
	if font.scale < 1 || font.glyph_height < 1 || len(font.glyphs) == 0 {
		return .Invalid_Input
	}
	line_width := 0
	width^ = 0
	height^ = font.glyph_height * font.scale
	if left != nil {
		left^ = 0
	}
	if top != nil {
		top^ = 0
	}
	for character in text {
		switch character {
		case '\r':
			line_width = 0
		case '\n':
			line_width = 0
			height^ += font.glyph_height * font.scale
		case:
			if glyph, ok := glyph_for(font, character); ok {
				line_width += glyph.width * font.scale
				width^ = max(width^, line_width)
			}
		}
	}
	return .None
}

draw :: proc(
	font_data: rawptr,
	text: string,
	destination: []u8,
	color: u32,
	x, y, left, top, pitch: int,
	crop_x0, crop_y0, crop_x1, crop_y1: int,
) -> smgui.Error {
	if font_data == nil || len(destination) == 0 || pitch < 4 ||
	   crop_x1 < crop_x0 || crop_y1 < crop_y0 {
		return .Invalid_Input
	}
	font := (^Font)(font_data)
	if font.scale < 1 || font.glyph_height < 1 || len(font.pixels) == 0 {
		return .Invalid_Input
	}
	origin_x := x
	cursor_x := x
	cursor_y := y
	_ = left
	_ = top

	for character in text {
		switch character {
		case '\r':
			cursor_x = origin_x
		case '\n':
			cursor_x = origin_x
			cursor_y += font.glyph_height * font.scale
		case:
			glyph, ok := glyph_for(font, character)
			if !ok {
				continue
			}
			draw_glyph(font, glyph, destination, color, cursor_x, cursor_y, pitch,
			           crop_x0, crop_y0, crop_x1, crop_y1)
			cursor_x += glyph.width * font.scale
		}
	}
	return .None
}

draw_glyph :: proc(
	font: ^Font,
	glyph: Glyph,
	destination: []u8,
	color: u32,
	x, y, pitch: int,
	crop_x0, crop_y0, crop_x1, crop_y1: int,
) {
	destination_width := pitch / 4
	destination_height := len(destination) / pitch
	for source_y in 0 ..< font.glyph_height {
		for source_x in 0 ..< glyph.width {
			source := ((glyph.y + source_y) * font.width + glyph.x + source_x) * 4
			if source < 0 || source + 3 >= len(font.pixels) || font.pixels[source + 3] < 128 {
				continue
			}
			for scale_y in 0 ..< font.scale {
				destination_y := y + source_y * font.scale + scale_y
				if destination_y < crop_y0 || destination_y >= crop_y1 ||
				   destination_y < 0 || destination_y >= destination_height {
					continue
				}
				for scale_x in 0 ..< font.scale {
					destination_x := x + source_x * font.scale + scale_x
					if destination_x < crop_x0 || destination_x >= crop_x1 ||
					   destination_x < 0 || destination_x >= destination_width {
						continue
					}
					pixel := destination_y * pitch + destination_x * 4
					destination[pixel] = u8(color)
					destination[pixel + 1] = u8(color >> 8)
					destination[pixel + 2] = u8(color >> 16)
					destination[pixel + 3] = u8(color >> 24)
				}
			}
		}
	}
}
