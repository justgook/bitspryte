package cpu_framebuffer

import sfb "../../sokol/framebuffer"
import sg "../../sokol/gfx"
import slog "../../sokol/log"
import "core:c"
import "core:mem"

// Pixel is an RGBA8 color packed as 0xAABBGGRR, as expected by sokol_framebuffer.
Pixel :: distinct u32

Framebuffer :: struct {
	pixels:      []Pixel,
	width:       int,
	height:      int,
	handle:      sfb.Framebuffer,
	allocator:   mem.Allocator,
	dirty:       bool,
	initialized: bool,
}

setup :: proc(max_framebuffers: int = 8) {
	sfb.setup({framebuffer_pool_size = i32(max_framebuffers + 1), logger = {func = slog.func}})
}

shutdown :: proc() {
	sfb.shutdown()
}

init :: proc(framebuffer: ^Framebuffer, width, height: int, allocator := context.allocator) -> bool {
	assert(framebuffer != nil)
	assert(!framebuffer.initialized)
	assert(width > 0 && height > 0)

	framebuffer^ = {
		pixels      = make([]Pixel, width * height, allocator),
		width       = width,
		height      = height,
		allocator   = allocator,
		dirty       = true,
		initialized = true,
	}
	framebuffer.handle = sfb.make_framebuffer({width = i32(width), height = i32(height), format = .RGBA8})

	if sfb.query_framebuffer_state(framebuffer.handle) != .VALID {
		deinit(framebuffer)
		return false
	}
	return true
}

deinit :: proc(framebuffer: ^Framebuffer) {
	if framebuffer == nil || !framebuffer.initialized {
		return
	}

	if framebuffer.handle.id != sfb.INVALID_ID {
		sfb.destroy_framebuffer(framebuffer.handle)
	}
	delete(framebuffer.pixels, framebuffer.allocator)
	framebuffer^ = {}
}

rgba :: proc(red, green, blue: u8, alpha: u8 = 255) -> Pixel {
	return Pixel(u32(red) | u32(green) << 8 | u32(blue) << 16 | u32(alpha) << 24)
}

clear :: proc(framebuffer: ^Framebuffer, color: Pixel) {
	assert(framebuffer != nil && framebuffer.initialized)
	for &pixel in framebuffer.pixels {
		pixel = color
	}
	framebuffer.dirty = true
}

put_pixel :: proc(framebuffer: ^Framebuffer, x, y: int, color: Pixel) -> bool {
	assert(framebuffer != nil && framebuffer.initialized)
	if x < 0 || x >= framebuffer.width || y < 0 || y >= framebuffer.height {
		return false
	}

	index := y * framebuffer.width + x
	if framebuffer.pixels[index] != color {
		framebuffer.pixels[index] = color
		framebuffer.dirty = true
	}
	return true
}

pixel :: proc(framebuffer: ^Framebuffer, x, y: int) -> (Pixel, bool) {
	assert(framebuffer != nil && framebuffer.initialized)
	if x < 0 || x >= framebuffer.width || y < 0 || y >= framebuffer.height {
		return 0, false
	}
	return framebuffer.pixels[y * framebuffer.width + x], true
}

// pixels_mut returns writable CPU storage and marks it dirty preemptively.
pixels_mut :: proc(framebuffer: ^Framebuffer) -> []Pixel {
	assert(framebuffer != nil && framebuffer.initialized)
	framebuffer.dirty = true
	return framebuffer.pixels
}

mark_dirty :: proc(framebuffer: ^Framebuffer) {
	assert(framebuffer != nil && framebuffer.initialized)
	framebuffer.dirty = true
}

// upload_if_dirty must be called outside a Sokol render pass, at most once per frame.
upload_if_dirty :: proc(framebuffer: ^Framebuffer) -> bool {
	assert(framebuffer != nil && framebuffer.initialized)
	if !framebuffer.dirty {
		return false
	}

	sfb.update(
		framebuffer.handle,
		{pixels = {ptr = raw_data(framebuffer.pixels), size = c.size_t(len(framebuffer.pixels) * size_of(Pixel))}},
	)
	framebuffer.dirty = false
	return true
}

// render draws into the current Sokol pass and viewport. The caller owns pass ordering.
render :: proc(framebuffer: ^Framebuffer, nearest_filter := true) {
	assert(framebuffer != nil && framebuffer.initialized)
	sfb.render_ex(framebuffer.handle, {use_nearest_filter = nearest_filter})
}

// texture returns the resolved framebuffer texture and its nearest-neighbor sampler.
// It is valid after upload_if_dirty and can be consumed by custom compositors.
texture :: proc(framebuffer: ^Framebuffer) -> (sg.View, sg.Sampler) {
	assert(framebuffer != nil && framebuffer.initialized)
	info := sfb.query_framebuffer_info(framebuffer.handle)
	return info.offscreen.tex_view, info.nearest_sampler
}

size :: proc(framebuffer: ^Framebuffer) -> (width, height: int) {
	assert(framebuffer != nil && framebuffer.initialized)
	return framebuffer.width, framebuffer.height
}
