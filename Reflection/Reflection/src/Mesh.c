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

Mesh create_mesh(int triangles, size_t data_size, GLfloat *data) {
	Mesh mesh;
	mesh.tri_count = triangles;
	
	/* Generate + bind the VAO */
	glGenVertexArraysOES(1, &mesh.vao);
	assert(mesh.vao);
	glBindVertexArrayOES(mesh.vao);
	
	/* Generate + bind the VBO */
	glGenBuffers(1, &mesh.vbo);
	assert(mesh.vbo);
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo);
	
	/* Set the buffer's data */
	glBufferData(GL_ARRAY_BUFFER, data_size, data, GL_STATIC_DRAW);
	
	/*	Enable the custom vertex attributes at some indices (for eg. kAttribPosition).
	 We previously binded those indices to the variables in our shader (for eg. vec4 a_Position)
	 */
	glEnableVertexAttribArray(kAttribPosition);
	glEnableVertexAttribArray(kAttribNormal);
	
	/* Sets the vertex data to enabled attribute indices */
	GLsizei stride = 6 * sizeof(data[0]);
	GLvoid *position_offset = (GLvoid*)(0 * sizeof(data[0]));
	GLvoid *normal_offset = (GLvoid*)(3 * sizeof(data[0]));
	glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, position_offset);
	glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, normal_offset);
	
	/* Unbind the VAO */
	glBindVertexArrayOES(0);
	
	return mesh;
}

Mesh CubeMesh() {
	GLfloat cubeVertexData[216] = {
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

	return create_mesh(12, sizeof(cubeVertexData), cubeVertexData);
}

Mesh SquareMesh() {
	GLfloat squareVertexData[] = {
		// Data layout for each line below is:
		// positionX, positionY, positionZ,     normalX, normalY, normalZ,
		0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,

		0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		-0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
	};

	return create_mesh(2, sizeof(squareVertexData), squareVertexData);
}

Mesh TriangleMesh() {
	GLfloat triVertexData[] = {
		// Data layout for each line below is:
		// positionX, positionY, positionZ,     normalX, normalY, normalZ,
		-0.5f, -0.5f, 0.0f,        0.0f, 0.0f, 1.0f,
		0.5f, -0.5f, 0.0f,         0.0f, 0.0f, 1.0f,
		0.0f, 0.5f, 0.0f,         0.0f, 0.0f, 1.0f,
	};

	return create_mesh(1, sizeof(triVertexData), triVertexData);
}

void TearDown_Mesh(const Mesh mesh) {
	glDeleteBuffers(1, &mesh.vbo);
	glDeleteVertexArraysOES(1, &mesh.vao);

}

//EOF
