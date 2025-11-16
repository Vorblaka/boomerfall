shader_type spatial;
render_mode blend_mix, unshaded;

uniform float ray_length = 50.0;
uniform float width_scale : hint_range(0.01, 1.0) = 0.05;
uniform float center_intensity : hint_range(1.0, 10.0) = 5.0;
uniform vec3 ray_color : source_color = vec3(0.9, 0.1, 0.1);
uniform float active_time;

const float MAXTIME = .75;

void vertex() {
}

void fragment() {
    vec3 local_pos = VERTEX;

    float dist_from_center = length(local_pos.x);

	if(UV.y < (1. - (MAXTIME/2. +active_time)/MAXTIME)){
		discard;
	}

    ALBEDO =  ray_color.rgb; // Base color

	// 3. Apply the glow boost with the pulse
	EMISSION = ray_color.rgb;
	ALPHA = 0.75;
}