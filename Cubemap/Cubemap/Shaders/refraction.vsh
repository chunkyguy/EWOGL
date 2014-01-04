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
struct Material {
 lowp float ref_index; /*ratio of refractive index (n2/n1)*/
 lowp float relection; /*ratio of light reflected*/
};
uniform Material u_Material;

attribute vec4 a_Position;
attribute vec3 a_Normal;

varying lowp vec3 v_RefractDir;
varying lowp vec3 v_ReflectDir;

void main()
{
 vec3 eyePos = vec3(u_M * a_Position);
 vec3 eyeNormal = vec3(u_M * vec4(a_Normal, 0.0));
 vec3 eyeDir = normalize(u_EyePosition - eyePos);
 v_ReflectDir = reflect(-eyeDir, eyeNormal);
 v_RefractDir = refract(-eyeDir, eyeNormal, u_Material.ref_index);
 gl_Position = u_Mvp * a_Position;
}
