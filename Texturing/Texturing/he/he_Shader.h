//
//  Shader.h
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef OGL_Basic_Shader_h
#define OGL_Basic_Shader_h

#include "he_Types.h"

/**
 *	Compile shader from filename
 *
 *	@param	vsh_filename Vertex shader filename
 *	@param	fsh_filename	 Fragment shader filename
 */
Shader *CompileShader(Shader *shader,
                      const char *vsh_filename,
                      const char *fsh_filename);

/**
 *	Compile shader from source
 *
 *	@param	vsh_src	Vertex shader source
 *	@param	fsh_src	Fragment shader source
 */
Shader *CompileShaderSource(Shader *shader,
                            const char *vsh_src,
                            const char *fsh_src);
/**
 *	Release the shader.
 *
 *	@param	program	The program object.
 */
void ReleaseShader(Shader *shader);
#endif
