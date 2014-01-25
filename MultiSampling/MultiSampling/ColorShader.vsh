attribute vec4 av4o_Position;
attribute vec3 av3o_Normal;

struct Light {
  vec4 uv4e_Position;
  vec4 uv4k_Color;
};

struct Material {
  vec4 uv4k_Diffuse;
  float ufk_gloss;
};

uniform Light light;
uniform Material material;
uniform mat3 um3k_Normal;
uniform mat4 um4k_Modelview;
uniform mat4 um4k_Modelviewproj;

varying lowp vec4 vv4k_Color;

void main()
{
  /* Convert normals from object space to eye space*/
  vec3 lv3e_Normal = normalize(um3k_Normal * av3o_Normal);
  
  /* Convert position to eye space*/
  vec4 lv4e_Position = normalize(um4k_Modelview * av4o_Position);

  /* Calculate light vector */
	vec3 lv3e_Light =   normalize(vec3(light.uv4e_Position - lv4e_Position));
  if (light.uv4e_Position.w == 0.0) {
    lv3e_Light = normalize(vec3(light.uv4e_Position));
  }

  /* Calculate diffuse factor as DOT product of normal and light vector
   * In eye space
   */
  float lfk_Diffuse = max(0.0, dot(lv3e_Light, lv3e_Normal));

  /* Calc specular highlight */
  /* Method 1: Using refletion vector */
  /* Calc reflection vector as reflection of light vector about eyeNormal*/
  /*
  vec3 lv3e_Reflex = reflect(-lv3e_Light, lv3e_Normal);
	float lfk_Specular = 0.0;
  if (lfk_Diffuse > 0.0) {
    lfk_Specular = pow(max(0.0, dot(normalize(-lv4e_Position.xyz), lv3e_Reflex)), material.ufk_gloss);
  }
   */
  /* Method 2: Using halway vector */
  vec4 lv3e_Half = normalize(-lv4e_Position + light.uv4e_Position);
  float lfk_Specular = 0.0;
  if (lfk_Diffuse > 0.0) {
    lfk_Specular = pow(max(0.0, dot(lv3e_Normal, normalize(lv3e_Half.xyz))), material.ufk_gloss);
  }


  vv4k_Color = (material.uv4k_Diffuse * lfk_Diffuse) + (light.uv4k_Color * lfk_Specular);
  gl_Position = um4k_Modelviewproj * av4o_Position;
}
