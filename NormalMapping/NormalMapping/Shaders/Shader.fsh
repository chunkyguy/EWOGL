//
//  Shader.fsh
//  NormalMapping
//
//  Created by Sid on 20/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

precision highp float;

varying vec3 v_Tangent;
varying vec3 v_Binormal;
varying vec3 v_Normal;
varying vec2 v_Texcoord;

uniform sampler2D u_Tex;

void main()
{
 /*create TBN matrix*/
 mat3 tbn = mat3(normalize(v_Tangent), normalize(v_Binormal), normalize(v_Normal));
 /*extract perturbed normal from texture*/
 vec3 pN = texture2D(u_Tex, v_Texcoord).xyz * 2.0 - 1.0;
 /*create normal*/
 vec3 N = tbn * pN;
 vec3 L = vec3(-1.0, 1.0, 1.0);
 vec4 color = vec4(0.5, 0.5, 0.7, 1.0);
 float nDotVP = max(0.0, dot(normalize(N), normalize(L)));
 gl_FragColor = color * nDotVP;
}
