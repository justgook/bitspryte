package compositor

import sg "../../sokol/gfx"
import "core:c"

Vertex :: struct {
	position: [2]f32,
	uv:       [2]f32,
}

Renderer :: struct {
	pipeline:      sg.Pipeline,
	shader:        sg.Shader,
	vertex_buffer: sg.Buffer,
	initialized:   bool,
}

setup :: proc(renderer: ^Renderer) {
	assert(renderer != nil && !renderer.initialized)

	vertices := [?]Vertex {
		{{-1, -1}, {0, 1}},
		{{1, -1}, {1, 1}},
		{{1, 1}, {1, 0}},
		{{-1, -1}, {0, 1}},
		{{1, 1}, {1, 0}},
		{{-1, 1}, {0, 0}},
	}
	renderer.vertex_buffer = sg.make_buffer(
		{data = {ptr = &vertices, size = c.size_t(size_of(vertices))}, label = "compositor-quad-vertices"},
	)

	renderer.shader = sg.make_shader(textured_quad_shader_desc(sg.query_backend()))
	pipeline_desc := sg.Pipeline_Desc {
		shader = renderer.shader,
		colors = {
			0 = {
				blend = {
					enabled = true,
					src_factor_rgb = .SRC_ALPHA,
					dst_factor_rgb = .ONE_MINUS_SRC_ALPHA,
					src_factor_alpha = .ONE,
					dst_factor_alpha = .ONE_MINUS_SRC_ALPHA,
				},
			},
		},
		label = "alpha-texture-compositor",
	}
	pipeline_desc.layout.attrs[ATTR_textured_quad_position].format = .FLOAT2
	pipeline_desc.layout.attrs[ATTR_textured_quad_texcoord0].format = .FLOAT2
	renderer.pipeline = sg.make_pipeline(pipeline_desc)
	renderer.initialized = true
}

shutdown :: proc(renderer: ^Renderer) {
	if renderer == nil || !renderer.initialized {
		return
	}
	sg.destroy_pipeline(renderer.pipeline)
	sg.destroy_shader(renderer.shader)
	sg.destroy_buffer(renderer.vertex_buffer)
	renderer^ = {}
}

// draw composites a texture over the current render target and viewport.
draw :: proc(renderer: ^Renderer, view: sg.View, sampler: sg.Sampler, opacity: f32 = 1) {
	assert(renderer != nil && renderer.initialized)

	bindings := sg.Bindings{}
	bindings.vertex_buffers[0] = renderer.vertex_buffer
	bindings.views[VIEW_source_texture] = view
	bindings.samplers[SMP_source_sampler] = sampler
	params := Fs_Params {
		opacity = opacity,
	}

	sg.apply_pipeline(renderer.pipeline)
	sg.apply_bindings(bindings)
	sg.apply_uniforms(UB_fs_params, {ptr = &params, size = c.size_t(size_of(params))})
	sg.draw(0, 6, 1)
}
