package main

import actions "./app/actions"
import events "./app/events"
import drawing "./drawing"
import canvas_view "./editor/canvas_view"
import checkerboard "./editor/checkerboard"
import overlay "./editor/overlay"
import canvas_gesture "./platform/canvas_gesture"
import native_menu "./platform/native_menu"
import compositor "./render/compositor"
import cpu_framebuffer "./render/cpu_framebuffer"
import runtime "base:runtime"
import "core:math"
import sapp "sokol/app"
import sg "sokol/gfx"
import sglue "sokol/glue"
import slog "sokol/log"

WINDOW_WIDTH :: 960
WINDOW_HEIGHT :: 720
WINDOW_TITLE :: "BitSpryte"
CANVAS_WIDTH :: 160
CANVAS_HEIGHT :: 120

SCROLL_PAN_PIXELS :: f32(32)
PINCH_SCALE_THRESHOLD :: f32(1.1)

Touch_Pinch :: struct {
	active:            bool,
	previous_distance: f32,
	previous_x:        f32,
	previous_y:        f32,
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
action_bus: actions.Bus
event_bus: events.Bus
view: canvas_view.View
touch_pinch: Touch_Pinch

sync_view_size :: proc() {
	width := sapp.widthf()
	height := sapp.heightf()
	if width != view.window_width || height != view.window_height {
		canvas_view.resize(&view, width, height)
	}
}

canvas_viewport :: proc() -> canvas_view.Viewport {
	return canvas_view.viewport(&view)
}

clear_canvas_requested :: proc(action: actions.Action, _: rawptr) {
	checkerboard.fill(&canvas, checkerboard_config)
	overlay.clear(&preview_overlay)
	drawing.reset_stroke(&paint_stroke)
	drawing.cancel_line_preview(&line_preview)
	events.publish(&event_bus, events.make(.Canvas_Cleared, action.source))
}

actual_size_requested :: proc(_: actions.Action, _: rawptr) {
	canvas_view.actual_size(&view)
}

dispatch_native_menu :: proc() {
	kind := native_menu.take_action()
	if kind != .None {
		actions.publish(&action_bus, actions.make(kind, .Native_Menu))
	}
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
	canvas_view.init(&view, CANVAS_WIDTH, CANVAS_HEIGHT, sapp.widthf(), sapp.heightf())
	actions.subscribe(&action_bus, .Clear, clear_canvas_requested)
	actions.subscribe(&action_bus, .View_Home, actual_size_requested)
	native_menu.install()
	canvas_gesture.install()
}

frame :: proc "c" () {
	context = runtime.default_context()

	dispatch_native_menu()
	sync_view_size()
	gesture := canvas_gesture.take()
	if gesture.steps != 0 {
		direction := 1 if gesture.steps > 0 else -1
		for _ in 0 ..< abs(gesture.steps) {
			canvas_view.zoom_at(&view, direction, gesture.x, gesture.y)
		}
	}
	cpu_framebuffer.upload_if_dirty(&canvas)
	overlay.upload_if_dirty(&preview_overlay)

	pass := sg.Pass {
		action = {colors = {0 = {load_action = .CLEAR, clear_value = {0.055, 0.071, 0.102, 1.0}}}},
		swapchain = sglue.swapchain(),
	}

	sg.begin_pass(pass)
	viewport := canvas_viewport()
	sg.apply_viewportf(viewport.x, viewport.y, viewport.width, viewport.height, true)
	sg.apply_scissor_rectf(0, 0, sapp.widthf(), sapp.heightf(), true)
	cpu_framebuffer.render(&canvas)
	preview_view, preview_sampler := overlay.texture(&preview_overlay)
	compositor.draw(&texture_compositor, preview_view, preview_sampler, 0.75)
	sg.end_pass()
	sg.commit()
}

cleanup :: proc "c" () {
	context = runtime.default_context()

	actions.destroy(&action_bus)
	events.destroy(&event_bus)
	compositor.shutdown(&texture_compositor)
	overlay.deinit(&preview_overlay)
	cpu_framebuffer.deinit(&canvas)
	cpu_framebuffer.shutdown()
	sg.shutdown()
}

screen_to_canvas :: proc(x, y: f32) -> (drawing.Point, bool) {
	canvas_x, canvas_y, inside := canvas_view.screen_to_canvas(&view, x, y)
	return {canvas_x, canvas_y}, inside
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

update_touch_pinch :: proc(event: ^sapp.Event) {
	if event.num_touches < 2 {
		touch_pinch.active = false
		return
	}

	first := event.touches[0]
	second := event.touches[1]
	mid_x := (first.pos_x + second.pos_x) * 0.5
	mid_y := (first.pos_y + second.pos_y) * 0.5
	delta_x := second.pos_x - first.pos_x
	delta_y := second.pos_y - first.pos_y
	distance := math.sqrt(delta_x * delta_x + delta_y * delta_y)
	if !touch_pinch.active || distance <= 0 {
		touch_pinch = {true, distance, mid_x, mid_y}
		return
	}

	canvas_view.pan(&view, mid_x - touch_pinch.previous_x, mid_y - touch_pinch.previous_y)
	if distance >= touch_pinch.previous_distance * PINCH_SCALE_THRESHOLD {
		canvas_view.zoom_at(&view, 1, mid_x, mid_y)
		touch_pinch.previous_distance = distance
	} else if distance <= touch_pinch.previous_distance / PINCH_SCALE_THRESHOLD {
		canvas_view.zoom_at(&view, -1, mid_x, mid_y)
		touch_pinch.previous_distance = distance
	}
	touch_pinch.previous_x = mid_x
	touch_pinch.previous_y = mid_y
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
	case .MOUSE_SCROLL:
		if event.modifiers & (sapp.MODIFIER_CTRL | sapp.MODIFIER_SUPER) != 0 {
			if event.scroll_y != 0 {
				canvas_view.zoom_at(&view, 1 if event.scroll_y > 0 else -1, event.mouse_x, event.mouse_y)
			}
		} else {
			canvas_view.pan(&view, event.scroll_x * SCROLL_PAN_PIXELS, event.scroll_y * SCROLL_PAN_PIXELS)
		}

	case .TOUCHES_BEGAN, .TOUCHES_MOVED:
		update_touch_pinch(event)

	case .TOUCHES_ENDED, .TOUCHES_CANCELLED:
		touch_pinch.active = false

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
			events.publish(&event_bus, events.make(.Canvas_Changed, .Pointer))
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
			if drawing.is_active(&paint_stroke) {
				drawing.end_stroke(&paint_stroke)
				events.publish(&event_bus, events.make(.Canvas_Changed, .Pointer))
			}
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
