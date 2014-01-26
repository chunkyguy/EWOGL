//
//  RenderingEngine.cpp
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "RenderingEngine.h"
#include <cassert>
#include <cstring>
#include <iostream>
#include <GLKit/GLKMath.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include "Constants.h"
#include "Geometry.h"
#include "ShaderProgram.h"

#define MSAA_ENABLED

enum {
  FBO_Main = 0,
  FBO_Multisample
};

enum {
  RBO_ColorMain = 0,
#if defined (MSAA_ENABLED)
  RBO_ColorMultisample,
  RBO_DepthMultisample
#else
  RBO_DepthMain,
#endif
};

RenderingEngine::RenderingEngine() :
fbo_(),
rbo_(),
geometry_(NULL),
shader_(NULL),
renderer_()
{}

void RenderingEngine::Init(const RenderBufferStorage &renderbufferStorage, void *context)
{
  /* test if multisampling is available */
  //  const GLubyte *extensions = glGetString(GL_EXTENSIONS);
  //  for (const GLubyte *extnPtr = extensions; *extnPtr != '\0'; ++extnPtr) {
  //    std::cout << *extnPtr;
  //    if (*extnPtr == ' ') {
  //      std::cout << std::endl;
  //    }
  //  }
  //  assert(strstr(reinterpret_cast<const char *>(extensions), "GL_APPLE_framebuffer_multisample") != NULL);
  
  /*create buffers */
  glGenFramebuffers(2, fbo_);
  glGenRenderbuffers(3, rbo_);
  
  /* bind main framebuffer */
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[FBO_Main]);
  
  /* bind main color renderbuffer */
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_ColorMain]);
  renderbufferStorage(context);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rbo_[RBO_ColorMain]);

  /* read framebuffer dimension */
  GLint width;
  GLint height;
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);

#if !defined (MSAA_ENABLED)

  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_DepthMain]);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo_[RBO_DepthMain]);
  
#endif
  
  assert (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);

  
#if defined (MSAA_ENABLED)
  
  /* bind multisample framebuffer */
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[FBO_Multisample]);
  
  /* bind multisample color renderbuffer */
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_ColorMultisample]);
  glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, width, height);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rbo_[RBO_ColorMultisample]);
  
  /* bind multisample depth buffer */
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_DepthMultisample]);
  glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, width, height);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo_[RBO_DepthMultisample]);
  
  assert (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);

#endif
  
  glViewport(0, 0, width, height);
  glEnable(GL_DEPTH_TEST);
}

RenderingEngine::~RenderingEngine()
{
  glDeleteFramebuffers(2, fbo_);
  glDeleteRenderbuffers(3, rbo_);
}

void RenderingEngine::Draw(size_t width, size_t height, unsigned int dt)
{
  assert(shader_);
  assert(geometry_);

#if defined (MSAA_ENABLED)
	  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[FBO_Multisample]);
#else
    glBindFramebuffer(GL_FRAMEBUFFER, fbo_[FBO_Main]);
#endif
  
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

#if defined (MSAA_ENABLED)
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, fbo_[FBO_Multisample]);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, fbo_[FBO_Main]);
    glResolveMultisampleFramebufferAPPLE();
    GLenum discardAttachments[] = {
      GL_COLOR_ATTACHMENT0,
      GL_DEPTH_ATTACHMENT
    };
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, discardAttachments);

#else
  
  GLenum discardAttachments[] = {
      GL_DEPTH_ATTACHMENT
    };
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discardAttachments);

#endif
  
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_ColorMain]);
  
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
