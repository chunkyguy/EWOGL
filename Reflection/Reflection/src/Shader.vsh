attribute highp vec4 a_Positon;
attribute highp vec3 a_Normal;

varying lowp vec4 v_Color;

uniform mediump mat4 u_Mvp;
uniform mediump mat3 u_N;
uniform lowp vec4 u_Color;

void main(void) {
 vec3 eye_normal = normalize(u_N * a_Normal);
 vec3 light_position = vec3(1.0, 1.0, 1.0);
 float n_dot_vp = max(0.0, dot(eye_normal, normalize(light_position)));
 vec4 diffuse_color = u_Color;
 v_Color = diffuse_color * n_dot_vp;
 
 gl_Position = u_Mvp * a_Positon;
}