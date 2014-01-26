//
//  he_Quaternion.h
//  EdgeDetection
//
//  Created by Sid on 17/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//
#ifndef he_Quaternion_h
#define he_Quaternion_h

#include <GLKit/GLKMath.h>

/** Create quaternion from start to end vectors
 * "The Shortest Arc Quaternion" by Stan Melax in "Game Programming Gems".
 */
GLKQuaternion QuaternionFromVectors(const GLKVector3 &start, const GLKVector3 &end);

/** If a and b are two quaternion, then
 * c = a.Rotate(b);
 * Here left = a and right = b
 */
GLKQuaternion QuaternionRotate(const GLKQuaternion &left, const GLKQuaternion &right);
#endif
