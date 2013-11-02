//
//  Transform.h
//  HideousGameEngine
//
//  Created by Sid on 06/04/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef __HideousGameEngine__Transform__
#define __HideousGameEngine__Transform__

#include "he_std_incl.h"
#include "he_Types.h"

/** @file Transform.h
 */

Transform *DefaultTransform(Transform *transform);

/** Get the model-view matrix in world-space.
 Useful when batching several coordinates.
 */
Mat4 *ModelViewMatrix(Mat4 *mat, const Transform *transform);

bool NormalMatrix(Mat3 *mat, const Mat4 *mvMat);

bool TransformsEqual(const Transform *one, const Transform *two);

Frustum *DefaultPerspective(Frustum *frustum);

Mat4 *PerspectiveMatrix(Mat4 *matrix, const Frustum *frustum);

float FarZ(const Frustum *frustum);
#endif /* defined(__HideousGameEngine__Transform__) */
