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
uniform bool u_ShadeReflection;

attribute vec4 a_Position;
attribute vec3 a_Normal;

varying lowp float v_DiffuseFactor;
varying lowp vec3 v_ReflectDir;

void main()
{
 if (u_ShadeReflection) {
  vec3 eyePos = vec3(u_M * a_Position);
  vec3 eyeNormal = vec3(u_M * vec4(a_Normal, 0.0));
  vec3 eyeDir = normalize(u_EyePosition - eyePos);
  v_ReflectDir = reflect(-eyeDir, eyeNormal);
  //vec3 eyeDir = normalize(a_Position.xyz - u_EyePosition);
  //v_ReflectDir = u_M * reflect(eyeDir, a_Normal);
  v_DiffuseFactor = max(0.0, dot(normalize(u_N * a_Normal), normalize(u_EyePosition)));
 } else {
  v_ReflectDir = a_Position.xyz;
  //v_ReflectDir = u_M * a_Position.xyz;
  v_DiffuseFactor = 1.0;
 }
 gl_Position = u_Mvp * a_Position;
}
