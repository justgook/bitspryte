package events

import actions "../actions"

// Kind is the canonical registry of application requests and facts.
// Requested values are commands; past-tense values describe completed work.
Kind :: enum {
	Any,
	Canvas_Cleared,
	Canvas_Changed,
}

Event :: struct {
	kind:      Kind,
	source:    actions.Source,
	int_value: i32,
}

make :: proc(kind: Kind, source := actions.Source.Application) -> Event {
	assert(kind != .Any, "Any is a subscription filter, not a publishable event")
	return {kind = kind, source = source}
}
