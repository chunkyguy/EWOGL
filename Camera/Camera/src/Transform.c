//
//  Transform.cpp
//  HideousGameEngine
//
//  Created by Sid on 06/04/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "Transform.h"


Transform Transform_Create(const GLKVector3 pos,
						   const GLKQuaternion orient,
						   const GLKVector3 sc,
						   const Transform *p)
{
 Transform t;
 t.position = pos;
 t.orientation = orient;
 t.scale = sc;
 t.parent = p;
 return t;
}

GLKMatrix4 Transform_GetMV(const Transform *slf){
 
 GLKMatrix4 tMat = GLKMatrix4MakeTranslation(slf->position.x, slf->position.y, slf->position.z);
 GLKMatrix4 rMat = GLKMatrix4MakeWithQuaternion(slf->orientation);
 GLKMatrix4 sMat = GLKMatrix4MakeScale(slf->scale.x, slf->scale.y, slf->scale.z);

 GLKMatrix4 mv = GLKMatrix4Multiply(tMat, GLKMatrix4Multiply(rMat, sMat));

 // mv = GLKMatrix4Translate(mv, slf->position.x, slf->position.y, slf->position.z);
// mv = GLKMatrix4Multiply(mv, rMat);
// mv = GLKMatrix4RotateWithVector3(mv, GLKQuaternionAngle(slf->orientation), GLKQuaternionAxis(slf->orientation));
// // mv = GLKMatrix4Rotate(mv, slf->rotation.w, slf->rotation.x, slf->rotation.y, slf->rotation.z);
// mv = GLKMatrix4Scale(mv, slf->scale.x, slf->scale.y, slf->scale.z);
 if (slf->parent) {
  mv = GLKMatrix4Multiply(Transform_GetMV(slf->parent), mv);
 }
 return mv;
}

GLKMatrix4 Transform_GetMVP(const Transform *slf, const GLKMatrix4 projection){
 return GLKMatrix4Multiply(projection, Transform_GetMV(slf));
}

Transform Add(const Transform one, const Transform two){
 assert(one.parent == two.parent);
 return Transform_Create(GLKVector3Add(one.position, two.position),
                         GLKQuaternionAdd(one.orientation, two.orientation),
                         //                         GLKVector4Add(one.orientation, two.orientation),
                         GLKVector3Add(one.scale, two.scale),
                         0);
}

Transform Subtract(const Transform one, const Transform two){
 assert(one.parent == two.parent);
 return Transform_Create(GLKVector3Subtract(one.position, two.position),
                         GLKQuaternionSubtract(one.orientation, two.orientation),
                         //                         GLKVector4Subtract(one.rotation, two.rotation),
                         GLKVector3Subtract(one.scale, two.scale),
                         0);
}
//Transform Multiply(const Transform one, float two){
// return Transform_Create(GLKVector3MultiplyScalar(one.position, two),
//                         GLKVector4MultiplyScalar(one.rotation, two),
//                         GLKVector3MultiplyScalar(one.scale, two),
//                         0);
//}

void Transform_SetPosition(Transform *slf, const GLKVector2 pos){
 slf->position.x = pos.x;
 slf->position.y = pos.y;
}

GLKVector2 Transform_GetPosition(const Transform slf){
 return GLKVector2Make(slf.position.x, slf.position.y);
}

GLKVector3 Transform_GetLocalPosition(const Transform slf, GLKVector3 world_position) {
 bool inv_result;
 GLKMatrix4 transform_inv = GLKMatrix4Invert(Transform_GetMV(&slf), &inv_result);
 assert(inv_result);	// the matrix should be invertible.
 GLKVector4 position4 = GLKMatrix4MultiplyVector4(transform_inv, GLKVector4Make(world_position.x, world_position.y, world_position.z, 1.0f));
 return GLKVector3Make(position4.x, position4.y, position4.z);
}

//int Equal(const Transform one, const Transform two) {
// return (one.parent		== two.parent	&&
//         GLKVector3AllEqualToVector3(one.position, two.position)	&&
//         GLKVector4AllEqualToVector4(one.rotation, two.rotation)	&&
//         GLKVector3AllEqualToVector3(one.scale,	two.scale));
//}

///EOF
