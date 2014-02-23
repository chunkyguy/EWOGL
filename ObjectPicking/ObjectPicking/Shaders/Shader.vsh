//
//  Shader.vsh
//  ObjectPicking
//
//  Created by Sid on 22/02/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

varying highp vec3 eyeNormal;
varying highp vec4 eyePosition;

uniform mat4 modelViewMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
  eyeNormal = normalize(normalMatrix * normal);
  eyePosition = normalize(modelViewMatrix * position);
  
  gl_Position = modelViewProjectionMatrix * position;
}
