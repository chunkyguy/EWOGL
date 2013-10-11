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
#include "Utilities.h"

typedef union {
 GLvoid *ptr;
 size_t size;
} Offset;

/*******************************************************************************
 MARK: private
*******************************************************************************/
 
static Mesh *create_mesh(Mesh *mesh,
                         int vertex_count, size_t vertex_data_size, GLfloat *vertex_data,
						int face_count, size_t face_data_size, GLushort *face_data) {
 Mesh m;
 m.index_count = face_count * 3;
 m.vertex_count = vertex_count;
 
 /* Generate + bind the VAO */
 glGenVertexArraysOES(1, &m.vao);
 glBindVertexArrayOES(m.vao);
 assert(m.vao);
 
 /* Generate + bind the VBO */
 glGenBuffers(1, &m.vbo);
 glBindBuffer(GL_ARRAY_BUFFER, m.vbo);
 assert(m.vbo);
 
 /* Set the buffer's data */
 glBufferData(GL_ARRAY_BUFFER, vertex_data_size, vertex_data, GL_STATIC_DRAW);
 
 /* Bind index buffer if available */
 if (face_count > 0) {
  glGenBuffers(1, &m.ibo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m.ibo);
  assert(m.ibo);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, face_data_size, face_data, GL_STATIC_DRAW);
 }
 
 /*	Enable the custom vertex attributes at some indices (for eg. kAttribPosition).
  We previously binded those indices to the variables in our shader (for eg. vec4 a_Position)
  */
 glEnableVertexAttribArray(kAttribPosition);
 glEnableVertexAttribArray(kAttribNormal);
 
 /* Sets the vertex data to enabled attribute indices */
 GLsizei stride = sizeof(Vertex);
 Offset position_offset;
 Offset normal_offset;

 position_offset.size = 0;
 glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, position_offset.ptr);
 normal_offset.size = sizeof(Vec3f);
 glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, normal_offset.ptr);
 
 /* Unbind the VAO */
 glBindVertexArrayOES(0);

 return memcpy(mesh, &m, sizeof(m));
}

static Mesh *create_mesh_from_vertex_data(Mesh *mesh, int vertex_count, Vertex *vertex_data) {
 return create_mesh(mesh,
                    vertex_count, sizeof(vertex_data[0]) * vertex_count, (GLfloat *)vertex_data,
                    -1, 0, NULL);
}

static Mesh *cube_mesh(Mesh *mesh) {
 Vertex cubeVertexData[36] = {
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
 
 return create_mesh_from_vertex_data(mesh, 36, cubeVertexData);
}

static Mesh *square_mesh(Mesh *mesh) {
 Vertex squareVertexData[6] = {
  // Data layout for each line below is:
  // positionX, positionY, positionZ,     normalX, normalY, normalZ,
  1.0f, 1.0f, 1.0f,          0.0f, 1.0f, 0.0f,
  -1.0f, 1.0f, 1.0f,         0.0f, 1.0f, 0.0f,
  1.0f, -1.0f, 1.0f,         0.0f, 1.0f, 0.0f,
  
  1.0f, -1.0f, 1.0f,         0.0f, 1.0f, 0.0f,
  -1.0f, 1.0f, 1.0f,         0.0f, 1.0f, 0.0f,
  -1.0f, -1.0f, 1.0f,        0.0f, 1.0f, 0.0f,
 };
 
 return create_mesh_from_vertex_data(mesh, 6, squareVertexData);
}

static Mesh *triangle_mesh(Mesh *mesh) {
 Vertex triVertexData[3] = {
  -1.0f, -1.0f, 0.0f,        0.0f, 0.0f, 1.0f,
  1.0f, -1.0f, 0.0f,         0.0f, 0.0f, 1.0f,
  0.0f, 1.0f, 0.0f,         0.0f, 0.0f, 1.0f,
 };
 
 // Create with triangles
 //	return create_mesh_from_vertex_data(3, triVertexData);
 
 // Create with indices
 int vertex_count = 3;
 Face face[1] = {0, 1, 2};
 int face_count = 1;
 return create_mesh(mesh,
                    vertex_count, sizeof(triVertexData[0]) * vertex_count, (GLfloat*)triVertexData,
                    face_count, sizeof(face[0]) * face_count, (GLushort*)face);
 
}

/*******************************************************************************
 MARK: public
 *******************************************************************************/
Mesh *CreateMesh(Mesh *mesh, const kCommonMesh mesh_type) {
 switch (mesh_type) {
  case kCommonMesh_Cube: return cube_mesh(mesh);
  case kCommonMesh_Square: return square_mesh(mesh);
  case kCommonMesh_Triangle: return triangle_mesh(mesh);
 }
 return NULL;
}

Mesh *CreateMeshFromFile(Mesh *mesh, const char *filename) {
 // Read file
 char path_buffer[kBuffer1K];
 BundlePath(filename, path_buffer);
 FILE *file = fopen(path_buffer, "r");
 
 // Parse data
 Vertex vertex[kBuffer16K];
 int vertex_count = 0;
 Face face[kBuffer32K];
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
 return create_mesh(mesh,
                    vertex_count, sizeof(vertex[0]) * vertex_count, (GLfloat*)vertex,
                    face_count, sizeof(face[0]) * face_count, (GLushort*)face);
}

const Mesh *RenderMesh(const Mesh *mesh,   /*	The mesh to be rendered */
                       const Transform *transform, /*	The transform. */
                       const Shader *shader,	/*	The program in use. */
                       const Perspective *perspective, /* The perpective to be applied*/
                       const Vec4f *color
) {
 /* Matrices used */
 Mat4 mvMat;
 Mat3 nMat;
 Mat4 pMat;

 ModelViewMatrix(&mvMat, transform);
 NormalMatrix(&nMat, &mvMat);
 PerspectiveMatrix(&pMat, perspective);

 GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
 
 /*	Bind the data to the associated uniform variable in the shader
  First gets the location of that variable in the shader using its name
  Then passes the matrix to that variable
  */
 int mvp_loc = glGetUniformLocation(shader->program, "u_Mvp");
 glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, mvpMat.m);
 int n_loc = glGetUniformLocation(shader->program, "u_N");
 glUniformMatrix3fv(n_loc, 1, GL_FALSE, nMat.m);
 int color_loc = glGetUniformLocation(shader->program, "u_Color");
 glUniform4fv(color_loc, 1, &color->v[0]);
 
 // Bind the VAO
 glBindVertexArrayOES(mesh->vao);
 
 /*
  This function allows the use of other primitive types : triangle strips, lines, ...
  For indexed geometry, use the function glDrawElements() with an index list.
  Else draws a non-indexed triangle array from the pointers previously given.
  */
 if (mesh->index_count > 0) {
  glDrawElements(GL_TRIANGLES, mesh->index_count, GL_UNSIGNED_SHORT, 0);
 } else {
  glDrawArrays(GL_TRIANGLES, 0, mesh->vertex_count);
 }
 
 // Unbind the VAO
 glBindVertexArrayOES(0);
 return mesh;
}

void ReleaseMesh(Mesh *mesh) {
 glDeleteBuffers(1, &mesh->vbo);
 if (mesh->index_count > 0) {
  glDeleteBuffers(1, &mesh->ibo);
 }
 glDeleteVertexArraysOES(1, &mesh->vao);
}

//EOF
