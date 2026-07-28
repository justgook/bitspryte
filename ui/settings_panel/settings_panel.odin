// PROTOTYPE: draggable settings shell and routed mock pages.
// Keep page actions as logging stubs until the settings model is designed.
package settings_panel

import "core:c"
import "core:fmt"
import themes "../../app/themes"
import alerts_layout "generated:settings_alerts"
import aseprite_format_layout "generated:settings_aseprite_format"
import background_layout "generated:settings_background"
import color_layout "generated:settings_color"
import cursors_layout "generated:settings_cursors"
import editor_layout "generated:settings_editor"
import experimental_layout "generated:settings_experimental"
import extensions_layout "generated:settings_extensions"
import files_layout "generated:settings_files"
import general_layout "generated:settings_general"
import grid_layout "generated:settings_grid"
import guides_layout "generated:settings_guides_and_slices"
import shortcuts_layout "generated:settings_keyboard_shortcuts"
import reset_layout "generated:settings_reset"
import selection_layout "generated:settings_selection"
import theme_layout "generated:settings_theme"
import timeline_layout "generated:settings_timeline"
import undo_layout "generated:settings_undo"
import settings_layout "generated:settings_window"
import rl "vendor:raylib/v55"

TITLE_BAR_HEIGHT :: f32(28)
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

State :: struct {
	visible:     bool,
	theme:                  c.int,
	theme_dropdown_editing: bool,
	bounds:                 rl.Rectangle,
	dragging:    bool,
	drag_offset: rl.Vector2,

	page:            c.int,
	category_scroll: c.int,
	search:          [128]u8,
	search_editing:  bool,
	shortcut_search: [128]u8,
	shortcut_search_editing: bool,
	shortcut_scroll: rl.Vector2,
	shortcut_view:          rl.Rectangle,
	selected_shortcut:      int,
	shortcut_capture_index: int,
	close_window_key:       rl.KeyboardKey,

	save_format:              c.int,
	export_image_format:      c.int,
	export_animation_format:  c.int,
	sprite_sheet_format:      c.int,
	recent_items:             f32,
	show_full_path:           bool,
	auto_recovery:            bool,
	recovery_interval:        c.int,
	keep_edited:              bool,
	keep_edited_duration:     c.int,
	keep_closed:              bool,
	keep_closed_duration:     c.int,
}

Result :: struct {
	theme_changed: bool,
}

