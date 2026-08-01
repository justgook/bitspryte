package drawing

Point :: struct {
	x, y: int,
}

Plot_Proc :: proc(point: Point, user_data: rawptr)

// Stroke tracks sampled pointer positions independently from any canvas or brush.
Stroke :: struct {
	active:        bool,
	previous:      Point,
	last_endpoint: Point,
	has_endpoint:  bool,
}

// raster_line visits every pixel on an inclusive Bresenham line.
raster_line :: proc(from, to: Point, plot: Plot_Proc, user_data: rawptr = nil) {
	raster_line_internal(from, to, true, plot, user_data)
}

raster_line_internal :: proc(from, to: Point, include_start: bool, plot: Plot_Proc, user_data: rawptr) {
	assert(plot != nil)

	x := from.x
	y := from.y
	delta_x := abs(to.x - from.x)
	step_x := 1 if from.x < to.x else -1
	delta_y := -abs(to.y - from.y)
	step_y := 1 if from.y < to.y else -1
	error := delta_x + delta_y
	first := true

	for {
		if include_start || !first {
			plot({x, y}, user_data)
		}
		first = false
		if x == to.x && y == to.y {
			break
		}

		doubled_error := 2 * error
		if doubled_error >= delta_y {
			error += delta_y
			x += step_x
		}
		if doubled_error <= delta_x {
			error += delta_x
			y += step_y
		}
	}
}

// begin_stroke starts at point. With connect_to_last_endpoint, it draws from the
// endpoint of the previous completed stroke, which provides Shift+click lines.
begin_stroke :: proc(
	stroke: ^Stroke,
	point: Point,
	connect_to_last_endpoint: bool,
	plot: Plot_Proc,
	user_data: rawptr = nil,
) {
	assert(stroke != nil)

	if connect_to_last_endpoint && stroke.has_endpoint {
		raster_line(stroke.last_endpoint, point, plot, user_data)
	} else {
		plot(point, user_data)
	}

	stroke.active = true
	stroke.previous = point
	stroke.last_endpoint = point
	stroke.has_endpoint = true
}

// continue_stroke connects the previous sampled point to the new one. This is
// independent of event frequency, so fast pointer movement cannot leave gaps.
continue_stroke :: proc(stroke: ^Stroke, point: Point, plot: Plot_Proc, user_data: rawptr = nil) {
	assert(stroke != nil)
	if !stroke.active || point == stroke.previous {
		return
	}

	raster_line_internal(stroke.previous, point, false, plot, user_data)
	stroke.previous = point
	stroke.last_endpoint = point
	stroke.has_endpoint = true
}

end_stroke :: proc(stroke: ^Stroke) {
	assert(stroke != nil)
	stroke.active = false
}

is_active :: proc(stroke: ^Stroke) -> bool {
	assert(stroke != nil)
	return stroke.active
}

endpoint :: proc(stroke: ^Stroke) -> (Point, bool) {
	assert(stroke != nil)
	return stroke.last_endpoint, stroke.has_endpoint
}

set_endpoint :: proc(stroke: ^Stroke, point: Point) {
	assert(stroke != nil)
	stroke.active = false
	stroke.last_endpoint = point
	stroke.previous = point
	stroke.has_endpoint = true
}

reset_stroke :: proc(stroke: ^Stroke) {
	assert(stroke != nil)
	stroke^ = {}
}
