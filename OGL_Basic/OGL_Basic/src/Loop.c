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

GLuint				m_ui32Vbo;


void Init() {
	glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
	
	// We're going to draw a triangle to the screen so create a vertex buffer object for our triangle
	// Interleaved vertex data
	GLfloat afVertices[] = {
		-0.4f,-0.4f,0.0f, // Position
		0.4f ,-0.4f,0.0f,
		0.0f ,0.4f ,0.0f };
	
	// Generate the vertex buffer object (VBO)
	glGenBuffers(1, &m_ui32Vbo);
	
	// Bind the VBO so we can fill it with data
	glBindBuffer(GL_ARRAY_BUFFER, m_ui32Vbo);
	
	// Set the buffer's data
	unsigned int uiSize = 3 * (sizeof(GLfloat) * 3); // Calc afVertices size (3 vertices * stride (3 GLfloats per vertex))
	glBufferData(GL_ARRAY_BUFFER, uiSize, afVertices, GL_STATIC_DRAW);
}

void Update(int dt) {
}

void Render() {
	
	// Bind the VBO
	glBindBuffer(GL_ARRAY_BUFFER, m_ui32Vbo);
	
	/*
	 Enable the custom vertex attribute at index VERTEX_ARRAY.
	 We previously binded that index to the variable in our shader "vec4 MyVertex;"
	 */
	glEnableVertexAttribArray(VERTEX_ARRAY);
	
	// Sets the vertex data to this attribute index
	glVertexAttribPointer(VERTEX_ARRAY, 3, GL_FLOAT, GL_FALSE, 0, 0);
	
	/*
	 Draws a non-indexed triangle array from the pointers previously given.
	 This function allows the use of other primitive types : triangle strips, lines, ...
	 For indexed geometry, use the function glDrawElements() with an index list.
	 */
	glDrawArrays(GL_TRIANGLES, 0, 3);
	
	// Unbind the VBO
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}
