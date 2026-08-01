package events

Subscription :: distinct u64
Handler :: proc(event: Event, user_data: rawptr)

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

// publish synchronously notifies the subscribers that existed when dispatch
// began. Handlers may publish follow-up events or add/remove subscriptions.
publish :: proc(bus: ^Bus, event: Event) {
	assert(bus != nil)
	assert(event.kind != .Any, "Any is a subscription filter, not a publishable event")

	subscriber_count := len(bus.subscribers)
	for index in 0 ..< subscriber_count {
		subscriber := &bus.subscribers[index]
		if subscriber.active && (subscriber.kind == .Any || subscriber.kind == event.kind) {
			subscriber.handler(event, subscriber.user_data)
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
