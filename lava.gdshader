shader_type spatial;

uniform sampler2D tex : source_color, repeat_enable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 col = texture(tex, UV + TIME*0.01);
	ALBEDO = col.rgb;
	EMISSION = col.rgb*5.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
