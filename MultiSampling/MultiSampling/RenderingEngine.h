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

#include "Constants.h"
#include "Renderer.h"

class IGeometry;
class ShaderProgram;

typedef bool (*RenderBufferStorage)(void *context);

struct RenderingEngine {
public:
  /** The rendering engine. Nothing interesting happens in the constructor.
   * Here just the default values get set.
   */
  RenderingEngine();
  virtual ~RenderingEngine();
  
  /** Initialize the engine.
   * @param renderbufferStorage Callback to allocate the renderbuffer storage
   * It is equivalent to the OpenGL call glRenderbufferStorage
   * but, asks the EAGLContext to allocate it.
   * @param context The context is the required stuff by EAGLContext to allocate the renderbuffer
   * This value is just passed back with the callback.
   */
  void Init(const RenderBufferStorage &renderbufferStorage, void *context);
  
  /** Draw calls
   * @param width The width to be view to be rendered. Probably should by the width of the screen.
   * @param height The height of the view to be rendered. Should be the height of the screen,
   * @param dt The delta time in milliseconds.
   * Just prepares the framebuffers for drawing.
   */
  void Draw(size_t width, size_t height, unsigned int dt);

  /** The shader to be used for rendering */
  void BindShader(const ShaderProgram *shader);
  
  /** The geometry to be used for rendering */
  void BindGeometry(IGeometry *geometry);
  
protected:

  /** Binding of the MSAA framebuffers are delegate to the appropriatly subclassed engines
   * This is due to the difference in the fucntion calls for same tasks between ES1 and ES2
   * @param fbo The MSAA framebuffer.
   * @param crbo The MSAA color render buffer
   * @param drbo The MSAA depth render buffer.
   */
  virtual void bind_msaa_framebuffer(const GLuint fbo, const GLuint crbo, const GLuint drbo) = 0;
  
  /** Actually writing of MSAA framebuffer to the on-screen framebuffer 
   * This is due to the difference in the fucntion calls for same tasks between ES1 and ES2
   * @param readFBO The framebuffer to be read. Most probably the MSAA framebuffer.
   * @param writeFBO The framebuffer to be written to. Most probably the on-screen framebuffer.
   * But could be a textured-framebuffer who knows.
   */
  virtual void resolve_msaa(const GLuint readFBO, const GLuint writeFBO) = 0;
  
  GLuint fbo_[2];
  GLuint rbo_[4];
  IGeometry *geometry_;
  const ShaderProgram *shader_;
  Renderer renderer_;
  GLint bufferWidth_;
  GLint bufferHeight_;
};

/** Delegate class to implement specs in ES2 context */
class RenderingEngine2 : public RenderingEngine {
public:
  ~RenderingEngine2(){}

protected:
  virtual void bind_msaa_framebuffer(const GLuint fbo, const GLuint crbo, const GLuint drbo);
  virtual void resolve_msaa(const GLuint readFBO, const GLuint writeFBO);
};

/** Delegate class to implement specs in ES3 context */
class RenderingEngine3 : public RenderingEngine {
public:
  ~RenderingEngine3(){}
  
protected:
  virtual void bind_msaa_framebuffer(const GLuint fbo, const GLuint crbo, const GLuint drbo);
  virtual void resolve_msaa(const GLuint readFBO, const GLuint writeFBO);
};

#endif /* defined(__MultiSampling__RenderingEngine__) */
