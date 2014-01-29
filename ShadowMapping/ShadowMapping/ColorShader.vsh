attribute vec4 av4o_Position;
attribute vec3 av3o_Normal;

uniform mat4 um4k_Modelview;
uniform mat3 um3k_Normal;
uniform mat4 um4k_Modelviewproj;

varying lowp vec4 vv4e_Position;
varying lowp vec3 vv3e_Normal;

void main()
{
  vv3e_Normal = normalize(um3k_Normal * av3o_Normal);
  vv4e_Position = normalize(um4k_Modelview * av4o_Position);
  gl_Position = um4k_Modelviewproj * av4o_Position;
}