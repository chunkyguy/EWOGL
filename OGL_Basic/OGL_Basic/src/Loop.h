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
 *	Bind all shader attributes constants. This callback is invoked while the Shader is compiling.
 *
 *	@param	program	The Program reference.
 */
void BindAttributes(Program *program);

/**
 *	Init all stuff.
 */
void Init();

/**
 *	Update physics and data.
 *
 *	@param	dt	delta time in ms.
 */
void Update(int dt);

/**
 *	All draw commands should go here.
 */
void Render(const Program program);

#endif
