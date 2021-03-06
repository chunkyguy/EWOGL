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
attribute vec3 a_Normal;

varying lowp float v_DiffuseFactor;
varying lowp vec3 v_ReflectDir;

void main()
{
  vec3 eyePos = vec3(u_M * a_Position);
  vec3 eyeNormal = vec3(u_M * vec4(a_Normal, 0.0));
  vec3 eyeDir = normalize(u_EyePosition - eyePos);
  v_ReflectDir = reflect(-eyeDir, eyeNormal);
  v_DiffuseFactor = max(0.0, dot(normalize(u_N * a_Normal), normalize(u_EyePosition)));
 gl_Position = u_Mvp * a_Position;
}
