package drawing_test

import drawing "../../drawing"
import "core:testing"

@(test)
test_line_preview_updates_without_plotting_until_commit :: proc(t: ^testing.T) {
	preview: drawing.Line_Preview
	points := make([dynamic]drawing.Point, 0, 8)
	defer delete(points)

	drawing.begin_line_preview(&preview, {1, 2}, {3, 2})
	drawing.update_line_preview(&preview, {5, 2})

	testing.expect(t, len(points) == 0)
	testing.expect(t, preview.anchor == drawing.Point{1, 2})
	testing.expect(t, preview.current == drawing.Point{5, 2})
	testing.expect(t, drawing.commit_line_preview(&preview, collect_point, &points))

	expected := [?]drawing.Point{{1, 2}, {2, 2}, {3, 2}, {4, 2}, {5, 2}}
	expect_points(t, points[:], expected[:])
	testing.expect(t, !drawing.line_preview_active(&preview))
}

@(test)
test_committed_line_preview_can_continue_from_new_endpoint :: proc(t: ^testing.T) {
	preview: drawing.Line_Preview
	points := make([dynamic]drawing.Point, 0, 12)
	defer delete(points)

	drawing.begin_line_preview(&preview, {1, 2}, {4, 2})
	testing.expect(t, drawing.commit_and_continue_line_preview(&preview, collect_point, &points))

	testing.expect(t, drawing.line_preview_active(&preview))
	testing.expect(t, preview.anchor == drawing.Point{4, 2})
	testing.expect(t, preview.current == drawing.Point{4, 2})

	drawing.update_line_preview(&preview, {4, 5})
	testing.expect(t, drawing.commit_and_continue_line_preview(&preview, collect_point, &points))

	expected := [?]drawing.Point{{1, 2}, {2, 2}, {3, 2}, {4, 2}, {4, 2}, {4, 3}, {4, 4}, {4, 5}}
	expect_points(t, points[:], expected[:])
	testing.expect(t, preview.anchor == drawing.Point{4, 5})
}

@(test)
test_cancelled_line_preview_does_not_commit :: proc(t: ^testing.T) {
	preview: drawing.Line_Preview
	points := make([dynamic]drawing.Point, 0, 8)
	defer delete(points)

	drawing.begin_line_preview(&preview, {1, 2}, {5, 2})
	drawing.cancel_line_preview(&preview)

	testing.expect(t, !drawing.commit_line_preview(&preview, collect_point, &points))
	testing.expect(t, len(points) == 0)
}
