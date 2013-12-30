/** Double sided shading: Frag shader */

varying lowp vec4 v_FrontColor; /*per fragment front color*/
varying lowp vec4 v_BackColor;	/*per fragment back color*/

void main()
{
 if (gl_FrontFacing) {
 gl_FragColor = v_FrontColor;
 } else {
  gl_FragColor = v_BackColor;
 }
}
