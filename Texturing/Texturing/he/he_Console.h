//
//  Console.h
//  Reflection
//
//  Created by Sid on 10/10/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Reflection_Console_h
#define Reflection_Console_h

#include "he_Types.h"

void PrintBuffer(const char *pre, const char *post,
                 const int rows, const int cols,
                 const char *row_del, const char *col_del,
                 const int start, const int end,
                 const float *data);

void PrintMat4(const Mat4 *mat);

#endif
