package events

// Kind is the canonical registry of application requests and facts.
// Requested values are commands; past-tense values describe completed work.
Kind :: enum {
	Any,
	Open_Settings_Requested,
	Export_PNG_Requested,
	Clear_Canvas_Requested,
	Canvas_Cleared,
	Canvas_Changed,
}

Source :: enum {
	Application,
	Keyboard,
	Native_Menu,
	Pointer,
	User_Interface,
	Script,
}

Event :: struct {
	kind:      Kind,
	source:    Source,
	int_value: i32,
}

make :: proc(kind: Kind, source := Source.Application) -> Event {
	assert(kind != .Any, "Any is a subscription filter, not a publishable event")
	return {kind = kind, source = source}
}
