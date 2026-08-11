package layout

import smgui "../../vendor/smgui/smgui"
import "core:fmt"

TOP_HEIGHT :: 32
FOOTER_HEIGHT :: 32
RIGHT_SIDEBAR_WIDTH :: 32
LEFT_SIDEBAR_DEFAULT_WIDTH :: 96
LEFT_SIDEBAR_MIN_WIDTH :: 32
MIN_CANVAS_REGION_WIDTH :: 64
SIDEBAR_SPLITTER_HIT_RADIUS :: 3
LEFT_PANEL_MIN_HEIGHT :: 32
PANEL_GAP :: 4
PANEL_LABEL_MIN_WIDTH :: 80
PANEL_BACKGROUND_COLOR :: 0xff2d1e1e // #1E1E2D in SMGUI's little-endian RGBA format.
TOOL_BUTTON_COUNT :: 12
TOOL_BUTTON_SIZE :: 32
TOOL_BUTTON_GAP :: 0
TOOL_BUTTON_HORIZONTAL_PADDING :: 1
TOOL_PANEL_TOP_PADDING :: 3
TOOL_ICON_NAMES := [TOOL_BUTTON_COUNT]string {
	"tool_rectangular_marquee",
	"tool_pencil",
	"tool_eraser",
	"tool_eyedropper",
	"tool_zoom",
	"tool_move",
	"tool_paint_bucket",
	"tool_line",
	"tool_rectangle",
	"tool_contour",
	"tool_blur",
	"", // The text tool uses the Aseprite font instead of an atlas icon.
}

Panel_Config :: struct {
	style:      ^smgui.Panel_Style,
	padding:    smgui.Panel_Padding,
	content:    smgui.Panel_Content,
	background: u32,
}

Panel_Configs :: struct {
	canvas_style:      ^smgui.Panel_Style,
	palette_style:     ^smgui.Panel_Style,
	color_wheel_style: ^smgui.Panel_Style,
	tool_button_style: ^smgui.Panel_Style,
	padding:           smgui.Panel_Padding,
}

Canvas_Region :: struct {
	x, y:          int,
	width, height: int,
}

Layout :: struct {
	forms:                  [8]smgui.Form,
	workspace_children:     [3]smgui.Form,
	left_sidebar_children:  [2]smgui.Form,
	center_children:        [1]smgui.Form,
	palette_children:       [1]smgui.Form,
	color_wheel_children:   [1]smgui.Form,
	right_sidebar_children: [TOOL_BUTTON_COUNT + 1]smgui.Form,
	tool_icons:             [TOOL_BUTTON_COUNT]smgui.Image,
	active_tool:            int,
	tool_scale:             int,
	right_sidebar_width:    int,
	home_requested:         bool,
	clear_requested:        bool,
	left_sidebar_width:     int,
	palette_panel_height:   int,
	resizing_left_sidebar:  bool,
	resizing_left_panels:   bool,
}

TEXTS := [?]string{"BitSpryte", "BitSpryte", "Home", "Clear", "", "Palette", "Color Wheel", "T"}

canvas_status_text :: proc(
	buffer: []u8,
	cursor_x, cursor_y: int,
	cursor_inside: bool,
	canvas_width, canvas_height: int,
) -> string {
	if cursor_inside {
		return fmt.bprintf(buffer, "+ %d %d    [] %d %d", cursor_x, cursor_y, canvas_width, canvas_height)
	}
	return fmt.bprintf(buffer, "+ -- --    [] %d %d", canvas_width, canvas_height)
}

