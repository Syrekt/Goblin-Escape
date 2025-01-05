shader_type canvas_item;

uniform float flash_intensity : hint_range(0, 1) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (flash_intensity > 0.0) {
        tex_color.rgb = mix(tex_color.rgb, flash_color.rgb, flash_intensity);
    }
    COLOR = tex_color;
}
