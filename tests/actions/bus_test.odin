package actions_test

import actions "../../app/actions"
import "core:testing"

Counter :: struct {
	count: int,
	last:  actions.Action,
}

count_action :: proc(action: actions.Action, user_data: rawptr) {
	counter := cast(^Counter)user_data
	counter.count += 1
	counter.last = action
}

@(test)
test_action_bus_routes_specific_and_all_actions :: proc(t: ^testing.T) {
	bus: actions.Bus
	defer actions.destroy(&bus)
	matching, unrelated, all: Counter

	actions.subscribe(&bus, .New_File, count_action, &matching)
	actions.subscribe(&bus, .Save_File, count_action, &unrelated)
	actions.subscribe(&bus, .None, count_action, &all)
	action := actions.make(.New_File, .Native_Menu)
	actions.publish(&bus, action)

	testing.expect(t, matching.count == 1)
	testing.expect(t, matching.last == action)
	testing.expect(t, unrelated.count == 0)
	testing.expect(t, all.count == 1)
}

@(test)
test_action_bus_unsubscribes :: proc(t: ^testing.T) {
	bus: actions.Bus
	defer actions.destroy(&bus)
	counter: Counter

	subscription := actions.subscribe(&bus, .Clear, count_action, &counter)
	testing.expect(t, actions.unsubscribe(&bus, subscription))
	actions.publish(&bus, actions.make(.Clear))

	testing.expect(t, counter.count == 0)
}
