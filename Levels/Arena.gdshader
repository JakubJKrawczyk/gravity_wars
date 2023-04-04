shader_type canvas_item;

uniform vec3 color: source_color = vec3(1, 0, 0);
uniform float distance_from_center = 0.5;
uniform float width = 0.025;
uniform float outer_smoothness = 20.;
uniform float inner_smoothness = 20.;

void fragment() {
	float max_dist = distance_from_center + width;
	float min_dist = distance_from_center - width;
	
	vec3 dist = FRAGCOORD.xyz;
	float alpha = .0;
	vec2 center = vec2(.5, .5);
	if(distance(UV, center) > min_dist && distance(UV, center) < max_dist)
	{
		alpha = 1.0;
	} else if(distance(UV, center) > max_dist){
		alpha = mix(1., 0., (distance(UV, center) - max_dist)*outer_smoothness);
	} else if(distance(UV, center) < min_dist){
		alpha = mix(1., 0., (min_dist - distance(UV, center))*inner_smoothness);
	}
	COLOR = vec4(color, alpha);
}
