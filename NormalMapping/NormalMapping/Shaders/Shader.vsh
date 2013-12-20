//
//  Shader.vsh
//  NormalMapping
//
//  Created by Sid on 20/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

attribute vec4 a_Position;
attribute vec3 a_Normal;

varying lowp vec4 v_Color;

uniform mat4 u_Mvp;
uniform mat3 u_N;

void main()
{
 vec3 lightPosition = vec3(0.0, 0.0, 1.0);
 vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
 
 vec3 eyeNormal = normalize(u_N * a_Normal);
 float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
 
 v_Color = diffuseColor * nDotVP;
 gl_Position = u_Mvp * a_Position;
}
