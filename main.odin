package main

import drawing "./drawing"
import checkerboard "./editor/checkerboard"
import overlay "./editor/overlay"
import compositor "./render/compositor"
import cpu_framebuffer "./render/cpu_framebuffer"
import runtime "base:runtime"
import sapp "sokol/app"
import sg "sokol/gfx"
import sglue "sokol/glue"
import slog "sokol/log"

WINDOW_WIDTH :: 960
WINDOW_HEIGHT :: 720
WINDOW_TITLE :: "BitSpryte"
CANVAS_WIDTH :: 160
CANVAS_HEIGHT :: 120

Viewport :: struct {
	x, y:          f32,
	width, height: f32,
}

canvas: cpu_framebuffer.Framebuffer
preview_overlay: overlay.Overlay
texture_compositor: compositor.Renderer
paint_stroke: drawing.Stroke
line_preview: drawing.Line_Preview
stroke_color: cpu_framebuffer.Pixel
cursor_point: drawing.Point
cursor_inside: bool
shift_held: bool
checkerboard_config: checkerboard.Config

canvas_viewport :: proc() -> Viewport {
	window_width := sapp.widthf()
	window_height := sapp.heightf()
	scale := min(window_width / f32(CANVAS_WIDTH), window_height / f32(CANVAS_HEIGHT))
	if scale >= 1 {
		scale = f32(int(scale))
	}

	width := f32(CANVAS_WIDTH) * scale
	height := f32(CANVAS_HEIGHT) * scale
	return {x = (window_width - width) * 0.5, y = (window_height - height) * 0.5, width = width, height = height}
}

init :: proc "c" () {
	context = runtime.default_context()

	sg.setup({environment = sglue.environment(), logger = {func = slog.func}})
	cpu_framebuffer.setup()
	assert(cpu_framebuffer.init(&canvas, CANVAS_WIDTH, CANVAS_HEIGHT), "failed to create canvas framebuffer")
	assert(overlay.init(&preview_overlay, CANVAS_WIDTH, CANVAS_HEIGHT), "failed to create preview overlay")
	compositor.setup(&texture_compositor)
	overlay.clear(&preview_overlay)

	checkerboard_config = checkerboard.default_config()
	checkerboard.fill(&canvas, checkerboard_config)
}

frame :: proc "c" () {
	context = runtime.default_context()

	cpu_framebuffer.upload_if_dirty(&canvas)
	overlay.upload_if_dirty(&preview_overlay)

	pass := sg.Pass {
		action = {colors = {0 = {load_action = .CLEAR, clear_value = {0.055, 0.071, 0.102, 1.0}}}},
		swapchain = sglue.swapchain(),
	}

	sg.begin_pass(pass)
	viewport := canvas_viewport()
	sg.apply_viewportf(viewport.x, viewport.y, viewport.width, viewport.height, true)
	cpu_framebuffer.render(&canvas)
	preview_view, preview_sampler := overlay.texture(&preview_overlay)
	compositor.draw(&texture_compositor, preview_view, preview_sampler, 0.75)
	sg.end_pass()
	sg.commit()
}

cleanup :: proc "c" () {
	context = runtime.default_context()

	compositor.shutdown(&texture_compositor)
	overlay.deinit(&preview_overlay)
	cpu_framebuffer.deinit(&canvas)
	cpu_framebuffer.shutdown()
	sg.shutdown()
}

screen_to_canvas :: proc(x, y: f32) -> (drawing.Point, bool) {
	viewport := canvas_viewport()
	if x < viewport.x || x >= viewport.x + viewport.width || y < viewport.y || y >= viewport.y + viewport.height {
		return {}, false
	}

	return {
			x = int((x - viewport.x) * f32(CANVAS_WIDTH) / viewport.width),
			y = int((y - viewport.y) * f32(CANVAS_HEIGHT) / viewport.height),
		},
		true
}

plot_canvas_pixel :: proc(point: drawing.Point, _: rawptr) {
	cpu_framebuffer.put_pixel(&canvas, point.x, point.y, stroke_color)
}

