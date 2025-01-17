shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform sampler2D SideTexture;
uniform sampler2D TopTexture;
uniform sampler2D BottomTexture;
uniform sampler2D MainColor;  // Brick texture
uniform sampler2D Paint;      // DrawViewport texture

uniform float brightness : hint_range(0, 1, 0.1) = 1.0;
uniform vec2 texture_scale = vec2(2.0, 2.0);
uniform vec2 texture_offset = vec2(0.0, 0.0);
uniform float rotation_angle : hint_range(0, 360, 1) = 0.0;

varying vec3 vertex_normal;

void vertex() {
    vertex_normal = NORMAL;
}

// Function to handle UV transformation
vec2 transform_uv(vec2 uv) {
	float angle_rad = rotation_angle * PI / 180.0;
	
	// Center for rotation
	uv -= vec2(0.5);
	
	// Rotate
	float cos_angle = cos(angle_rad);
	float sin_angle = sin(angle_rad);
	uv = mat2(vec2(cos_angle, -sin_angle), vec2(sin_angle, cos_angle)) * uv;
	
	// Move back
	uv += vec2(0.5);
	
	// Scale and offset
	return uv * texture_scale + texture_offset;
}

void fragment() {
	//vec2 uv = UV;
	vec2 transformed_uv = transform_uv(UV);
	//vec4 brick_color = texture(MainColor, transformed_uv);
	vec4 paint_mask = texture(Paint, UV);
	
	// Choose texture based on normal direction
	vec4 base_texture;
	if (vertex_normal.y > 0.9) {        // Top face
        base_texture = texture(TopTexture, transformed_uv);
    } else if (vertex_normal.y < -0.9) { // Bottom face
        base_texture = texture(BottomTexture, transformed_uv);
    } else {                            // Side faces
        base_texture = texture(SideTexture, transformed_uv);
    }
	
	// Start with white (1,1,1) and reveal brick texture based on paint alpha
	vec3 final_color = mix(vec3(1.0), base_texture.rgb, paint_mask.a);
	
	ALBEDO = final_color * brightness;
}
