//
//  Loop.h
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef OGL_Basic_Loop_h
#define OGL_Basic_Loop_h
#include "Types.h"

/**
 *	SetUp all data when the framebuffer is reallocated.
 *
 *	@param	width	The width of new framebuffer.
 *	@param	height	The height of new framebuffer.
 */
void SetUp(GLsizei width, GLsizei height);

/**
 *	Release all resources.
 */
void TearDown();

/**
 *	Bind all shader attributes constants. This callback is invoked while the Shader is compiling.
 *
 *	@param	program	The Program reference.
 */
void BindAttributes(Shader *program);

/**
 *	Load all stuff. The VBO, textures, anything that can be loaded independently of the framebuffer. Only called once at first render.
 */
void Load();

/**
 *	Do everything opposite of Load();
 */
void Unload();

/**
 *	Update physics and data.
 *
 *	@param	dt	delta time in ms.
 */
void Update(int dt);

#endif
