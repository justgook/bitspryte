package layout_test

import layout "../../editor/layout"
import smgui "../../vendor/smgui/smgui"
import "core:testing"

@(test)
canvas_status_reports_zero_indexed_cursor_and_pixel_dimensions :: proc(t: ^testing.T) {
	buffer: [64]u8
	text := layout.canvas_status_text(buffer[:], 0, 26, true, 256, 105)
	testing.expect_value(t, text, "+ 0 26    [] 256 105")

	text = layout.canvas_status_text(buffer[:], 0, 0, false, 256, 105)
	testing.expect_value(t, text, "+ -- --    [] 256 105")
}

@(test)
left_sidebar_splitter_has_a_resizable_hit_target :: proc(t: ^testing.T) {
	shell: layout.Layout
	layout.init(&shell, 960, 720)

	testing.expect_value(t, layout.left_sidebar_splitter_x(&shell), 96)
	testing.expect(t, layout.point_on_left_sidebar_splitter(&shell, 96, 100, 960, 720))
	testing.expect(t, layout.point_on_left_sidebar_splitter(&shell, 99, 100, 960, 720))
	testing.expect(t, !layout.point_on_left_sidebar_splitter(&shell, 100, 100, 960, 720))
	testing.expect(t, !layout.point_on_left_sidebar_splitter(&shell, 96, 10, 960, 720))
	testing.expect(t, !layout.point_on_left_sidebar_splitter(&shell, 96, 700, 960, 720))
}

@(test)
dragging_splitter_resizes_left_sidebar_and_center_panel :: proc(t: ^testing.T) {
	shell: layout.Layout
	layout.init(&shell, 960, 720)

	started := layout.begin_left_sidebar_resize(&shell, 96, 100, 960, 720)
	layout.drag_left_sidebar(&shell, 160, 960, 720)

	testing.expect(t, started && shell.resizing_left_sidebar)
	testing.expect_value(t, shell.left_sidebar_width, 160)
	testing.expect_value(t, int(shell.workspace_children[2].x.value), 160 + layout.PANEL_GAP)
	testing.expect_value(t, shell.workspace_children[1].width, 160)
	// The right sidebar remains fixed while the left sidebar changes.
	testing.expect_value(t, int(shell.forms[5].x.value), 960 - layout.RIGHT_SIDEBAR_WIDTH)
	testing.expect_value(t, shell.forms[5].width, layout.RIGHT_SIDEBAR_WIDTH)
	// Placeholder labels become visible once their Panels are wide enough.
	testing.expect(t, .Hidden not_in shell.palette_children[0].flags)
	testing.expect(t, .Hidden not_in shell.color_wheel_children[0].flags)

	layout.end_left_sidebar_resize(&shell)
	testing.expect(t, !shell.resizing_left_sidebar)
}

@(test)
center_canvas_and_left_placeholders_use_smgui_panel_containers :: proc(t: ^testing.T) {
	shell: layout.Layout
	layout.init(&shell, 960, 720)

	testing.expect_value(t, shell.forms[4].kind, smgui.Field_Kind.Division)
	testing.expect_value(t, shell.workspace_children[0].kind, smgui.Field_Kind.Custom)
	testing.expect_value(t, shell.workspace_children[1].kind, smgui.Field_Kind.Division)
	testing.expect_value(t, shell.workspace_children[2].kind, smgui.Field_Kind.Panel)
	testing.expect_value(t, shell.left_sidebar_children[0].kind, smgui.Field_Kind.Panel)
	testing.expect_value(t, shell.left_sidebar_children[1].kind, smgui.Field_Kind.Panel)
	testing.expect(t, .Focused in shell.workspace_children[2].flags)
	testing.expect(t, .Focused not_in shell.left_sidebar_children[0].flags)
	testing.expect(t, .Focused not_in shell.left_sidebar_children[1].flags)
	testing.expect_value(t, int(shell.workspace_children[2].x.value), 100)
	testing.expect_value(t, int(shell.workspace_children[2].y.value), layout.PANEL_GAP)
	testing.expect_value(t, shell.center_children[0].width, shell.workspace_children[2].width - 6)
	testing.expect_value(t, int(shell.left_sidebar_children[0].x.value), layout.PANEL_GAP)
	testing.expect_value(t, int(shell.left_sidebar_children[1].x.value), layout.PANEL_GAP)
	testing.expect_value(t, shell.palette_children[0].kind, smgui.Field_Kind.Label)
	testing.expect_value(t, shell.color_wheel_children[0].kind, smgui.Field_Kind.Label)
	testing.expect(t, .Hidden not_in shell.palette_children[0].flags)
	testing.expect(t, .Hidden not_in shell.color_wheel_children[0].flags)
}

