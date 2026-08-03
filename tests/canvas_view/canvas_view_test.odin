package canvas_view_test

import canvas_view "../../editor/canvas_view"
import "core:testing"

@(test)
test_starts_centered_at_actual_size :: proc(t: ^testing.T) {
	view: canvas_view.View
	canvas_view.init(&view, 160, 120, 960, 720)
	viewport := canvas_view.viewport(&view)

	testing.expect(t, canvas_view.scale(&view) == 1)
	testing.expect(t, viewport == canvas_view.Viewport{400, 300, 160, 120})
}

@(test)
test_zoom_uses_only_predefined_levels_and_keeps_pointer_anchored :: proc(t: ^testing.T) {
	view: canvas_view.View
	canvas_view.init(&view, 160, 120, 960, 720)
	before_x, before_y, before_inside := canvas_view.screen_to_canvas(&view, 440, 330)

	changed := canvas_view.zoom_at(&view, 1, 440, 330)
	after_x, after_y, after_inside := canvas_view.screen_to_canvas(&view, 440, 330)

	testing.expect(t, changed)
	testing.expect(t, canvas_view.scale(&view) == 2)
	testing.expect(t, before_inside && after_inside)
	testing.expect(t, before_x == after_x && before_y == after_y)

	canvas_view.zoom_at(&view, -1, 440, 330)
	canvas_view.zoom_at(&view, -1, 440, 330)
	testing.expect(t, canvas_view.scale(&view) == 0.5)
}

@(test)
test_zoom_is_clamped_to_constant_limits :: proc(t: ^testing.T) {
	view: canvas_view.View
	canvas_view.init(&view, 160, 120, 960, 720)
	for _ in 0 ..< 100 {
		canvas_view.zoom_at(&view, -1, 480, 360)
	}
	testing.expect(t, canvas_view.scale(&view) == canvas_view.ZOOM_LEVELS[0])

	for _ in 0 ..< 100 {
		canvas_view.zoom_at(&view, 1, 480, 360)
	}
	testing.expect(t, canvas_view.scale(&view) == canvas_view.ZOOM_LEVELS[len(canvas_view.ZOOM_LEVELS) - 1])
}

@(test)
test_pan_moves_canvas_and_keeps_an_edge_reachable :: proc(t: ^testing.T) {
	view: canvas_view.View
	canvas_view.init(&view, 160, 120, 960, 720)
	canvas_view.pan(&view, -1000, 1000)
	viewport := canvas_view.viewport(&view)

	testing.expect(t, viewport.x + viewport.width == canvas_view.MIN_VISIBLE_PIXELS)
	testing.expect(t, viewport.y == 720 - canvas_view.MIN_VISIBLE_PIXELS)
}

@(test)
test_resize_preserves_canvas_point_at_window_center :: proc(t: ^testing.T) {
	view: canvas_view.View
	canvas_view.init(&view, 160, 120, 960, 720)
	before_x, before_y, _ := canvas_view.screen_to_canvas(&view, 480, 360)

	canvas_view.resize(&view, 1200, 800)
	after_x, after_y, _ := canvas_view.screen_to_canvas(&view, 600, 400)

	testing.expect(t, before_x == after_x && before_y == after_y)
}
