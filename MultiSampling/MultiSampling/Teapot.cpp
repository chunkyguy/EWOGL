//
//  Teapot.cpp
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Teapot.h"

#include <OpenGLES/ES2/glext.h>

#include "ResourcePath.h"
#include "Constants.h"
#include "ModelParser.h"
#include "Renderer.h"

Teapot::Teapot()
{
  char buffer[1024];
  ModelParser teapotModel(BundlePath(buffer, sizeof(buffer), "teapot.obj"));

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
}

Teapot::~Teapot()
{
  glDeleteBuffers(2, vbo_);
  glDeleteVertexArraysOES(1, &vao_);
}

void Teapot::Draw(const Renderer *renderer)
{
  glBindVertexArrayOES(vao_);
  
  int um4k_Modelview = glGetUniformLocation(renderer->program, "um4k_Modelview");
  int um3k_Normal = glGetUniformLocation(renderer->program, "um3k_Normal");
  int um4k_Modelviewproj = glGetUniformLocation(renderer->program, "um4k_Modelviewproj");
  int light_uv4e_Position = glGetUniformLocation(renderer->program, "light.uv4e_Position");
  int material_uv4k_Diffuse = glGetUniformLocation(renderer->program, "material.uv4k_Diffuse");
  int material_ufk_Gloss = glGetUniformLocation(renderer->program, "material.ufk_gloss");
  int light_uv4k_Color = glGetUniformLocation(renderer->program, "light.uv4k_Color");
  
  GLKMatrix4 tMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -15.0f);
  GLKMatrix4 rMat = GLKMatrix4MakeWithQuaternion(trackball_.GetOrientation());
  //mvMat = GLKMatrix4Rotate(mvMat, GLKMathDegreesToRadians(-90.0f), -1.0f, 1.0f, 0.0f);
  GLKMatrix4 mvMat = GLKMatrix4Multiply(tMat, rMat);
  glUniformMatrix4fv(um4k_Modelview, 1, GL_FALSE, mvMat.m);

  GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
  glUniformMatrix3fv(um3k_Normal, 1, GL_FALSE, nMat.m);
  
  GLKMatrix4 mvpMat = GLKMatrix4Multiply(renderer->projection, mvMat);
  glUniformMatrix4fv(um4k_Modelviewproj, 1, GL_FALSE, mvpMat.m);
  
  glUniform4f(light_uv4e_Position, 0.0f, 0.0f, 1.0f, 1.0f);
  glUniform4f(light_uv4k_Color, 1.0f, 1.0f, 0.0f, 1.0f);
  glUniform4f(material_uv4k_Diffuse, 0.0f, 1.0f, 1.0f, 1.0f);
  glUniform1f(material_ufk_Gloss, 30.0f);
  
  glDrawElements(GL_TRIANGLES, indexCount_, GL_UNSIGNED_SHORT, NULL);

  glBindVertexArrayOES(0);
}

void Teapot::Update(const int dt)
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
