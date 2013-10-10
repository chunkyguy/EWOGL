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
#include "Utilities.h"

typedef union {
	struct {
		GLKVector3 position;
		GLKVector3 normal;
	};
	GLfloat data[6];
} Vertex;

typedef union {
	GLushort data[3];
} Face;

typedef union {
	GLvoid *ptr;
	size_t size;
} Offset;

static Mesh create_mesh(int vertex_count, size_t vertex_data_size, GLfloat *vertex_data,
						int face_count, size_t face_data_size, GLushort *face_data) {
	Mesh mesh;
	mesh.index_count = face_count * 3;
	mesh.vertex_count = vertex_count;
	
	/* Generate + bind the VAO */
	glGenVertexArraysOES(1, &mesh.vao);
	glBindVertexArrayOES(mesh.vao);
	assert(mesh.vao);
	
	/* Generate + bind the VBO */
	glGenBuffers(1, &mesh.vbo);
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo);
	assert(mesh.vbo);
	
	/* Set the buffer's data */
	glBufferData(GL_ARRAY_BUFFER, vertex_data_size, vertex_data, GL_STATIC_DRAW);

	/* Bind index buffer if available */
	if (face_count > 0) {
		glGenBuffers(1, &mesh.ibo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ibo);
		assert(mesh.ibo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, face_data_size, face_data, GL_STATIC_DRAW);
	}

	/*	Enable the custom vertex attributes at some indices (for eg. kAttribPosition).
	 We previously binded those indices to the variables in our shader (for eg. vec4 a_Position)
	 */
	glEnableVertexAttribArray(kAttribPosition);
	glEnableVertexAttribArray(kAttribNormal);

	/* Sets the vertex data to enabled attribute indices */
	Vertex v;
	GLsizei stride = sizeof(v);
	Offset position_offset;
	position_offset.size = 0;
	glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, position_offset.ptr);
	Offset normal_offset;
	normal_offset.size = sizeof(v.position);
	glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, normal_offset.ptr);
	
	/* Unbind the VAO */
	glBindVertexArrayOES(0);
	
	return mesh;
}

static Mesh create_mesh_from_vertex_data(int vertex_count, Vertex *vertex_data) {
	return create_mesh(vertex_count, sizeof(vertex_data[0]) * vertex_count, (GLfloat *)vertex_data, -1, 0, 0);
}

static Mesh cube_mesh() {
	Vertex cubeVertexData[36] = {
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

	return create_mesh_from_vertex_data(36, cubeVertexData);
}

static Mesh square_mesh() {
	Vertex squareVertexData[6] = {
		// Data layout for each line below is:
		// positionX, positionY, positionZ,     normalX, normalY, normalZ,
		0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,

		0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		-0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
		-0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
	};

	return create_mesh_from_vertex_data(6, squareVertexData);
}

static Mesh triangle_mesh() {
	Vertex triVertexData[3] = {
		-0.5f, -0.5f, 0.0f,        0.0f, 0.0f, 1.0f,
		0.5f, -0.5f, 0.0f,         0.0f, 0.0f, 1.0f,
		0.0f, 0.5f, 0.0f,         0.0f, 0.0f, 1.0f,
	};

	// Create with triangles
	//	return create_mesh_from_vertex_data(3, triVertexData);
	
	// Create with indices
	int vertex_count = 3;
	Face face[1] = {0, 1, 2};
	int face_count = 1;
	return create_mesh(vertex_count, sizeof(triVertexData[0]) * vertex_count, (GLfloat*)triVertexData,
					   face_count, sizeof(face[0]) * face_count, (GLushort*)face);

}

Mesh CreatStaticMesh(StaticMesh mesh_type) {
	switch (mesh_type) {
		case kMesh_Cube: return cube_mesh();
		case kMesh_Square: return square_mesh();
		case kMesh_Triangle: return triangle_mesh();
	}
	assert(0);	// Undefined operation.
}

Mesh CreateMeshFromFile(const char *filename) {
	// Read file
	char path_buffer[kBuffer(10)];
	BundlePath(filename, path_buffer);
	FILE *file = fopen(path_buffer, "r");
	
	// Parse data
	Vertex vertex[kBuffer(14)];
	int vertex_count = 0;
	Face face[kBuffer(15)];
	int face_count = 0;
	int ch;
	while ((ch = fgetc(file)) != EOF) {
		if (ch == 'v') {
			GLKVector3 data;
			fscanf(file, "%f %f %f", &data.v[0], &data.v[1], &data.v[2]);
			vertex[vertex_count].position = data;
			vertex[vertex_count].normal = GLKVector3Make(0.0f, 0.0f, 0.0f);
			vertex_count++;
		} else if (ch == 'f') {
			GLushort data[3];
			fscanf(file, "%hu %hu %hu", &data[0], &data[1], &data[2]);
			for (int i = 0; i < 3; ++i) {
				face[face_count].data[i] = data[i] - 1;
			}
			face_count++;
		}
	}
	fclose(file);
	
	// Calculate normals for each face.
	for (int i = 0; i < face_count; ++i) {
		Face f = face[i];
		Vertex a = vertex[f.data[0]];
		Vertex b = vertex[f.data[1]];
		Vertex c = vertex[f.data[2]];
		
		GLKVector3 ab = GLKVector3Subtract(b.position, a.position);
		GLKVector3 ac = GLKVector3Subtract(c.position, a.position);
		GLKVector3 normal = GLKVector3CrossProduct(ab, ac);
		
		vertex[f.data[0]].normal = GLKVector3Add(a.normal, normal);
		vertex[f.data[1]].normal = GLKVector3Add(b.normal, normal);
		vertex[f.data[2]].normal = GLKVector3Add(c.normal, normal);
	}
	
	// normalize
	for (int i = 0; i < vertex_count; ++i) {
		vertex[i].normal = GLKVector3Normalize(vertex[i].normal);
	}
	
	// Create mesh
	return create_mesh(vertex_count, sizeof(vertex[0]) * vertex_count, (GLfloat*)vertex,
					   face_count, sizeof(face[0]) * face_count, (GLushort*)face);
}

void TearDown_Mesh(const Mesh mesh) {
	glDeleteBuffers(1, &mesh.vbo);
	if (mesh.index_count > 0) {
		glDeleteBuffers(1, &mesh.ibo);
	}
	glDeleteVertexArraysOES(1, &mesh.vao);
}

//EOF
