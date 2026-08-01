package checkerboard_test

import checkerboard "../../editor/checkerboard"
import cpu_framebuffer "../../render/cpu_framebuffer"
import "core:testing"

@(test)
test_default_checkerboard_uses_sixteen_pixel_gray_cells :: proc(t: ^testing.T) {
	config := checkerboard.default_config()
	dark := cpu_framebuffer.rgba(0x80, 0x80, 0x80)
	light := cpu_framebuffer.rgba(0xc0, 0xc0, 0xc0)

	testing.expect(t, config.cell_width == 16)
	testing.expect(t, config.cell_height == 16)
	testing.expect(t, checkerboard.color_at(config, 0, 0) == dark)
	testing.expect(t, checkerboard.color_at(config, 15, 15) == dark)
	testing.expect(t, checkerboard.color_at(config, 16, 0) == light)
	testing.expect(t, checkerboard.color_at(config, 0, 16) == light)
	testing.expect(t, checkerboard.color_at(config, 16, 16) == dark)
}
