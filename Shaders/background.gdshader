shader_type canvas_item;

uniform vec4 color_top    : source_color = vec4(0.75,1.00,0.90, 1.0);
uniform vec4 color_middle : source_color = vec4(0.25,0.80,0.80, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.35,0.70,0.50, 1.0);

uniform float noise_strength = 0.05;
uniform float noise_scale = 12.3;
uniform float time_speed = 1.6;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) +
	       (c - a) * u.y * (1.0 - u.x) +
	       (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = UV;

	// 基础纵向插值
	float t = uv.y;

	// 动态噪声
	float n = noise(uv * noise_scale + vec2(0.0, TIME * time_speed));
	t += (n - 0.5) * noise_strength;

	// 三段渐变
	vec4 color;
	if (t < 0.5) {
		color = mix(color_top, color_middle, t * 2.0);
	} else {
		color = mix(color_middle, color_bottom, (t - 0.5) * 2.0);
	}

	COLOR = color;
}
