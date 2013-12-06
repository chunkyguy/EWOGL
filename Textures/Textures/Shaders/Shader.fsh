//
//  Shader.fsh
//  Textures
//
//  Created by Sid on 06/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 v_texcoord;

uniform sampler2D u_tex;

void main()
{
 gl_FragColor = colorVarying * texture2D(u_tex, v_texcoord);
}
