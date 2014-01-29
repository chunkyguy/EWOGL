//
//  RenderingEngine.cpp
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "RenderingEngine.h"
#include "Camera.h"
#include "ShaderProgram.h"
#include "IGeometry.h"

RenderingEngine::RenderingEngine() :
screenSize_(GLKVector2Make(0.0f, 0.0f))
{}

bool RenderingEngine::Init(const GLKVector2 &screenSize)
{
  screenSize_ = screenSize;
  renderer_.projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f), screenSize_.x/screenSize_.y, 0.1f, 100.0f);
  
  glEnable(GL_DEPTH_TEST);
  
  init_ = true;
  return init_;
}


void RenderingEngine::Draw(const ShaderProgram *shader, const IGeometry *geometry, const Camera *camera)
{ 
  GLuint program = shader->GetProgram();

  glUseProgram(program);
  renderer_.program = program;
  renderer_.view = camera->GetViewMatrix();
  
  geometry->Draw(&renderer_);
}
