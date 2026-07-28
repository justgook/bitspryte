package main

import "core:c"
import "core:fmt"
import actions "./app/actions"
import events "./app/events"
import themes "./app/themes"
import layout "generated:layout"
import native "./platform/native_menu"
import rl "vendor:raylib"
import settings_panel "./ui/settings_panel"
import smgui "./ui/smgui"

CANVAS_SIZE :: 32
WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 800

Tool :: enum c.int {
	Selection,
	Pencil,
	Eraser,
	Eyedropper,
	Zoom,
	Move,
	Fill,
	Line,
	Rectangle,
	Ellipse,
	Brush,
	Text,
}

resource_path :: proc(relative_path: cstring) -> cstring {
	application_dir := rl.GetApplicationDirectory()
	bundle_resources := rl.TextFormat("%s/../Resources/resources", application_dir)
	if rl.DirectoryExists(bundle_resources) {
		return rl.TextFormat("%s/%s", bundle_resources, relative_path)
	}
	return rl.TextFormat("%s/resources/%s", application_dir, relative_path)
}

translated :: proc(rect: rl.Rectangle, x, y: f32) -> rl.Rectangle {
	return rl.Rectangle{rect.x + x, rect.y + y, rect.width, rect.height}
}

draw_tool_toggle :: proc(bounds: rl.Rectangle, text: cstring, kind: Tool, selected: ^c.int, status: ^cstring) {
	active := selected^ == c.int(kind)
	rl.GuiToggle(bounds, text, &active)
	if active && selected^ != c.int(kind) {
		selected^ = c.int(kind)
		status^ = "Tool selected"
	}
}

load_style :: proc(style: c.int) {
	if !themes.is_valid(i32(style)) {
		return
	}
	theme := themes.Kind(style)
	if theme == .Default {
		rl.GuiLoadStyleDefault()
		return
	}
	rl.GuiLoadStyle(resource_path(themes.file_name(theme)))
}

settings_snapshot :: proc(settings: ^settings_panel.State) -> smgui.Settings_Snapshot {
	return smgui.Settings_Snapshot{
		page = settings.page,
		theme = settings.theme,
		close_window_key = c.int(settings.close_window_key),
		save_format = settings.save_format,
		export_image_format = settings.export_image_format,
		export_animation_format = settings.export_animation_format,
		sprite_sheet_format = settings.sprite_sheet_format,
		recent_items = settings.recent_items,
		show_full_path = c.int(1) if settings.show_full_path else 0,
		auto_recovery = c.int(1) if settings.auto_recovery else 0,
		recovery_interval = settings.recovery_interval,
		keep_edited = c.int(1) if settings.keep_edited else 0,
		keep_edited_duration = settings.keep_edited_duration,
		keep_closed = c.int(1) if settings.keep_closed else 0,
		keep_closed_duration = settings.keep_closed_duration,
	}
}

dispatch_actions :: proc(
	bus: ^actions.Bus,
	event_bus: ^events.Bus,
	image: ^rl.Image,
	texture: rl.Texture2D,
	settings: ^settings_panel.State,
	smgui_layer: ^smgui.State,
	status: ^cstring,
) {
	for action in actions.items(bus) {
		switch action.kind {
		case .Open_Settings:
			settings_panel.open(settings)
			smgui.open_settings(smgui_layer, settings_snapshot(settings))
			events.publish(event_bus, events.make(.Settings_Opened, action.source))

		case .Close_Active_Window:
			closed := smgui.close(smgui_layer)
			if settings_panel.close_active(settings) {
				closed = true
			}
			if closed {
				events.publish(event_bus, events.make(.Active_Window_Closed, action.source))
			}

		case .Export_PNG:
			if rl.ExportImage(image^, "bitspryte.png") {
				status^ = "Exported bitspryte.png"
				events.publish(event_bus, events.make(.PNG_Exported, action.source))
			} else {
				status^ = "PNG export failed"
				events.publish(event_bus, events.make(.PNG_Export_Failed, action.source))
			}

		case .Clear_Canvas:
			rl.ImageClearBackground(image, rl.BLANK)
			rl.UpdateTexture(texture, image.data)
			status^ = "Canvas cleared"
			events.publish(event_bus, events.make(.Canvas_Cleared, action.source))

		case .Set_Theme:
			settings.theme = c.int(action.int_value)
			load_style(settings.theme)
			smgui.sync_settings(smgui_layer, settings_snapshot(settings))
			status^ = "Application theme changed"
			event := events.make(.Theme_Changed, action.source)
			event.int_value = action.int_value
			events.publish(event_bus, event)
		}
	}
	actions.reset(bus)
}

