//
//  Geometry.h
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef MultiSampling_Geometry_h
#define MultiSampling_Geometry_h

struct Renderer;

/** A geometry abstract class. Every object that needs to drawn should subclass this. */
struct IGeometry {
  virtual void Update(const int dt) = 0;
  virtual void Draw(const Renderer *renderer) = 0;
};

#endif
