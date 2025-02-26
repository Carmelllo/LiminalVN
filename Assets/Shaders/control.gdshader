shader_type canvas_item;

uniform sampler2D noise_texture; // External noise texture
uniform sampler2D noise_texture_grain; // External noise texture for grain
uniform float strength = 0.05;   // Distortion strength
uniform float speed = 1.0;       // Speed of distortion
uniform float aberration_strength = 0.02; // Chromatic aberration strength
uniform float grain_strength = 0.8; // Strength of the grain effect
uniform float flicker_interval = 0.05; // Interval between flickers (how often the grain "jumps")
uniform float blur_strength = 0.02; // Strength of the blur effect (0-1)

const float kernel[5] = float[](0.227027, 0.316216, 0.227027, 0.316216, 0.227027); // Simplified Gaussian kernel

void fragment() {
    vec2 uv = UV;
    
    // Apply the distortion from the noise texture
    vec2 noise_uv = uv + vec2(TIME * speed, TIME * speed);
    noise_uv.x = fract(noise_uv.x);  // Smoothly wrap X-coordinate
    noise_uv.y = fract(noise_uv.y);  // Smoothly wrap Y-coordinate (optional)

    // Sample noise texture for distortion
    vec2 noise = texture(noise_texture, noise_uv).rg;
    
    // Apply the distortion to the UV coordinates
    uv += (noise - 0.5) * strength; // Offset UVs based on noise

    // Apply chromatic aberration by offsetting UVs for different color channels
    vec2 red_uv = uv + vec2(aberration_strength , 0.0);  // Offset for red channel (to the right)
    vec2 green_uv = uv - vec2(aberration_strength , 0.0); // Offset for green channel (stronger shift)
    vec2 blue_uv = uv + vec2(aberration_strength, 0.0);  // Offset for blue channel (to the left)

    // Fetch and apply the distorted texture with chromatic aberration
    vec4 red_color = texture(TEXTURE, red_uv);
    vec4 green_color = texture(TEXTURE, green_uv);
    vec4 blue_color = texture(TEXTURE, blue_uv);

    // Combine the RGB channels with their respective offsets
    vec4 color = vec4(red_color.r, green_color.g, blue_color.b, 1.0);

    // Apply the blur effect by sampling neighboring pixels in a 5-tap Gaussian kernel
    vec4 blurred_color = vec4(0.0);
    for (int i = -2; i <= 2; i++) {
		blurred_color += texture(TEXTURE, uv + vec2(float(i) * blur_strength, 0.0)) * kernel[i + 2];

    }

    vec4 final_color = vec4(0.0);
    for (int i = -2; i <= 2; i++) {
        final_color += texture(TEXTURE, uv + vec2(0.0, float(i) * blur_strength)) * kernel[i + 2];
    }

    // Combine the blurred color and chromatic aberration effect
    color = mix(color, blurred_color, 0.5);  // Mix the original color with the blurred color (adjust weight as needed)

    // Sample the noise texture for the grain effect
    vec2 grain_uv = uv + vec2(fract(TIME / flicker_interval), fract(TIME / flicker_interval));
    grain_uv.x = fract(grain_uv.x);  // Smoothly wrap X-coordinate
    grain_uv.y = fract(grain_uv.y);  // Smoothly wrap Y-coordinate (optional)
    vec4 grain = texture(noise_texture_grain, grain_uv); // Sample grain texture

    // Apply grain effect: mix noise with color to add graininess
    color.rgb += grain.rgb * grain_strength;

    // Enhance the greenish tint and adjust other color channels
    color.r *= 1.0; // Reduce the red channel slightly
    color.g *= 1.0; // Increase the green channel to enhance the greenish tint
    color.b *= 1.0; // Reduce the blue channel slightly

    // Output the final color with grain effect, blur, and chromatic aberration
    COLOR = color;
}
