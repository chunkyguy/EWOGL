#version 300 es

layout (location=0) in vec4 av4o_Position;
layout (location=1) in vec3 av3o_Normal;

out lowp vec4 vv4e_Position;
out lowp vec3 vv3e_Normal;
out lowp vec4 vv4s_Texcoord;

uniform mat4 um4k_Modelview;
uniform mat3 um3k_Normal;
uniform mat4 um4k_Modelviewproj;
uniform mat4 um4k_Shadow;

void main()
{
  vv4e_Position = um4k_Modelview * av4o_Position;
  vv3e_Normal = normalize(um3k_Normal * av3o_Normal);
  vv4s_Texcoord = um4k_Shadow * av4o_Position;
  gl_Position = um4k_Modelviewproj * av4o_Position;
}