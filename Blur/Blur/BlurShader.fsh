#define NUM_WEIGHT 1

varying lowp vec2 vv2o_Texcoord;
uniform sampler2D us2k_Tex0;
uniform lowp float uf1k_OneOverWidth;
uniform lowp float uf1k_OneOverHeight;
uniform lowp float uf5k_Weight0;
uniform lowp float uf5k_Weight1;
uniform lowp float uf5k_Weight2;
uniform lowp float uf5k_Weight3;
uniform lowp float uf5k_Weight4;
uniform lowp float uf5k_PixelOffset1;
uniform lowp float uf5k_PixelOffset2;
uniform lowp float uf5k_PixelOffset3;
uniform lowp float uf5k_PixelOffset4;
uniform bool ub1k_IsBlurDirectionX;

lowp vec4 blurX()
{
  lowp vec4 lv4k_finalColor = texture2D(us2k_Tex0, vv2o_Texcoord) * uf5k_Weight0;
  lv4k_finalColor += texture2D(us2k_Tex0, vv2o_Texcoord + vec2(uf5k_PixelOffset1 * uf1k_OneOverWidth, 0.0)) * uf5k_Weight1;
  lv4k_finalColor += texture2D(us2k_Tex0, vv2o_Texcoord + vec2(uf5k_PixelOffset2 * uf1k_OneOverWidth, 0.0)) * uf5k_Weight2;
  lv4k_finalColor += texture2D(us2k_Tex0, vv2o_Texcoord + vec2(uf5k_PixelOffset3 * uf1k_OneOverWidth, 0.0)) * uf5k_Weight3;
  lv4k_finalColor += texture2D(us2k_Tex0, vv2o_Texcoord + vec2(uf5k_PixelOffset4 * uf1k_OneOverWidth, 0.0)) * uf5k_Weight4;
  return lv4k_finalColor;
}

lowp vec4 blurY()
{
  lowp vec4 lv4k_finalColor = texture2D(us2k_Tex0, vv2o_Texcoord) * uf5k_Weight0;
  lv4k_finalColor += texture2D(us2k_Tex0, vv2o_Texcoord + vec2(0.0, uf5k_PixelOffset1 * uf1k_OneOverHeight)) * uf5k_Weight1;
  lv4k_finalColor += texture2D(us2k_Tex0, vv2o_Texcoord + vec2(0.0, uf5k_PixelOffset2 * uf1k_OneOverHeight)) * uf5k_Weight2;
  lv4k_finalColor += texture2D(us2k_Tex0, vv2o_Texcoord + vec2(0.0, uf5k_PixelOffset3 * uf1k_OneOverHeight)) * uf5k_Weight3;
  lv4k_finalColor += texture2D(us2k_Tex0, vv2o_Texcoord + vec2(0.0, uf5k_PixelOffset4 * uf1k_OneOverHeight)) * uf5k_Weight4;
  return lv4k_finalColor;
}

void main()
{
  if (ub1k_IsBlurDirectionX) {
    gl_FragColor = blurX();
  } else {
    gl_FragColor = blurY();
  }
}