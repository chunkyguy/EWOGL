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

#include "Loop.h"
#include "Constants.h"

GLuint	vbo_;

void BindAttributes(Program *program) {
	// Bind the custom vertex attribute "a_Position" to location VERTEX_ARRAY
	glBindAttribLocation(program->program, kAttribPosition, "a_Position");
}


void Init() {
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	
	// We're going to draw a triangle to the screen so create a vertex buffer object for our triangle
	// Interleaved vertex data
	GLfloat position_data[] = {
		-0.4f,-0.4f,0.0f, // Position
		0.4f ,-0.4f,0.0f,
		0.0f ,0.4f ,0.0f };
	
	// Generate the vertex buffer object (VBO)
	glGenBuffers(1, &vbo_);
	assert(vbo_);
	
	// Bind the VBO so we can fill it with data
	glBindBuffer(GL_ARRAY_BUFFER, vbo_);
	
	// Set the buffer's data
	unsigned int uiSize = 3 * (sizeof(GLfloat) * 3); // Calc afVertices size (3 vertices * stride (3 GLfloats per vertex))
	glBufferData(GL_ARRAY_BUFFER, uiSize, position_data, GL_STATIC_DRAW);
}

void Update(int dt) {
}

void Render(const Program program) {
	// Matrix used for projection model view (u_Mvp)
	float pfIdentity[] = {
		1.0f,0.0f,0.0f,0.0f,
		0.0f,1.0f,0.0f,0.0f,
		0.0f,0.0f,1.0f,0.0f,
		0.0f,0.0f,0.0f,1.0f
	};
	
	/*
	 Bind the projection model view matrix (u_Mvp) to
	 the associated uniform variable in the shader
	 */
	
	// First gets the location of that variable in the shader using its name
	int mvp_loc = glGetUniformLocation(program.program, "u_Mvp");
	
	// Then passes the matrix to that variable
	glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, pfIdentity);

	// Bind the VBO
	glBindBuffer(GL_ARRAY_BUFFER, vbo_);
	
	/*
	 Enable the custom vertex attribute at index VERTEX_ARRAY.
	 We previously binded that index to the variable in our shader "vec4 a_Position;"
	 */
	glEnableVertexAttribArray(kAttribPosition);
	
	// Sets the vertex data to this attribute index
	glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, 0);
	
	/*
	 Draws a non-indexed triangle array from the pointers previously given.
	 This function allows the use of other primitive types : triangle strips, lines, ...
	 For indexed geometry, use the function glDrawElements() with an index list.
	 */
	glDrawArrays(GL_TRIANGLES, 0, 3);
	
	// Unbind the VBO
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}
