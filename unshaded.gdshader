shader_type spatial;

render_mode unshaded;
varying vec4 col;
void vertex() {
	col = COLOR;
}

void fragment() {
	ALPHA = col.a;
	ALBEDO = col.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
