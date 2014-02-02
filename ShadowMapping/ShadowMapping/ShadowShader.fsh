#version 300 es

in lowp vec4 vv4e_Position;
in lowp vec3 vv3e_Normal;
in highp vec4 vv4s_Texcoord;

layout (location = 0) out lowp vec4 FragColor;

struct Light {
  lowp vec4 uv4k_Color;
  lowp vec4 uv4e_Position;
};
uniform Light light;

struct Material {
  lowp vec4 uv4k_Color;
  highp float uf1k_Gloss;
};
uniform Material material;

uniform highp sampler2DShadow us2s_Tex0;

/*quick and dirty method*/
//highp float calc_shadow()
//{
//  return textureProj(us2s_Tex0, vv4s_Texcoord);
//}

/*Percentage Closer Filtering (PCF) method*/
highp float calc_shadow()
{
  highp float average = 0.0;
  average += textureProjOffset(us2s_Tex0, vv4s_Texcoord, ivec2(-1, -1), 0.005);
  average += textureProjOffset(us2s_Tex0, vv4s_Texcoord, ivec2(-1, 1), 0.005);
  average += textureProjOffset(us2s_Tex0, vv4s_Texcoord, ivec2(1, -1), 0.005);
  average += textureProjOffset(us2s_Tex0, vv4s_Texcoord, ivec2(1, 1), 0.005);
  return average * 0.25;
}


void main()
{
  lowp vec4 lv4e_LightPositionLight = normalize(light.uv4e_Position);
  if (light.uv4e_Position.w > 0.0) {
    lv4e_LightPositionLight = normalize(light.uv4e_Position - vv4e_Position);
  }
  
  lowp float lf1k_Diffuse = max(0.0, dot(lv4e_LightPositionLight.xyz, vv3e_Normal));
  
  lowp vec4 lv4e_PositionEye = normalize(vec4(0.0) - vv4e_Position);
  lowp vec4 lv4e_Half = normalize(lv4e_PositionEye + lv4e_LightPositionLight);
  lowp float lf1k_Specular = 0.0;
  if (lf1k_Diffuse > 0.0) {
    lf1k_Specular = pow(max(0.0, dot(lv4e_Half.xyz, vv3e_Normal)), material.uf1k_Gloss);
  }
  
  highp float lf1k_Shadow = calc_shadow();
  highp vec4 lv4k_Final = vec4((material.uv4k_Color.xyz * lf1k_Diffuse + light.uv4k_Color.xyz * lf1k_Specular) * lf1k_Shadow, 1.0);
  
  FragColor = lv4k_Final;
}