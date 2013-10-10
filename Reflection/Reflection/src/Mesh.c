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
#include "Transform.h"

/*******************************************************************************
 MARK: Private functions
 ******************************************************************************/
static Mesh *create_mesh(Mesh *mesh, int triangles, size_t data_size, GLfloat *data) {
	mesh->tri_count = triangles;
	
	/* Generate + bind the VAO */
	glGenVertexArraysOES(1, &mesh->vao);
	assert(mesh->vao);
	glBindVertexArrayOES(mesh->vao);
	
	/* Generate + bind the VBO */
	glGenBuffers(1, &mesh->vbo);
	assert(mesh->vbo);
	glBindBuffer(GL_ARRAY_BUFFER, mesh->vbo);
	
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

static Mesh *create_cube_mesh(Mesh *mesh) {
	GLfloat cubeVertexData[216] = {
		// Data layout for each line below is:
		// positionX, positionY, positionZ,     normalX, normalY, normalZ,
		1.0f, -1.0f, -1.0f,        1.0f, 0.0f, 0.0f,
		1.0f, 1.0f, -1.0f,         1.0f, 0.0f, 0.0f,
		1.0f, -1.0f, 1.0f,         1.0f, 0.0f, 0.0f,
		1.0f, -1.0f, 1.0f,         1.0f, 0.0f, 0.0f,
		1.0f, 1.0f, -1.0f,          1.0f, 0.0f, 0.0f,
		1.0f, 1.0f, 1.0f,         1.0f, 0.0f, 0.0f,
		
		1.0f, 1.0f, -1.0f,         0.0f, 1.0f, 0.0f,
		-1.0f, 1.0f, -1.0f,        0.0f, 1.0f, 0.0f,
		1.0f, 1.0f, 1.0f,          0.0f, 1.0f, 0.0f,
		1.0f, 1.0f, 1.0f,          0.0f, 1.0f, 0.0f,
		-1.0f, 1.0f, -1.0f,        0.0f, 1.0f, 0.0f,
		-1.0f, 1.0f, 1.0f,         0.0f, 1.0f, 0.0f,
		
		-1.0f, 1.0f, -1.0f,        -1.0f, 0.0f, 0.0f,
		-1.0f, -1.0f, -1.0f,       -1.0f, 0.0f, 0.0f,
		-1.0f, 1.0f, 1.0f,         -1.0f, 0.0f, 0.0f,
		-1.0f, 1.0f, 1.0f,         -1.0f, 0.0f, 0.0f,
		-1.0f, -1.0f, -1.0f,       -1.0f, 0.0f, 0.0f,
		-1.0f, -1.0f, 1.0f,        -1.0f, 0.0f, 0.0f,
		
		-1.0f, -1.0f, -1.0f,       0.0f, -1.0f, 0.0f,
		1.0f, -1.0f, -1.0f,        0.0f, -1.0f, 0.0f,
		-1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,
		-1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,
		1.0f, -1.0f, -1.0f,        0.0f, -1.0f, 0.0f,
		1.0f, -1.0f, 1.0f,         0.0f, -1.0f, 0.0f,
		
		1.0f, 1.0f, 1.0f,          0.0f, 0.0f, 1.0f,
		-1.0f, 1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
		1.0f, -1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
		1.0f, -1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
		-1.0f, 1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
		-1.0f, -1.0f, 1.0f,        0.0f, 0.0f, 1.0f,
		
		1.0f, -1.0f, -1.0f,        0.0f, 0.0f, -1.0f,
		-1.0f, -1.0f, -1.0f,       0.0f, 0.0f, -1.0f,
		1.0f, 1.0f, -1.0f,         0.0f, 0.0f, -1.0f,
		1.0f, 1.0f, -1.0f,         0.0f, 0.0f, -1.0f,
		-1.0f, -1.0f, -1.0f,       0.0f, 0.0f, -1.0f,
		-1.0f, 1.0f, -1.0f,        0.0f, 0.0f, -1.0f
	};

	return create_mesh(mesh, 12, sizeof(cubeVertexData), cubeVertexData);
}

static Mesh *create_square_mesh(Mesh *mesh) {
	GLfloat squareVertexData[] = {
		// Data layout for each line below is:
		// positionX, positionY, positionZ,     normalX, normalY, normalZ,
		1.0f, 1.0f, 0.0f,          0.0f, 0.0f, 1.0f,
		-1.0f, 1.0f, 0.0f,         0.0f, 0.0f, 1.0f,
		1.0f, -1.0f, 0.0f,         0.0f, 0.0f, 1.0f,

		1.0f, -1.0f, 0.0f,         0.0f, 0.0f, 1.0f,
		-1.0f, 1.0f, 0.0f,         0.0f, 0.0f, 1.0f,
		-1.0f, -1.0f, 0.0f,        0.0f, 0.0f, 1.0f,
	};

	return create_mesh(mesh, 2, sizeof(squareVertexData), squareVertexData);
}

static Mesh *create_triangle_mesh(Mesh *mesh) {
	GLfloat triVertexData[] = {
		// Data layout for each line below is:
		// positionX, positionY, positionZ,     normalX, normalY, normalZ,
		-1.0f, -1.0f, 0.0f,        0.0f, 0.0f, 1.0f,
		1.0f, -1.0f, 0.0f,         0.0f, 0.0f, 1.0f,
		0.0f, 1.0f, 0.0f,         0.0f, 0.0f, 1.0f,
	};

	return create_mesh(mesh, 1, sizeof(triVertexData), triVertexData);
}

/*******************************************************************************
 MARK: Public functions
 ******************************************************************************/
Mesh *CreateMesh(Mesh *mesh,
                 const kCommonMesh mesh_type) {
 switch (mesh_type) {
  case kCommonMesh_Triangle: return create_triangle_mesh(mesh); break;
  case kCommonMesh_Square: return create_square_mesh(mesh); break;
  case kCommonMesh_Cube: return create_cube_mesh(mesh); break;
 }
 return NULL;
}

const Mesh *RenderMesh(const Mesh *mesh, const Transform *transform,
                 const Shader *shader, const Perspective *perspective) {
 /* Matrices used */
 Mat4 mvMat;
 Mat3 nMat;
 Mat4 pMat;
 Mat4 mvpMat;
 ModelViewMatrix(&mvMat, transform);
 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), 0);
 PerspectiveMatrix(&pMat, perspective);
 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
 
 /*	Bind the data to the associated uniform variable in the shader
  First gets the location of that variable in the shader using its name
  Then passes the matrix to that variable
  */
 int mvp_loc = glGetUniformLocation(shader->program, "u_Mvp");
 glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, mvpMat.m);
 int n_loc = glGetUniformLocation(shader->program, "u_N");
 glUniformMatrix3fv(n_loc, 1, GL_FALSE, nMat.m);
 
 // Bind the VAO
 glBindVertexArrayOES(mesh->vao);
 
 
 /*
  Draws a non-indexed triangle array from the pointers previously given.
  This function allows the use of other primitive types : triangle strips, lines, ...
  For indexed geometry, use the function glDrawElements() with an index list.
  */
 glDrawArrays(GL_TRIANGLES, 0, mesh->tri_count * 3);
 
 // Unbind the VAO
 glBindVertexArrayOES(0);
 return mesh;
}

void ReleaseMesh(Mesh *mesh) {
 glDeleteBuffers(1, &mesh->vbo);
 glDeleteVertexArraysOES(1, &mesh->vao);
 mesh = NULL;
}

//EOF
