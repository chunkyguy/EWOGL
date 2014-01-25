//
//  AppEngine.cpp
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "AppEngine.h"

#include "RenderingEngine.h"
#include "Teapot.h"
#include "ShaderProgram.h"
#include "ResourcePath.h"
#include "he_BitFlag.h"
#include "Constants.h"

AppEngine::AppEngine(const size_t width, const size_t height, RenderingEngine *renderer) :
width_(width),
height_(height),
renderer_(renderer)
{
  char path[2][1024];
  shader_ = new ShaderProgram(BundlePath(path[0], 1024, "ColorShader.vsh"),
                              BundlePath(path[1], 1024, "ColorShader.fsh"),
                              BF_Mask(kAttribPosition) | BF_Mask(kAttribNormal));
  
  teapot_ = new Teapot;
}

AppEngine::~AppEngine()
{
  delete renderer_;
  delete shader_;
  delete teapot_;
}

void AppEngine::UpdateAndDraw(unsigned int dt)
{
  renderer_->BindGeometry(teapot_);
  renderer_->BindShader(shader_);
  renderer_->Draw(width_, height_, dt);
}

void AppEngine::TouchBegan(const GLKVector2 &point)
{
  
}

void AppEngine::TouchEnd(const GLKVector2 &point)
{
  
}

void AppEngine::TouchMove(const GLKVector2 &point)
{
  
}

