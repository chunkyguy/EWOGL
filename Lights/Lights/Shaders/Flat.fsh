#version 300 es

/** Flat shading: Frag shader */

out lowp vec4 FragColor;

flat in lowp vec4 v_Color; /*final color; interpolated between per vertex color calculate in vert shader*/

void main()
{
 FragColor = v_Color;
}
