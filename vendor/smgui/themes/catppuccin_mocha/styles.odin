package catppuccin_mocha

import smgui "../../smgui"
import "core:c"
import stbi "vendor:stb/image"

// Generated from the named nine-slice parts in an Aseprite theme sprite sheet.
// Source: https://github.com/catppuccin/aseprite at 3113df487afbb564f20e6e9402ee077f002f926c
STYLE_ATLAS_PNG :: #load("styles.png")

Style_Atlas :: struct {
	pixels: []u8,
	width:  int,
	height: int,
	scale:  int,
}

Style_Rect :: struct {
	x, y:    int,
	columns: [3]int,
	rows:    [3]int,
}

STYLE_COUNT :: 92
STYLE_NAMES := [STYLE_COUNT]string {
	"button_focused",
	"button_hot",
	"button_normal",
	"button_selected",
	"buttonset_item_focused",
	"buttonset_item_hot",
	"buttonset_item_hot_focused",
	"buttonset_item_normal",
	"buttonset_item_pushed",
	"check_focus",
	"colorbar_0",
	"colorbar_1",
	"colorbar_2",
	"colorbar_3",
	"colorbar_selection",
	"colorbar_selection_hot",
	"drop_down_button_left_focused",
	"drop_down_button_left_hot",
	"drop_down_button_left_normal",
	"drop_down_button_left_selected",
	"drop_down_button_right_focused",
	"drop_down_button_right_hot",
	"drop_down_button_right_normal",
	"drop_down_button_right_selected",
	"editor_normal",
	"editor_selected",
	"menu",
	"mini_scrollbar_bg",
	"mini_scrollbar_bg_hot",
	"mini_scrollbar_thumb",
	"mini_scrollbar_thumb_hot",
	"mini_slider_empty",
	"mini_slider_empty_focused",
	"mini_slider_full",
	"mini_slider_full_focused",
	"radio_focus",
	"scrollbar_bg",
	"scrollbar_thumb",
	"simple_color_border",
	"simple_color_selected",
	"slider_empty",
	"slider_empty_focused",
	"slider_full",
	"slider_full_focused",
	"sunken2_focused",
	"sunken2_normal",
	"sunken_focused",
	"sunken_mini_focused",
	"sunken_mini_normal",
	"sunken_normal",
	"tab_active",
	"tab_bottom_active",
	"tab_normal",
	"timeline_active",
	"timeline_active_hover",
	"timeline_both_links_active",
	"timeline_clicked",
	"timeline_drop_frame_deco",
	"timeline_drop_layer_deco",
	"timeline_empty_frame_active",
	"timeline_empty_frame_normal",
	"timeline_focused",
	"timeline_from_both_active",
	"timeline_from_both_normal",
	"timeline_from_left_active",
	"timeline_from_left_normal",
	"timeline_from_right_active",
	"timeline_from_right_normal",
	"timeline_hover",
	"timeline_keyframe_active",
	"timeline_keyframe_normal",
	"timeline_left_link_active",
	"timeline_loop_range",
	"timeline_none",
	"timeline_normal",
	"timeline_onionskin_range",
	"timeline_padding",
	"timeline_padding_bl",
	"timeline_padding_br",
	"timeline_padding_tr",
	"timeline_right_link_active",
	"toolbutton_hot",
	"toolbutton_last",
	"toolbutton_normal",
	"toolbutton_pushed",
	"tooltip",
	"tooltip_arrow",
	"transparent_scrollbar_bg",
	"transparent_scrollbar_bg_hot",
	"transparent_scrollbar_thumb",
	"transparent_scrollbar_thumb_hot",
	"window",
}
STYLE_RECTS := [STYLE_COUNT]Style_Rect {
	{0, 0, {4, 6, 4}, {4, 6, 6}},
	{15, 0, {4, 6, 4}, {4, 6, 6}},
	{30, 0, {4, 6, 4}, {4, 6, 6}},
	{45, 0, {4, 6, 4}, {4, 6, 6}},
	{60, 0, {3, 10, 3}, {3, 9, 4}},
	{77, 0, {3, 10, 3}, {3, 9, 4}},
	{94, 0, {3, 10, 3}, {3, 9, 4}},
	{111, 0, {3, 10, 3}, {3, 9, 4}},
	{128, 0, {3, 10, 3}, {3, 9, 4}},
	{145, 0, {2, 6, 2}, {2, 6, 2}},
	{156, 0, {5, 6, 5}, {5, 6, 5}},
	{173, 0, {5, 6, 5}, {5, 6, 5}},
	{190, 0, {5, 6, 5}, {5, 6, 5}},
	{207, 0, {5, 6, 5}, {5, 6, 5}},
	{224, 0, {5, 6, 5}, {5, 6, 5}},
	{0, 17, {5, 6, 5}, {5, 6, 5}},
	{17, 17, {3, 2, 3}, {4, 6, 6}},
	{26, 17, {3, 2, 3}, {4, 6, 6}},
	{35, 17, {3, 2, 3}, {4, 6, 6}},
	{44, 17, {3, 2, 3}, {4, 6, 6}},
	{53, 17, {2, 2, 2}, {4, 6, 6}},
	{60, 17, {2, 1, 3}, {4, 6, 6}},
	{67, 17, {2, 1, 3}, {4, 6, 6}},
	{74, 17, {2, 2, 2}, {4, 6, 6}},
	{81, 17, {3, 10, 3}, {3, 10, 3}},
	{98, 17, {3, 10, 3}, {3, 10, 3}},
	{115, 17, {3, 10, 3}, {3, 9, 4}},
	{132, 17, {3, 2, 3}, {3, 2, 3}},
	{141, 17, {3, 2, 3}, {3, 2, 3}},
	{150, 17, {3, 2, 3}, {3, 2, 3}},
	{159, 17, {3, 2, 3}, {3, 2, 3}},
	{168, 17, {2, 12, 2}, {2, 11, 3}},
	{185, 17, {2, 12, 2}, {2, 11, 3}},
	{202, 17, {2, 12, 2}, {2, 11, 3}},
	{219, 17, {2, 12, 2}, {2, 11, 3}},
	{236, 17, {2, 6, 2}, {2, 6, 2}},
	{0, 34, {5, 6, 5}, {5, 6, 5}},
	{17, 34, {5, 6, 5}, {5, 6, 5}},
	{34, 34, {3, 6, 3}, {3, 6, 3}},
	{47, 34, {3, 6, 3}, {3, 6, 3}},
	{60, 34, {5, 6, 5}, {5, 5, 6}},
	{77, 34, {5, 6, 5}, {5, 5, 6}},
	{94, 34, {5, 6, 5}, {5, 5, 6}},
	{111, 34, {5, 6, 5}, {5, 5, 6}},
	{128, 34, {5, 6, 5}, {5, 6, 5}},
	{145, 34, {5, 6, 5}, {5, 6, 5}},
	{162, 34, {4, 4, 4}, {4, 4, 4}},
	{175, 34, {4, 4, 4}, {3, 6, 3}},
	{188, 34, {4, 4, 4}, {3, 6, 3}},
	{201, 34, {4, 4, 4}, {4, 4, 4}},
	{214, 34, {4, 7, 5}, {4, 6, 2}},
	{231, 34, {4, 7, 5}, {2, 1, 2}},
	{0, 51, {4, 5, 5}, {4, 6, 2}},
	{15, 51, {2, 8, 2}, {2, 8, 2}},
	{28, 51, {2, 8, 2}, {2, 8, 2}},
	{41, 51, {0, 12, 0}, {4, 1, 7}},
	{54, 51, {2, 8, 2}, {2, 8, 2}},
	{67, 51, {2, 1, 2}, {3, 1, 3}},
	{73, 51, {3, 1, 3}, {2, 1, 2}},
	{81, 51, {5, 3, 4}, {5, 3, 4}},
	{94, 51, {5, 3, 4}, {5, 3, 4}},
	{107, 51, {2, 8, 2}, {2, 8, 2}},
	{120, 51, {0, 12, 0}, {5, 3, 4}},
	{133, 51, {0, 12, 0}, {5, 3, 4}},
	{146, 51, {0, 8, 4}, {5, 3, 4}},
	{159, 51, {0, 8, 4}, {5, 3, 4}},
	{172, 51, {5, 7, 0}, {5, 3, 4}},
	{185, 51, {5, 7, 0}, {5, 3, 4}},
	{198, 51, {2, 8, 2}, {2, 8, 2}},
	{211, 51, {5, 3, 4}, {5, 3, 4}},
	{224, 51, {5, 3, 4}, {5, 3, 4}},
	{237, 51, {3, 9, 0}, {4, 1, 7}},
	{0, 64, {4, 4, 4}, {3, 6, 3}},
	{13, 64, {2, 8, 2}, {2, 8, 2}},
	{26, 64, {2, 8, 2}, {2, 8, 2}},
	{39, 64, {3, 6, 3}, {3, 6, 3}},
	{52, 64, {1, 10, 1}, {1, 10, 1}},
	{65, 64, {1, 10, 1}, {1, 10, 1}},
	{78, 64, {1, 10, 1}, {1, 10, 1}},
	{91, 64, {1, 10, 1}, {1, 10, 1}},
	{104, 64, {0, 9, 3}, {4, 1, 7}},
	{117, 64, {3, 10, 3}, {3, 9, 4}},
	{134, 64, {3, 10, 3}, {3, 9, 4}},
	{151, 64, {3, 10, 3}, {3, 9, 4}},
	{168, 64, {3, 10, 3}, {3, 9, 4}},
	{185, 64, {5, 6, 5}, {5, 5, 6}},
	{202, 64, {5, 6, 5}, {5, 5, 6}},
	{219, 64, {3, 2, 3}, {3, 2, 3}},
	{228, 64, {3, 2, 3}, {3, 2, 3}},
	{237, 64, {3, 2, 3}, {3, 2, 3}},
	{246, 64, {3, 2, 3}, {3, 2, 3}},
	{0, 81, {3, 7, 3}, {15, 4, 5}},
}

