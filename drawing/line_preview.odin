package drawing

Line_Preview :: struct {
	active:  bool,
	anchor:  Point,
	current: Point,
}

begin_line_preview :: proc(preview: ^Line_Preview, anchor, current: Point) {
	assert(preview != nil)
	preview^ = {
		active  = true,
		anchor  = anchor,
		current = current,
	}
}

update_line_preview :: proc(preview: ^Line_Preview, current: Point) {
	assert(preview != nil)
	if preview.active {
		preview.current = current
	}
}

commit_line_preview :: proc(preview: ^Line_Preview, plot: Plot_Proc, user_data: rawptr = nil) -> bool {
	assert(preview != nil)
	if !preview.active {
		return false
	}

	raster_line(preview.anchor, preview.current, plot, user_data)
	preview.active = false
	return true
}

// commit_and_continue_line_preview commits the current segment and immediately
// re-anchors the preview at its endpoint for chained Shift+click lines.
commit_and_continue_line_preview :: proc(preview: ^Line_Preview, plot: Plot_Proc, user_data: rawptr = nil) -> bool {
	assert(preview != nil)
	if !preview.active {
		return false
	}

	raster_line(preview.anchor, preview.current, plot, user_data)
	preview.anchor = preview.current
	return true
}

cancel_line_preview :: proc(preview: ^Line_Preview) {
	assert(preview != nil)
	preview.active = false
}

line_preview_active :: proc(preview: ^Line_Preview) -> bool {
	assert(preview != nil)
	return preview.active
}
