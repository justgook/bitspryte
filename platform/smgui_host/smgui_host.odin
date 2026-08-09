package smgui_host

// SMGUI adapter for BitSpryte's existing Sokol application loop. This module
// translates input and presents the SMGUI software framebuffer, but deliberately
// does not own sapp.run, sg.setup, render passes, or sg.commit.

import cpu_framebuffer "../../render/cpu_framebuffer"
import sapp "../../sokol/app"
import sg "../../sokol/gfx"
import smgui "../../vendor/smgui/smgui"
import "core:mem"
import "core:unicode/utf8"

State :: struct {
	ctx:                ^smgui.Context,
	presentation:       cpu_framebuffer.Framebuffer,
	presented_revision: u64,
	buttons:            smgui.Input_Buttons,
	pending_mouse_move: smgui.Event,
	has_mouse_move:     bool,
	initialized:        bool,
}

create :: proc(state: ^State) -> smgui.Backend {
	return {
		data = state,
		init = backend_init,
		deinit = backend_deinit,
		poll = backend_poll,
		redraw = backend_redraw,
		fullscreen = backend_fullscreen,
		set_title = backend_set_title,
		native_window = backend_native_window,
	}
}

prepare :: proc(state: ^State) {
	assert(state != nil && state.initialized)
	cpu_framebuffer.upload_if_dirty(&state.presentation)
}

texture :: proc(state: ^State) -> (sg.View, sg.Sampler) {
	assert(state != nil && state.initialized)
	return cpu_framebuffer.texture(&state.presentation)
}

push_sokol_event :: proc(state: ^State, source: ^sapp.Event) -> smgui.Error {
	if state == nil || source == nil || state.ctx == nil {
		return .Invalid_Input
	}

	state.ctx.mouse_x = int(source.mouse_x)
	state.ctx.mouse_y = int(source.mouse_y)
	state.buttons = buttons_from_modifiers(source.modifiers)
	event: smgui.Event
	#partial switch source.type {
	case .MOUSE_DOWN, .MOUSE_UP:
		button, ok := mouse_button(source.mouse_button)
		if !ok {return .None}
		if source.type == .MOUSE_DOWN {
			state.buttons += {button}
		} else {
			state.buttons -= {button}
		}
		event = {
			kind    = .Mouse,
			buttons = state.buttons,
			x       = state.ctx.mouse_x,
			y       = state.ctx.mouse_y,
		}
		if source.type == .MOUSE_UP {event.buttons += {.Released}}
	case .MOUSE_MOVE:
		state.pending_mouse_move = {
			kind    = .Mouse,
			buttons = state.buttons,
			x       = state.ctx.mouse_x,
			y       = state.ctx.mouse_y,
		}
		state.has_mouse_move = true
		return .None
	case .MOUSE_SCROLL:
		event = {
			kind    = .Mouse,
			buttons = state.buttons,
			x       = state.ctx.mouse_x,
			y       = state.ctx.mouse_y,
		}
		if source.scroll_y > 0 {event.buttons += {.Direction_Up}}
		if source.scroll_y < 0 {event.buttons += {.Direction_Down}}
	case .KEY_DOWN:
		text := special_key_text(source.key_code)
		if len(text) == 0 {return .None}
		event = {
			kind    = .Key,
			buttons = state.buttons,
			key     = smgui.key_input(text),
		}
	case .CHAR:
		if source.char_code < 32 {return .None}
		bytes, length := utf8.encode_rune(rune(source.char_code))
		event = {
			kind    = .Key,
			buttons = state.buttons,
			key     = smgui.key_input(string(bytes[:length])),
		}
	case:
		return .None
	}
	return smgui.push_event(state.ctx, event)
}

resize :: proc(state: ^State, width, height: int) -> smgui.Error {
	if state == nil || state.ctx == nil || width < 1 || height < 1 {
		return .Invalid_Input
	}
	if width == state.ctx.screen.width && height == state.ctx.screen.height {
		return .None
	}
	if error := smgui.resize_framebuffer(state.ctx, width, height); error != .None {
		return error
	}
	cpu_framebuffer.deinit(&state.presentation)
	if !cpu_framebuffer.init(&state.presentation, width, height) {
		return .Backend_Failure
	}
	state.presented_revision = ~u64(0)
	return smgui.push_event(state.ctx, {kind = .Resize, x = width, y = height})
}