init :: proc() -> State {
	return State{
		bounds = rl.Rectangle{
			(f32(rl.GetScreenWidth()) - settings_layout.REFERENCE_WIDTH) / 2,
			(f32(rl.GetScreenHeight()) - settings_layout.REFERENCE_HEIGHT) / 2,
			settings_layout.REFERENCE_WIDTH,
			settings_layout.REFERENCE_HEIGHT,
		},
		page = c.int(Page.Files),
		selected_shortcut = -1,
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
	log_open_preferences()
}

close_active :: proc(state: ^State) -> bool {
	if !state.visible {
		return false
	}
	state.visible = false
	state.dragging = false
	state.shortcut_capture_index = -1
	return true
}

captures_keyboard :: proc(state: ^State) -> bool {
	return state.visible && state.shortcut_capture_index >= 0
}

captures_mouse :: proc(state: ^State, mouse: rl.Vector2) -> bool {
	return state.visible && (state.dragging || rl.CheckCollisionPointRec(mouse, state.bounds))
}

at :: proc(state: ^State, local: rl.Rectangle) -> rl.Rectangle {
	return rl.Rectangle{
		state.bounds.x + local.x,
		state.bounds.y + local.y,
		local.width,
		local.height,
	}
}

page_at :: proc(state: ^State, local: rl.Rectangle) -> rl.Rectangle {
	return rl.Rectangle{
		state.bounds.x + settings_layout.contentPanel.x + local.x,
		state.bounds.y + settings_layout.contentPanel.y + local.y,
		local.width,
		local.height,
	}
}

keep_on_screen :: proc(state: ^State) {
	max_x := max(f32(0), f32(rl.GetScreenWidth()) - state.bounds.width)
	max_y := max(f32(0), f32(rl.GetScreenHeight()) - TITLE_BAR_HEIGHT)
	state.bounds.x = clamp(state.bounds.x, 0, max_x)
	state.bounds.y = clamp(state.bounds.y, 0, max_y)
}

update_dragging :: proc(state: ^State) {
	mouse := rl.GetMousePosition()
	title_bar := rl.Rectangle{state.bounds.x, state.bounds.y, state.bounds.width - 28, TITLE_BAR_HEIGHT}

	if !state.dragging && rl.IsMouseButtonPressed(.LEFT) && rl.CheckCollisionPointRec(mouse, title_bar) {
		state.dragging = true
		state.drag_offset = rl.Vector2{mouse.x - state.bounds.x, mouse.y - state.bounds.y}
	}
	if state.dragging {
		if rl.IsMouseButtonReleased(.LEFT) {
			state.dragging = false
		} else {
			state.bounds.x = mouse.x - state.drag_offset.x
			state.bounds.y = mouse.y - state.drag_offset.y
			max_x := f32(rl.GetScreenWidth()) - state.bounds.width
			max_y := f32(rl.GetScreenHeight()) - TITLE_BAR_HEIGHT
			state.bounds.x = clamp(state.bounds.x, 0, max_x)
			state.bounds.y = clamp(state.bounds.y, 0, max_y)
		}
	}
}

draw :: proc(state: ^State) -> Result {
	result: Result
	if !state.visible {
		return result
	}

	keep_on_screen(state)
	update_dragging(state)
	if rl.GuiWindowBox(state.bounds, settings_layout.window_TEXT) != 0 {
		state.visible = false
		state.dragging = false
		log_cancel_settings()
		return result
	}

	if rl.GuiTextBox(at(state, settings_layout.search), cstring(&state.search[0]), len(state.search), state.search_editing) {
		state.search_editing = !state.search_editing
		log_search_changed()
	}

	previous_page := state.page
	rl.GuiListView(
		at(state, settings_layout.categories),
		settings_layout.categories_TEXT,
		&state.category_scroll,
		&state.page,
	)
	if state.page != previous_page {
		log_page_opened(Page(state.page))
	}

	rl.GuiPanel(at(state, settings_layout.contentPanel), settings_layout.contentPanel_TEXT)
	switch Page(state.page) {
	case .General:            draw_general_page(state)
	case .Files:              draw_files_page(state)
	case .Keyboard_Shortcuts: draw_keyboard_shortcuts_page(state)
	case .Color:              draw_color_page(state)
	case .Alerts:             draw_alerts_page(state)
	case .Editor:             draw_editor_page(state)
	case .Selection:          draw_selection_page(state)
	case .Timeline:           draw_timeline_page(state)
	case .Cursors:            draw_cursors_page(state)
	case .Background:         draw_background_page(state)
	case .Grid:               draw_grid_page(state)
	case .Guides_And_Slices:  draw_guides_and_slices_page(state)
	case .Undo:               draw_undo_page(state)
	case .Theme:              result.theme_changed = draw_theme_page(state)
	case .Extensions:         draw_extensions_page(state)
	case .Aseprite_Format:    draw_aseprite_format_page(state)
	case .Experimental:       draw_experimental_page(state)
	case .Reset:              draw_reset_page(state)
	}

	rl.GuiLine(at(state, settings_layout.footerLine), settings_layout.footerLine_TEXT)
	if rl.GuiButton(at(state, settings_layout.okButton), settings_layout.okButton_TEXT) {
		log_ok_settings()
		state.visible = false
	}
	if rl.GuiButton(at(state, settings_layout.applyButton), settings_layout.applyButton_TEXT) {
		log_apply_settings()
	}
	if rl.GuiButton(at(state, settings_layout.cancelButton), settings_layout.cancelButton_TEXT) {
		log_cancel_settings()
		state.visible = false
	}

	return result
}

// Files is the detailed visual mock from the reference. Every mutation is
// routed to a logging-only callback for now.
draw_files_page :: proc(state: ^State) {
	rl.GuiLabel(page_at(state, files_layout.pageTitle), files_layout.pageTitle_TEXT)
	rl.GuiLine(page_at(state, files_layout.sectionLine), files_layout.sectionLine_TEXT)
	rl.GuiLabel(page_at(state, files_layout.defaultExtensionHeading), files_layout.defaultExtensionHeading_TEXT)

	combo(state, files_layout.saveLabel, files_layout.saveLabel_TEXT, files_layout.saveFormat, files_layout.saveFormat_TEXT, &state.save_format, log_save_format_changed)
	combo(state, files_layout.exportImageLabel, files_layout.exportImageLabel_TEXT, files_layout.exportImageFormat, files_layout.exportImageFormat_TEXT, &state.export_image_format, log_export_image_format_changed)
	combo(state, files_layout.exportAnimationLabel, files_layout.exportAnimationLabel_TEXT, files_layout.exportAnimationFormat, files_layout.exportAnimationFormat_TEXT, &state.export_animation_format, log_export_animation_format_changed)
	combo(state, files_layout.spriteSheetLabel, files_layout.spriteSheetLabel_TEXT, files_layout.spriteSheetFormat, files_layout.spriteSheetFormat_TEXT, &state.sprite_sheet_format, log_sprite_sheet_format_changed)

	rl.GuiLabel(page_at(state, files_layout.recentItemsLabel), files_layout.recentItemsLabel_TEXT)
	previous_recent := state.recent_items
	rl.GuiSliderBar(page_at(state, files_layout.recentItems), nil, nil, &state.recent_items, 0, 32)
	if state.recent_items != previous_recent { log_recent_items_changed() }
	if rl.GuiButton(page_at(state, files_layout.clearRecentButton), files_layout.clearRecentButton_TEXT) {
		state.recent_items = 0
		log_clear_recent_items()
	}

	checkbox(state, files_layout.fullPath, files_layout.fullPathLabel, files_layout.fullPathLabel_TEXT, &state.show_full_path, log_full_path_changed)
	rl.GuiLabel(page_at(state, files_layout.recoveryHeading), files_layout.recoveryHeading_TEXT)
	rl.GuiLine(page_at(state, files_layout.recoveryLine), files_layout.recoveryLine_TEXT)
	checkbox(state, files_layout.autoRecovery, files_layout.autoRecoveryLabel, files_layout.autoRecoveryLabel_TEXT, &state.auto_recovery, log_auto_recovery_changed)
	combo_only(state, files_layout.recoveryInterval, files_layout.recoveryInterval_TEXT, &state.recovery_interval, log_recovery_interval_changed)
	checkbox(state, files_layout.keepEdited, files_layout.keepEditedLabel, files_layout.keepEditedLabel_TEXT, &state.keep_edited, log_keep_edited_changed)
	combo_only(state, files_layout.keepEditedDuration, files_layout.keepEditedDuration_TEXT, &state.keep_edited_duration, log_keep_edited_duration_changed)
	checkbox(state, files_layout.keepClosed, files_layout.keepClosedLabel, files_layout.keepClosedLabel_TEXT, &state.keep_closed, log_keep_closed_changed)
	combo_only(state, files_layout.keepClosedDuration, files_layout.keepClosedDuration_TEXT, &state.keep_closed_duration, log_keep_closed_duration_changed)
}

combo :: proc(state: ^State, label: rl.Rectangle, label_text: cstring, control: rl.Rectangle, control_text: cstring, value: ^c.int, action: proc()) {
	rl.GuiLabel(page_at(state, label), label_text)
	combo_only(state, control, control_text, value, action)
}

combo_only :: proc(state: ^State, control: rl.Rectangle, text: cstring, value: ^c.int, action: proc()) {
	previous := value^
	rl.GuiComboBox(page_at(state, control), text, value)
	if value^ != previous { action() }
}

checkbox :: proc(state: ^State, control, label: rl.Rectangle, label_text: cstring, value: ^bool, action: proc()) {
	previous := value^
	rl.GuiCheckBox(page_at(state, control), nil, value)
	rl.GuiLabel(page_at(state, label), label_text)
	if value^ != previous { action() }
}

draw_stub_page :: proc(state: ^State, title: rl.Rectangle, title_text: cstring, description: rl.Rectangle, description_text: cstring, button: rl.Rectangle, button_text: cstring, action: proc()) {
	rl.GuiLabel(page_at(state, title), title_text)
	rl.GuiLabel(page_at(state, description), description_text)
	if rl.GuiButton(page_at(state, button), button_text) {
		action()
	}
}

Shortcut_Row :: struct {
	action: cstring,
	key:    cstring,
	scope:  cstring,
}

SHORTCUT_ROWS := [?]Shortcut_Row{
	{"About", "", "Global"},
	{"Add Background Color to Palette", "", "Editor"},
	{"Add Foreground Color to Palette", "", "Editor"},
	{"Adjust Brightness/Contrast", "", "Editor"},
	{"Adjust Hue/Saturation", "Cmd+U", "Editor"},
	{"Apply", "Enter", "Transformation"},
	{"Close Active Window", "Esc", "Global"},
	{"Canvas Size", "C", "Sprite"},
	{"Change Brush: Custom Brush #1", "Alt+1", "Editor"},
	{"Change Brush: Custom Brush #2", "Alt+2", "Editor"},
	{"Change Brush: Custom Brush #3", "Alt+3", "Editor"},
	{"Change Brush: Custom Brush #4", "Alt+4", "Editor"},
	{"Change Brush: Flip Horizontally", "Space+H", "Editor"},
	{"Change Brush: Flip Vertically", "Space+V", "Editor"},
	{"Change Brush: Increment Size", "+", "Editor"},
	{"Change Brush: Decrement Size", "-", "Editor"},
	{"Clear Canvas", "", "Sprite"},
	{"Export PNG", "Cmd+E", "Global"},
	{"Open Settings", "Cmd+,", "Global"},
	{"Pencil Tool", "B", "Editor"},
}

draw_keyboard_shortcuts_page :: proc(state: ^State) {
	if rl.GuiTextBox(page_at(state, shortcuts_layout.shortcutSearch), cstring(&state.shortcut_search[0]), len(state.shortcut_search), state.shortcut_search_editing) {
		state.shortcut_search_editing = !state.shortcut_search_editing
		log_shortcut_search_changed()
	}

	rl.GuiLabel(page_at(state, shortcuts_layout.shortcutActionHeader), shortcuts_layout.shortcutActionHeader_TEXT)
	rl.GuiLabel(page_at(state, shortcuts_layout.shortcutKeyHeader), shortcuts_layout.shortcutKeyHeader_TEXT)
	rl.GuiLabel(page_at(state, shortcuts_layout.shortcutContextHeader), shortcuts_layout.shortcutContextHeader_TEXT)

	viewport := page_at(state, shortcuts_layout.shortcutViewport)
	content := rl.Rectangle{0, 0, viewport.width - 18, f32(len(SHORTCUT_ROWS)) * 34 + 8}
	rl.GuiScrollPanel(viewport, nil, content, &state.shortcut_scroll, &state.shortcut_view)

	rl.BeginScissorMode(
		c.int(state.shortcut_view.x),
		c.int(state.shortcut_view.y),
		c.int(state.shortcut_view.width),
		c.int(state.shortcut_view.height),
	)
	for row, index in SHORTCUT_ROWS {
		y := viewport.y + state.shortcut_scroll.y + 6 + f32(index) * 34
		row_bounds := rl.Rectangle{viewport.x + 4, y, viewport.width - 26, 32}
		if index == state.selected_shortcut {
			rl.DrawRectangleRec(row_bounds, rl.Color{82, 92, 112, 90})
		} else if index % 2 == 1 {
			rl.DrawRectangleRec(row_bounds, rl.Color{255, 255, 255, 10})
		}

		rl.GuiLabel(rl.Rectangle{row_bounds.x + 8, y + 2, 330, 28}, row.action)
		key_text := row.key
		if index == CLOSE_WINDOW_SHORTCUT_ROW {
			key_text = key_name(state.close_window_key)
		}
		if state.shortcut_capture_index == index {
			key_text = "Press a key..."
		}
		if rl.GuiButton(rl.Rectangle{row_bounds.x + 346, y + 3, 126, 26}, key_text) {
			state.selected_shortcut = index
			state.shortcut_capture_index = index
			log_shortcut_edit_requested()
		}
		rl.GuiLabel(rl.Rectangle{row_bounds.x + 486, y + 2, 112, 28}, row.scope)
	}
	rl.EndScissorMode()

	if state.shortcut_capture_index >= 0 {
		key := rl.GetKeyPressed()
		if key != .KEY_NULL {
			if state.shortcut_capture_index == CLOSE_WINDOW_SHORTCUT_ROW {
				state.close_window_key = key
				log_close_window_shortcut_changed()
			} else {
				log_shortcut_capture_not_implemented()
			}
			state.shortcut_capture_index = -1
		}
	}

	if rl.GuiButton(page_at(state, shortcuts_layout.shortcutImport), shortcuts_layout.shortcutImport_TEXT) { log_shortcut_import() }
	if rl.GuiButton(page_at(state, shortcuts_layout.shortcutExport), shortcuts_layout.shortcutExport_TEXT) { log_shortcut_export() }
	if rl.GuiButton(page_at(state, shortcuts_layout.shortcutReset), shortcuts_layout.shortcutReset_TEXT) { log_shortcut_reset() }
	rl.GuiLabel(page_at(state, shortcuts_layout.shortcutHint), shortcuts_layout.shortcutHint_TEXT)
}

key_name :: proc(key: rl.KeyboardKey) -> cstring {
	#partial switch key {
	case .ESCAPE: return "Esc"
	case .ENTER: return "Enter"
	case .TAB: return "Tab"
	case .BACKSPACE: return "Backspace"
	case .SPACE: return "Space"
	case .DELETE: return "Delete"
	case .A: return "A"
	case .B: return "B"
	case .C: return "C"
	case .D: return "D"
	case .E: return "E"
	case .F: return "F"
	case .G: return "G"
	case .H: return "H"
	case .I: return "I"
	case .J: return "J"
	case .K: return "K"
	case .L: return "L"
	case .M: return "M"
	case .N: return "N"
	case .O: return "O"
	case .P: return "P"
	case .Q: return "Q"
	case .R: return "R"
	case .S: return "S"
	case .T: return "T"
	case .U: return "U"
	case .V: return "V"
	case .W: return "W"
	case .X: return "X"
	case .Y: return "Y"
	case .Z: return "Z"
	case .ZERO: return "0"
	case .ONE: return "1"
	case .TWO: return "2"
	case .THREE: return "3"
	case .FOUR: return "4"
	case .FIVE: return "5"
	case .SIX: return "6"
	case .SEVEN: return "7"
	case .EIGHT: return "8"
	case .NINE: return "9"
	case .LEFT: return "Left"
	case .RIGHT: return "Right"
	case .UP: return "Up"
	case .DOWN: return "Down"
	case .F1: return "F1"
	case .F2: return "F2"
	case .F3: return "F3"
	case .F4: return "F4"
	case .F5: return "F5"
	case .F6: return "F6"
	case .F7: return "F7"
	case .F8: return "F8"
	case .F9: return "F9"
	case .F10: return "F10"
	case .F11: return "F11"
	case .F12: return "F12"
	}
	return "Custom Key"
}

