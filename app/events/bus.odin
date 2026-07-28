package events

Bus :: struct {
	pending: [dynamic]Event,
}

publish :: proc(bus: ^Bus, event: Event) {
	append(&bus.pending, event)
}

items :: proc(bus: ^Bus) -> []Event {
	return bus.pending[:]
}

reset :: proc(bus: ^Bus) {
	clear(&bus.pending)
}

destroy :: proc(bus: ^Bus) {
	delete(bus.pending)
	bus^ = {}
}
