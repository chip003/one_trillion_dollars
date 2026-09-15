shader_type spatial;

varying vec3 worldPos;

uniform sampler2D displace : repeat_enable, hint_normal, filter_nearest;
uniform sampler2D waveColor : repeat_enable, source_color, filter_nearest;

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 nt = texture(displace, worldPos.xz*.01 + TIME*0.01).rgb;
	NORMAL_MAP = nt;
	ALBEDO = texture(waveColor, (worldPos.xz*.01 + vec2(-0.01, 0.01)*TIME) * nt.r).rgb;

}