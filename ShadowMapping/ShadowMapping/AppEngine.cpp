//
//  AppEngine.cpp
//  ShadowMapping
//
//  Created by Sid on 28/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "AppEngine.h"
#include <cassert>
#include "Debugger.h"
#include "he_File.h"
#include "he_Path.h"
#include "Renderer.h"

enum {
  FBO_Main = 0,
  FBO_Shadow
};

enum {
  RBO_MainColor = 0,
  RBO_MainDepth,
  RBO_Shadow
};

enum {
  Cam_Front = 0,
  Cam_Top
};

enum {
  Sh_DropShadow = 0,
  Sh_Main
};


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
  //  cube_.Init();

  /* eye camera */
  camera_[Cam_Front].SetAspectRatio(screenSize.x/screenSize.y);
  camera_[Cam_Front].SetPosition(GLKVector3Make(0.0f, 0.0f, 25.0f));

  /* light camera */
  camera_[Cam_Top].SetAspectRatio(screenSize.x/screenSize.y);
  camera_[Cam_Top].SetPosition(GLKVector3Make(0.0f, 15.0f, 10.0f));
  camera_[Cam_Top].SetUp(GLKVector3Make(0.0f, 1.0f, -1.0f));

  /* main light */
  light_.SetPosition(GLKVector4Make(0.0f, 0.0f, 1.0f, 0.0f));
  
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
  glGenFramebuffers(2, fbo_);
  glGenRenderbuffers(3, rbo_);

  /* create onscreen framebuffer */
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[FBO_Main]);
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_MainColor]);
  renderbufferStorage();
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rbo_[RBO_MainColor]);
  
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &fboSize_[0]);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &fboSize_[1]);
  
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_MainDepth]);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, fboSize_[0], fboSize_[1]);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo_[RBO_MainDepth]);
  
  assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
  
  /* create shadow framebuffer */
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[FBO_Shadow]);
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_Shadow]);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, fboSize_[0], fboSize_[1]);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rbo_[RBO_Shadow]);

  /* create shadow texture*/
  glActiveTexture(GL_TEXTURE0);
	glGenTextures(1, &shadowTexture_);
  glBindTexture(GL_TEXTURE_2D, shadowTexture_);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT16, fboSize_[0], fboSize_[1], 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT, NULL);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LESS);
  
  /* attach shadow buffer to texture */
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, shadowTexture_, 0);

  assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
}

void AppEngine::destroy_framebuffer()
{
  glDeleteFramebuffers(2, fbo_);
  glDeleteRenderbuffers(3, rbo_);
}

/* MARK: Shader */
void AppEngine::load_shaders()
{
  char shName[4][256] = {
    "DropShadowShader.vsh", "DropShadowShader.fsh",
    "ShadowShader.vsh", "ShadowShader.fsh"
  };
  char vshPathBuffer[1024];
  char fshPathBuffer[1024];
  
  /* Drop shadow shader */
  GetBundlePath(vshPathBuffer, sizeof(vshPathBuffer), shName[0]);
  GetBundlePath(fshPathBuffer, sizeof(fshPathBuffer), shName[1]);
  const char *paths[] = {vshPathBuffer, fshPathBuffer};
  shaders_[Sh_DropShadow].Init(paths, BF_Mask(kAttribPosition));
  
  /* main shader */
  GetBundlePath(vshPathBuffer, sizeof(vshPathBuffer), shName[2]);
  GetBundlePath(fshPathBuffer, sizeof(fshPathBuffer), shName[3]);
  shaders_[Sh_Main].Init(paths, BF_Mask(kAttribPosition) | BF_Mask(kAttribNormal));
}

/* MARK: Loop */
void AppEngine::Update(unsigned int dt)
{
  glEnable(GL_DEPTH_TEST);

  /* pass 1: Create shadow map */
  render_pass1();
  
  /* pass 2 Draw with shadows */
  render_pass2();
  
  /* this should be the final step */
  glBindRenderbuffer(GL_RENDERBUFFER, rbo_[RBO_MainColor]);
  assert(DebugGL() == 0);
}

void AppEngine::render_pass1()
{
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[FBO_Shadow]);
  glClear(GL_DEPTH_BUFFER_BIT);
  
  glCullFace(GL_FRONT);
  glEnable(GL_CULL_FACE);
  
  GLuint program = shaders_[Sh_DropShadow].GetProgram();
  glUseProgram(program);
  
  Renderer renderer;
  renderer.pass = 0;
  renderer.program = program;
  renderer.view = camera_[Cam_Front].GetViewMatrix();
  renderer.projection = camera_[Cam_Front].GetProjectionMatrix();
  
  teapot_.Draw(&renderer);
  quad_.Draw(&renderer);
  //  cube_.Draw(&renderer);

    glDisable(GL_CULL_FACE);
}

void AppEngine::render_pass2()
{
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_[FBO_Main]);
  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glBindTexture(GL_TEXTURE_2D, shadowTexture_);
  
	GLuint program = shaders_[Sh_Main].GetProgram();
  glUseProgram(program);
  
  Renderer renderer;
  renderer.pass = 1;
  renderer.program = program;
  renderer.view = camera_[Cam_Top].GetViewMatrix();
  renderer.projection = camera_[Cam_Top].GetProjectionMatrix();
  renderer.shadowView = camera_[Cam_Front].GetViewMatrix();
  renderer.shadowProjection = camera_[Cam_Front].GetProjectionMatrix();
  
  int light_uv4e_Position = glGetUniformLocation(program, "light.uv4e_Position");
  glUniform4fv(light_uv4e_Position, 1, light_.GetPosition().v);
  
  int light_uv4k_Color = glGetUniformLocation(program, "light.uv4k_Color");
  glUniform4fv(light_uv4k_Color, 1, light_.GetColor().v);
  
  int us2s_Tex0 = glGetUniformLocation(program, "us2s_Tex0");
  glUniform1i(us2s_Tex0, 0);
  
  teapot_.Draw(&renderer);
  quad_.Draw(&renderer);
  //  cube_.Draw(&renderer);
  
  glBindTexture(GL_TEXTURE_2D, 0);
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
