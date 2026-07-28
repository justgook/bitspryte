package actions

Action :: struct {
	kind:      Kind,
	source:    Source,
	int_value: i32,
}

make :: proc(kind: Kind, source := Source.Application) -> Action {
	return Action{kind = kind, source = source}
}

set_theme :: proc(theme: i32, source := Source.User_Interface) -> Action {
	return Action{kind = .Set_Theme, source = source, int_value = theme}
}
