/** ADS shading: Frag shader */

varying lowp vec4 v_Color; /*final color; interpolated between per vertex color calculate in vert shader*/

void main()
{
 gl_FragColor = v_Color;
}
