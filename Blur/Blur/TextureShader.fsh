varying lowp vec2 vv2o_Texcoord;
uniform sampler2D us2k_Tex0;

void main()
{
  gl_FragColor = texture2D(us2k_Tex0, vv2o_Texcoord);
}