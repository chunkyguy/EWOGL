//
//  Teapot.cpp
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Teapot.h"

#include <OpenGLES/ES2/glext.h>

#include "he_Path.h"
#include "ModelParser.h"
#include "ShaderProgram.h"

bool Teapot::Init()
{
  char buffer[1024];
  GetBundlePath(buffer, sizeof(buffer), "teapot.obj");
  ModelParser teapotModel(buffer);
  
  glGenVertexArraysOES(1, &vao_);
  glGenBuffers(2, vbo_);
  
  /* push data to GPU RAM */
  glBindVertexArrayOES(vao_);
  
  glBindBuffer(GL_ARRAY_BUFFER, vbo_[0]);
  glBufferData(GL_ARRAY_BUFFER,
               sizeof(Vertex) * teapotModel.GetVertexCount(),
               reinterpret_cast<GLfloat*>(teapotModel.GetVertexData()),
               GL_STATIC_DRAW);
  
  glEnableVertexAttribArray(kAttribPosition);
  glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
  
  glEnableVertexAttribArray(kAttribNormal);
  glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), reinterpret_cast<GLvoid*>(sizeof(GLKVector3)));
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo_[1]);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER,
               teapotModel.GetFaceCount() * sizeof(Face),
               reinterpret_cast<GLushort*>(teapotModel.GetFaceData()),
               GL_STATIC_DRAW);
  
  
  glBindVertexArrayOES(0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  
  glDisableVertexAttribArray(kAttribPosition);
  glDisableVertexAttribArray(kAttribNormal);
  
  indexCount_ = teapotModel.GetIndexCount();
  
  trackball_.SetRadius(160.0f);
  
  init_ = true;
  return init_;
}

Teapot::~Teapot()
{
  if (init_) {
    glDeleteBuffers(2, vbo_);
    glDeleteVertexArraysOES(1, &vao_);
  }
}

void Teapot::Draw(const Renderer *renderer) const
{
  glBindVertexArrayOES(vao_);
  
  
  GLKMatrix4 mMat = GLKMatrix4MakeWithQuaternion(trackball_.GetOrientation());
 
  //  GLKMatrix4 mMat = GLKMatrix4Multiply(tMat, rMat);
  GLKMatrix4 mvMat = GLKMatrix4Multiply(renderer->view, mMat);
  
  GLKMatrix4 mvpMat = GLKMatrix4Multiply(renderer->projection, mvMat);
  int um4k_Modelviewproj = glGetUniformLocation(renderer->program, "um4k_Modelviewproj");
  glUniformMatrix4fv(um4k_Modelviewproj, 1, GL_FALSE, mvpMat.m);

  if (renderer->pass == 1) {
    
    GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
    int um3k_Normal = glGetUniformLocation(renderer->program, "um3k_Normal");
    glUniformMatrix3fv(um3k_Normal, 1, GL_FALSE, nMat.m);
    
    GLKMatrix4 shadowBasis = GLKMatrix4Make(0.5f, 0.0f, 0.0f, 0.0f,
                                            0.0f, 0.5f, 0.0f, 0.0f,
                                            0.0f, 0.0f, 0.5f, 0.0f,
                                            0.5f, 0.5f, 0.5f, 1.0f);

    GLKVector4 t = GLKVector4Make(-1, 0, 1, 1);
    //    GLKVector4 t_expect = GLKVector4Make(1, 0.5f, 0, 1);
        GLKVector4 t_expect = GLKVector4Make(0, 0.5f, 1, 1);
    GLKVector4 t_actual = GLKMatrix4MultiplyVector4(shadowBasis, t);
    assert(GLKVector4AllEqualToVector4(t_expect, t_actual));
    
    GLKMatrix4 shadowMat = GLKMatrix4Multiply(shadowBasis,
                                              GLKMatrix4Multiply(renderer->shadowProjection,
                                                                 GLKMatrix4Multiply(renderer->shadowView, mMat)));
    int um4k_Shadow = glGetUniformLocation(renderer->program, "um4k_Shadow");
    glUniformMatrix4fv(um4k_Shadow, 1, GL_FALSE, shadowMat.m);
    
    int um4k_Modelview = glGetUniformLocation(renderer->program, "um4k_Modelview");
    glUniformMatrix4fv(um4k_Modelview, 1, GL_FALSE, mvMat.m);

    int material_uv4k_Color = glGetUniformLocation(renderer->program, "material.uv4k_Color");
    glUniform4f(material_uv4k_Color, 0.0f, 0.6f, 0.7f, 1.0f);

    int material_ufk_Gloss = glGetUniformLocation(renderer->program, "material.ufk_Gloss");
    glUniform1f(material_ufk_Gloss, 30.0f);
    
  }
  
  glDrawElements(GL_TRIANGLES, indexCount_, GL_UNSIGNED_SHORT, NULL);
  
  glBindVertexArrayOES(0);
}

void Teapot::Update(const unsigned int dt)
{}

void Teapot::TouchBegan(const GLKVector2 &point)
{
  trackball_.TouchBegan(point);
}

void Teapot::TouchEnd(const GLKVector2 &point)
{
  trackball_.TouchEnded(point);
}

void Teapot::TouchMove(const GLKVector2 &point)
{
  trackball_.TouchMoved(point);
}
