
in vec2 TexCoord;
layout(location=0) out vec4 FragColor;

layout(binding=0) uniform sampler2D LeftEyeTexture;
//layout(binding=1) uniform sampler2D RightEyeTexture;

const float screen_width = 2560;
const float screen_height = 1600;

// raw data from calibration
const float v_pitch = LGpitch; // 47.584781646728516;
const float v_slope = LGslope; // -5.4085869789123535;
const float v_center = LGcenter; // -0.156521737575531;
//const float v_viewCone = 40.0;
const float v_dpi = 338.0;

const float screenInches = screen_width / v_dpi;
const float pitch = v_pitch * screenInches * cos( atan( 1.0/v_slope ) );
const float tilt = screen_height / ( screen_width * v_slope );
const float subp = 1.0 / (3*screen_width)*pitch;
const float center = v_center;
const float eyes=45;
const float ri = subp * 0; // !config.flipSubp.asBool ? 0 : 2
const float gi = subp * 1; // always 1
const float bi = subp * 2; // !config.flipSubp.asBool ? 2 : 0
const float invView=1.0; // config.invView

vec4 ApplyGamma(vec4 c) {
	vec3 val = c.rgb * Contrast - (Contrast - 1.0) * 0.5;
	val += Brightness * 0.5;
	val = pow(max(val, vec3(0.0)), vec3(InvGamma));
	return vec4(val, c.a);
}
  
int determineEye(float a){
	float res=eyes-1.0;
	res-=floor(fract(a)*eyes);
	return int(res);
}

void main(){
	vec4 inputColor=vec4(0,0,0,1);
	vec4 eyeTexture=texture(LeftEyeTexture, TexCoord);

	float p = (TexCoord.x + TexCoord.y * tilt) * pitch - center;
	inputColor.r = determineEye(p+ri)==WindowPositionParity ? eyeTexture.r : 0;
	inputColor.g = determineEye(p+gi)==WindowPositionParity ? eyeTexture.g : 0;
	inputColor.b = determineEye(p+bi)==WindowPositionParity ? eyeTexture.b : 0;

	FragColor = ApplyGamma(inputColor);
}
