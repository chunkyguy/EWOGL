//
//  he_Quaternion.m
//  EdgeDetection
//
//  Created by Sid on 17/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//
#include "he_Quaternion.h"

/* Create quaternion from start to end vectors
 * "The Shortest Arc Quaternion" by Stan Melax in "Game Programming Gems".
 */
GLKQuaternion QuaternionFromVectors(const GLKVector3 &start, const GLKVector3 &end)
{
 /* start == -end */
 if (GLKVector3AllEqualToVector3(start, GLKVector3Negate(end))) {
  return GLKQuaternionMakeWithAngleAndAxis(M_PI, 1.0f, 0.0f, 0.0f);
 }
 
 GLKVector3 normal = GLKVector3CrossProduct(start, end);
 float dot = GLKVector3DotProduct(start, end);
 float sq = sqrtf((1.0f + dot) * 2.0f);
 return GLKQuaternionMakeWithVector3(GLKVector3DivideScalar(normal, sq), sq/2.0f);
}

GLKQuaternion QuaternionRotate(const GLKQuaternion &left, const GLKQuaternion &right)
{
 GLKQuaternion q = GLKQuaternionMake(
                                     left.w * right.x + left.x * right.w + left.y * right.z - left.z * right.y,
                                     left.w * right.y + left.y * right.w + left.z * right.x - left.x * right.z,
                                     left.w * right.z + left.z * right.w + left.x * right.y - left.y * right.x,
                                     left.w * right.w - left.x * right.x - left.y * right.y - left.z * right.z
                                     );
 return GLKQuaternionNormalize(q);
 return q;
}

