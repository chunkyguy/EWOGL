//
//  AppEngine.cpp
//  ShadowMapping
//
//  Created by Sid on 28/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "AppEngine.h"
#include <cassert>
#include "he_File.h"
#include "he_Path.h"

RenderbufferStorage::RenderbufferStorage(void *eaglContext, void *layer, bool (*cb)(void *, void *)) :
eaglContext_(eaglContext),
layer_(layer),
callback(cb)
{  }

bool RenderbufferStorage::operator()()
{
  return callback(eaglContext_, layer_);
}


bool AppEngine::Init(RenderbufferStorage &renderbufferStorage, const GLKVector2 &screenSize)
{
  create_framebuffer(renderbufferStorage);
  load_shaders();
  
  glViewport(0, 0, fboSize_[0], fboSize_[1]);
  screenSize_ = screenSize;

  quad_.Init();
  teapot_.Init();
  
  renderer_.Init(screenSize);

  init_ = true;
  return init_;
}

AppEngine::AppEngine() :
init_(false)
{}

AppEngine::~AppEngine()
{
  if (!init_) {
    return;
  }
  
  destroy_framebuffer();
}

/* MARK: Framebuffer */
void AppEngine::create_framebuffer(RenderbufferStorage &renderbufferStorage)
{
  glGenFramebuffers(1, fbo_);
  glGenRenderbuffers(2, rbo_);
  
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[0]);
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[0]);
  renderbufferStorage();
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rbo_[0]);
  
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &fboSize_[0]);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &fboSize_[1]);
  
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[1]);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, fboSize_[0], fboSize_[1]);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo_[1]);
  
  assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
}

void AppEngine::destroy_framebuffer()
{
  glDeleteFramebuffers(1, fbo_);
  glDeleteRenderbuffers(2, rbo_);
}

/* MARK: Shader */
void AppEngine::load_shaders()
{
  char shName[2][256] = {
    "ColorShader.vsh", "ColorShader.fsh"
  };
  char vshPathBuffer[1024];
  char fshPathBuffer[1024];
  GetBundlePath(vshPathBuffer, sizeof(vshPathBuffer), shName[0]);
  GetBundlePath(fshPathBuffer, sizeof(fshPathBuffer), shName[1]);
  
  const char *paths[] = {vshPathBuffer, fshPathBuffer};
  shaders_[0].Init(paths, BF_Mask(kAttribPosition) | BF_Mask(kAttribNormal));
}

/* MARK: Loop */
void AppEngine::Update(unsigned int dt)
{
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[0]);

  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  renderer_.DrawFrame(&shaders_[0], &quad_);
  renderer_.DrawFrame(&shaders_[0], &teapot_);
  
  /* this should be the final step */
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[0]);
  assert(glGetError() == GL_NO_ERROR);
}

void AppEngine::TouchBegan(const GLKVector2 &point)
{
  teapot_.TouchBegan(point);
}

void AppEngine::TouchEnd(const GLKVector2 &point)
{
  teapot_.TouchEnd(point);
}

void AppEngine::TouchMove(const GLKVector2 &point)
{
  teapot_.TouchMove(point);
}
