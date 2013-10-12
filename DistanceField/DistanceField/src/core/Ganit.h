//
//  Ganit.h
//  Reflection
//
//  Created by Sid on 09/10/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Reflection_Ganit_h
#define Reflection_Ganit_h
#include <GLKit/GLKMath.h>

typedef GLKVector2 Vec2f;
typedef GLKVector3 Vec3f;
typedef GLKVector4 Vec4f;
typedef GLKMatrix2 Mat2;
typedef GLKMatrix3 Mat3;
typedef GLKMatrix4 Mat4;

typedef union {
 struct {int x, y; };
 int v[2];
} Vec2i;

typedef struct {
 struct {int x, y, z; };
 int v[3];
} Vec3i;

typedef struct {
 struct {int x, y, z, w; };
 int v[4];
} Vec4i;

#endif