init :: proc(layout: ^Layout, width, height: int, panels: Panel_Configs = {}, tool_icons: []smgui.Image = nil) {
	assert(layout != nil)
	layout^ = {
		left_sidebar_width  = LEFT_SIDEBAR_DEFAULT_WIDTH,
		tool_scale          = 1,
		right_sidebar_width = RIGHT_SIDEBAR_WIDTH,
	}
	for icon in tool_icons {
		if icon.width > 0 {
			layout.tool_scale = max(layout.tool_scale, (icon.width + 15) / 16)
		}
	}
	button_width := TOOL_BUTTON_SIZE
	layout.right_sidebar_width = RIGHT_SIDEBAR_WIDTH
	// Empty Custom Form retains Canvas Region geometry; the transparent Panel
	// clears its full framed interior before this child is visited.
	layout.center_children = {{kind = .Custom}}
	layout.palette_children = {{kind = .Label, label = 5}}
	layout.color_wheel_children = {{kind = .Label, label = 6}}
	layout.right_sidebar_children[0] = {
		kind = .Custom,
		custom = {view = draw_background},
	}
	for index in 0 ..< TOOL_BUTTON_COUNT {
		if index < len(tool_icons) {
			layout.tool_icons[index] = tool_icons[index]
		}
		button := &layout.right_sidebar_children[index + 1]
		button^ = {
			kind                      = .Button,
			width                     = button_width,
			height                    = TOOL_BUTTON_SIZE,
			value                     = index,
			button_horizontal_padding = TOOL_BUTTON_HORIZONTAL_PADDING,
			button_fixed_size         = true,
			button_style              = panels.tool_button_style,
		}
		if index == TOOL_BUTTON_COUNT - 1 {
			button.label = 7
		} else {
			button.icon = &layout.tool_icons[index]
		}
		button.binding = smgui.bind(&layout.active_tool)
	}
	layout.left_sidebar_children = {
		panel(
			layout.palette_children[:],
			{style = panels.palette_style, padding = panels.padding, background = PANEL_BACKGROUND_COLOR},
		),
		panel(
			layout.color_wheel_children[:],
			{style = panels.color_wheel_style, padding = panels.padding, background = PANEL_BACKGROUND_COLOR},
		),
	}
	layout.workspace_children = {
		// Paint the workspace background first; framed Panels are always above it.
		{kind = .Custom, custom = {view = draw_background}},
		{kind = .Division, children = layout.left_sidebar_children[:]},
		panel(
			layout.center_children[:],
			{style = panels.canvas_style, padding = panels.padding, content = .Transparent},
		),
	}
	// Canvas is the initial active workspace; BitSpryte can move this flag later.
	layout.workspace_children[2].flags += {.Focused}
	layout.forms = {
		// Header.
		{kind = .Custom, custom = {view = draw_background}},
		{kind = .Label, label = 1},
		{kind = .Button, width = 58, height = 22, label = 2},
		{kind = .Button, width = 58, height = 22, label = 3},

		// Workspace parent, fixed right sidebar, and footer.
		{kind = .Division, children = layout.workspace_children[:]},
		{kind = .Division, children = layout.right_sidebar_children[:]},
		{kind = .Custom, custom = {view = draw_background}},
		{kind = .Label, label = 4},
	}
	layout.forms[2].binding = smgui.bind(&layout.home_requested)
	layout.forms[3].binding = smgui.bind(&layout.clear_requested)
	resize(layout, width, height)
}

panel :: proc(children: []smgui.Form, config: Panel_Config = {}) -> smgui.Form {
	return {
		kind = .Panel,
		children = children,
		panel_style = config.style,
		panel_padding = config.padding,
		panel_content = config.content,
		panel_background = config.background,
	}
}

