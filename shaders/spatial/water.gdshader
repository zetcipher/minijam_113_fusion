shader_type spatial; // I just stole this shader from: https://docs.godotengine.org/en/latest/tutorials/shaders/your_first_shader/your_second_3d_shader.html

render_mode specular_toon, diffuse_toon;

uniform vec4 color : source_color = vec4(0.2, 0.5, 1.0, 1.0);
uniform float displacement = 0.25;
uniform float ripple_speed = 1.0;
//uniform vec2 offset = vec2(0.0,0.0);

uniform sampler2D noise;
uniform sampler2D normalmap;

varying vec2 tex_pos;

float wave(vec2 position){
  position += texture(noise, position / 10.0).x * 2.0 - 1.0;
  vec2 wv = 1.0 - abs(sin(position));
  return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 position, float time) {
  float d = wave((position + time) * 0.4) * 0.3;
  d += wave((position - time) * 0.3) * 0.3;
  d += wave((position + time) * 0.5) * 0.2;
  d += wave((position - time) * 0.6) * 0.2;
  return d * displacement;
}

void vertex() {
	//VERTEX.y += (displacement * sin((VERTEX.x + offset.x) + (VERTEX.z + offset.y))) - displacement * 0.5;
	tex_pos = VERTEX.xz / 2.0 + 0.5;
	vec2 pos = VERTEX.xz;
	float k = height(pos, TIME * ripple_speed);
	VERTEX.y = k;
	NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME * ripple_speed)));
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 1.0;
	METALLIC = 0.0;
	ROUGHNESS = 0.01;
	//NORMAL_MAP = texture(normalmap, tex_pos).xyz;
	ALBEDO = color.rgb + (0.1 * fresnel);
	ALPHA = color.a;
}
