//
//  he_Shader.h
//  NormalMapping
//
//  Created by Sid on 20/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#ifndef he_Shader_h
#define he_Shader_h
#include <stdbool.h>
#include <OpenGLES/ES2/gl.h>

#include "he_BitFlag.h"

#define kAttribPosition 0
#define kAttribNormal 	1
#define kAttribColor	2
#define kAttribTexcoord 3

GLuint ShaderCreate(const char *vsh_src, const char *fsh_src, const he_BitFlag attrib_flags);

void ShaderDestroy(GLuint shader);
#endif