package canvas_gesture

import intrinsics "base:intrinsics"
import F "core:sys/darwin/Foundation"
import sapp "../../sokol/app"

Gesture :: struct {
	steps: int,
	x, y: f32,
}

when ODIN_OS == .Darwin {
	MAGNIFICATION_PER_STEP :: 0.04
	pending: Gesture
	magnification_remainder: f64

	magnify :: proc "c" (_: F.id, _: F.SEL, event: ^F.Event) {
		location := F.Event_locationInWindow(event)
		pending.x = f32(location.x)
		pending.y = sapp.heightf() - f32(location.y)
		magnification_remainder += intrinsics.objc_send(f64, event, "magnification")

		for magnification_remainder >= MAGNIFICATION_PER_STEP {
			pending.steps += 1
			magnification_remainder -= MAGNIFICATION_PER_STEP
		}
		for magnification_remainder <= -MAGNIFICATION_PER_STEP {
			pending.steps -= 1
			magnification_remainder += MAGNIFICATION_PER_STEP
		}
	}

	install :: proc() {
		window := F.Application_keyWindow(F.Application_sharedApplication())
		if window == nil {
			return
		}
		view := F.Window_contentView(window)
		if view == nil {
			return
		}
		class := F.object_getClass(auto_cast view)
		F.class_addMethod(class, F.sel_registerName("magnifyWithEvent:"), auto_cast magnify, "v@:@")
	}

	take :: proc() -> Gesture {
		gesture := pending
		pending.steps = 0
		return gesture
	}
} else {
	install :: proc() {}
	take :: proc() -> Gesture {return {}}
}
