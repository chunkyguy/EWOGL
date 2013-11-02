//
//  Game.h
//  Texturing
//
//  Created by Sid on 24/10/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Texturing_Game_h
#define Texturing_Game_h
#include "he/he_Types.h"

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
 *	Update physics and data.
 *
 *	@param	dt	delta time in ms.
 */
void Update(int dt);

/**
 * Draw stuff on screen.
 */
void Render();
#endif
