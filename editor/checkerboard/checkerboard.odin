package checkerboard

import cpu_framebuffer "../../render/cpu_framebuffer"

Config :: struct {
	cell_width:  int,
	cell_height: int,
	color_a:     cpu_framebuffer.Pixel,
	color_b:     cpu_framebuffer.Pixel,
}

default_config :: proc() -> Config {
	return {
		cell_width = 16,
		cell_height = 16,
		color_a = cpu_framebuffer.rgba(0x80, 0x80, 0x80),
		color_b = cpu_framebuffer.rgba(0xc0, 0xc0, 0xc0),
	}
}

color_at :: proc(config: Config, x, y: int) -> cpu_framebuffer.Pixel {
	assert(config.cell_width > 0 && config.cell_height > 0)
	cell_x := x / config.cell_width
	cell_y := y / config.cell_height
	return config.color_a if (cell_x + cell_y) % 2 == 0 else config.color_b
}

fill :: proc(framebuffer: ^cpu_framebuffer.Framebuffer, config: Config) {
	assert(framebuffer != nil)
	assert(config.cell_width > 0 && config.cell_height > 0)

	width, height := cpu_framebuffer.size(framebuffer)
	pixels := cpu_framebuffer.pixels_mut(framebuffer)
	for y in 0 ..< height {
		for x in 0 ..< width {
			pixels[y * width + x] = color_at(config, x, y)
		}
	}
}
