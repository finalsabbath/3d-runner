shader_type spatial;

uniform sampler2D diffuse_texture : source_color;
uniform sampler2D reflection_map : hint_default_white;
uniform vec4 reflection_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float reflection_strength = 0.5;
uniform float specular_strength : hint_range(0.0, 1.0) = 0.0;
uniform float metallic_strength : hint_range(0.0, 1.0) = 0.0;
uniform float roughness_value : hint_range(0.0, 1.0) = 1.0;

// UV variables for controlling reflection map movement and scale
uniform vec2 reflection_offset = vec2(0.0, 0.0);
uniform vec2 reflection_scale = vec2(1.0, 1.0);

void fragment() {
    // Sample the base diffuse texture
    vec4 diffuse = texture(diffuse_texture, UV);

    // Calculate reflection UV coordinates
    vec3 view_normal = normalize(VIEW * NORMAL);
    vec2 reflection_uv = vec2(
        view_normal.x * 0.5 + 0.5,
        view_normal.y * 0.5 + 0.5
    );

    // Apply reflection scale and offset
    reflection_uv = reflection_uv * reflection_scale + reflection_offset;

    // Sample the reflection map
    vec4 reflection = texture(reflection_map, reflection_uv);

    // Combine diffuse and reflection
    vec3 final_color = mix(
        diffuse.rgb,
        diffuse.rgb + reflection.rgb * reflection_color.rgb,
        reflection.r * reflection_strength
    );

    // Output the final color
    ALBEDO = final_color;

    // Apply the adjustable material properties
    SPECULAR = specular_strength;
    METALLIC = metallic_strength;
    ROUGHNESS = roughness_value;
}