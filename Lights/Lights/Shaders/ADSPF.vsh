/** ADS shading: Vertex shader */

/*vertex attributes*/
attribute vec4 a_Position; /*vertex position in object space*/
attribute vec3 a_Normal; /*vertex normal in object space*/


/*transformation matrices*/
uniform mat4 u_Mvp; /*mvp matrix to transform position from object space to clip space*/

varying lowp vec4 v_Position; /*per vertex color to be interpolated in frag shader*/
varying lowp vec3 v_Normal;
void main()
{
 v_Position = a_Position;
 v_Normal = a_Normal;
 
 /* 7. Calculate position in clip space */
 gl_Position = u_Mvp * a_Position;
}
