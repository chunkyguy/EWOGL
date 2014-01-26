//
//  RenderingEngine.h
//  MultiSampling
//
//  Created by Sid on 23/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __MultiSampling__RenderingEngine__
#define __MultiSampling__RenderingEngine__

#include <cstddef>
#include <OpenGLES/ES2/gl.h>

#include "Renderer.h"

class IGeometry;
class ShaderProgram;

typedef bool (*RenderBufferStorage)(void *context);


struct RenderingEngine {
public:
  RenderingEngine();
  ~RenderingEngine();
  void Init(const RenderBufferStorage &renderbufferStorage, void *context);
  void Draw(size_t width, size_t height, unsigned int dt);

  void BindShader(const ShaderProgram *shader);
  void BindGeometry(IGeometry *geometry);
  
protected:
  GLuint fbo_[2];
  GLuint rbo_[4];
  IGeometry *geometry_;
  const ShaderProgram *shader_;
  Renderer renderer_;
};

//class RenderingEngine2 : public RenderingEngine {
//public:
//  ~RenderingEngine2();
//  virtual void Init(const RenderBufferStorage &renderbufferStorage, void *context);
//  virtual void Draw(unsigned int dt);
//};
//
//class RenderingEngine3 : public RenderingEngine {
//public:
//  virtual void Init(const RenderBufferStorage &renderbufferStorage, void *context);
//  virtual void Draw(unsigned int dt);
//};

#endif /* defined(__MultiSampling__RenderingEngine__) */
