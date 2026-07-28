package smgui

import "core:c"
import rl "vendor:raylib"

SMGUI_LIB :: #config(SMGUI_LIB, "build.nosync/smgui/libbitspryte_smgui.a")

foreign import smgui_lib {
	SMGUI_LIB,
}

Settings_Snapshot :: struct {
	page, theme, close_window_key: c.int,
	save_format, export_image_format, export_animation_format: c.int,
	sprite_sheet_format, recent_items, show_full_path: c.int,
	auto_recovery, recovery_interval, keep_edited: c.int,
	keep_edited_duration, keep_closed, keep_closed_duration: c.int,
}

C_Event :: struct {kind, page, field, value: i32}

@(default_calling_convention="c")
foreign smgui_lib {
	bs_smgui_create         :: proc(width, height: c.int) -> rawptr ---
	bs_smgui_destroy        :: proc(handle: rawptr) ---
	bs_smgui_resize         :: proc(handle: rawptr, width, height: c.int) -> c.int ---
	bs_smgui_set_sprite_sheet_font :: proc(handle: rawptr, rgba: rawptr, width, height, scale: c.int) -> c.int ---
	bs_smgui_show           :: proc(handle: rawptr) ---
	bs_smgui_close          :: proc(handle: rawptr) ---
	bs_smgui_sync_settings  :: proc(handle: rawptr, settings: ^Settings_Snapshot) ---
	bs_smgui_set_mouse      :: proc(handle: rawptr, x, y: c.int) ---
	bs_smgui_mouse_button   :: proc(handle: rawptr, button, pressed: c.int) ---
	bs_smgui_mouse_wheel    :: proc(handle: rawptr, delta: f32) ---
	bs_smgui_key            :: proc(handle: rawptr, key: cstring, pressed, modifiers: c.int) ---
	bs_smgui_text           :: proc(handle: rawptr, codepoint: u32) ---
	bs_smgui_frame          :: proc(handle: rawptr) -> rawptr ---
	bs_smgui_poll_event     :: proc(handle: rawptr, event: ^C_Event) -> c.int ---
	bs_smgui_contains       :: proc(handle: rawptr, x, y: c.int) -> c.int ---
	bs_smgui_captures_keyboard :: proc(handle: rawptr) -> c.int ---
	bs_smgui_is_open        :: proc(handle: rawptr) -> c.int ---
}

Event_Kind :: enum i32 {
	None,
	Page_Selected,
	Theme_Selected,
	Accepted,
	Apply_Requested,
	Cancelled,
	Closed,
	Setting_Changed,
	Shortcut_Capture_Requested,
	Page_Action,
}

Event :: struct {
	kind:  Event_Kind,
	page:  i32,
	field: i32,
	value: i32,
}

#assert(size_of(Settings_Snapshot) == 15 * size_of(c.int))
#assert(size_of(C_Event) == 4 * size_of(i32))
#assert(i32(Event_Kind.Page_Selected) == 1)
#assert(i32(Event_Kind.Page_Action) == 9)

State :: struct {
	handle:  rawptr,
	texture: rl.Texture2D,
	width:   c.int,
	height:  c.int,
	visible: bool,
}

make_texture :: proc(width, height: c.int) -> rl.Texture2D {
	image := rl.GenImageColor(width, height, rl.BLANK)
	texture := rl.LoadTextureFromImage(image)
	rl.UnloadImage(image)
	return texture
}

init :: proc(width, height: c.int) -> State {
	state := State{
		handle = bs_smgui_create(width, height),
		width = width,
		height = height,
	}
	if state.handle != nil {
		state.texture = make_texture(width, height)
	}
	return state
}

load_sprite_sheet_font :: proc(state: ^State, path: cstring, scale: c.int = 2) -> bool {
	if state.handle == nil {
		return false
	}
	image := rl.LoadImage(path)
	if !rl.IsImageValid(image) {
		return false
	}
	defer rl.UnloadImage(image)
	colors := rl.LoadImageColors(image)
	if colors == nil {
		return false
	}
	defer rl.UnloadImageColors(colors)
	return bs_smgui_set_sprite_sheet_font(
		state.handle,
		cast(rawptr)colors,
		image.width,
		image.height,
		scale,
	) == 0
}

