package actions

Subscription :: distinct u64
Handler :: proc(action: Action, user_data: rawptr)

Subscriber :: struct {
	id:        Subscription,
	kind:      Kind,
	handler:   Handler,
	user_data: rawptr,
	active:    bool,
}

Bus :: struct {
	subscribers: [dynamic]Subscriber,
	next_id:     u64,
}

// Subscribe with .None to observe every action.
subscribe :: proc(bus: ^Bus, kind: Kind, handler: Handler, user_data: rawptr = nil) -> Subscription {
	assert(bus != nil)
	assert(handler != nil)

	bus.next_id += 1
	id := Subscription(bus.next_id)
	append(&bus.subscribers, Subscriber{id = id, kind = kind, handler = handler, user_data = user_data, active = true})
	return id
}

unsubscribe :: proc(bus: ^Bus, subscription: Subscription) -> bool {
	assert(bus != nil)
	for &subscriber in bus.subscribers {
		if subscriber.active && subscriber.id == subscription {
			subscriber.active = false
			return true
		}
	}
	return false
}

publish :: proc(bus: ^Bus, action: Action) {
	assert(bus != nil)
	assert(action.kind != .None)

	subscriber_count := len(bus.subscribers)
	for index in 0 ..< subscriber_count {
		subscriber := &bus.subscribers[index]
		if subscriber.active && (subscriber.kind == .None || subscriber.kind == action.kind) {
			subscriber.handler(action, subscriber.user_data)
		}
	}
}

destroy :: proc(bus: ^Bus) {
	if bus == nil {
		return
	}
	delete(bus.subscribers)
	bus^ = {}
}
