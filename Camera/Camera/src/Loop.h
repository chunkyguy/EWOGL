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
 *	Preheat assets required in the loop.
 */
void SetUp();

void TearDown();

/**
 *	Bind all shader attributes constants. This callback is invoked while the Shader is compiling.
 *
 *	@param	program	The Program reference.
 */
void BindAttributes(Program *program);

/**
 *	Init all stuff.
 */
void Load();

/**
 *	Update physics and data.
 *
 *	@param	dt	delta time in ms.
 */
void Update(int dt);

#endif
