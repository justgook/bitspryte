package events

import actions "../actions"

Event :: struct {
	kind:          Kind,
	action_source: actions.Source,
	int_value:     i32,
}

make :: proc(kind: Kind, action_source := actions.Source.Application) -> Event {
	return Event{kind = kind, action_source = action_source}
}
