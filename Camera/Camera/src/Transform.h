//
//  Transform.h
//  HideousGameEngine
//
//  Created by Sid on 06/04/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef __HideousGameEngine__Transform__
#define __HideousGameEngine__Transform__

#include "std_incl.h"
#include "Types.h"

/** @file Transform.h
 */

/** @fn Transform_Create
 @brief Construct a new coordinate system Transform.
 @param position The position vector. Default is in the world-space, as it is the most used.
 @param rotation The rotation vector + w component is the angle.
 @param scale The scale vector.
 @param parent transform system.
 @return A Transform instance.
 */
Transform Transform_Create(const GLKVector3 position,
						   const GLKQuaternion orientation,
						   const GLKVector3 scale,
						   const Transform *parent);

/** Set the {x, y} component of the position */
void Transform_SetPosition(Transform *slf, const GLKVector2 pos);
/** Get the {x, y} component of the position */
GLKVector2 Transform_GetPosition(const Transform slf);
GLKVector3 Transform_GetLocalPosition(const Transform slf, GLKVector3 world_position);

Transform Add(const Transform one, const Transform two);
Transform Subtract(const Transform one, const Transform two);
//Transform Multiply(const Transform one, float two);

/** Get the model-view matrix in world-space.
 Useful when batching several coordinates.
 */
GLKMatrix4 Transform_GetMV(const Transform *slf);

/** Get the model-view-projection in world-space.
 */
GLKMatrix4 Transform_GetMVP(const Transform *slf, const GLKMatrix4 projection);


//int Equal(const Transform one, const Transform two);
#endif /* defined(__HideousGameEngine__Transform__) */
