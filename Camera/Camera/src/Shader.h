//
//  Shader.h
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef OGL_Basic_Shader_h
#define OGL_Basic_Shader_h

#include "Types.h"

typedef void(*BindAttribs)(Program *program);

/**
 *	Compile shader from filename
 *
 *	@param	vsh_filename Vertex shader filename
 *	@param	fsh_filename	 Fragment shader filename
 */
Program CompileShader(const char *vsh_filename, const char *fsh_filename, BindAttribs bind_attribs);

/**
 *	Compile shader from source
 *
 *	@param	vsh_src	Vertex shader source
 *	@param	fsh_src	Fragment shader source
 */
Program CompileShaderSource(const char *vsh_src, const char *fsh_src, BindAttribs bind_attribs);
#endif
