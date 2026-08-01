package native_menu

import actions "../../app/actions"

when ODIN_OS == .Darwin {
	NATIVE_MENU_LIB :: #config(NATIVE_MENU_LIB, "../../build.nosync/native/libbitspryte_native.a")

	foreign import native_menu {NATIVE_MENU_LIB, "system:Cocoa.framework"}

	@(default_calling_convention = "c")
	foreign native_menu {
		bs_native_menu_install :: proc() ---
		bs_native_menu_action_count :: proc() -> i32 ---
		bs_native_menu_take_action :: proc() -> i32 ---
	}

	install :: proc() {
		assert(
			bs_native_menu_action_count() == i32(actions.Kind.Help_About) + 1,
			"native menu action IDs are out of sync",
		)
		bs_native_menu_install()
	}

	take_action :: proc() -> actions.Kind {
		return actions.Kind(bs_native_menu_take_action())
	}
} else {
	install :: proc() {}
	take_action :: proc() -> actions.Kind {
		return .None
	}
}
