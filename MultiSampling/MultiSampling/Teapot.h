//
//  Teapot.h
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __MultiSampling__Teapot__
#define __MultiSampling__Teapot__

#include <GLKit/GLKMath.h>
#include <OpenGLES/ES2/gl.h>
#include "Geometry.h"
#include "Trackball.h"

class Teapot : public IGeometry {
public:
  Teapot();
  ~Teapot();

  virtual void Update(const int dt);
  virtual void Draw(const Renderer *renderer);
  
  void TouchBegan(const GLKVector2 &point);
  void TouchEnd(const GLKVector2 &point);
  void TouchMove(const GLKVector2 &point);
  
private:
  GLuint vao_;
  GLuint vbo_[2]; /* geometry data + face index data */
  int indexCount_;
  Trackball trackball_;
};
#endif /* defined(__MultiSampling__Teapot__) */