shift_key :: proc(key: sapp.Keycode) -> bool {
	return key == .LEFT_SHIFT || key == .RIGHT_SHIFT
}

hide_line_preview :: proc() {
	drawing.cancel_line_preview(&line_preview)
	overlay.clear(&preview_overlay)
}

start_line_preview_at_cursor :: proc() {
	if !shift_held || !cursor_inside || drawing.line_preview_active(&line_preview) {
		return
	}
	anchor, has_anchor := drawing.endpoint(&paint_stroke)
	if !has_anchor {
		return
	}
	drawing.begin_line_preview(&line_preview, anchor, cursor_point)
	overlay.redraw_line(&preview_overlay, anchor, cursor_point, stroke_color)
}

update_cursor :: proc(x, y: f32) {
	cursor_point, cursor_inside = screen_to_canvas(x, y)
}

event :: proc "c" (event: ^sapp.Event) {
	context = runtime.default_context()

	if event.type == .KEY_DOWN && event.key_code == .ESCAPE {
		if drawing.line_preview_active(&line_preview) {
			shift_held = false
			hide_line_preview()
		} else {
			sapp.request_quit()
		}
		return
	}

	#partial switch event.type {
	case .KEY_DOWN:
		if shift_key(event.key_code) && !event.key_repeat {
			shift_held = true
			drawing.end_stroke(&paint_stroke)
			start_line_preview_at_cursor()
		}

	case .KEY_UP:
		if shift_key(event.key_code) {
			shift_held = false
			hide_line_preview()
		}

	case .MOUSE_DOWN:
		if event.mouse_button != .LEFT && event.mouse_button != .RIGHT {
			return
		}
		update_cursor(event.mouse_x, event.mouse_y)
		if !cursor_inside {
			return
		}

		if event.mouse_button == .LEFT {
			stroke_color = cpu_framebuffer.rgba(255, 92, 138)
		} else {
			stroke_color = cpu_framebuffer.rgba(38, 42, 54)
		}

		shift_held = shift_held || event.modifiers & sapp.MODIFIER_SHIFT != 0
		if shift_held {
			if !drawing.line_preview_active(&line_preview) {
				anchor, has_anchor := drawing.endpoint(&paint_stroke)
				if !has_anchor {
					anchor = cursor_point
				}
				drawing.begin_line_preview(&line_preview, anchor, cursor_point)
			} else {
				drawing.update_line_preview(&line_preview, cursor_point)
			}

			drawing.commit_and_continue_line_preview(&line_preview, plot_canvas_pixel)
			drawing.set_endpoint(&paint_stroke, cursor_point)
			overlay.redraw_line(&preview_overlay, cursor_point, cursor_point, stroke_color)
		} else {
			drawing.begin_stroke(&paint_stroke, cursor_point, false, plot_canvas_pixel)
		}

	case .MOUSE_MOVE:
		update_cursor(event.mouse_x, event.mouse_y)
		if !cursor_inside {
			if drawing.line_preview_active(&line_preview) {
				hide_line_preview()
			}
			return
		}

		if shift_held {
			start_line_preview_at_cursor()
			if drawing.line_preview_active(&line_preview) {
				drawing.update_line_preview(&line_preview, cursor_point)
				overlay.redraw_line(&preview_overlay, line_preview.anchor, line_preview.current, stroke_color)
			}
		} else if drawing.is_active(&paint_stroke) {
			drawing.continue_stroke(&paint_stroke, cursor_point, plot_canvas_pixel)
		}

	case .MOUSE_UP:
		if !shift_held && (event.mouse_button == .LEFT || event.mouse_button == .RIGHT) {
			drawing.end_stroke(&paint_stroke)
		}
	}
}

main :: proc() {
	desc := sapp.Desc {
		init_cb = init,
		frame_cb = frame,
		cleanup_cb = cleanup,
		event_cb = event,
		width = WINDOW_WIDTH,
		height = WINDOW_HEIGHT,
		sample_count = 1,
		window_title = WINDOW_TITLE,
		icon = {sokol_default = true},
		logger = {func = slog.func},
	}
	sapp.run(desc)
}
