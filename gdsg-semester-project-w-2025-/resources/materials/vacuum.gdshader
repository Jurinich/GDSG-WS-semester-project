shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_count = 10.0;
uniform float line_width = 0.015;
uniform float min_line_length = 0.2;
uniform float max_line_length = 0.5;
uniform float curve_strength = 0.1;
uniform float speed = 35.0;
uniform float line_spacing_jitter = 0.3;

float rand(float n) {
	return fract(sin(n * 43758.5453) * 43758.5453);
}

float line_shape(float y, float target_y) {
	float d = abs(y - target_y);
	return 1.0 - smoothstep(0.0, line_width, d);
}

void fragment() {
	vec2 uv = UV;
	float time = TIME * speed;
	float alpha = 0.0;

	for (float i = 0.0; i < line_count; i++)
	{
		float start_y = i / max(line_count - 1.0, 1.0);

		start_y += (rand(i) - 0.5) * line_spacing_jitter;
		start_y = clamp(start_y, 0.0, 1.0);

		float end_y = mix(0.25, 0.75, i / max(line_count - 1.0, 1.0));

		float curve = smoothstep(0.0, 1.0, uv.x);
		float inward = sin(curve * PI);
		
		float line_y = mix(start_y, end_y, curve);

		line_y += (0.5 - line_y) * inward * curve_strength;

		float offset = fract(time * 0.1 * sign(speed) + i / line_count);
		float x_position = fract((sign(speed) > 0.0) ? offset : 1.0 - offset);

		float x_fade = smoothstep(0.0, 0.15, uv.x) * smoothstep(1.0, 0.65, uv.x);

		float distance_x = abs(uv.x - x_position);
		
		float life = fract(time * 0.1 + i / line_count);
		float cycle = floor(time * 0.1 + i / line_count);

		float individual_length = mix(
			min_line_length,
			max_line_length,
			rand(floor(time * 0.1) + i * 10.0)
		);

		float streak = 1.0 - smoothstep(0.0, individual_length, distance_x);

		alpha += line_shape(uv.y, line_y) * streak * x_fade;
	}

	alpha = clamp(alpha, 0.0, 1.0);

	COLOR = vec4(line_color.rgb, line_color.a * alpha);
}