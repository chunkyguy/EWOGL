//
//  Shader.fsh
//  Cubemap
//
//  Created by Sid on 02/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

uniform samplerCube u_CubeTex;

varying lowp float v_DiffuseFactor;
varying lowp vec3 v_ReflectDir;

void main()
{
 lowp vec4 color = textureCube(u_CubeTex, v_ReflectDir);
 gl_FragColor = color * v_DiffuseFactor;
}
