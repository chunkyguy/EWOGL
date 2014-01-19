attribute vec4 a_Position;
attribute vec3 a_Normal;

struct Light {
 vec3 p; /*light position in eye space. Must be normalized*/
 vec3 d; /*diffuse color*/
 vec3 s; /*specular color*/
 float gloss; /*glossiness (1,200)*/
};
uniform Light u_Light;
uniform mat3 u_N; /*normal matrix*/
uniform mat4 u_Mvp; /*mvp matrix*/

varying lowp vec3 v_Color;

void main()
{
 vec3 eNormal = normalize(u_N * a_Normal);
 float diffuseFactor = max(dot(eNormal, u_Light.p), 0.0);

 vec3 eye = normalize(vec3(-a_Position.xyz));
 vec3 h = normalize(eye + u_Light.p);
 float specularFactor = pow(max(0.0, dot(h, eNormal)), u_Light.gloss);

 v_Color = u_Light.d * diffuseFactor + u_Light.s * specularFactor;
 gl_Position = u_Mvp * a_Position;
}
