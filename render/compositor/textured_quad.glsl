@header package compositor
@header import sg "../../sokol/gfx"

@vs vs
layout(location=0) in vec2 position;
layout(location=1) in vec2 texcoord0;

out vec2 uv;

void main() {
    gl_Position = vec4(position, 0.0, 1.0);
    uv = texcoord0;
}
@end

@fs fs
layout(binding=0) uniform texture2D source_texture;
layout(binding=0) uniform sampler source_sampler;

layout(binding=0) uniform fs_params {
    float opacity;
};

in vec2 uv;
out vec4 frag_color;

void main() {
    vec4 color = texture(sampler2D(source_texture, source_sampler), uv);
    frag_color = vec4(color.rgb, color.a * opacity);
}
@end

@program textured_quad vs fs
