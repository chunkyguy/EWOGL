//
//  Shader.vsh
//  Cubemap
//
//  Created by Sid on 02/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

uniform mat4 u_M;
uniform mat3 u_N;
uniform mat4 u_Mvp;
uniform vec3 u_EyePosition;

attribute vec4 a_Position;

varying lowp vec3 v_Texcoord;

void main()
{
 v_Texcoord = a_Position.xyz;
 gl_Position = u_Mvp * a_Position;
}
