//
//  Shader.vsh
//  Textures
//
//  Created by Sid on 06/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec2 a_texcoord;

varying lowp vec4 colorVarying;
varying lowp vec2 v_texcoord;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
 vec3 eyeNormal = normalize(normalMatrix * normal);
 vec3 lightPosition = vec3(0.0, 0.0, 1.0);
 vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
 
 float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
 
 colorVarying = diffuseColor * nDotVP;
 v_texcoord = a_texcoord;
 gl_Position = modelViewProjectionMatrix * position;
}
