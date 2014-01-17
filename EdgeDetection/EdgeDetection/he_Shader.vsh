attribute vec4 a_Position;
attribute vec3 a_Normal;

uniform vec3 u_Light; /*light vector in eye space. Must be normalized*/
uniform vec3 u_Color; /*diffuse color*/
uniform mat3 u_N; /*normal matrix*/
uniform mat4 u_Mvp; /*mvp matrix*/

varying lowp vec3 v_Color;

void main()
{
 vec3 eNormal = normalize(u_N * a_Normal);
 float diffuseFactor = max(dot(eNormal, u_Light), 0.0);
 v_Color = u_Color * diffuseFactor;
 gl_Position = u_Mvp * a_Position;
}
