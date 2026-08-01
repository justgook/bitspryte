package overlay

import drawing "../../drawing"
import cpu_framebuffer "../../render/cpu_framebuffer"
import sg "../../sokol/gfx"

Overlay :: struct {
	framebuffer: cpu_framebuffer.Framebuffer,
}

Line_Context :: struct {
	overlay: ^Overlay,
	color:   cpu_framebuffer.Pixel,
}

init :: proc(overlay: ^Overlay, width, height: int, allocator := context.allocator) -> bool {
	assert(overlay != nil)
	return cpu_framebuffer.init(&overlay.framebuffer, width, height, allocator)
}

deinit :: proc(overlay: ^Overlay) {
	if overlay == nil {
		return
	}
	cpu_framebuffer.deinit(&overlay.framebuffer)
}

clear :: proc(overlay: ^Overlay) {
	assert(overlay != nil)
	cpu_framebuffer.clear(&overlay.framebuffer, cpu_framebuffer.Pixel(0))
}

plot_line_pixel :: proc(point: drawing.Point, user_data: rawptr) {
	line := cast(^Line_Context)user_data
	cpu_framebuffer.put_pixel(&line.overlay.framebuffer, point.x, point.y, line.color)
}

redraw_line :: proc(overlay: ^Overlay, from, to: drawing.Point, color: cpu_framebuffer.Pixel) {
	assert(overlay != nil)
	clear(overlay)
	line := Line_Context {
		overlay = overlay,
		color   = color,
	}
	drawing.raster_line(from, to, plot_line_pixel, &line)
}

upload_if_dirty :: proc(overlay: ^Overlay) -> bool {
	assert(overlay != nil)
	return cpu_framebuffer.upload_if_dirty(&overlay.framebuffer)
}

texture :: proc(overlay: ^Overlay) -> (sg.View, sg.Sampler) {
	assert(overlay != nil)
	return cpu_framebuffer.texture(&overlay.framebuffer)
}
