//
//  Loop.h
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef OGL_Basic_Loop_h
#define OGL_Basic_Loop_h

#include "Shader.h"

/**
 * Load all stuff. 
 * The VBO, textures, anything that can be loaded independently of the framebuffer.
 * Only called once at first render.
 */
void Load();

/**
 *	Do everything opposite of Load();
 */
void Unload();

/**
 *	SetUp all data when the framebuffer is reallocated.
 *
 *	@param	width	The width of new framebuffer.
 *	@param	height	The height of new framebuffer.
 */
void Reshape(GLsizei width, GLsizei height);

/**
 *	Bind all shader attributes constants. This callback is invoked while the Shader is compiling.
 *
 *	@param	program	The Program reference.
 */
void BindAttributes(Shader *shader);

/**
 *	Update physics and data.
 *
 *	@param	dt	delta time in ms.
 */
void Update(int dt);

#endif
