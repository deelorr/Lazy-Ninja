shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float dissolve_threshold : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float noise = texture(noise_texture, UV).r;

    if (noise > dissolve_threshold) {
        discard;
    } else {
        COLOR = tex_color;
    }
}
