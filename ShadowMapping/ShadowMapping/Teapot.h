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
#include "IGeometry.h"
#include "Trackball.h"

/** Draw a teapot. Has trackball implemented to help user rotate Teapot around on screen */
class Teapot : public IGeometry {
public:
  ~Teapot();
  bool Init();
  
  virtual void Update(const unsigned int dt);
  virtual void Draw(const Renderer *renderer) const;
  
  void TouchBegan(const GLKVector2 &point);
  void TouchEnd(const GLKVector2 &point);
  void TouchMove(const GLKVector2 &point);
  
private:
  GLuint vao_;
  GLuint vbo_[2]; /* geometry data + face index data */
  int indexCount_;
  Trackball trackball_;
  bool init_;
};
#endif /* defined(__MultiSampling__Teapot__) */
