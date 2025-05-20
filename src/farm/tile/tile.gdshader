shader_type canvas_item;
uniform vec2 push;
uniform bool corrupted;

void vertex() {
	float mult = VERTEX.y / 16.0;
	VERTEX += push * vec2(mult, mult);
}

void fragment() {
	// Called for every pixel the material is visible on.
	if(corrupted) {
		vec4 color = texture(TEXTURE, UV);
		COLOR = vec4(1.0 - color.rgb, color.a);
	}
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
