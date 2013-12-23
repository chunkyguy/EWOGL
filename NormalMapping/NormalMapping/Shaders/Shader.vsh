//
//  Shader.vsh
//  NormalMapping
//
//  Created by Sid on 20/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

attribute vec4 a_Position;
attribute vec3 a_Tangent;
attribute vec3 a_Binormal;
attribute vec3 a_Normal;
attribute vec2 a_Texcoord;

varying vec3 v_Tangent;
varying vec3 v_Binormal;
varying vec3 v_Normal;
varying vec2 v_Texcoord;

uniform mat4 u_Mvp;

void main()
{
 v_Tangent = a_Tangent;
 v_Binormal = a_Binormal;
 v_Normal = a_Normal;
 v_Texcoord = a_Texcoord;
 gl_Position = u_Mvp * a_Position;
}
