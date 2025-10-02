shader_type canvas_item;

uniform float flash_intensity : hint_range(0, 1) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

vec3 overlay(vec3 base, vec3 blend){
	return mix(
		2.0 * base * blend,
		1.0 - 2.0 * (1.0 - base) * (1.0 - blend),
		step(0.5, base)
	);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (flash_intensity > 0.0) {
        tex_color.rgb = mix(tex_color.rgb, flash_color.rgb, flash_intensity);
    }
    COLOR = tex_color;
	// Apply tint to all visible pixels (except alpha = 0)
	if (COLOR.a > 0.0) {
		//COLOR.rgb *= tint_color.rgb;
		//float original_modulation = 1.0 - tint_factor;
		//COLOR.rgb = mix(COLOR.rgb * original_modulation, tint_color.rgb * tint_factor, tint_factor);
		//COLOR.a *= fade;
		vec3 overlay_result = overlay(COLOR.rgb, tint_color.rgb);
		COLOR.rgb = mix(COLOR.rgb, overlay_result, tint_color.a);
		COLOR.a *= alpha;
	}
}
