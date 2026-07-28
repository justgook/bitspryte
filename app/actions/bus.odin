package actions

Bus :: struct {
	pending: [dynamic]Action,
}

post :: proc(bus: ^Bus, action: Action) {
	append(&bus.pending, action)
}

items :: proc(bus: ^Bus) -> []Action {
	return bus.pending[:]
}

reset :: proc(bus: ^Bus) {
	clear(&bus.pending)
}

destroy :: proc(bus: ^Bus) {
	delete(bus.pending)
	bus^ = {}
}
