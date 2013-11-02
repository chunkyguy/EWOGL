//
//  Console.c
//  Reflection
//
//  Created by Sid on 10/10/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "he_Console.h"

#include <stdio.h>

void PrintBuffer(const char *pre, const char *post,
                 const int rows, const int cols,
                 const char *row_del, const char *col_del,
                 const int start, const int end,
                 const float *data) {
 printf("%s",pre);
 int p = start;
 for (int i = 0; (i < rows) && (p < end); ++i) {
  for (int j = 0; (j < cols) && (p < end); ++j) {
   printf("%0.5f%s",data[p++],row_del);
  }
  printf("%s",col_del);
 }
 printf("%s",post);
}

void PrintMat4(const Mat4 *mat) {
 PrintBuffer("Matrix4:\n", "\n",
             4, 4,
             " ", "\n",
             0, 16,
             mat->m);
}
