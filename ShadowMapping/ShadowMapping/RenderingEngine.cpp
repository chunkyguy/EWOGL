//
//  RenderingEngine.cpp
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "RenderingEngine.h"
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


void RenderingEngine::DrawFrame(const ShaderProgram *shader, const IGeometry *geometry)
{ 
  GLuint program = shader->GetProgram();

  glUseProgram(program);
  renderer_.program = program;
  //  GeometryRenderer geoRenderer(geometry);
  
//  GLfloat pData[] = {
//    -0.5f, -0.5f,
//    0.5f, -0.5f,
//    -0.5f, 0.5f,
//    0.5f, 0.5f
//  };
//  glEnableVertexAttribArray(kAttribPosition);
//  glVertexAttribPointer(kAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(pData[0]) * 2, pData);
//  
//  GLfloat nData[] = {
//    0.0f, 0.0f, 1.0f,
//    0.0f, 0.0f, 1.0f,
//    0.0f, 0.0f, 1.0f,
//    0.0f, 0.0f, 1.0f
//  };
//  glEnableVertexAttribArray(kAttribNormal);
//  glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(nData[0]*3), nData);
  
  
  geometry->Draw(&renderer_);
  //  geoRenderer.Draw();
//  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
