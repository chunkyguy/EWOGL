//
//  RenderingEngine.cpp
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "RenderingEngine.h"
#include <OpenGLES/ES2/gl.h>
#include "ShaderProgram.h"

RenderingEngine::RenderingEngine() :
shader_(nullptr),
screenSize_(GLKVector2Make(0.0f, 0.0f))
{}

bool RenderingEngine::Init(const GLKVector2 &screenSize)
{
  screenSize_ = screenSize;
  return true;
}

void RenderingEngine::BindShader(const ShaderProgram *shader)
{
  shader_ = shader;
}

void RenderingEngine::DrawFrame()
{
  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 
  GLuint program = shader_->GetProgram();

  glUseProgram(program);
  
  GLfloat pData[] = {
    -0.5f, -0.5f,
    0.5f, -0.5f,
    -0.5f, 0.5f,
    0.5f, 0.5f
  };
  glEnableVertexAttribArray(kAttribPosition);
  glVertexAttribPointer(kAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(pData[0]) * 2, pData);
  
  GLfloat nData[] = {
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f
  };
  glEnableVertexAttribArray(kAttribNormal);
  glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(nData[0]*3), nData);
  
  int um4k_Modelview = glGetUniformLocation(program, "um4k_Modelview");
  int um3k_Normal = glGetUniformLocation(program, "um3k_Normal");
  int um4k_Modelviewproj = glGetUniformLocation(program, "um4k_Modelviewproj");
  int light_uv4e_Position = glGetUniformLocation(program, "light.uv4e_Position");
  int light_uv4k_Color = glGetUniformLocation(program, "light.uv4k_Color");
  int material_uv4k_Color = glGetUniformLocation(program, "material.uv4k_Color");
  int material_uf1k_Gloss = glGetUniformLocation(program, "material.uf1k_Gloss");
  
  GLKMatrix4 mvMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
  glUniformMatrix4fv(um4k_Modelview, 1, GL_FALSE, mvMat.m);
  
  GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
  glUniformMatrix3fv(um3k_Normal, 1, GL_FALSE, nMat.m);
  
  GLKMatrix4 pMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f), screenSize_.x/screenSize_.y, 0.1f, 100.0f);
  GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
  glUniformMatrix4fv(um4k_Modelviewproj, 1, GL_FALSE, mvpMat.m);
  
  glUniform4f(light_uv4e_Position, 1.0f, 1.0f, 1.0f, 1.0f);
  glUniform4f(light_uv4k_Color, 1.0f, 0.0f, 0.0f, 1.0f);
  glUniform4f(material_uv4k_Color, 0.0f, 1.0f, 0.0f, 1.0f);
  glUniform1f(material_uf1k_Gloss, 4.0f);
  
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
