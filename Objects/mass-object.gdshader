shader_type canvas_item;

uniform vec3 color: source_color;

const vec2 center = vec2(.5, .5);

void fragment() {
	float dist = distance(UV, center);
	COLOR = vec4(color, mix(1., 0., (dist - .35)*7.5));
}
