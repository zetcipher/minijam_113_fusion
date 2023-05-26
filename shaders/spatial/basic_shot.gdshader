shader_type spatial;

uniform vec4 dark_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 bright_color : source_color = vec4(1.0);
uniform float intensity = 1.0;

void fragment() {
	ALBEDO = ((dark_color.rgb * vec3(intensity)) + vec3(bright_color.r * UV.x, bright_color.g * UV.x, bright_color.b * UV.x));
}