handle_events :: proc(bus: ^events.Bus) {
	for event in events.items(bus) {
		// Prototype subscriber: later, interested subsystems can consume these
		// facts without knowing which input source requested the action.
		fmt.println("[event]", event.kind, "source:", event.action_source)
	}
	events.reset(bus)
}

handle_smgui_events :: proc(layer: ^smgui.State, settings: ^settings_panel.State, bus: ^actions.Bus) {
	for {
		event, ok := smgui.poll_event(layer)
		if !ok {
			break
		}
		switch event.kind {
		case .Page_Selected:
			if event.value >= i32(settings_panel.Page.General) && event.value <= i32(settings_panel.Page.Reset) {
				settings_panel.cancel_shortcut_capture(settings)
				settings.page = c.int(event.value)
				smgui.sync_settings(layer, settings_snapshot(settings))
				fmt.println("[settings] opened page:", settings_panel.Page(settings.page))
			}
		case .Theme_Selected:
			if themes.is_valid(event.value) {
				actions.post(bus, actions.set_theme(event.value, .User_Interface))
			}
		case .Accepted:
			fmt.println("[settings] OK requested")
			settings_panel.close_active(settings)
		case .Apply_Requested:
			fmt.println("[settings] Apply requested")
		case .Cancelled:
			fmt.println("[settings] Cancel requested")
			settings_panel.close_active(settings)
		case .Closed:
			settings_panel.close_active(settings)
		case .Setting_Changed:
			if event.field >= i32(settings_panel.Setting_Field.Save_Format) && event.field <= i32(settings_panel.Setting_Field.Keep_Closed_Duration) {
				settings_panel.apply_field(settings, settings_panel.Setting_Field(event.field), event.value)
				smgui.sync_settings(layer, settings_snapshot(settings))
			}
		case .Shortcut_Capture_Requested:
			if event.field >= 0 && event.field < 20 {
				settings_panel.request_shortcut_capture(settings, int(event.field))
			}
		case .Page_Action:
			if event.page >= i32(settings_panel.Page.General) && event.page <= i32(settings_panel.Page.Reset) {
				fmt.println("[settings] page action:", settings_panel.Page(event.page), event.field)
			}
		case .None:
		}
	}
}

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "BitSpryte — raylib + SMGUI")
	defer rl.CloseWindow()
	rl.SetWindowMinSize(1000, 700)
	// Disable raylib's default ESC-to-exit behavior. Escape is an ordinary,
	// configurable shortcut that closes only the active BitSpryte subwindow.
	rl.SetExitKey(.KEY_NULL)
	rl.SetTargetFPS(60)
	native.install()

	// The main shell still uses the legacy raygui icon pack during migration.
	rl.GuiLoadIcons(resource_path("icons/bitspryte.rgi"), false)

	image := rl.GenImageColor(CANVAS_SIZE, CANVAS_SIZE, rl.BLANK)
	defer rl.UnloadImage(image)
	texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadTexture(texture)
	rl.SetTextureFilter(texture, .POINT)

	tool := c.int(Tool.Pencil)
	settings := settings_panel.init()
	smgui_layer := smgui.init(WINDOW_WIDTH, WINDOW_HEIGHT)
	defer smgui.destroy(&smgui_layer)
	// Aseprite's proportional pixel font is rendered directly from its sprite
	// sheet through SMGUI font hooks. The built-in PSF2 font remains fallback.
	_ = smgui.load_sprite_sheet_font(&smgui_layer, resource_path("fonts/aseprite_font.png"), 2)
	action_bus: actions.Bus
	defer actions.destroy(&action_bus)
	event_bus: events.Bus
	defer events.destroy(&event_bus)
	zoom: f32 = 16
	paint_color := rl.Color{239, 71, 111, 255}
	status: cstring = "Ready — left drag paints, right drag erases"

	palette := [8]rl.Color{
		{29, 43, 83, 255},
		{126, 37, 83, 255},
		{0, 135, 81, 255},
		{171, 82, 54, 255},
		{95, 87, 79, 255},
		{194, 195, 199, 255},
		{255, 241, 232, 255},
		{255, 0, 77, 255},
	}

	for !rl.WindowShouldClose() {
		screen_width := f32(rl.GetScreenWidth())
		screen_height := f32(rl.GetScreenHeight())
		toolbar := layout.toolbar
		toolbar.width = screen_width
		status_bar := layout.statusBar
		status_bar.y = screen_height - status_bar.height
		status_bar.width = screen_width
		sidebar := layout.sidebar
		sidebar.height = status_bar.y - sidebar.y
		tool_panel := layout.toolPanel
		tool_panel.x = screen_width - tool_panel.width
		tool_panel.height = status_bar.y - tool_panel.y
		tool_x_offset := tool_panel.x - layout.toolPanel.x
		workspace := layout.workspace
		workspace.x = sidebar.x + sidebar.width
		workspace.width = tool_panel.x - workspace.x
		workspace.height = status_bar.y - workspace.y

		export_button := layout.exportButton
		export_button.x = screen_width - export_button.width - 16
		clear_button := layout.clearButton
		clear_button.x = export_button.x - clear_button.width - 10
		settings_button := layout.settingsButton
		settings_button.width = 120
		settings_button.x = clear_button.x - settings_button.width - 10
		palette_group := layout.paletteGroup
		color_group := layout.colorGroup
		color_group.y = status_bar.y - color_group.height - 12
		color_picker := layout.colorPicker
		color_picker.x = color_group.x + 16
		color_picker.y = color_group.y + 28
		color_swatch := layout.colorSwatch
		color_swatch.x = color_group.x + 16
		color_swatch.y = color_group.y + color_group.height - color_swatch.height - 16

		switch native.take_action() {
		case .Settings:     actions.post(&action_bus, actions.make(.Open_Settings, .Native_Menu))
		case .Export_PNG:   actions.post(&action_bus, actions.make(.Export_PNG, .Native_Menu))
		case .Clear_Canvas: actions.post(&action_bus, actions.make(.Clear_Canvas, .Native_Menu))
		case .None:
		}
		if settings_panel.captures_keyboard(&settings) {
			if key := rl.GetKeyPressed(); key != .KEY_NULL {
				settings_panel.capture_shortcut(&settings, key)
				smgui.sync_settings(&smgui_layer, settings_snapshot(&settings))
			}
		} else if !smgui.captures_keyboard(&smgui_layer) && rl.IsKeyPressed(settings.close_window_key) {
			actions.post(&action_bus, actions.make(.Close_Active_Window, .Keyboard))
		}
		dispatch_actions(&action_bus, &event_bus, &image, texture, &settings, &smgui_layer, &status)
		handle_events(&event_bus)

		available_zoom := min(
			(workspace.width - 32) / f32(CANVAS_SIZE),
			(workspace.height - 32) / f32(CANVAS_SIZE),
		)
		canvas_zoom := max(f32(1), min(zoom, available_zoom))
		canvas_width := f32(CANVAS_SIZE) * canvas_zoom
		canvas_height := f32(CANVAS_SIZE) * canvas_zoom
		canvas_rect := rl.Rectangle{
			workspace.x + (workspace.width - canvas_width) / 2,
			workspace.y + (workspace.height - canvas_height) / 2,
			canvas_width,
			canvas_height,
		}

		mouse := rl.GetMousePosition()
		// Preserve capture for the whole frame even when this input closes the
		// popup, preventing the closing click from reaching controls underneath.
		smgui_captured_before_update := smgui.captures_mouse(&smgui_layer, mouse)
		smgui.update(&smgui_layer, c.int(screen_width), c.int(screen_height), mouse)
		handle_smgui_events(&smgui_layer, &settings, &action_bus)
		smgui_captures_mouse := smgui_captured_before_update || smgui.captures_mouse(&smgui_layer, mouse)
		over_canvas := rl.CheckCollisionPointRec(mouse, canvas_rect)
		paint_tool_active := tool == c.int(Tool.Pencil) || tool == c.int(Tool.Eraser) || tool == c.int(Tool.Brush)
		painting := !smgui_captures_mouse && over_canvas && (rl.IsMouseButtonDown(.RIGHT) || (paint_tool_active && rl.IsMouseButtonDown(.LEFT)))
		if painting {
			x := c.int((mouse.x - canvas_rect.x) / canvas_zoom)
			y := c.int((mouse.y - canvas_rect.y) / canvas_zoom)
			use_eraser := tool == c.int(Tool.Eraser) || rl.IsMouseButtonDown(.RIGHT)
			color := paint_color
			if use_eraser {
				color = rl.BLANK
			}
			rl.ImageDrawPixel(&image, x, y, color)
			rl.UpdateTexture(texture, image.data)
			status = "Canvas changed"
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.Color{20, 22, 28, 255})

		// Workspace and a checkerboard beneath transparent pixels.
		rl.DrawRectangleRec(workspace, rl.Color{31, 34, 42, 255})
		for y in 0..<CANVAS_SIZE {
			for x in 0..<CANVAS_SIZE {
				checker := rl.Color{183, 187, 195, 255}
				if (x + y) % 2 == 0 {
					checker = rl.Color{218, 220, 225, 255}
				}
				rl.DrawRectangle(
					c.int(canvas_rect.x + f32(x) * canvas_zoom),
					c.int(canvas_rect.y + f32(y) * canvas_zoom),
					c.int(canvas_zoom + 1),
					c.int(canvas_zoom + 1),
					checker,
				)
			}
		}

		rl.DrawTexturePro(
			texture,
			rl.Rectangle{0, 0, f32(CANVAS_SIZE), f32(CANVAS_SIZE)},
			canvas_rect,
			rl.Vector2{},
			0,
			rl.WHITE,
		)

		if canvas_zoom >= 10 {
			grid_color := rl.Color{45, 48, 55, 90}
			for i in 0..=CANVAS_SIZE {
				x := c.int(canvas_rect.x + f32(i) * canvas_zoom)
				y := c.int(canvas_rect.y + f32(i) * canvas_zoom)
				rl.DrawLine(x, c.int(canvas_rect.y), x, c.int(canvas_rect.y + canvas_rect.height), grid_color)
				rl.DrawLine(c.int(canvas_rect.x), y, c.int(canvas_rect.x + canvas_rect.width), y, grid_color)
			}
		}
		rl.DrawRectangleLinesEx(canvas_rect, 2, rl.Color{8, 9, 12, 255})

		// Floating UI layers are modeless. Only controls directly beneath one are
		// locked while the pointer is over that layer.
		if smgui_captures_mouse {
			rl.GuiLock()
		}

		// All control rectangles and labels below are generated from main.rgl.
		rl.GuiPanel(toolbar, layout.toolbar_TEXT)
		rl.GuiLabel(layout.title, layout.title_TEXT)
		rl.GuiSliderBar(layout.zoomSlider, layout.zoomSlider_TEXT, nil, &zoom, 6, 20)

		if rl.GuiButton(settings_button, layout.settingsButton_TEXT) {
			actions.post(&action_bus, actions.make(.Open_Settings, .User_Interface))
		}

		if rl.GuiButton(clear_button, layout.clearButton_TEXT) {
			actions.post(&action_bus, actions.make(.Clear_Canvas, .User_Interface))
		}
		if rl.GuiButton(export_button, layout.exportButton_TEXT) {
			actions.post(&action_bus, actions.make(.Export_PNG, .User_Interface))
		}

		// Left palette/color inspector and right vertical tool strip.
		rl.GuiPanel(sidebar, layout.sidebar_TEXT)
		rl.GuiGroupBox(color_group, layout.colorGroup_TEXT)
		rl.GuiColorPicker(color_picker, layout.colorPicker_TEXT, &paint_color)
		rl.DrawRectangleRec(color_swatch, paint_color)

		rl.GuiGroupBox(palette_group, layout.paletteGroup_TEXT)
		for color, i in palette {
			x := palette_group.x + 16 + f32(i % 4) * 50
			y := palette_group.y + 28 + f32(i / 4) * 42
			bounds := rl.Rectangle{x, y, 36, 30}
			rl.DrawRectangleRec(bounds, color)
			if rl.CheckCollisionPointRec(mouse, bounds) && rl.IsMouseButtonPressed(.LEFT) {
				paint_color = color
				tool = c.int(Tool.Pencil)
				status = "Palette color selected"
			}
			rl.DrawRectangleLinesEx(bounds, 1, rl.Color{20, 22, 28, 255})
		}

		rl.GuiPanel(tool_panel, layout.toolPanel_TEXT)
		draw_tool_toggle(translated(layout.toolSelection, tool_x_offset, 0), layout.toolSelection_TEXT, .Selection, &tool, &status)
		draw_tool_toggle(translated(layout.toolPencil, tool_x_offset, 0), layout.toolPencil_TEXT, .Pencil, &tool, &status)
		draw_tool_toggle(translated(layout.toolEraser, tool_x_offset, 0), layout.toolEraser_TEXT, .Eraser, &tool, &status)
		draw_tool_toggle(translated(layout.toolEyedropper, tool_x_offset, 0), layout.toolEyedropper_TEXT, .Eyedropper, &tool, &status)
		draw_tool_toggle(translated(layout.toolZoom, tool_x_offset, 0), layout.toolZoom_TEXT, .Zoom, &tool, &status)
		draw_tool_toggle(translated(layout.toolMove, tool_x_offset, 0), layout.toolMove_TEXT, .Move, &tool, &status)
		draw_tool_toggle(translated(layout.toolFill, tool_x_offset, 0), layout.toolFill_TEXT, .Fill, &tool, &status)
		draw_tool_toggle(translated(layout.toolLine, tool_x_offset, 0), layout.toolLine_TEXT, .Line, &tool, &status)
		draw_tool_toggle(translated(layout.toolRectangle, tool_x_offset, 0), layout.toolRectangle_TEXT, .Rectangle, &tool, &status)
		draw_tool_toggle(translated(layout.toolEllipse, tool_x_offset, 0), layout.toolEllipse_TEXT, .Ellipse, &tool, &status)
		draw_tool_toggle(translated(layout.toolBrush, tool_x_offset, 0), layout.toolBrush_TEXT, .Brush, &tool, &status)
		draw_tool_toggle(translated(layout.toolText, tool_x_offset, 0), layout.toolText_TEXT, .Text, &tool, &status)

		rl.GuiStatusBar(status_bar, status)

		if smgui_captures_mouse {
			rl.GuiUnlock()
		}

		// SMGUI owns the complete Settings window and all page content.
		smgui.draw(&smgui_layer)

		rl.EndDrawing()
	}
}