resize :: proc(layout: ^Layout, width, height: int) {
	assert(layout != nil)
	working_height := max(height - TOP_HEIGHT - FOOTER_HEIGHT, 0)
	max_left_width := max(width - layout.right_sidebar_width - MIN_CANVAS_REGION_WIDTH, 0)
	minimum := min(LEFT_SIDEBAR_MIN_WIDTH, max_left_width)
	layout.left_sidebar_width = clamp(layout.left_sidebar_width, minimum, max_left_width)

	set_rect(&layout.forms[0], 0, 0, width, TOP_HEIGHT)
	layout.forms[1].x = smgui.absolute(10)
	layout.forms[1].y = smgui.absolute(8)
	layout.forms[2].x = smgui.absolute(120)
	layout.forms[2].y = smgui.absolute(5)
	layout.forms[3].x = smgui.absolute(184)
	layout.forms[3].y = smgui.absolute(5)

	workspace_width := max(width - layout.right_sidebar_width, 0)
	set_rect(&layout.forms[4], 0, TOP_HEIGHT, workspace_width, working_height)
	set_rect(&layout.workspace_children[0], 0, 0, workspace_width, working_height)
	set_rect(&layout.workspace_children[1], 0, 0, layout.left_sidebar_width, working_height)

	center_x := layout.left_sidebar_width + PANEL_GAP
	center_y := PANEL_GAP
	center_width := max(workspace_width - layout.left_sidebar_width - 2 * PANEL_GAP, 0)
	center_height := max(working_height - 2 * PANEL_GAP, 0)
	center_panel := &layout.workspace_children[2]
	set_rect(center_panel, center_x, center_y, center_width, center_height)
	panel_left, panel_top, panel_right, panel_bottom := smgui.panel_insets(center_panel)
	padding := center_panel.panel_padding
	layout.center_children[0].width = max(center_width - padding.left - padding.right - panel_left - panel_right, 0)
	layout.center_children[0].height = max(center_height - padding.top - padding.bottom - panel_top - panel_bottom, 0)

	left_panel_x := PANEL_GAP
	left_panel_width := max(layout.left_sidebar_width - 2 * PANEL_GAP, 0)
	available_panel_height := max(working_height - 3 * PANEL_GAP, 0)
	if layout.palette_panel_height == 0 {
		layout.palette_panel_height = available_panel_height / 2
	}
	maximum_palette_height := max(available_panel_height - LEFT_PANEL_MIN_HEIGHT, 0)
	minimum_palette_height := min(LEFT_PANEL_MIN_HEIGHT, maximum_palette_height)
	layout.palette_panel_height = clamp(layout.palette_panel_height, minimum_palette_height, maximum_palette_height)
	color_wheel_panel_height := max(available_panel_height - layout.palette_panel_height, 0)
	first_panel_y := PANEL_GAP
	second_panel_y := first_panel_y + layout.palette_panel_height + PANEL_GAP
	set_rect(
		&layout.left_sidebar_children[0],
		left_panel_x,
		first_panel_y,
		left_panel_width,
		layout.palette_panel_height,
	)
	set_rect(
		&layout.left_sidebar_children[1],
		left_panel_x,
		second_panel_y,
		left_panel_width,
		color_wheel_panel_height,
	)
	show_panel_labels :=
		left_panel_width >= PANEL_LABEL_MIN_WIDTH && min(layout.palette_panel_height, color_wheel_panel_height) >= 24
	set_form_visible(&layout.palette_children[0], show_panel_labels)
	set_form_visible(&layout.color_wheel_children[0], show_panel_labels)

	right_sidebar_width := min(layout.right_sidebar_width, width)
	set_rect(
		&layout.forms[5],
		max(width - layout.right_sidebar_width, 0),
		TOP_HEIGHT,
		right_sidebar_width,
		working_height,
	)
	set_rect(&layout.right_sidebar_children[0], 0, 0, right_sidebar_width, working_height)
	button_width := layout.right_sidebar_children[1].width
	button_height := layout.right_sidebar_children[1].height
	for index in 0 ..< TOOL_BUTTON_COUNT {
		button := &layout.right_sidebar_children[index + 1]
		button.x = smgui.absolute((right_sidebar_width - button_width) / 2)
		button.y = smgui.absolute(TOOL_PANEL_TOP_PADDING + index * (button_height + TOOL_BUTTON_GAP))
	}
	footer_y := max(height - FOOTER_HEIGHT, TOP_HEIGHT)
	set_rect(&layout.forms[6], 0, footer_y, width, FOOTER_HEIGHT)
	layout.forms[7].x = smgui.absolute(10)
	layout.forms[7].y = smgui.absolute(footer_y + 6)
}

left_sidebar_splitter_x :: proc(layout: ^Layout) -> int {
	assert(layout != nil)
	return layout.left_sidebar_width
}

point_on_left_sidebar_splitter :: proc(layout: ^Layout, x, y, window_width, window_height: int) -> bool {
	assert(layout != nil)
	_ = window_width
	splitter_x := left_sidebar_splitter_x(layout)
	return y >= TOP_HEIGHT && y < window_height - FOOTER_HEIGHT && abs(x - splitter_x) <= SIDEBAR_SPLITTER_HIT_RADIUS
}

