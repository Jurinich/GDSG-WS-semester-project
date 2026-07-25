shader_type canvas_item;

uniform sampler2D tile_texture : source_color;
uniform sampler2D mask_texture : source_color;

uniform float sphere_scale = 0.8;
uniform float offset_radius = 0.2;
uniform float alpha_modifier = 1.0;

uniform float texture_rotation = 0.0;
uniform float offset = 0.0;

float wrap_offset(float x) {
	return mod(x + offset_radius, offset_radius * 2.0) - offset_radius;
}

vec2 sphere_uv(vec2 uv) {
	uv = (uv - vec2(0.5)) / sphere_scale + vec2(0.5);
	vec2 p = uv * 2.0 - 1.0;
	float r2 = dot(p, p);
	
	if (r2 > 1.0)
		return vec2(-1.0);
	
	float z = sqrt(1.0 - r2);
	float lon = atan(p.x, z);
	float lat = asin(p.y);
	
	return vec2(lon / (2.0 * PI) + 0.5, lat / PI + 0.5);
}

vec2 rotate_uv(vec2 uv, float angle) {
	vec2 center = vec2(0.5);
	uv -= center;
	
	float s = sin(angle);
	float c = cos(angle);
	
	uv = vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
	return uv + center;
}

vec2 rotate_vec2(vec2 v, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

void fragment() {
	vec4 overlay = texture(TEXTURE, UV);
	float mask = texture(mask_texture, UV).r;
	
	vec2 tile_uv = sphere_uv(rotate_uv(UV, texture_rotation));
	tile_uv.x += wrap_offset(offset);
	vec4 color = texture(tile_texture, fract(tile_uv));
	
	color.a *= step(0.5, mask) * alpha_modifier;
	if (color.a > 0.0) {
		COLOR = mix(color, overlay, overlay.a);
	} else {
		COLOR = overlay;
	}
}