backend_init :: proc(
	data: rawptr,
	ctx: ^smgui.Context,
	title: string,
	width, height: int,
	icon: ^smgui.Image,
) -> smgui.Error {
	_ = title
	_ = icon
	if data == nil || ctx == nil || width < 1 || height < 1 {
		return .Invalid_Input
	}
	state := (^State)(data)
	state.ctx = ctx
	if !cpu_framebuffer.init(&state.presentation, width, height) {
		state.ctx = nil
		return .Backend_Failure
	}
	state.presented_revision = ~u64(0)
	state.initialized = true
	return .None
}

backend_deinit :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	state := (^State)(data)
	cpu_framebuffer.deinit(&state.presentation)
	state^ = {}
	return .None
}

backend_poll :: proc(data: rawptr) -> (bool, smgui.Error) {
	if data == nil {return false, .Invalid_Input}
	state := (^State)(data)
	if state.has_mouse_move {
		if error := smgui.push_event(state.ctx, state.pending_mouse_move); error != .None {
			return false, error
		}
		state.has_mouse_move = false
	}
	return false, .None
}

backend_redraw :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	state := (^State)(data)
	if !state.initialized || state.ctx == nil {return .Backend_Failure}
	if state.presented_revision == state.ctx.screen_revision {return .None}

	destination := cpu_framebuffer.pixels_mut(&state.presentation)
	source := state.ctx.screen.pixels
	if len(source) != len(destination) * size_of(cpu_framebuffer.Pixel) {
		return .Backend_Failure
	}
	mem.copy(raw_data(destination), raw_data(source), len(source))
	state.presented_revision = state.ctx.screen_revision
	return .None
}

backend_fullscreen :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	sapp.toggle_fullscreen()
	return .None
}

backend_set_title :: proc(data: rawptr, title: string) -> smgui.Error {
	if data == nil || len(title) == 0 {return .Invalid_Input}
	// BitSpryte owns the stable C string in sapp.Desc; runtime title changes are
	// currently outside this host adapter's interface.
	return .None
}

backend_native_window :: proc(data: rawptr) -> rawptr {
	if data == nil {return nil}
	when ODIN_OS == .Darwin {return sapp.macos_get_window()} else when ODIN_OS == .Windows {return sapp.win32_get_hwnd()} else when ODIN_OS == .Linux {return sapp.x11_get_window()} else {return nil}
}

buttons_from_modifiers :: proc(modifiers: u32) -> smgui.Input_Buttons {
	buttons: smgui.Input_Buttons
	if modifiers & sapp.MODIFIER_SHIFT != 0 {buttons += {.Shift}}
	if modifiers & sapp.MODIFIER_CTRL != 0 {buttons += {.Control}}
	if modifiers & sapp.MODIFIER_ALT != 0 {buttons += {.Alt}}
	if modifiers & sapp.MODIFIER_SUPER != 0 {buttons += {.Gui}}
	if modifiers & sapp.MODIFIER_LMB != 0 {buttons += {.Mouse_Left}}
	if modifiers & sapp.MODIFIER_MMB != 0 {buttons += {.Mouse_Middle}}
	if modifiers & sapp.MODIFIER_RMB != 0 {buttons += {.Mouse_Right}}
	return buttons
}

mouse_button :: proc(button: sapp.Mousebutton) -> (smgui.Input_Button, bool) {
	#partial switch button {
	case .LEFT:
		return .Mouse_Left, true
	case .MIDDLE:
		return .Mouse_Middle, true
	case .RIGHT:
		return .Mouse_Right, true
	case:
		return {}, false
	}
}

special_key_text :: proc(key: sapp.Keycode) -> string {
	#partial switch key {
	case .ESCAPE:
		return "Escape"
	case .ENTER, .KP_ENTER:
		return "Enter"
	case .TAB:
		return "Tab"
	case .BACKSPACE:
		return "Backspace"
	case .DELETE:
		return "Delete"
	case .LEFT:
		return "Left"
	case .RIGHT:
		return "Right"
	case .UP:
		return "Up"
	case .DOWN:
		return "Down"
	case .HOME:
		return "Home"
	case .END:
		return "End"
	case .PAGE_UP:
		return "PgUp"
	case .PAGE_DOWN:
		return "PgDown"
	case .INSERT:
		return "Insert"
	}
	return ""
}
