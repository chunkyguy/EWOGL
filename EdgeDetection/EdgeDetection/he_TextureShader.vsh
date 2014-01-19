/* render the geometry with texture mapping */
attribute vec4 a_Position;
attribute vec2 a_Texcoord;

varying lowp vec2 v_Texcoord;

uniform mat4 u_Mvp;

void main()
{
 v_Texcoord = a_Texcoord;
 gl_Position = u_Mvp * a_Position;
}