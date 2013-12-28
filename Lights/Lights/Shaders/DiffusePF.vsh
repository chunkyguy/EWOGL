/** Diffuse per fragment shading: Vertex shader */

/*vertex attributes*/
attribute vec4 a_Position; /*vertex position in object space*/
attribute vec3 a_Normal; /*vertex normal in object space*/

uniform mat4 u_Mvp; /*mvp matrix to transform position from object space to clip space*/

varying lowp vec3 v_Normal; /*per vertex normal to be interpolated in frag shader*/
varying lowp vec4 v_Position;

void main()
{
 /* 1. Pass normal to frag shader*/
 v_Normal = a_Normal;
 v_Position = a_Position;
 
 /* 2. Calculate position in clip space */
 gl_Position = u_Mvp * a_Position;
}
