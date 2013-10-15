//
//  Font.h
//  DistanceField
//
//  Created by Sid on 12/09/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef DistanceField_Font_h
#define DistanceField_Font_h
#include "HE_Types.h"

Font *CreateFont(Font *font, const char *path);
void ReleaseFont(Font *font);

#endif
