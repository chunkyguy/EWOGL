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
  GLKMatrix4 mMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -3.0f);
  mMat =  GLKMatrix4Rotate(mMat, GLKMathDegreesToRadians(-90.0f), 1.0f, 0.0f, 0.0f);
  mMat = GLKMatrix4Scale(mMat, 10.0f, 10.0f, 1.0f);
  
  GLKMatrix4 mvMat = GLKMatrix4Multiply(renderer->view, mMat);
  
  GLKMatrix4 pMat = renderer->projection;
  GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
  int um4k_Modelviewproj = glGetUniformLocation(renderer->program, "um4k_Modelviewproj");
  glUniformMatrix4fv(um4k_Modelviewproj, 1, GL_FALSE, mvpMat.m);
  
  GLfloat pData[] = {
    -0.5f, -0.5f, 0.0f,
    0.5f, -0.5f, 0.0f,
    -0.5f, 0.5f, 0.0f,
    0.5f, 0.5f, 0.0f
  };
  glEnableVertexAttribArray(kAttribPosition);
  glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, NULL, pData);  
  
  if (renderer->pass == 1) {
    
    GLfloat nData[] = {
      0.0f, 0.0f, 1.0f,
      0.0f, 0.0f, 1.0f,
      0.0f, 0.0f, 1.0f,
      0.0f, 0.0f, 1.0f
    };
    glEnableVertexAttribArray(kAttribNormal);
    glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, NULL, nData);

    int um4k_Modelview = glGetUniformLocation(renderer->program, "um4k_Modelview");
    glUniformMatrix4fv(um4k_Modelview, 1, GL_FALSE, mvMat.m);

    bool canNormal = true;
    GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), &canNormal);
    assert(canNormal);
    int um3k_Normal = glGetUniformLocation(renderer->program, "um3k_Normal");
    glUniformMatrix3fv(um3k_Normal, 1, GL_FALSE, nMat.m);
    
    GLKMatrix4 basisMat = GLKMatrix4Make(0.5f, 0.0f, 0.0f, 0.0f,
                                         0.0f, 0.5f, 0.0f, 0.0f,
                                         0.0f, 0.0f, 0.5f, 0.0f,
                                         0.5f, 0.5f, 0.5f, 1.0f);
    GLKMatrix4 shadowMat = GLKMatrix4Multiply(basisMat,
                                              GLKMatrix4Multiply(renderer->shadowProjection,
                                                                 GLKMatrix4Multiply(renderer->shadowView ,mMat)));
    int um4k_Shadow = glGetUniformLocation(renderer->program, "um4k_Shadow");
    glUniformMatrix4fv(um4k_Shadow, 1, GL_FALSE, shadowMat.m);
    
    int material_uv4k_Color = glGetUniformLocation(renderer->program, "material.uv4k_Color");
    glUniform4f(material_uv4k_Color, 1.0f, 1.0f, 0.0f, 1.0f);
    
    int material_uf1k_Gloss = glGetUniformLocation(renderer->program, "material.uf1k_Gloss");
    glUniform1f(material_uf1k_Gloss, 10.0f);
    
	}

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  
  glDisableVertexAttribArray(kAttribPosition);
  glDisableVertexAttribArray(kAttribNormal);
}

