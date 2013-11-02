attribute vec4 a_Position;
attribute vec3 a_Normal;

varying lowp vec4 v_Color;

uniform mat4 u_Mvp;
uniform mat3 u_N;
uniform lowp vec4 u_Color;

void main()
{
 vec3 eyeNormal = normalize(u_N * a_Normal);
 vec3 lightPosition = vec3(0.0, 0.0, 1.0);
 
 float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
 
 v_Color = u_Color * nDotVP;
 gl_Position = u_Mvp * a_Position;
}
