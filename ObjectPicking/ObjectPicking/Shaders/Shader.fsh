//
//  Shader.fsh
//  ObjectPicking
//
//  Created by Sid on 22/02/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

varying highp vec3 eyeNormal;
varying highp vec4 eyePosition;
uniform lowp vec4 diffuseColor;

void main()
{

  lowp vec3 lightPosition = vec3(0.0, 0.0, 1.0);
  
  lowp float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
  
  highp vec4 eyeVector = normalize(-eyePosition);
  highp float spec = pow(max(0.0, dot(eyeVector.xyz, reflect(-lightPosition, eyeNormal))), 1.0);
  
  gl_FragColor = diffuseColor * nDotVP + diffuseColor * spec;
}
