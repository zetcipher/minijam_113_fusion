shader_type spatial;

render_mode unshaded;

uniform bool on = false;
uniform vec4 off_color : source_color = vec4(0.25, 0.0, 0.0, 1.0);
uniform vec4 on_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	if (on) {ALBEDO = on_color.rgb;}
	else {ALBEDO = off_color.rgb;}
}
