//
//  Shader.fsh
//  Cubemap
//
//  Created by Sid on 02/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

uniform samplerCube u_CubeTex;

varying lowp vec3 v_Texcoord;

void main()
{
 gl_FragColor = textureCube(u_CubeTex, v_Texcoord);
}