begin_left_sidebar_resize :: proc(layout: ^Layout, x, y, window_width, window_height: int) -> bool {
	assert(layout != nil)
	if !point_on_left_sidebar_splitter(layout, x, y, window_width, window_height) {
		return false
	}
	layout.resizing_left_sidebar = true
	return true
}

drag_left_sidebar :: proc(layout: ^Layout, pointer_x, window_width, window_height: int) {
	assert(layout != nil)
	if !layout.resizing_left_sidebar {return}
	layout.left_sidebar_width = pointer_x
	resize(layout, window_width, window_height)
}

end_left_sidebar_resize :: proc(layout: ^Layout) {
	assert(layout != nil)
	layout.resizing_left_sidebar = false
}

left_panel_splitter_y :: proc(layout: ^Layout) -> int {
	assert(layout != nil)
	return TOP_HEIGHT + PANEL_GAP + layout.palette_panel_height + PANEL_GAP / 2
}

point_on_left_panel_splitter :: proc(layout: ^Layout, x, y: int) -> bool {
	assert(layout != nil)
	return(
		x >= PANEL_GAP &&
		x < layout.left_sidebar_width - PANEL_GAP &&
		abs(y - left_panel_splitter_y(layout)) <= SIDEBAR_SPLITTER_HIT_RADIUS \
	)
}

begin_left_panel_resize :: proc(layout: ^Layout, x, y: int) -> bool {
	assert(layout != nil)
	if !point_on_left_panel_splitter(layout, x, y) {return false}
	layout.resizing_left_panels = true
	return true
}

drag_left_panels :: proc(layout: ^Layout, pointer_y, window_width, window_height: int) {
	assert(layout != nil)
	if !layout.resizing_left_panels {return}
	first_panel_y := TOP_HEIGHT + PANEL_GAP
	layout.palette_panel_height = pointer_y - first_panel_y - PANEL_GAP / 2
	resize(layout, window_width, window_height)
}

end_left_panel_resize :: proc(layout: ^Layout) {
	assert(layout != nil)
	layout.resizing_left_panels = false
}

forms :: proc(layout: ^Layout) -> []smgui.Form {
	assert(layout != nil)
	return layout.forms[:]
}

canvas_region :: proc(layout: ^Layout) -> Canvas_Region {
	assert(layout != nil)
	field := &layout.center_children[0]
	return {x = field.computed_x, y = field.computed_y, width = field.computed_width, height = field.computed_height}
}

@(private = "file")
set_rect :: proc(form: ^smgui.Form, x, y, width, height: int) {
	form.x = smgui.absolute(x)
	form.y = smgui.absolute(y)
	form.width = width
	form.height = height
}

@(private = "file")
set_form_visible :: proc(form: ^smgui.Form, visible: bool) {
	if visible {
		form.flags -= {.Hidden}
	} else {
		form.flags += {.Hidden}
	}
}

@(private = "file")
draw_background :: proc(ctx: ^smgui.Context, x, y, width, height: int, form: ^smgui.Form) -> smgui.Error {
	if ctx == nil || form == nil {return .Invalid_Input}
	fill_rectangle(ctx, x, y, width, height, ctx.theme[int(smgui.Theme_Color.Background)])
	return .None
}

@(private = "file")
fill_rectangle :: proc(ctx: ^smgui.Context, x, y, width, height: int, color: u32) {
	if width < 1 || height < 1 {return}
	for row in max(y, ctx.clip_y0) ..< min(y + height, ctx.clip_y1) {
		for column in max(x, ctx.clip_x0) ..< min(x + width, ctx.clip_x1) {
			pixel := row * ctx.screen.pitch + column * 4
			ctx.screen.pixels[pixel + 0] = u8(color)
			ctx.screen.pixels[pixel + 1] = u8(color >> 8)
			ctx.screen.pixels[pixel + 2] = u8(color >> 16)
			ctx.screen.pixels[pixel + 3] = u8(color >> 24)
		}
	}
}
