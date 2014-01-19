varying lowp vec2 v_Texcoord;

uniform sampler2D u_Tex0;

void main()
{
 gl_FragColor = texture2D(u_Tex0, v_Texcoord);
}