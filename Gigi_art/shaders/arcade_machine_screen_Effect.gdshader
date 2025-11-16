shader_type spatial;

// The correct render mode for transparent glass.
render_mode blend_mix, depth_draw_opaque, cull_back;

// Uniforms to control the effect.
uniform float curve_amount : hint_range(0.0, 0.5) = 0.08;
uniform float vignette_intensity : hint_range(0.0, 3.0) = 1.5;
uniform float scanline_intensity : hint_range(0.0, 0.5) = 0.1;
uniform float noise_amount : hint_range(0.0, 0.1) = 0.02;
uniform float aberration_amount : hint_range(0.0, 0.01) = 0.002;
uniform float glass_opacity : hint_range(0.0, 1.0) = 0.1; // How "solid" the glass itself is.

// This special uniform grabs whatever is rendered behind the mesh.
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Simple random function for noise.
float random(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	// --- 1. Calculate Distorted UVs ---
	// We start with the actual screen coordinates of this pixel.
	vec2 uv = SCREEN_UV;

	// Apply curvature
	vec2 centered_uv = (uv - 0.5) * 2.0;
	float dist_sq = dot(centered_uv, centered_uv);
	vec2 distorted_uv = centered_uv * (1.0 - (dist_sq * curve_amount));
	
	// Remap back to the [0, 1] range for sampling.
	vec2 final_uv = (distorted_uv * 0.5) + 0.5;
	
	// Apply some random noise to the coordinates to make the image shimmer.
	final_uv.x += (random(uv + TIME * 0.1) - 0.5) * noise_amount;
	final_uv.y += (random(uv + TIME * 0.1 + 5.0) - 0.5) * noise_amount;

	// --- 2. Sample the background with Chromatic Aberration ---
	// We sample the background three times using our distorted UVs,
	// with slight offsets for the red and blue channels.
	float aberration_offset = aberration_amount * dist_sq;
	float r = texture(SCREEN_TEXTURE, vec2(final_uv.x + aberration_offset, final_uv.y)).r;
	float g = texture(SCREEN_TEXTURE, final_uv).g;
	float b = texture(SCREEN_TEXTURE, vec2(final_uv.x - aberration_offset, final_uv.y)).b;
	
	// This is the color of the world as seen THROUGH the distorted glass.
	vec3 scene_color = vec3(r, g, b);

	// --- 3. Calculate Overlays (Scanlines & Vignette) ---
	// These effects happen ON the glass, so we calculate them as multipliers.
	float scanline_effect = 1.0 - (sin(UV.y * 2.0 * PI * scanline_intensity * 180.0) * 0.5 + 0.5) * scanline_intensity;
	float vignette = 1.0 - (dist_sq * vignette_intensity);
	
	// Apply the overlays to the see-through color.
	vec3 final_color = scene_color * vignette * scanline_effect;

	// --- 4. Final Output ---
	// If our distorted coordinates are outside the screen, we're in the border area.
	if (final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0) {
		// Make the border opaque and black.
		ALBEDO = vec3(0.0);
		ALPHA = 1.0;
	} else {
		// For the main glass area, output the final distorted color.
		ALBEDO = final_color;
		// The alpha controls the transparency of the glass itself.
		// A small value makes it very clear, a higher value makes it look like smokey glass.
		ALPHA = glass_opacity + scanline_effect * 0.1; // Make scanlines slightly more opaque.
	}
}