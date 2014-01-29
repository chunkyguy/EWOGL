//
//  AppEngine.h
//  ShadowMapping
//
//  Created by Sid on 28/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__AppEngine__
#define __ShadowMapping__AppEngine__
#include <GLKit/GLKMath.h>
#include <OpenGLES/ES2/gl.h>
#include "RenderingEngine.h"
#include "ShaderProgram.h"
#include "Quad.h"
#include "Teapot.h"
#include "Camera.h"

/** Functor to allocate the on-screen renderbuffer 
 * Replacement for glRenderbufferStorage call
 */
class RenderbufferStorage {
public:
  RenderbufferStorage(void *eaglContext, void *layer, bool (*cb)(void *, void *));
  bool operator()();

private:
  bool (*callback)(void *context, void *layer);
  void *eaglContext_;
  void *layer_;
};


class AppEngine {
public:
  AppEngine();
  ~AppEngine();
  
  /** Start all the subsystems */
  bool Init(RenderbufferStorage &renderbufferStorage, const GLKVector2 &screenSize);
  
  /** Update all subsystems. Prepare the final renderbuffer to be presented on screen */
  void Update(unsigned int dt);
  
  /** Touch events.
   * @param point The point in OpenGL coordinate system
   */
  void TouchBegan(const GLKVector2 &point);
  void TouchEnd(const GLKVector2 &point);
  void TouchMove(const GLKVector2 &point);

private:

  bool init_;
  
  /** Create the framebuffer */
  void create_framebuffer(RenderbufferStorage &renderbufferStorage);
  /** Destroy the framebuffer */
  void destroy_framebuffer();
  GLuint fbo_[1];
  GLuint rbo_[2];
  GLint fboSize_[2];
  
  GLKVector2 screenSize_;
  RenderingEngine renderer_;

  void load_shaders();
  ShaderProgram shaders_[1];
  
  Quad quad_;
  Teapot teapot_;
  Camera camera_;
};
#endif /* defined(__ShadowMapping__AppEngine__) */
