varying lowp vec4 vv4e_Position;
varying lowp vec3 vv3e_Normal;

struct Light {
  lowp vec4 uv4e_Position;
  lowp vec4 uv4k_Color;
};
uniform Light light;

struct Material {
  lowp vec4 uv4k_Color;
  lowp float uf1k_Gloss;
};
uniform Material material;

void main()
{
  lowp vec4 lv4e_LightFromSurface = normalize(light.uv4e_Position - vv4e_Position);
	lowp float lf1k_DiffuseFactor = max(0.0, dot(lv4e_LightFromSurface.xyz, vv3e_Normal));
  
  lowp vec4 lv4e_PositionToEye = vec4(0.0) - vv4e_Position;
  lowp vec4 lv4e_Half = normalize(lv4e_LightFromSurface + lv4e_PositionToEye);
  lowp float lf1k_SpecularFactor = 0.0;
  if (lf1k_DiffuseFactor > 0.0) {
    lf1k_SpecularFactor = pow(max(0.0, dot(lv4e_Half.xyz, vv3e_Normal)), material.uf1k_Gloss);
  }
  
  gl_FragColor = material.uv4k_Color * lf1k_DiffuseFactor + light.uv4k_Color * lf1k_SpecularFactor;
}