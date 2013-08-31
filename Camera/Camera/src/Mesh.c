//
//  Cube.c
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "std_incl.h"
#include "Mesh.h"
#include "Constants.h"

Mesh CubeMesh() {
	GLfloat g_CubeVertexData[216] = {
		// Data layout for each line below is:
		// positionX, positionY, positionZ,     normalX, normalY, normalZ,
		0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
		0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
		0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
		0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
		0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
		0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
		
		0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
		-0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
		0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
		0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
		-0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
		
		-0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
		-0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
		-0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
		-0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
		-0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
		-0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
		
		-0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
		0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
		-0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
		-0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
		0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
		0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
		
		0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		-0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
		
		0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
		-0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
		0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
		0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
		-0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
		-0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
	};

	Mesh cube;
	cube.tri_count = 36;
	
	/* Generate + bind the VAO */
	glGenVertexArraysOES(1, &cube.vao);
	assert(cube.vao);
	glBindVertexArrayOES(cube.vao);
	
	/* Generate + bind the VBO */
	glGenBuffers(1, &cube.vbo);
	assert(cube.vbo);
	glBindBuffer(GL_ARRAY_BUFFER, cube.vbo);
	
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
	
	return cube;
}

void TearDown_Mesh(const Mesh mesh) {
	glDeleteBuffers(1, &mesh.vbo);
	glDeleteVertexArraysOES(1, &mesh.vao);
}

//EOF
