//
//  Loop.c
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include <stdio.h>
#include <assert.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <GLKit/GLKMath.h>

#include "Loop.h"
#include "Constants.h"
#include "Cube.h"

GLuint	vbo_;
GLuint	vao_;

void BindAttributes(Program *program) {
	// Bind the custom vertex attribute "a_Position" to location VERTEX_ARRAY
	glBindAttribLocation(program->program, kAttribPosition, "a_Position");
	glBindAttribLocation(program->program, kAttribNormal, "a_Normal");
}


void Init() {
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	
	glEnable(GL_DEPTH_TEST);
	
	/* Generate + bind the VAO */
	glGenVertexArraysOES(1, &vao_);
	assert(vao_);
	glBindVertexArrayOES(vao_);
	
	/* Generate + bind the VBO */
	glGenBuffers(1, &vbo_);
	assert(vbo_);
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
	glBindVertexArrayOES(0);
}

void Destroy() {
	glDisableVertexAttribArray(kAttribPosition);
	glDisableVertexAttribArray(kAttribNormal);
	glDeleteBuffers(1, &vbo_);
	glDeleteVertexArraysOES(1, &vao_);
}

void Update(int dt) {
}

void Render(const Program program) {
	/* Matrices used */
	GLKMatrix4 pMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), 1.0f, 0.1f, 100.0f);
	GLKMatrix4 tMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
	GLKMatrix4 rMat = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(45.0f), 1.0f, 1.0f, 1.0f);
	GLKMatrix4 mvMat = GLKMatrix4Multiply(tMat, rMat);
	GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), 0);
	GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
	
	/*	Bind the data to the associated uniform variable in the shader
		First gets the location of that variable in the shader using its name
		Then passes the matrix to that variable
	 */
	int mvp_loc = glGetUniformLocation(program.program, "u_Mvp");
	glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, mvpMat.m);
	int n_loc = glGetUniformLocation(program.program, "u_N");
	glUniformMatrix3fv(n_loc, 1, GL_FALSE, nMat.m);

	// Bind the VAO
	glBindVertexArrayOES(vao_);
	
	
	/*
	 Draws a non-indexed triangle array from the pointers previously given.
	 This function allows the use of other primitive types : triangle strips, lines, ...
	 For indexed geometry, use the function glDrawElements() with an index list.
	 */
	glDrawArrays(GL_TRIANGLES, 0, 36);
	
	// Unbind the VAO
	glBindVertexArrayOES(0);
}
