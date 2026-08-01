package drawing_test

import drawing "../../drawing"
import "core:testing"

Point :: drawing.Point
Stroke :: drawing.Stroke
raster_line :: drawing.raster_line
begin_stroke :: drawing.begin_stroke
continue_stroke :: drawing.continue_stroke
end_stroke :: drawing.end_stroke

collect_point :: proc(point: Point, user_data: rawptr) {
	points := cast(^[dynamic]Point)user_data
	append(points, point)
}

expect_points :: proc(t: ^testing.T, actual, expected: []Point) {
	testing.expectf(t, len(actual) == len(expected), "got %d points, expected %d", len(actual), len(expected))
	for point, index in expected {
		if index >= len(actual) {
			break
		}
		testing.expectf(t, actual[index] == point, "point %d: got %v, expected %v", index, actual[index], point)
	}
}

@(test)
test_raster_line_fills_skipped_horizontal_pixels :: proc(t: ^testing.T) {
	points := make([dynamic]Point, 0, 8)
	defer delete(points)

	raster_line({1, 3}, {6, 3}, collect_point, &points)

	expected := [?]Point{{1, 3}, {2, 3}, {3, 3}, {4, 3}, {5, 3}, {6, 3}}
	expect_points(t, points[:], expected[:])
}

@(test)
test_raster_line_is_connected_for_steep_segments :: proc(t: ^testing.T) {
	points := make([dynamic]Point, 0, 8)
	defer delete(points)

	raster_line({2, 1}, {4, 7}, collect_point, &points)

	testing.expect(t, points[0] == Point{2, 1})
	testing.expect(t, points[len(points) - 1] == Point{4, 7})
	for index in 1 ..< len(points) {
		dx := abs(points[index].x - points[index - 1].x)
		dy := abs(points[index].y - points[index - 1].y)
		testing.expectf(t, dx <= 1 && dy <= 1, "gap between %v and %v", points[index - 1], points[index])
	}
}

@(test)
test_stroke_connects_consecutive_mouse_samples :: proc(t: ^testing.T) {
	points := make([dynamic]Point, 0, 8)
	defer delete(points)
	stroke: Stroke

	begin_stroke(&stroke, {1, 2}, false, collect_point, &points)
	continue_stroke(&stroke, {5, 2}, collect_point, &points)
	end_stroke(&stroke)

	expected := [?]Point{{1, 2}, {2, 2}, {3, 2}, {4, 2}, {5, 2}}
	expect_points(t, points[:], expected[:])
}

@(test)
test_shift_stroke_connects_previous_endpoint_to_new_point :: proc(t: ^testing.T) {
	points := make([dynamic]Point, 0, 8)
	defer delete(points)
	stroke: Stroke

	begin_stroke(&stroke, {1, 4}, false, collect_point, &points)
	end_stroke(&stroke)
	clear(&points)

	begin_stroke(&stroke, {5, 4}, true, collect_point, &points)
	end_stroke(&stroke)

	expected := [?]Point{{1, 4}, {2, 4}, {3, 4}, {4, 4}, {5, 4}}
	expect_points(t, points[:], expected[:])
}
