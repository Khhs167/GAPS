shader_type canvas_item;

uniform vec2 curvature = vec2(5, 5);
uniform float bloom_strength;
uniform bool do_bloom;
uniform bool do_curve;
uniform int bloom_level;
uniform float brightness = 1;
uniform sampler2D wonk;
uniform float wonk_strength = 0.5f;
uniform sampler2D noise;
uniform float noise_strength;
uniform float noise_bright_strength;
uniform int noise_steps;

vec2 curveRemapUV(vec2 uv)
{
	uv = uv * 2.0-1.0;
    vec2 offset = abs(uv.yx) / vec2(curvature.x, curvature.y);
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

float sample_noise(vec2 uv) {
	float value = 0.0f;
	const float SPEED = 0.1f;
	if(noise_steps >= 1)
		value += texture(noise, uv + vec2(TIME * SPEED, 0)).r;
	if(noise_steps >= 2)
		value += texture(noise, uv + vec2(TIME * -SPEED, 0)).r;
	if(noise_steps >= 3)
		value += texture(noise, uv + vec2(0, TIME * SPEED)).r;
	if(noise_steps >= 4)
		value += texture(noise, uv + vec2(0, TIME * -SPEED)).r;
	
	value /= float(noise_steps);
	return (value * 2.0f - 1.0f);
}

vec4 sample_distorted(sampler2D tex, vec2 uv) 
{
	vec2 distorted_uv = do_curve ? curveRemapUV(uv) : uv;
	if (distorted_uv.x < 0.0 || distorted_uv.y < 0.0 || distorted_uv.x > 1.0 || distorted_uv.y > 1.0)
		return vec4(0.1, 0.1, 0.1, 1);
	if(noise_strength > 0.0f) {
		float noise_raw = sample_noise(distorted_uv);
		float noise_value = noise_raw * noise_strength / (1.0f - wonk_strength);
		distorted_uv += noise_value;
		return texture(tex, distorted_uv) + noise_raw * noise_bright_strength;
	}
	return texture(tex, distorted_uv);

}

void fragment(){	
		vec4 bloom = vec4(0, 0, 0, 0);
		
		int BLOOM = bloom_level * 2 + 2;
		
		if(do_bloom) {
			int samples = 0;
			for(int x = -BLOOM; x <= BLOOM; x++) {
				for(int y = -BLOOM; y <= BLOOM; y++) {
					vec2 uv = SCREEN_UV + SCREEN_PIXEL_SIZE * vec2(float(x), float(y));
					bloom += sample_distorted(SCREEN_TEXTURE, uv);
					samples++;
				}
			}
		
			bloom /= float(samples);
		} else {
			bloom = sample_distorted(SCREEN_TEXTURE, SCREEN_UV);
		}
		
		COLOR = (sample_distorted(SCREEN_TEXTURE, SCREEN_UV) + bloom * bloom_strength);
		COLOR *= brightness;
		COLOR = mix(texture(wonk, SCREEN_UV), COLOR, 1.0f - wonk_strength);
}
