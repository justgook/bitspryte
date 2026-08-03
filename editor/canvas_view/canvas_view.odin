package canvas_view

import "core:math"

// Zoom levels preserve hard pixel edges: below 100% each step halves the
// image, and above 100% every scale is an integer pixel multiple.
@(rodata)
ZOOM_LEVELS := [?]f32 {
	0.0625, 0.125, 0.25, 0.5,
	1,
	2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
	17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
	33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
	49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64,
}
ACTUAL_SIZE_INDEX :: 4
MIN_VISIBLE_PIXELS :: f32(50)

Viewport :: struct {
	x, y:          f32,
	width, height: f32,
}

View :: struct {
	canvas_width, canvas_height: f32,
	window_width, window_height: f32,
	x, y:                         f32,
	zoom_index:                   int,
	initialized:                  bool,
}

init :: proc(view: ^View, canvas_width, canvas_height: int, window_width, window_height: f32) {
	assert(view != nil)
	assert(canvas_width > 0 && canvas_height > 0)
	view^ = {
		canvas_width  = f32(canvas_width),
		canvas_height = f32(canvas_height),
		window_width  = window_width,
		window_height = window_height,
		zoom_index    = ACTUAL_SIZE_INDEX,
		initialized   = true,
	}
	center(view)
}

scale :: proc(view: ^View) -> f32 {
	assert(view != nil && view.initialized)
	return ZOOM_LEVELS[view.zoom_index]
}

viewport :: proc(view: ^View) -> Viewport {
	assert(view != nil && view.initialized)
	current_scale := scale(view)
	return {
		x      = math.round(view.x),
		y      = math.round(view.y),
		width  = view.canvas_width * current_scale,
		height = view.canvas_height * current_scale,
	}
}

center :: proc(view: ^View) {
	assert(view != nil && view.initialized)
	current_scale := scale(view)
	view.x = math.round((view.window_width - view.canvas_width * current_scale) * 0.5)
	view.y = math.round((view.window_height - view.canvas_height * current_scale) * 0.5)
}

actual_size :: proc(view: ^View) {
	assert(view != nil && view.initialized)
	view.zoom_index = ACTUAL_SIZE_INDEX
	center(view)
}

resize :: proc(view: ^View, window_width, window_height: f32) {
	assert(view != nil && view.initialized)
	// Keep the same canvas point under the center of the resized window.
	view.x += (window_width - view.window_width) * 0.5
	view.y += (window_height - view.window_height) * 0.5
	view.window_width = window_width
	view.window_height = window_height
	constrain(view)
}

constrain :: proc(view: ^View) {
	assert(view != nil && view.initialized)
	bounds := viewport(view)
	visible_x := min(MIN_VISIBLE_PIXELS, bounds.width)
	visible_y := min(MIN_VISIBLE_PIXELS, bounds.height)
	view.x = clamp(view.x, visible_x - bounds.width, view.window_width - visible_x)
	view.y = clamp(view.y, visible_y - bounds.height, view.window_height - visible_y)
}

pan :: proc(view: ^View, delta_x, delta_y: f32) {
	assert(view != nil && view.initialized)
	view.x += delta_x
	view.y += delta_y
	constrain(view)
}

zoom_at :: proc(view: ^View, direction: int, screen_x, screen_y: f32) -> bool {
	assert(view != nil && view.initialized)
	if direction == 0 {
		return false
	}

	old_index := view.zoom_index
	view.zoom_index = clamp(view.zoom_index + (1 if direction > 0 else -1), 0, len(ZOOM_LEVELS) - 1)
	if view.zoom_index == old_index {
		return false
	}

	old_scale := ZOOM_LEVELS[old_index]
	old_bounds := viewport(view)
	new_scale := scale(view)
	world_x := (screen_x - old_bounds.x) / old_scale
	world_y := (screen_y - old_bounds.y) / old_scale
	view.x = screen_x - world_x * new_scale
	view.y = screen_y - world_y * new_scale
	constrain(view)
	return true
}

screen_to_canvas :: proc(view: ^View, x, y: f32) -> (canvas_x, canvas_y: int, inside: bool) {
	assert(view != nil && view.initialized)
	bounds := viewport(view)
	if x < bounds.x || x >= bounds.x + bounds.width || y < bounds.y || y >= bounds.y + bounds.height {
		return 0, 0, false
	}
	return int((x - bounds.x) / scale(view)), int((y - bounds.y) / scale(view)), true
}