destroy :: proc(state: ^State) {
	if state.texture.id != 0 {
		rl.UnloadTexture(state.texture)
	}
	if state.handle != nil {
		bs_smgui_destroy(state.handle)
	}
	state^ = {}
}

open_settings :: proc(state: ^State, settings: Settings_Snapshot) {
	if state.handle == nil {
		return
	}
	snapshot := settings
	bs_smgui_sync_settings(state.handle, &snapshot)
	bs_smgui_show(state.handle)
	state.visible = true
}

sync_settings :: proc(state: ^State, settings: Settings_Snapshot) {
	if state.handle != nil {
		snapshot := settings
		bs_smgui_sync_settings(state.handle, &snapshot)
	}
}

close :: proc(state: ^State) -> bool {
	if !state.visible || state.handle == nil {
		return false
	}
	bs_smgui_close(state.handle)
	state.visible = false
	return true
}

captures_mouse :: proc(state: ^State, mouse: rl.Vector2) -> bool {
	return state.visible && state.handle != nil &&
		bs_smgui_contains(state.handle, c.int(mouse.x), c.int(mouse.y)) != 0
}

captures_keyboard :: proc(state: ^State) -> bool {
	return state.visible && state.handle != nil && bs_smgui_captures_keyboard(state.handle) != 0
}

poll_event :: proc(state: ^State) -> (Event, bool) {
	if state.handle == nil {
		return {}, false
	}
	for {
		event: C_Event
		if bs_smgui_poll_event(state.handle, &event) == 0 {
			return {}, false
		}
		if event.kind >= i32(Event_Kind.None) && event.kind <= i32(Event_Kind.Page_Action) {
			return Event{Event_Kind(event.kind), event.page, event.field, event.value}, true
		}
	}
}

send_special_key :: proc(state: ^State, key: rl.KeyboardKey, name: cstring) {
	if rl.IsKeyPressed(key) {
		bs_smgui_key(state.handle, name, 1, 0)
	}
}

forward_keyboard :: proc(state: ^State) {
	send_special_key(state, .ESCAPE, "\x1b")
	send_special_key(state, .BACKSPACE, "\b")
	send_special_key(state, .TAB, "\t")
	send_special_key(state, .ENTER, "\n")
	send_special_key(state, .DELETE, "Del")
	send_special_key(state, .LEFT, "Left")
	send_special_key(state, .RIGHT, "Right")
	send_special_key(state, .UP, "Up")
	send_special_key(state, .DOWN, "Down")
	send_special_key(state, .HOME, "Home")
	send_special_key(state, .END, "End")

	for {
		codepoint := rl.GetCharPressed()
		if codepoint == 0 {
			break
		}
		bs_smgui_text(state.handle, u32(codepoint))
	}
}

update :: proc(state: ^State, width, height: c.int, mouse: rl.Vector2) {
	if !state.visible || state.handle == nil {
		return
	}
	if width != state.width || height != state.height {
		if bs_smgui_resize(state.handle, width, height) == 0 {
			if state.texture.id != 0 {
				rl.UnloadTexture(state.texture)
			}
			state.texture = make_texture(width, height)
			state.width = width
			state.height = height
		}
	}

	bs_smgui_set_mouse(state.handle, c.int(mouse.x), c.int(mouse.y))
	buttons := [?]rl.MouseButton{.LEFT, .RIGHT, .MIDDLE}
	for button, index in buttons {
		if rl.IsMouseButtonPressed(button) {
			bs_smgui_mouse_button(state.handle, c.int(index), 1)
		}
		if rl.IsMouseButtonReleased(button) {
			bs_smgui_mouse_button(state.handle, c.int(index), 0)
		}
	}
	wheel := rl.GetMouseWheelMove()
	if wheel != 0 {
		bs_smgui_mouse_wheel(state.handle, wheel)
	}
	// Drain text only while an SMGUI text field owns keyboard input.
	if bs_smgui_captures_keyboard(state.handle) != 0 {
		forward_keyboard(state)
	}
	pixels := bs_smgui_frame(state.handle)
	if pixels != nil {
		rl.UpdateTexture(state.texture, pixels)
	}
	state.visible = bs_smgui_is_open(state.handle) != 0
}

draw :: proc(state: ^State) {
	if state.visible && state.handle != nil && state.texture.id != 0 {
		rl.DrawTexture(state.texture, 0, 0, rl.WHITE)
	}
}
