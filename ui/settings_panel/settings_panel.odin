package settings_panel

import "core:c"
import rl "vendor:raylib"

CLOSE_WINDOW_SHORTCUT_ROW :: 6

Page :: enum c.int {
	General,
	Files,
	Keyboard_Shortcuts,
	Color,
	Alerts,
	Editor,
	Selection,
	Timeline,
	Cursors,
	Background,
	Grid,
	Guides_And_Slices,
	Undo,
	Theme,
	Extensions,
	Aseprite_Format,
	Experimental,
	Reset,
}

Setting_Field :: enum i32 {
	Save_Format,
	Export_Image_Format,
	Export_Animation_Format,
	Sprite_Sheet_Format,
	Recent_Items,
	Show_Full_Path,
	Auto_Recovery,
	Recovery_Interval,
	Keep_Edited,
	Keep_Edited_Duration,
	Keep_Closed,
	Keep_Closed_Duration,
}

State :: struct {
	visible: bool,
	theme:   c.int,
	page:    c.int,

	shortcut_capture_index: int,
	close_window_key:       rl.KeyboardKey,

	save_format:             c.int,
	export_image_format:     c.int,
	export_animation_format: c.int,
	sprite_sheet_format:     c.int,
	recent_items:            c.int,
	show_full_path:          bool,
	auto_recovery:           bool,
	recovery_interval:       c.int,
	keep_edited:             bool,
	keep_edited_duration:    c.int,
	keep_closed:             bool,
	keep_closed_duration:    c.int,
}

init :: proc() -> State {
	return State{
		page = c.int(Page.Files),
		shortcut_capture_index = -1,
		close_window_key = .ESCAPE,
		recent_items = 16,
		show_full_path = true,
		auto_recovery = true,
		keep_edited = true,
		keep_closed = true,
	}
}

open :: proc(state: ^State) {
	state.visible = true
}

close_active :: proc(state: ^State) -> bool {
	if !state.visible {
		return false
	}
	state.visible = false
	state.shortcut_capture_index = -1
	return true
}

captures_keyboard :: proc(state: ^State) -> bool {
	return state.visible && state.page == c.int(Page.Keyboard_Shortcuts) &&
		state.shortcut_capture_index >= 0
}

request_shortcut_capture :: proc(state: ^State, row: int) {
	state.shortcut_capture_index = row
}

cancel_shortcut_capture :: proc(state: ^State) {
	state.shortcut_capture_index = -1
}

capture_shortcut :: proc(state: ^State, key: rl.KeyboardKey) {
	if state.shortcut_capture_index == CLOSE_WINDOW_SHORTCUT_ROW {
		state.close_window_key = key
	}
	state.shortcut_capture_index = -1
}

apply_field :: proc(state: ^State, field: Setting_Field, value: i32) {
	switch field {
	case .Save_Format:              state.save_format = c.int(value)
	case .Export_Image_Format:      state.export_image_format = c.int(value)
	case .Export_Animation_Format:  state.export_animation_format = c.int(value)
	case .Sprite_Sheet_Format:      state.sprite_sheet_format = c.int(value)
	case .Recent_Items:             state.recent_items = c.int(value)
	case .Show_Full_Path:           state.show_full_path = value != 0
	case .Auto_Recovery:            state.auto_recovery = value != 0
	case .Recovery_Interval:        state.recovery_interval = c.int(value)
	case .Keep_Edited:              state.keep_edited = value != 0
	case .Keep_Edited_Duration:     state.keep_edited_duration = c.int(value)
	case .Keep_Closed:              state.keep_closed = value != 0
	case .Keep_Closed_Duration:     state.keep_closed_duration = c.int(value)
	}
}
