package events_test

import events "../../app/events"
import "core:testing"

Counter :: struct {
	count: int,
	last:  events.Event,
}

count_event :: proc(event: events.Event, user_data: rawptr) {
	counter := cast(^Counter)user_data
	counter.count += 1
	counter.last = event
}

Nested_Publisher :: struct {
	bus: ^events.Bus,
}

publish_cleared :: proc(event: events.Event, user_data: rawptr) {
	state := cast(^Nested_Publisher)user_data
	events.publish(state.bus, events.make(.Canvas_Cleared, event.source))
}

@(test)
test_publish_notifies_matching_and_any_subscribers :: proc(t: ^testing.T) {
	bus: events.Bus
	defer events.destroy(&bus)
	matching, unrelated, all: Counter

	events.subscribe(&bus, .Canvas_Changed, count_event, &matching)
	events.subscribe(&bus, .Canvas_Cleared, count_event, &unrelated)
	events.subscribe(&bus, .Any, count_event, &all)
	event := events.make(.Canvas_Changed, .Native_Menu)
	events.publish(&bus, event)

	testing.expect(t, matching.count == 1)
	testing.expect(t, matching.last == event)
	testing.expect(t, unrelated.count == 0)
	testing.expect(t, all.count == 1)
}

@(test)
test_unsubscribe_stops_delivery :: proc(t: ^testing.T) {
	bus: events.Bus
	defer events.destroy(&bus)
	counter: Counter

	subscription := events.subscribe(&bus, .Canvas_Changed, count_event, &counter)
	testing.expect(t, events.unsubscribe(&bus, subscription))
	testing.expect(t, !events.unsubscribe(&bus, subscription))
	events.publish(&bus, events.make(.Canvas_Changed))

	testing.expect(t, counter.count == 0)
}

@(test)
test_subscriber_can_publish_a_followup_fact :: proc(t: ^testing.T) {
	bus: events.Bus
	defer events.destroy(&bus)
	publisher := Nested_Publisher {
		bus = &bus,
	}
	facts: Counter

	events.subscribe(&bus, .Canvas_Changed, publish_cleared, &publisher)
	events.subscribe(&bus, .Canvas_Cleared, count_event, &facts)
	events.publish(&bus, events.make(.Canvas_Changed, .Native_Menu))

	testing.expect(t, facts.count == 1)
	testing.expect(t, facts.last.kind == .Canvas_Cleared)
	testing.expect(t, facts.last.source == .Native_Menu)
}
