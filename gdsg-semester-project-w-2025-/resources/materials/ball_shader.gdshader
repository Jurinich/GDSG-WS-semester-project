shader_type canvas_item;

uniform sampler2D tile_texture : source_color;
uniform sampler2D mask_texture : source_color;

uniform vec2 tiling = vec2(1.0);
uniform float fisheye_strength = 2.0;
uniform float strech_speed_min = 500.0;
uniform float strech_speed_max = 1000.0;
uniform float stretch_amount = 0.25;

uniform vec2 tile_offset = vec2(0.0);
uniform vec2 velocity = vec2(0.0, 0.0);

float get_stretch_factor() {
	float speed = length(velocity);
	float speed_diff = speed - strech_speed_min;
	return clamp(speed_diff / (strech_speed_max - strech_speed_min), 0.0, 1.0);
}

void vertex() {
	vec2 direction = normalize(velocity);
	float stretch_factor = get_stretch_factor();
	if (stretch_factor > 0.0) {
		float stretch = 1.0 + stretch_factor * stretch_amount;
		
		vec2 up = vec2(-direction.y, direction.x);
		float x = dot(VERTEX, direction);
		float y = dot(VERTEX, up);
		x *= stretch;

		VERTEX = direction * x + up * y;
	}
}

vec2 fisheye(vec2 uv) {
	vec2 centered = uv - vec2(0.5);
	
	float r = length(centered);
	float factor = 1.0 + fisheye_strength * r * r;
	centered *= factor;
	return centered + vec2(0.5);
}

void fragment() {
	vec4 overlay = texture(TEXTURE, UV);
	float mask = texture(mask_texture, UV).r;
	
	vec2 tile_uv = fisheye(UV) + tile_offset;
	vec4 color = vec4(0.0);
	
	float stretch_factor = get_stretch_factor();
	if (stretch_factor > 0.0) {
		vec2 direction = normalize(velocity);
		vec2 pixel_dir = direction * TEXTURE_PIXEL_SIZE * stretch_factor * 30.0;
		
		int samples = 8;
		for (int i = 0; i < samples; i++) {
			float t = float(i) / float(samples) - 0.5;
			vec2 sample_uv = fisheye(UV + pixel_dir * t) + tile_offset;
			color += texture(tile_texture, fract(sample_uv * tiling));
		}
		color /= float(samples);
	} else {
		color = texture(tile_texture, fract(tile_uv * tiling));
	}
	
	color.a *= step(0.5, mask);
	if (color.a > 0.0) {
		COLOR = mix(color, overlay, overlay.a);
	} else {
		COLOR = overlay;
	}
}
