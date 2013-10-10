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

Perspective *DefaultPerspective(Perspective *perspective) {
 Perspective p = {
  45.0f, 1.0f, 101.0f,
  {1, 1}
 };
 return memcpy(perspective, &p, sizeof(p));
}

GLKMatrix4 *PerspectiveMatrix(GLKMatrix4 *matrix, const Perspective *perspective) {
 float width = perspective->size.x;
 float height = perspective->size.y;
 float aspect_ratio = width/height;//(width > height) ? height/width: width/height;

 GLKMatrix4 mat = GLKMatrix4MakePerspective(perspective->fov,
                                            aspect_ratio,
                                            perspective->near, perspective->far);
 return memcpy(matrix, &mat, sizeof(mat));
}

///EOF
