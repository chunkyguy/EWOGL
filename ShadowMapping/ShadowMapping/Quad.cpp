//
//  Quad.cpp
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Quad.h"
#include <OpenGLES/ES2/gl.h>
#include "ShaderProgram.h"

bool Quad::Init()
{
  init_ = true;
  return init_;
}

Quad::~Quad()
{
  if (!init_) {
    return;
  }
}

void Quad::Update(const unsigned int dt)
{
}

void Quad::Draw(const Renderer *renderer) const
{
  int um4k_Modelview = glGetUniformLocation(renderer->program, "um4k_Modelview");
  int um3k_Normal = glGetUniformLocation(renderer->program, "um3k_Normal");
  int um4k_Modelviewproj = glGetUniformLocation(renderer->program, "um4k_Modelviewproj");
  int light_uv4e_Position = glGetUniformLocation(renderer->program, "light.uv4e_Position");
  int light_uv4k_Color = glGetUniformLocation(renderer->program, "light.uv4k_Color");
  int material_uv4k_Color = glGetUniformLocation(renderer->program, "material.uv4k_Color");
  int material_uf1k_Gloss = glGetUniformLocation(renderer->program, "material.uf1k_Gloss");
  
  GLKMatrix4 mvMat = GLKMatrix4MakeTranslation(0.0f, -2.0f, -15.0f);
  mvMat = GLKMatrix4Rotate(mvMat, GLKMathDegreesToRadians(-85.0f), 1.0f, 0.0f, 0.0f);
  mvMat = GLKMatrix4Scale(mvMat, 10.0f, 10.0f, 1.0f);
  glUniformMatrix4fv(um4k_Modelview, 1, GL_FALSE, mvMat.m);
  
  bool canNormal = true;
  GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), &canNormal);
  assert(canNormal);
  glUniformMatrix3fv(um3k_Normal, 1, GL_FALSE, nMat.m);
  
  GLKMatrix4 pMat = renderer->projection;
  GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
  glUniformMatrix4fv(um4k_Modelviewproj, 1, GL_FALSE, mvpMat.m);
  
  glUniform4f(light_uv4e_Position, 0.0f, 3.0f, 0.0f, 1.0f);
  glUniform4f(light_uv4k_Color, 1.0f, 1.0f, 1.0f, 1.0f);
  
  glUniform4f(material_uv4k_Color, 0.9f, 0.8f, 0.7f, 1.0f);
  glUniform1f(material_uf1k_Gloss, 10.0f);
  
  GLfloat pData[] = {
    -0.5f, -0.5f, 0.0f,
    0.5f, -0.5f, 0.0f,
    -0.5f, 0.5f, 0.0f,
    0.5f, 0.5f, 0.0f
  };
  glEnableVertexAttribArray(kAttribPosition);
  glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, NULL, pData);
  
  GLfloat nData[] = {
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f
  };
  glEnableVertexAttribArray(kAttribNormal);
  glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, NULL, nData);
  
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  
  glDisableVertexAttribArray(kAttribPosition);
  glDisableVertexAttribArray(kAttribNormal);
}

