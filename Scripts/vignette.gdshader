shader_type canvas_item;

uniform float inner_radius = 0.0;
uniform float outer_radius = 1.0;
uniform vec4  color : source_color = vec4(0.0, 0.0, 0.0, 0.2);

void fragment() {
	float x = abs(UV.x - 0.5) * 2.0;
	float y = abs(UV.y - 0.5) * 2.0;

	float q = 1.0 - (1.0 - sqrt(x * x + y * y) / outer_radius)
	                    / (1.0 - inner_radius);

	q = clamp(q, 0.0, 1.0);

	float alpha = q * color.a;
	COLOR = vec4(color.rgb * alpha, alpha);
}
