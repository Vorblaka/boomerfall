shader_type spatial;

// This is the key. It tells Godot to skip all lighting calculations.
render_mode unshaded;
render_mode depth_prepass_alpha;

// Varyings to pass data from the vertex to the fragment shader
varying vec3 world_pos;
varying vec3 world_normal;

// --- Uniforms (Unchanged) ---
uniform vec3 background_color : source_color = vec3(0.02, 0.04, 0.12);
uniform float aspect_ratio = 1.0;
uniform float density : hint_range(0.0, 3.0, 0.0001) = 1.3;
uniform int layer_parascale : hint_range(0, 5, 1) = 4;
uniform vec2 star_speed = vec2(0.0);
uniform vec2 star_wave = vec2(0.0);
uniform float star_size : hint_range(0.0, 100.0, 0.01) = 3.0;
uniform float star_rotate_speed : hint_range(-3.0, 3.0) = 0.5;
uniform float twinkle_effect : hint_range(0.0, 1.0, 0.01) = 0.6;
uniform float twinkle_speed : hint_range(0.0, 100.0, 0.01) = 0.3;
uniform bool pixelate_enabled = false;
uniform float pixelate_count = 1000.0;
uniform float texture_scale : hint_range(0.001, 1.0) = 0.1;


// --- Helper Functions (Unchanged) ---
float one_div_x(float x) {
    return (abs(x) < 0.0001) ? 1.0 : (1.0/x);
}

float one_div_x2(float x) {
    return one_div_x(x) * one_div_x(x);
}

float get_beta_w(float x, float f, float size) {
    return size * x * PI / f;
}

float get_beta_h(float y, float f, float size) {
    return size * y * PI / f;
}

float get_i(vec2 uv, float f, vec2 SIZE) {
    return one_div_x2(get_beta_w(uv.x, f, SIZE.x)) * one_div_x2(get_beta_h(uv.y, f, SIZE.y));
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43759.5453123);
}

vec2 get_snowflake_world_center(vec2 grid_id, vec2 time_offset, vec2 snow_offset, float layer_scale) {
    return (grid_id + snow_offset + time_offset) / layer_scale;
}

vec2 rotate(vec2 uv, float add_theta) {
    float theta = atan(uv.y, uv.x) + add_theta;
    float r = length(uv);
    return vec2(r * cos(theta), r * sin(theta));
}

// --- Vertex Shader (Unchanged) ---
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((inverse(transpose(MODEL_MATRIX)) * vec4(NORMAL, 0.0)).xyz);
}

// --- Fragment Shader ---
void fragment() {
    vec3 color = background_color;

	// --- Triplanar Mapping Logic (Unchanged) ---
	vec3 blend_weights = abs(world_normal);
	blend_weights = max(blend_weights, 0.00001);
	blend_weights /= (blend_weights.x + blend_weights.y + blend_weights.z);

	vec2 uv_x = world_pos.yz * texture_scale;
	vec2 uv_y = world_pos.xz * texture_scale;
	vec2 uv_z = world_pos.xy * texture_scale;

	vec2 st = uv_x * blend_weights.x + uv_y * blend_weights.y + uv_z * blend_weights.z;

	if (pixelate_enabled) {
		st = round(st * pixelate_count) / pixelate_count;
	}
    st.x *= aspect_ratio;
    vec2 cuv = (st - 0.5) * 2.0;

    // --- Starfield Logic (Unchanged) ---
    for (int layer = 0; layer < layer_parascale; layer++) {
        float layer_scale = exp(float(layer + 1) * density);
        vec2 layer_speed = vec2(star_speed.x, star_speed.y) * (1.0 + float(layer) * 0.3);
        float layer_size = star_size * (1.0 - float(layer) * 0.2);

        vec2 layer_st = st * layer_scale;
        vec2 cuv_st = cuv;

        vec2 time_offset = TIME * layer_speed;
        layer_st -= time_offset;

        vec2 grid_st = fract(layer_st);
        vec2 grid_id = floor(layer_st);

        float rand_seed = random(grid_id);

        vec2 snow_pos = vec2(
            0.5 + (0.3 * sin((rand_seed * 6.28) + (TIME * star_wave.x))),
            0.5 + (0.2 * cos((rand_seed * 12.56) + (TIME * star_wave.y)))
        );

        float dist = distance(grid_st, snow_pos);
        float snow_size = layer_size * 0.01 * (0.5 + 0.5 * rand_seed);
        float brightness = 1.0 - (float(layer) * 0.3);

        float m = exp((-dist * dist) / (snow_size * snow_size));

        vec2 fst = cuv_st - (get_snowflake_world_center(grid_id, time_offset, snow_pos, layer_scale) - 0.5) * 2.0;
		fst = rotate(fst, TIME * star_rotate_speed);

        float snowflake = m * 0.5 * (get_i(fst, 0.8 - (dist * 42.0), vec2(1.0 / snow_size)) + 1.0);

        float twinkle = (1.0 - twinkle_effect) + twinkle_effect * (sin(rand_seed * 100.0 + TIME * twinkle_speed) * cos(rand_seed * 120.0 + TIME * (twinkle_speed + 2.0)));
        snowflake *= twinkle;

        vec3 color_type = vec3(random(grid_id - 3.0), random(grid_id + 7.0), random(grid_id + 5.0));

        color = max(color + (snowflake * brightness) * color_type, color);
    }

    // CHANGED: For unshaded materials in Godot, the final color goes into ALBEDO.
    ALBEDO = color;
    ALPHA = 1.0;
}