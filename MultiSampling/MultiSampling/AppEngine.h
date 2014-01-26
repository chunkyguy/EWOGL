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
  /** Create an AppEngine that is responsible for all that gets drawn 
   * @param width The width of the screen
   * @param height The height of the screen
   * @param renderer The selected rendering engine
   */
  AppEngine(const size_t width, const size_t height, RenderingEngine *renderer);
  ~AppEngine();

  /** Update and draw the world 
   * dt Time in millisecs
   */
  void UpdateAndDraw(unsigned int dt);

  /** Touch events.
   * @param point The point in OpenGL coordinate system
   */
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
