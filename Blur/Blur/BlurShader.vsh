attribute vec4 av4o_Position;
attribute vec2 av2o_Texcoord;
varying lowp vec2 vv2o_Texcoord;
uniform mat4 um4k_Modelviewproj;

void main()
{
  vv2o_Texcoord = av2o_Texcoord;
	gl_Position = um4k_Modelviewproj * av4o_Position;
}

