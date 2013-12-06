//
//  he_Sprite.h
//  Textures
//
//  Created by Sid on 06/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#ifndef he_Sprite_h
#define he_Sprite_h
#include <GLKit/GLKMath.h>

typedef struct {
 GLKVector3 position;
} Sprite;

GLKMatrix4 *Sprite_MVMatrix(GLKMatrix4 *mvMat_buff, const Sprite *sprite);
#endif
