package native_menu

Action :: enum i32 {
	None,
	Settings,
	Export_PNG,
	Clear_Canvas,
}

when ODIN_OS == .Darwin {
	NATIVE_MENU_LIB :: #config(NATIVE_MENU_LIB, "../../build.nosync/native/libbitspryte_native.a")

	foreign import native_menu {NATIVE_MENU_LIB, "system:Cocoa.framework"}

	@(default_calling_convention = "c")
	foreign native_menu {
		bs_native_menu_install :: proc() ---
		bs_native_menu_take_action :: proc() -> i32 ---
	}

	install :: proc() {
		bs_native_menu_install()
	}

	take_action :: proc() -> Action {
		return Action(bs_native_menu_take_action())
	}
} else {
	install :: proc() {}
	take_action :: proc() -> Action {
		return .None
	}
}
