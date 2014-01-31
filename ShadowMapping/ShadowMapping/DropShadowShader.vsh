#version 100

attribute vec4 av4o_Position;

uniform mat4 um4k_Modelviewproj;

void main()
{
  gl_Position = um4k_Modelviewproj * av4o_Position;
}