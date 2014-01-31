//
//  Cube.cpp
//  ShadowMapping
//
//  Created by Sid on 31/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Cube.h"
#include "ShaderProgram.h"

bool Cube::Init()
{
	GLfloat g_CubeVertexData[216] = {
		// Data layout for each line below is:
		// positionX, positionY, positionZ,     normalX, normalY, normalZ,
		0.5f, -0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
		0.5f, 0.5f, -0.5f,         -1.0f, 0.0f, 0.0f,
		0.5f, -0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
		0.5f, -0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
		0.5f, 0.5f, -0.5f,         -1.0f, 0.0f, 0.0f,
		0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
		
		0.5f, 0.5f, -0.5f,         0.0f, -1.0f, 0.0f,
		-0.5f, 0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
		0.5f, 0.5f, 0.5f,          0.0f, -1.0f, 0.0f,
		0.5f, 0.5f, 0.5f,          0.0f, -1.0f, 0.0f,
		-0.5f, 0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
		
		-0.5f, 0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
		-0.5f, -0.5f, -0.5f,       1.0f, 0.0f, 0.0f,
		-0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
		-0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
		-0.5f, -0.5f, -0.5f,       1.0f, 0.0f, 0.0f,
		-0.5f, -0.5f, 0.5f,        1.0f, 0.0f, 0.0f,
		
		-0.5f, -0.5f, -0.5f,       0.0f, 1.0f, 0.0f,
		0.5f, -0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
		-0.5f, -0.5f, 0.5f,        0.0f, 1.0f, 0.0f,
		-0.5f, -0.5f, 0.5f,        0.0f, 1.0f, 0.0f,
		0.5f, -0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
		0.5f, -0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
		
		0.5f, 0.5f, 0.5f,          0.0f, 0.0f, -1.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 0.0f, -1.0f,
		0.5f, -0.5f, 0.5f,         0.0f, 0.0f, -1.0f,
		0.5f, -0.5f, 0.5f,         0.0f, 0.0f, -1.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 0.0f, -1.0f,
		-0.5f, -0.5f, 0.5f,        0.0f, 0.0f, -1.0f,
		
		0.5f, -0.5f, -0.5f,        0.0f, 0.0f, 1.0f,
		-0.5f, -0.5f, -0.5f,       0.0f, 0.0f, 1.0f,
		0.5f, 0.5f, -0.5f,         0.0f, 0.0f, 1.0f,
		0.5f, 0.5f, -0.5f,         0.0f, 0.0f, 1.0f,
		-0.5f, -0.5f, -0.5f,       0.0f, 0.0f, 1.0f,
		-0.5f, 0.5f, -0.5f,        0.0f, 0.0f, 1.0f
	};
  

	vertexCount_ = 36;
	
	/* Generate + bind the VAO */
	glGenVertexArrays(1, &vao_);
	glBindVertexArray(vao_);
	
	/* Generate + bind the VBO */
	glGenBuffers(1, &vbo_);
	glBindBuffer(GL_ARRAY_BUFFER, vbo_);
	
	/* Set the buffer's data */
	glBufferData(GL_ARRAY_BUFFER, sizeof(g_CubeVertexData), g_CubeVertexData, GL_STATIC_DRAW);
	
	/*	Enable the custom vertex attributes at some indices (for eg. kAttribPosition).
	 We previously binded those indices to the variables in our shader (for eg. vec4 a_Position)
	 */
	glEnableVertexAttribArray(kAttribPosition);
	glEnableVertexAttribArray(kAttribNormal);
	
	/* Sets the vertex data to enabled attribute indices */
	GLsizei stride = 6 * sizeof(g_CubeVertexData[0]);
	GLvoid *position_offset = (GLvoid*)(0 * sizeof(g_CubeVertexData[0]));
	GLvoid *normal_offset = (GLvoid*)(3 * sizeof(g_CubeVertexData[0]));
	glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, position_offset);
	glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, normal_offset);
	
	/* Unbind the VAO */
	glBindVertexArray(0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);

  glDisableVertexAttribArray(kAttribPosition);
  glDisableVertexAttribArray(kAttribNormal);
  
  init_ = true;
  return init_;
}

Cube::~Cube()
{
  if (init_) {
    glDeleteVertexArrays(1, &vao_);
    glDeleteBuffers(1, &vbo_);
  }
}

void Cube::Update(const unsigned int dt)
{
  
}

void Cube::Draw(const Renderer *renderer) const
{  
	glEnableVertexAttribArray(kAttribPosition);
	glEnableVertexAttribArray(kAttribNormal);

  glBindVertexArray(vao_);

  float scale = 20.0f;
  GLKMatrix4 mMat = GLKMatrix4MakeScale(scale, scale, scale);
  
  //  GLKMatrix4 mMat = GLKMatrix4Multiply(tMat, rMat);
  GLKMatrix4 mvMat = GLKMatrix4Multiply(renderer->view, mMat);
  
  GLKMatrix4 mvpMat = GLKMatrix4Multiply(renderer->projection, mvMat);
  int um4k_Modelviewproj = glGetUniformLocation(renderer->program, "um4k_Modelviewproj");
  glUniformMatrix4fv(um4k_Modelviewproj, 1, GL_FALSE, mvpMat.m);
  
  if (renderer->pass == 1) {
    
    GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
    int um3k_Normal = glGetUniformLocation(renderer->program, "um3k_Normal");
    glUniformMatrix3fv(um3k_Normal, 1, GL_FALSE, nMat.m);
    
    GLKMatrix4 shadowBasis = GLKMatrix4Make(0.5f, 0.0f, 0.0f, 0.5f,
                                            0.0f, 0.5f, 0.0f, 0.5f,
                                            0.0f, 0.0f, 0.5f, 0.5f,
                                            0.0f, 0.0f, 0.0f, 1.0f);
    
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
  
  glDrawArrays(GL_TRIANGLES, 0, vertexCount_);
  
  glBindVertexArray(0);

  glDisableVertexAttribArray(kAttribPosition);
  glDisableVertexAttribArray(kAttribNormal);
}

