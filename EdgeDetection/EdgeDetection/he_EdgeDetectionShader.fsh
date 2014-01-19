/*Edge detection using Sobel operator*/
precision mediump float;

varying lowp vec2 v_Texcoord;
uniform float u_OneOverScreenX;
uniform float u_OneOverScreenY;
struct Color {
 vec4 a;
 vec4 b;
 float threshold;
};
uniform Color u_Color;
uniform sampler2D u_Tex0;

float color_to_luminance(vec4 color)
{
 return 0.21276 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

void main()
{
 float dx = u_OneOverScreenX;
 float dy = u_OneOverScreenY;
 
 float s00 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(-dx,dy)));
 float s01 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(0.0,dy)));
 float s02 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(dx,dy)));
 
 float s10 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(-dx,0.0)));
 //float s11 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(-dx,dy)));
 float s12 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(dx,0.0)));

 float s20 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(-dx,-dy)));
 float s21 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(0.0,-dy)));
 float s22 = color_to_luminance(texture2D(u_Tex0, v_Texcoord + vec2(dx,-dy)));
 
 float sx = (s00 + 2.0*s10 + s20) - (s02 + 2.0*s12 + s22);
 float sy = (s00 + 2.0*s01 + s02) - (s20 + 2.0*s21 + s22);
 
 float s = sx*sx + sy+sy;

 vec4 final_color;
 if (s < u_Color.threshold) {
  final_color = u_Color.a;
 } else {
  final_color = u_Color.b;
 }
 
 gl_FragColor = final_color;
}
