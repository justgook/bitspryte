package main

import "core:c"
import "core:fmt"
import actions "./app/actions"
import events "./app/events"
import themes "./app/themes"
import layout "generated:layout"
import native "./platform/native_menu"
import rl "vendor:raylib/v55"
import settings_panel "./ui/settings_panel"

CANVAS_SIZE :: 32
WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 800

Tool :: enum c.int {
	Pencil,
	Eraser,
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

dispatch_actions :: proc(
	bus: ^actions.Bus,
	event_bus: ^events.Bus,
	image: ^rl.Image,
	texture: rl.Texture2D,
	settings: ^settings_panel.State,
	status: ^cstring,
) {
	for action in actions.items(bus) {
		switch action.kind {
		case .Open_Settings:
			settings_panel.open(settings)
			events.publish(event_bus, events.make(.Settings_Opened, action.source))

		case .Close_Active_Window:
			if settings_panel.close_active(settings) {
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

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "BitSpryte — raylib + raygui lab")
	defer rl.CloseWindow()
	rl.SetWindowMinSize(1000, 700)
	// Disable raylib's default ESC-to-exit behavior. Escape is an ordinary,
	// configurable shortcut that closes only the active BitSpryte subwindow.
	rl.SetExitKey(.KEY_NULL)
	rl.SetTargetFPS(60)
	native.install()

	// These files remain editable by rGuiStyler/rGuiIcons and are copied beside
	// the executable by the Makefile.
	rl.GuiLoadIcons(resource_path("icons/bitspryte.rgi"), false)

	image := rl.GenImageColor(CANVAS_SIZE, CANVAS_SIZE, rl.BLANK)
	defer rl.UnloadImage(image)
	texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadTexture(texture)
	rl.SetTextureFilter(texture, .POINT)

	tool := c.int(Tool.Pencil)
	settings := settings_panel.init()
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
		x_offset := screen_width - layout.REFERENCE_WIDTH

		toolbar := layout.toolbar
		toolbar.width = screen_width
		status_bar := layout.statusBar
		status_bar.y = screen_height - status_bar.height
		status_bar.width = screen_width
		sidebar := layout.sidebar
		sidebar.x += x_offset
		sidebar.height = status_bar.y - sidebar.y
		workspace := layout.workspace
		workspace.width = sidebar.x
		workspace.height = status_bar.y - workspace.y

		export_button := layout.exportButton
		export_button.x = screen_width - export_button.width - 16
		clear_button := layout.clearButton
		clear_button.x = export_button.x - clear_button.width - 10
		settings_button := layout.settingsButton
		settings_button.width = 120
		settings_button.x = clear_button.x - settings_button.width - 10
		color_group := translated(layout.colorGroup, x_offset, 0)
		color_picker := translated(layout.colorPicker, x_offset, 0)
		color_swatch := translated(layout.colorSwatch, x_offset, 0)
		palette_group := translated(layout.paletteGroup, x_offset, 0)

		switch native.take_action() {
		case .Settings:     actions.post(&action_bus, actions.make(.Open_Settings, .Native_Menu))
		case .Export_PNG:   actions.post(&action_bus, actions.make(.Export_PNG, .Native_Menu))
		case .Clear_Canvas: actions.post(&action_bus, actions.make(.Clear_Canvas, .Native_Menu))
		case .None:
		}
		if !settings_panel.captures_keyboard(&settings) && rl.IsKeyPressed(settings.close_window_key) {
			actions.post(&action_bus, actions.make(.Close_Active_Window, .Keyboard))
		}
		dispatch_actions(&action_bus, &event_bus, &image, texture, &settings, &status)
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
		settings_captures_mouse := settings_panel.captures_mouse(&settings, mouse)
		over_canvas := rl.CheckCollisionPointRec(mouse, canvas_rect)
		painting := !settings_captures_mouse && over_canvas && (rl.IsMouseButtonDown(.LEFT) || rl.IsMouseButtonDown(.RIGHT))
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

		// The settings window is modeless. Only controls directly beneath it are
		// locked while the pointer is over the floating window.
		if settings_captures_mouse {
			rl.GuiLock()
		}

		// All control rectangles and labels below are generated from main.rgl.
		rl.GuiPanel(toolbar, layout.toolbar_TEXT)
		rl.GuiLabel(layout.title, layout.title_TEXT)
		rl.GuiToggleGroup(layout.toolSelector, layout.toolSelector_TEXT, &tool)
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

		// raygui inspector and color controls.
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

		rl.GuiStatusBar(status_bar, status)

		if settings_captures_mouse {
			rl.GuiUnlock()
		}
		settings_result := settings_panel.draw(&settings)
		if settings_result.theme_changed {
			actions.post(&action_bus, actions.set_theme(i32(settings.theme), .User_Interface))
		}

		rl.EndDrawing()
	}
}