draw_general_page :: proc(s: ^State) { draw_stub_page(s, general_layout.title, general_layout.title_TEXT, general_layout.description, general_layout.description_TEXT, general_layout.action, general_layout.action_TEXT, log_general_action) }
draw_color_page :: proc(s: ^State) { draw_stub_page(s, color_layout.title, color_layout.title_TEXT, color_layout.description, color_layout.description_TEXT, color_layout.action, color_layout.action_TEXT, log_color_action) }
draw_alerts_page :: proc(s: ^State) { draw_stub_page(s, alerts_layout.title, alerts_layout.title_TEXT, alerts_layout.description, alerts_layout.description_TEXT, alerts_layout.action, alerts_layout.action_TEXT, log_alerts_action) }
draw_editor_page :: proc(s: ^State) { draw_stub_page(s, editor_layout.title, editor_layout.title_TEXT, editor_layout.description, editor_layout.description_TEXT, editor_layout.action, editor_layout.action_TEXT, log_editor_action) }
draw_selection_page :: proc(s: ^State) { draw_stub_page(s, selection_layout.title, selection_layout.title_TEXT, selection_layout.description, selection_layout.description_TEXT, selection_layout.action, selection_layout.action_TEXT, log_selection_action) }
draw_timeline_page :: proc(s: ^State) { draw_stub_page(s, timeline_layout.title, timeline_layout.title_TEXT, timeline_layout.description, timeline_layout.description_TEXT, timeline_layout.action, timeline_layout.action_TEXT, log_timeline_action) }
draw_cursors_page :: proc(s: ^State) { draw_stub_page(s, cursors_layout.title, cursors_layout.title_TEXT, cursors_layout.description, cursors_layout.description_TEXT, cursors_layout.action, cursors_layout.action_TEXT, log_cursors_action) }
draw_background_page :: proc(s: ^State) { draw_stub_page(s, background_layout.title, background_layout.title_TEXT, background_layout.description, background_layout.description_TEXT, background_layout.action, background_layout.action_TEXT, log_background_action) }
draw_grid_page :: proc(s: ^State) { draw_stub_page(s, grid_layout.title, grid_layout.title_TEXT, grid_layout.description, grid_layout.description_TEXT, grid_layout.action, grid_layout.action_TEXT, log_grid_action) }
draw_guides_and_slices_page :: proc(s: ^State) { draw_stub_page(s, guides_layout.title, guides_layout.title_TEXT, guides_layout.description, guides_layout.description_TEXT, guides_layout.action, guides_layout.action_TEXT, log_guides_action) }
draw_undo_page :: proc(s: ^State) { draw_stub_page(s, undo_layout.title, undo_layout.title_TEXT, undo_layout.description, undo_layout.description_TEXT, undo_layout.action, undo_layout.action_TEXT, log_undo_action) }
draw_extensions_page :: proc(s: ^State) { draw_stub_page(s, extensions_layout.title, extensions_layout.title_TEXT, extensions_layout.description, extensions_layout.description_TEXT, extensions_layout.action, extensions_layout.action_TEXT, log_extensions_action) }
draw_aseprite_format_page :: proc(s: ^State) { draw_stub_page(s, aseprite_format_layout.title, aseprite_format_layout.title_TEXT, aseprite_format_layout.description, aseprite_format_layout.description_TEXT, aseprite_format_layout.action, aseprite_format_layout.action_TEXT, log_aseprite_format_action) }
draw_experimental_page :: proc(s: ^State) { draw_stub_page(s, experimental_layout.title, experimental_layout.title_TEXT, experimental_layout.description, experimental_layout.description_TEXT, experimental_layout.action, experimental_layout.action_TEXT, log_experimental_action) }
draw_reset_page :: proc(s: ^State) { draw_stub_page(s, reset_layout.title, reset_layout.title_TEXT, reset_layout.description, reset_layout.description_TEXT, reset_layout.action, reset_layout.action_TEXT, log_reset_action) }

