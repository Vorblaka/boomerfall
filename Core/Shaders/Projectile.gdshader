shader_type spatial;

render_mode blend_mix, unshaded;



// Provide a hint to edit as a color. Optionally, a default value can be provided.
// If no default value is provided, the type's default is used (e.g. opaque black for colors).
instance uniform vec4 player_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 centerUV = UV * 2. - 1.;
	if(dot(centerUV, centerUV) > 1.)
	{
		discard;
	}
	
	ALBEDO = player_color.xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
