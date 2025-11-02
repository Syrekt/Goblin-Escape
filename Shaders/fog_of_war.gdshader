shader_type canvas_item;

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	t.a -= t.r;
	COLOR = t;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