@(require_results)
load_style_atlas :: proc(scale: int = 1) -> (Style_Atlas, smgui.Error) {
	width, height, channels: c.int
	decoded := stbi.load_from_memory(
		raw_data(STYLE_ATLAS_PNG),
		c.int(len(STYLE_ATLAS_PNG)),
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

style_atlas_deinit :: proc(atlas: ^Style_Atlas) {
	if atlas == nil {
		return
	}
	if atlas.pixels != nil {
		delete(atlas.pixels)
	}
	atlas^ = {}
}

style :: proc(atlas: ^Style_Atlas, index: int) -> (smgui.Nine_Slice, bool) {
	if atlas == nil ||
	   index < 0 ||
	   index >= STYLE_COUNT ||
	   len(atlas.pixels) == 0 ||
	   atlas.width < 1 ||
	   atlas.height < 1 ||
	   atlas.width > max(int) / atlas.height / 4 ||
	   len(atlas.pixels) < atlas.width * atlas.height * 4 {
		return {}, false
	}
	rect := STYLE_RECTS[index]
	x := rect.x * atlas.scale
	y := rect.y * atlas.scale
	width := (rect.columns[0] + rect.columns[1] + rect.columns[2]) * atlas.scale
	height := (rect.rows[0] + rect.rows[1] + rect.rows[2]) * atlas.scale
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
	result: smgui.Nine_Slice
	for row in 0 ..< 3 {
		x = rect.x * atlas.scale
		for column in 0 ..< 3 {
			offset := (y * atlas.width + x) * 4
			result[row][column] = smgui.Image {
				width  = rect.columns[column] * atlas.scale,
				height = rect.rows[row] * atlas.scale,
				pitch  = atlas.width * 4,
				pixels = atlas.pixels[offset:],
			}
			x += rect.columns[column] * atlas.scale
		}
		y += rect.rows[row] * atlas.scale
	}
	return result, true
}

find_style :: proc(name: string) -> (int, bool) {
	for candidate, index in STYLE_NAMES {
		if candidate == name {
			return index, true
		}
	}
	return 0, false
}

style_by_name :: proc(atlas: ^Style_Atlas, name: string) -> (smgui.Nine_Slice, bool) {
	index, found := find_style(name)
	if !found {return {}, false}
	return style(atlas, index)
}

style_pair :: proc(
	atlas: ^Style_Atlas,
	normal_name, focused_name: string,
) -> (
	smgui.Panel_Style,
	bool,
) {
	normal, normal_found := style_by_name(atlas, normal_name)
	focused, focused_found := style_by_name(atlas, focused_name)
	if !normal_found || !focused_found {return {}, false}
	return {normal = normal, focused = focused}, true
}
