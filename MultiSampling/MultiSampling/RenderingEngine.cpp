//
//  RenderingEngine.cpp
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "RenderingEngine.h"

#include <cassert>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <GLKit/GLKMath.h>

#include "Geometry.h"
#include "ShaderProgram.h"
#include "Constants.h"

RenderingEngine::RenderingEngine() :
fbo_(0),
rbo_(),
geometry_(NULL),
shader_(NULL),
renderer_()
{}

void RenderingEngine::Init(const RenderBufferStorage &renderbufferStorage, void *context)
{
  /*create buffers */
  glGenFramebuffers(1, &fbo_);
  glGenRenderbuffers(2, rbo_);
  
  /* bind framebuffer */
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_);
  
  /*bind color renderbuffer */
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[0]);
  renderbufferStorage(context);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rbo_[0]);
  
  /* read framebuffer dimension */
  GLint width;
  GLint height;
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
  
  /* bind depth buffer */
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[1]);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo_[1]);
  
  assert (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
  
  glViewport(0, 0, width, height);
  glEnable(GL_DEPTH_TEST);
}

RenderingEngine::~RenderingEngine()
{
  glDeleteFramebuffers(1, &fbo_);
  glDeleteRenderbuffers(2, rbo_);
}

void RenderingEngine::Draw(size_t width, size_t height, unsigned int dt)
{
  assert(shader_);
  assert(geometry_);
  
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_);
  
  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  /* bind shader */
  glUseProgram(shader_->GetProgram());

  /* create renderer */
  renderer_.program = shader_->GetProgram();
  renderer_.projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),
                                                  static_cast<float>(width)/height,
                                                  0.1f, 100.0f);
  
  /* draw geoemtry */
  geometry_->Update(dt);
  geometry_->Draw(&renderer_);
  
  /* disable unwanted things */
  GLenum discard_rbo[] = {
    GL_DEPTH_ATTACHMENT
  };
  glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discard_rbo);
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[0]);
  
  glDisableVertexAttribArray(kAttribPosition);
  glDisableVertexAttribArray(kAttribNormal);
}

void RenderingEngine::BindShader(const ShaderProgram *shader)
{
  shader_ = shader;
}

void RenderingEngine::BindGeometry(IGeometry *geometry)
{
  geometry_ = geometry;
}
