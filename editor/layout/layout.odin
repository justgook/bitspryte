package layout

import smgui "../../vendor/smgui/smgui"

TOP_HEIGHT :: 32
STATUS_HEIGHT :: 24

Canvas_Region :: struct {
	x, y:          int,
	width, height: int,
}

Layout :: struct {
	forms:           [7]smgui.Form,
	home_requested:  bool,
	clear_requested: bool,
}

TEXTS := [?]string{"BitSpryte", "BitSpryte", "Home", "Clear", "160 × 120 canvas"}

init :: proc(layout: ^Layout, width, height: int) {
	assert(layout != nil)
	layout^ = {}
	layout.forms = {
		{
			kind = .Custom,
			x = smgui.absolute(0),
			y = smgui.absolute(0),
			width_percentage = 100,
			height = TOP_HEIGHT,
			background = 0xff242936,
			custom = {view = draw_background},
		},
		{kind = .Label, x = smgui.absolute(10), y = smgui.absolute(8), label = 1},
		{kind = .Button, x = smgui.absolute(120), y = smgui.absolute(5), width = 58, height = 22, label = 2},
		{kind = .Button, x = smgui.absolute(184), y = smgui.absolute(5), width = 58, height = 22, label = 3},
		{
			kind = .Custom,
			x = smgui.absolute(0),
			y = smgui.absolute(TOP_HEIGHT),
			width_percentage = 100,
			height_percentage = 100,
			height = -(TOP_HEIGHT + STATUS_HEIGHT),
		},
		{
			kind = .Custom,
			x = smgui.absolute(0),
			width_percentage = 100,
			height = STATUS_HEIGHT,
			background = 0xff242936,
			custom = {view = draw_background},
		},
		{kind = .Label, x = smgui.absolute(10), label = 4},
	}
	layout.forms[2].binding = smgui.bind(&layout.home_requested)
	layout.forms[3].binding = smgui.bind(&layout.clear_requested)
	resize(layout, width, height)
}

resize :: proc(layout: ^Layout, width, height: int) {
	assert(layout != nil)
	_ = width
	status_y := max(height - STATUS_HEIGHT, TOP_HEIGHT)
	layout.forms[5].y = smgui.absolute(status_y)
	layout.forms[6].y = smgui.absolute(status_y + 6)
}

forms :: proc(layout: ^Layout) -> []smgui.Form {
	assert(layout != nil)
	return layout.forms[:]
}

canvas_region :: proc(layout: ^Layout) -> Canvas_Region {
	assert(layout != nil)
	field := &layout.forms[4]
	return {x = field.computed_x, y = field.computed_y, width = field.computed_width, height = field.computed_height}
}

@(private = "file")
draw_background :: proc(ctx: ^smgui.Context, x, y, width, height: int, form: ^smgui.Form) -> smgui.Error {
	if ctx == nil || form == nil {return .Invalid_Input}
	color := form.background
	for row in max(y, ctx.clip_y0) ..< min(y + height, ctx.clip_y1) {
		for column in max(x, ctx.clip_x0) ..< min(x + width, ctx.clip_x1) {
			pixel := row * ctx.screen.pitch + column * 4
			ctx.screen.pixels[pixel + 0] = u8(color)
			ctx.screen.pixels[pixel + 1] = u8(color >> 8)
			ctx.screen.pixels[pixel + 2] = u8(color >> 16)
			ctx.screen.pixels[pixel + 3] = u8(color >> 24)
		}
	}
	return .None
}
