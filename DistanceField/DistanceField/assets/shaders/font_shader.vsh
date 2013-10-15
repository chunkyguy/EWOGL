/**
 text mesh shader
 */

attribute highp vec4 a_Positon;
attribute lowp vec2 a_TexCoords;
attribute highp vec4 a_Color;

varying lowp vec4 v_Color;
varying lowp vec2 v_TexCoords;

uniform mediump mat4 u_Mvp;

void main(void) {
 v_Color = a_Color;
 v_TexCoords = a_TexCoords;
 
 gl_Position = u_Mvp * a_Positon;
}