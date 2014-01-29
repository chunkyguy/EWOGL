//
//  IGeometry.h
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef ShadowMapping_IGeometry_h
#define ShadowMapping_IGeometry_h
#include "RenderingEngine.h"

struct IGeometry {
  virtual void Update(const unsigned int dt) = 0;
  virtual void Draw(const Renderer *renderer) const = 0;
  
  virtual void TouchBegan(const GLKVector2 &point) {}
  virtual void TouchEnd(const GLKVector2 &point) {}
  virtual void TouchMove(const GLKVector2 &point) {}
};

#endif
