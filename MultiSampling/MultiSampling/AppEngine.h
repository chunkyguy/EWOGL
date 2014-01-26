//
//  AppEngine.h
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __MultiSampling__AppEngine__
#define __MultiSampling__AppEngine__
#include <cstddef>

#include <GLKit/GLKMath.h>

class RenderingEngine;
class Teapot;
class ShaderProgram;

class AppEngine {
public:
  AppEngine(const size_t width, const size_t height, RenderingEngine *renderer);
  ~AppEngine();

  void UpdateAndDraw(unsigned int dt);

  void TouchBegan(const GLKVector2 &point);
  void TouchEnd(const GLKVector2 &point);
  void TouchMove(const GLKVector2 &point);
  
private:
  const size_t width_;
  const size_t height_;
  RenderingEngine *renderer_;
  Teapot *teapot_;
  ShaderProgram *shader_;
};
#endif /* defined(__MultiSampling__AppEngine__) */