@(test)
workspace_panels_select_styles_independently_and_share_padding :: proc(t: ^testing.T) {
	canvas_style, palette_style, color_wheel_style: smgui.Panel_Style
	padding := smgui.Panel_Padding {
		left   = 1,
		top    = 2,
		right  = 3,
		bottom = 4,
	}
	shell: layout.Layout
	layout.init(
		&shell,
		960,
		720,
		{
			canvas_style = &canvas_style,
			palette_style = &palette_style,
			color_wheel_style = &color_wheel_style,
			padding = padding,
		},
	)

	canvas_panel := &shell.workspace_children[2]
	palette_panel := &shell.left_sidebar_children[0]
	color_wheel_panel := &shell.left_sidebar_children[1]
	testing.expect(t, canvas_panel.panel_style == &canvas_style)
	testing.expect(t, palette_panel.panel_style == &palette_style)
	testing.expect(t, color_wheel_panel.panel_style == &color_wheel_style)
	workspace_panels := [?]^smgui.Form{canvas_panel, palette_panel, color_wheel_panel}
	for panel in workspace_panels {
		testing.expect_value(t, panel.panel_padding, padding)
	}
	testing.expect_value(t, canvas_panel.panel_content, smgui.Panel_Content.Transparent)
	testing.expect_value(t, canvas_panel.panel_background, u32(0))
	testing.expect_value(t, palette_panel.panel_content, smgui.Panel_Content.Styled)
	testing.expect_value(t, palette_panel.panel_background, u32(layout.PANEL_BACKGROUND_COLOR))
	testing.expect_value(t, color_wheel_panel.panel_content, smgui.Panel_Content.Styled)
	testing.expect_value(t, color_wheel_panel.panel_background, u32(layout.PANEL_BACKGROUND_COLOR))
}

@(test)
left_panel_seam_resizes_palette_and_color_wheel_panels :: proc(t: ^testing.T) {
	shell: layout.Layout
	layout.init(&shell, 960, 720)

	testing.expect_value(t, layout.left_panel_splitter_y(&shell), 360)
	testing.expect(t, layout.point_on_left_panel_splitter(&shell, 48, 360))
	testing.expect(t, layout.point_on_left_panel_splitter(&shell, 48, 363))
	testing.expect(t, !layout.point_on_left_panel_splitter(&shell, 48, 364))
	testing.expect(t, !layout.point_on_left_panel_splitter(&shell, 100, 360))

	started := layout.begin_left_panel_resize(&shell, 48, 360)
	layout.drag_left_panels(&shell, 240, 960, 720)
	testing.expect(t, started && shell.resizing_left_panels)
	testing.expect_value(t, shell.palette_panel_height, 202)
	testing.expect_value(t, shell.left_sidebar_children[0].height, 202)
	testing.expect_value(t, int(shell.left_sidebar_children[1].y.value), 210)
	testing.expect_value(t, shell.left_sidebar_children[1].height, 442)

	layout.end_left_panel_resize(&shell)
	testing.expect(t, !shell.resizing_left_panels)
}

@(test)
left_panel_resize_preserves_both_panel_minimum_heights :: proc(t: ^testing.T) {
	shell: layout.Layout
	layout.init(&shell, 960, 720)
	layout.begin_left_panel_resize(&shell, 48, 360)

	layout.drag_left_panels(&shell, 0, 960, 720)
	testing.expect_value(t, shell.palette_panel_height, layout.LEFT_PANEL_MIN_HEIGHT)

	layout.drag_left_panels(&shell, 720, 960, 720)
	testing.expect_value(t, shell.palette_panel_height, 644 - layout.LEFT_PANEL_MIN_HEIGHT)
	testing.expect_value(t, shell.left_sidebar_children[1].height, layout.LEFT_PANEL_MIN_HEIGHT)
}

@(test)
left_sidebar_resize_preserves_minimum_sidebar_and_canvas_widths :: proc(t: ^testing.T) {
	shell: layout.Layout
	layout.init(&shell, 960, 720)
	layout.begin_left_sidebar_resize(&shell, 96, 100, 960, 720)

	layout.drag_left_sidebar(&shell, 10, 960, 720)
	testing.expect_value(t, shell.left_sidebar_width, layout.LEFT_SIDEBAR_MIN_WIDTH)

	layout.drag_left_sidebar(&shell, 1000, 960, 720)
	testing.expect_value(
		t,
		shell.left_sidebar_width,
		960 - layout.RIGHT_SIDEBAR_WIDTH - layout.MIN_CANVAS_REGION_WIDTH,
	)
}
