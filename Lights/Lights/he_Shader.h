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

#include "he_Availability.h"
#include "he_BitFlag.h"

#define kAttribPosition 0
#define kAttribColor	1
#define kAttribTexcoord 2
#define kAttribTangent 	3
#define kAttribBinormal 4
#define kAttribNormal 	5

/** Compile a shader
 * @param vsh_src Vertex shader source
 * @param fsh_src Fragment shader source
 * @param attrib_flags Attributes flags
 * @return The compiled shader program.
 * @note Even if the shader did not compile successfully call ShaderDestroy to free the resource.
 */
GLuint ShaderCreate(const char *vsh_src, const char *fsh_src, const he_BitFlag attrib_flags);

/** Delete the program */
void ShaderDestroy(GLuint shader);


#endif