draw_theme_page :: proc(state: ^State) -> bool {
	rl.GuiGroupBox(page_at(state, theme_layout.themeGroup), theme_layout.themeGroup_TEXT)
	rl.GuiLabel(page_at(state, theme_layout.themeLabel), theme_layout.themeLabel_TEXT)
	previous := state.theme
	if rl.GuiDropdownBox(
		page_at(state, theme_layout.themeSelector),
		themes.SELECTOR_TEXT,
		&state.theme,
		state.theme_dropdown_editing,
	) {
		state.theme_dropdown_editing = !state.theme_dropdown_editing
	}
	if state.theme != previous { log_theme_changed() }
	return state.theme != previous
}

log_page_opened :: proc(page: Page) { fmt.println("[settings] opened page:", page) }
log_open_preferences :: proc() { fmt.println("[settings] preferences opened") }
log_search_changed :: proc() { fmt.println("[settings] search editing toggled") }
log_ok_settings :: proc() { fmt.println("[settings] OK requested") }
log_apply_settings :: proc() { fmt.println("[settings] Apply requested") }
log_cancel_settings :: proc() { fmt.println("[settings] Cancel requested") }
log_save_format_changed :: proc() { fmt.println("[settings/files] save format changed") }
log_export_image_format_changed :: proc() { fmt.println("[settings/files] image export format changed") }
log_export_animation_format_changed :: proc() { fmt.println("[settings/files] animation export format changed") }
log_sprite_sheet_format_changed :: proc() { fmt.println("[settings/files] sprite-sheet format changed") }
log_recent_items_changed :: proc() { fmt.println("[settings/files] recent items changed") }
log_clear_recent_items :: proc() { fmt.println("[settings/files] clear recent items requested") }
log_full_path_changed :: proc() { fmt.println("[settings/files] full-path visibility changed") }
log_auto_recovery_changed :: proc() { fmt.println("[settings/files] auto recovery changed") }
log_recovery_interval_changed :: proc() { fmt.println("[settings/files] recovery interval changed") }
log_keep_edited_changed :: proc() { fmt.println("[settings/files] edited-data retention changed") }
log_keep_edited_duration_changed :: proc() { fmt.println("[settings/files] edited-data duration changed") }
log_keep_closed_changed :: proc() { fmt.println("[settings/files] closed-sprite retention changed") }
log_keep_closed_duration_changed :: proc() { fmt.println("[settings/files] closed-sprite duration changed") }
log_theme_changed :: proc() { fmt.println("[settings/theme] application theme changed") }
log_shortcut_search_changed :: proc() { fmt.println("[settings/shortcuts] search editing toggled") }
log_shortcut_edit_requested :: proc() { fmt.println("[settings/shortcuts] key editing requested") }
log_close_window_shortcut_changed :: proc() { fmt.println("[settings/shortcuts] close-window key changed") }
log_shortcut_capture_not_implemented :: proc() { fmt.println("[settings/shortcuts] capture is not implemented for this mock row") }
log_shortcut_import :: proc() { fmt.println("[settings/shortcuts] import requested") }
log_shortcut_export :: proc() { fmt.println("[settings/shortcuts] export requested") }
log_shortcut_reset :: proc() { fmt.println("[settings/shortcuts] reset requested") }
log_general_action :: proc() { fmt.println("[settings/general] mock action") }
log_color_action :: proc() { fmt.println("[settings/color] mock action") }
log_alerts_action :: proc() { fmt.println("[settings/alerts] mock action") }
log_editor_action :: proc() { fmt.println("[settings/editor] mock action") }
log_selection_action :: proc() { fmt.println("[settings/selection] mock action") }
log_timeline_action :: proc() { fmt.println("[settings/timeline] mock action") }
log_cursors_action :: proc() { fmt.println("[settings/cursors] mock action") }
log_background_action :: proc() { fmt.println("[settings/background] mock action") }
log_grid_action :: proc() { fmt.println("[settings/grid] mock action") }
log_guides_action :: proc() { fmt.println("[settings/guides] mock action") }
log_undo_action :: proc() { fmt.println("[settings/undo] mock action") }
log_extensions_action :: proc() { fmt.println("[settings/extensions] mock action") }
log_aseprite_format_action :: proc() { fmt.println("[settings/aseprite-format] mock action") }
log_experimental_action :: proc() { fmt.println("[settings/experimental] mock action") }
log_reset_action :: proc() { fmt.println("[settings/reset] mock action") }
