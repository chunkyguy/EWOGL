//
//  he_Sprite.m
//  Textures
//
//  Created by Sid on 06/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "he_Sprite.h"

GLKMatrix4 *Sprite_MVMatrix(GLKMatrix4 *mvMat_buff, const Sprite *sprite) {
 *mvMat_buff = GLKMatrix4MakeTranslation(sprite->position.x,
                                         sprite->position.y,
                                         sprite->position.z);
 return mvMat_buff;
}
