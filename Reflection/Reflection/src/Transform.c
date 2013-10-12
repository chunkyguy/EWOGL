//
//  Transform.cpp
//  HideousGameEngine
//
//  Created by Sid on 06/04/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "Transform.h"
#include "Console.h"

Transform *DefaultTransform(Transform *transform) {
 Transform t = {
  {0.0f, 0.0f, 0.0f},
  {1.0f, 1.0f, 1.0f},
  0.0f,
  {1.0f, 1.0f, 1.0f},
  NULL,
  (kTransformMask_Translation | kTransformMask_Rotation | kTransformMask_Scaling)
 };
 return memcpy(transform, &t, sizeof(t));
}


Mat4 *ModelViewMatrix(Mat4 *mat, const Transform *transform){
 
 Mat4 mv = GLKMatrix4Identity;
 
 if (transform->mask_flag & kTransformMask_Translation) {
  mv = GLKMatrix4Translate(mv, transform->position.x, transform->position.y, transform->position.z);
 }
 
 if (transform->mask_flag & kTransformMask_Rotation) {
  mv = GLKMatrix4Rotate(mv, GLKMathDegreesToRadians(transform->angle),
                        transform->axis.x, transform->axis.y, transform->axis.z);
 }
 
 if (transform->mask_flag & kTransformMask_Scaling) {
  mv = GLKMatrix4Scale(mv, transform->scale.x, transform->scale.y, transform->scale.z);
 }
 
 if (transform->parent) {
  Mat4 parent_mv;
  ModelViewMatrix(&parent_mv, transform->parent);
  mv = GLKMatrix4Multiply(parent_mv, mv);
 }
 return memcpy(mat, &mv, sizeof(mv));
}

bool NormalMatrix(Mat3 *mat, const Mat4 *mvMat) {
 bool possible;
 GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(*mvMat), &possible);
 memcpy(mat, &nMat, sizeof(nMat));
 return possible;
}

//GLKMatrix4 Transform_GetMVP(const Transform *slf, const GLKMatrix4 projection){
// return GLKMatrix4Multiply(projection, Transform_GetMV(slf));
//}


bool TransformsEqual(const Transform* one, const Transform* two) {
 
 return (one->parent == two->parent	&&
         GLKVector3AllEqualToVector3(one->position, two->position)	&&
         GLKVector3AllEqualToVector3(one->axis, two->axis)	&&
         (one->angle == two->angle) &&
         GLKVector3AllEqualToVector3(one->scale,	two->scale));
}

Frustum *DefaultPerspective(Frustum *frustum) {
 Frustum f = {
  {1.0f, 1.0f, 100.0f},	/* dimensions */
  1.0f	/* far */
 };
 return memcpy(frustum, &f, sizeof(f));
}

Mat4 *PerspectiveMatrix(Mat4 *matrix, const Frustum *frustum) {
 float width = frustum->dimension.x;
 float height = frustum->dimension.y;
 float near = frustum->nearZ;
 float far = FarZ(frustum);
 
 Mat4 mat = GLKMatrix4MakeFrustum(-width/2.0f, width/2.0f, -height/2.0f, height/2.0f, near, far);
 
 return memcpy(matrix, &mat, sizeof(mat));
}

float FarZ(const Frustum *frustum) {
 return frustum->nearZ + frustum->dimension.z;
}

///EOF
