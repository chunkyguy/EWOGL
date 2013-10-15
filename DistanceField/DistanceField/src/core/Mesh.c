//
//  Cube.c
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "Mesh.h"

#include <stdarg.h>

#include "std_incl.h"
#include "Constants.h"
#include "Transform.h"
#include "Utilities.h"
#include "Console.h"

#define kSize 10.0f

typedef union {
 GLvoid *ptr;
 size_t size;
} Offset;

typedef struct {
 GLuint index;
 GLint size;
 GLenum type;
 GLboolean normalized;
 GLsizei stride;
 size_t offset_size;
} AttribBuffer;

Mesh font_mesh;

/*******************************************************************************
 MARK: private
*******************************************************************************/
/*
AttribBuffer attr_buff[] = {
 { kAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0 },
 { kAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), sizeof(Vec3f) }
};

create_mesh(mesh,
            vertex_count, sizeof(vertex[0]) * vertex_count, (GLfloat*)vertex,
            face_count, sizeof(face[0]) * face_count, (GLushort*)face,
                2, attr_buff);
*/
static Mesh *create_mesh(Mesh *mesh,
                             int vertex_count, size_t vertex_data_size, GLfloat *vertex_data,
                             int face_count, size_t face_data_size, GLushort *face_data,
                             int buff_count, AttribBuffer *attrib_buffer) {
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
 
 /* Sets the vertex data to enabled attribute indices */
 for (int i = 0; i < buff_count; ++i) {
  AttribBuffer attr_buff = attrib_buffer[i];
  Offset offset;
  offset.size = attr_buff.offset_size;
  glVertexAttribPointer(attr_buff.index, attr_buff.size, attr_buff.type, attr_buff.normalized, attr_buff.stride, offset.ptr);
 }
 
 /* Unbind the VAO */
 glBindVertexArrayOES(0);
 
 return memcpy(mesh, &m, sizeof(m));
}
 
//static Mesh *create_mesh(Mesh *mesh,
//                         int vertex_count, size_t vertex_data_size, GLfloat *vertex_data,
//						int face_count, size_t face_data_size, GLushort *face_data) {
// Mesh m;
// m.index_count = face_count * 3;
// m.vertex_count = vertex_count;
// 
// /* Generate + bind the VAO */
// glGenVertexArraysOES(1, &m.vao);
// glBindVertexArrayOES(m.vao);
// assert(m.vao);
// 
// /* Generate + bind the VBO */
// glGenBuffers(1, &m.vbo);
// glBindBuffer(GL_ARRAY_BUFFER, m.vbo);
// assert(m.vbo);
// 
// /* Set the buffer's data */
// glBufferData(GL_ARRAY_BUFFER, vertex_data_size, vertex_data, GL_STATIC_DRAW);
// 
// /* Bind index buffer if available */
// if (face_count > 0) {
//  glGenBuffers(1, &m.ibo);
//  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m.ibo);
//  assert(m.ibo);
//  glBufferData(GL_ELEMENT_ARRAY_BUFFER, face_data_size, face_data, GL_STATIC_DRAW);
// }
// 
// /* Sets the vertex data to enabled attribute indices */
// GLsizei stride = sizeof(Vertex);
// Offset position_offset;
// Offset normal_offset;
//
// position_offset.size = 0;
// glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, position_offset.ptr);
// normal_offset.size = sizeof(Vec3f);
// glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, normal_offset.ptr);
// 
// /* Unbind the VAO */
// glBindVertexArrayOES(0);
//
// return memcpy(mesh, &m, sizeof(m));
//}

static Mesh *create_mesh_from_vertex_data(Mesh *mesh,
                                          int vertex_count, Vertex *vertex_data,
                                          int buff_count, AttribBuffer *attrib_buffer) {
 return create_mesh(mesh,
                    vertex_count, sizeof(vertex_data[0]) * vertex_count, (GLfloat *)vertex_data,
                    -1, 0, NULL,
                    buff_count, attrib_buffer);
}

static Mesh *cube_mesh(Mesh *mesh) {
 Vertex cubeVertexData[36] = {
  // Data layout for each line below is:
  // positionX, positionY, positionZ,     normalX, normalY, normalZ,
  kSize, -kSize, -kSize,        1.0f, 0.0f, 0.0f,
  kSize, kSize, -kSize,         1.0f, 0.0f, 0.0f,
  kSize, -kSize, kSize,         1.0f, 0.0f, 0.0f,
  kSize, -kSize, kSize,         1.0f, 0.0f, 0.0f,
  kSize, kSize, -kSize,          1.0f, 0.0f, 0.0f,
  kSize, kSize, kSize,         1.0f, 0.0f, 0.0f,
  
  kSize, kSize, -kSize,         0.0f, 1.0f, 0.0f,
  -kSize, kSize, -kSize,        0.0f, 1.0f, 0.0f,
  kSize, kSize, kSize,          0.0f, 1.0f, 0.0f,
  kSize, kSize, kSize,          0.0f, 1.0f, 0.0f,
  -kSize, kSize, -kSize,        0.0f, 1.0f, 0.0f,
  -kSize, kSize, kSize,         0.0f, 1.0f, 0.0f,
  
  -kSize, kSize, -kSize,        -1.0f, 0.0f, 0.0f,
  -kSize, -kSize, -kSize,       -1.0f, 0.0f, 0.0f,
  -kSize, kSize, kSize,         -1.0f, 0.0f, 0.0f,
  -kSize, kSize, kSize,         -1.0f, 0.0f, 0.0f,
  -kSize, -kSize, -kSize,       -1.0f, 0.0f, 0.0f,
  -kSize, -kSize, kSize,        -1.0f, 0.0f, 0.0f,
  
  -kSize, -kSize, -kSize,       0.0f, -1.0f, 0.0f,
  kSize, -kSize, -kSize,        0.0f, -1.0f, 0.0f,
  -kSize, -kSize, kSize,        0.0f, -1.0f, 0.0f,
  -kSize, -kSize, kSize,        0.0f, -1.0f, 0.0f,
  kSize, -kSize, -kSize,        0.0f, -1.0f, 0.0f,
  kSize, -kSize, kSize,         0.0f, -1.0f, 0.0f,
  
  kSize, kSize, kSize,          0.0f, 0.0f, 1.0f,
  -kSize, kSize, kSize,         0.0f, 0.0f, 1.0f,
  kSize, -kSize, kSize,         0.0f, 0.0f, 1.0f,
  kSize, -kSize, kSize,         0.0f, 0.0f, 1.0f,
  -kSize, kSize, kSize,         0.0f, 0.0f, 1.0f,
  -kSize, -kSize, kSize,        0.0f, 0.0f, 1.0f,
  
  kSize, -kSize, -kSize,        0.0f, 0.0f, -1.0f,
  -kSize, -kSize, -kSize,       0.0f, 0.0f, -1.0f,
  kSize, kSize, -kSize,         0.0f, 0.0f, -1.0f,
  kSize, kSize, -kSize,         0.0f, 0.0f, -1.0f,
  -kSize, -kSize, -kSize,       0.0f, 0.0f, -1.0f,
  -kSize, kSize, -kSize,        0.0f, 0.0f, -1.0f
 };
 
 AttribBuffer attr_buff[2] = {
  { kAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0 },
  { kAttrib_Normal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), sizeof(Vec3f) }
 };

 return create_mesh_from_vertex_data(mesh, 36, cubeVertexData, 2, attr_buff);
}

static Mesh *square_mesh(Mesh *mesh) {
 Vertex squareVertexData[6] = {
  // Data layout for each line below is:
  // positionX, positionY, positionZ,     normalX, normalY, normalZ,
  kSize, kSize, 0.0f,          0.0f, 0.0f, 1.0f,
  -kSize, kSize, 0.0f,         0.0f, 0.0f, 1.0f,
  kSize, -kSize, 0.0f,         0.0f, 0.0f, 1.0f,
  
  kSize, -kSize, 0.0f,         0.0f, 0.0f, 1.0f,
  -kSize, kSize, 0.0f,         0.0f, 0.0f, 1.0f,
  -kSize, -kSize, 0.0f,        0.0f, 0.0f, 1.0f,
 };

 AttribBuffer attr_buff[2] = {
  { kAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0 },
  { kAttrib_Normal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), sizeof(Vec3f) }
 };

 return create_mesh_from_vertex_data(mesh, 6, squareVertexData, 2, attr_buff);
}

static Mesh *triangle_mesh(Mesh *mesh) {
 Vertex triVertexData[3] = {
  -kSize, -kSize, 0.0f,        0.0f, 0.0f, 1.0f,
  kSize, -kSize, 0.0f,         0.0f, 0.0f, 1.0f,
  kSize, kSize, 0.0f,         0.0f, 0.0f, 1.0f,
 };
 
 // Create with triangles
 //	return create_mesh_from_vertex_data(3, triVertexData);
 
 // Create with indices
 int vertex_count = 3;
 Face face[1] = {0, 1, 2};
 int face_count = 1;

 AttribBuffer attr_buff[2] = {
  { kAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0 },
  { kAttrib_Normal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), sizeof(Vec3f) }
 };

 return create_mesh(mesh,
                    vertex_count, sizeof(triVertexData[0]) * vertex_count, (GLfloat*)triVertexData,
                    face_count, sizeof(face[0]) * face_count, (GLushort*)face,
                    2, attr_buff);
 
}

static void draw_bitmap(unsigned char image[][WIDTH],
                 FT_Bitmap*  bitmap,
				 FT_Int      x,
				 FT_Int      y)
{
 FT_Int  i, j, p, q;
 FT_Int  x_max = x + bitmap->width;
 FT_Int  y_max = y + bitmap->rows;
 
 for ( i = x, p = 0; i < x_max; i++, p++ )
 {
  for ( j = y, q = 0; j < y_max; j++, q++ )
  {
   if ( i < 0      || j < 0       ||
       i >= WIDTH || j >= HEIGHT )
    continue;
   
   image[j][i] |= bitmap->buffer[q * bitmap->width + p];
  }
 }
}


static void show_image( unsigned char image[][WIDTH] )
{
 int  i, j;
 
 
 for ( i = 0; i < HEIGHT; i++ )
 {
  for ( j = 0; j < WIDTH; j++ )
   putchar( image[i][j] == 0 ? ' '
           : image[i][j] < 128 ? '+'
           : '-' );
  putchar( '\n' );
 }
 
 putchar( '\n' );
 putchar( '\n' );
 
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
 FILE *file = fopen(BundlePath(path_buffer, filename), "r");
 
 // Parse data
 Vertex vertex[kBuffer16K];
 int vertex_count = 0;
 Face face[kBuffer32K];
 int face_count = 0;
 int ch;
 while ((ch = fgetc(file)) != EOF) {
  if (ch == 'v') {
   Vec3f data;
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
  
  Vec3f ab = GLKVector3Subtract(b.position, a.position);
  Vec3f ac = GLKVector3Subtract(c.position, a.position);
  Vec3f normal = GLKVector3CrossProduct(ab, ac);
  
  vertex[f.data[0]].normal = GLKVector3Add(a.normal, normal);
  vertex[f.data[1]].normal = GLKVector3Add(b.normal, normal);
  vertex[f.data[2]].normal = GLKVector3Add(c.normal, normal);
 }
 
 // normalize
 for (int i = 0; i < vertex_count; ++i) {
  vertex[i].normal = GLKVector3Normalize(vertex[i].normal);
 }
 
 // Create mesh
 AttribBuffer attr_buff[2] = {
  { kAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0 },
  { kAttrib_Normal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), sizeof(Vec3f) }
 };

 return create_mesh(mesh,
                    vertex_count, sizeof(vertex[0]) * vertex_count, (GLfloat*)vertex,
                    face_count, sizeof(face[0]) * face_count, (GLushort*)face,
                    2, attr_buff);
}

const Mesh *RenderMesh(const Mesh *mesh,   /*	The mesh to be rendered */
                       const Transform *transform, /*	The transform. */
                       const Shader *shader,	/*	The program in use. */
                       const Frustum *frustum, /* The perpective to be applied*/
                       const Vec4f *color
) {
 /* Matrices used */
 Mat4 mvMat;
 Mat3 nMat;
 Mat4 pMat;
 Mat4 mvpMat;
 
 ModelViewMatrix(&mvMat, transform);
 NormalMatrix(&nMat, &mvMat);
 PerspectiveMatrix(&pMat, frustum);
 mvpMat = GLKMatrix4Multiply(pMat, mvMat);

 PrintMat4(&mvMat);

 /*	Bind the data to the associated uniform variable in the shader
  First gets the location of that variable in the shader using its name
  Then passes the matrix to that variable
  */
 int mvp_loc = glGetUniformLocation(shader->program, u_Mvp);
 glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, mvpMat.m);
 int n_loc = glGetUniformLocation(shader->program, u_N);
 glUniformMatrix3fv(n_loc, 1, GL_FALSE, nMat.m);
 int color_loc = glGetUniformLocation(shader->program, u_Color);
 glUniform4fv(color_loc, 1, &color->v[0]);
 
 // Bind the VAO
 glBindVertexArrayOES(mesh->vao);
 
 /*	Enable the custom vertex attributes at some indices (for eg. kAttribPosition).
  We previously binded those indices to the variables in our shader (for eg. vec4 a_Position)
  */
 for (int index = 0; index < kAttrib_Total; ++index) {
  if (shader->attrib_flags & kAttribFlag(index)) {
   glEnableVertexAttribArray(index);
  }
 }
 
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
 for (int index = 0; index < kAttrib_Total; ++index) {
  if (shader->attrib_flags & kAttribFlag(index)) {
   glDisableVertexAttribArray(index);
  }
 }
 glBindVertexArrayOES(0);
 
 return mesh;
}

void RenderText(const Mesh *mesh,   /*	The mesh to be rendered */
                const Transform *transform, /*	The transform. */
                const Shader *shader,	/*	The program in use. */
                const Frustum *frustum) { /* The perpective to be applied*/

 Mat4 mvMat;
 Mat4 pMat;
 Mat4 mvpMat;

 ModelViewMatrix(&mvMat, transform);
 PerspectiveMatrix(&pMat, frustum);
 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
 
 /*	Bind the data to the associated uniform variable in the shader
  First gets the location of that variable in the shader using its name
  Then passes the matrix to that variable
  */
 int mvp_loc = glGetUniformLocation(shader->program, u_Mvp);
 glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, mvpMat.m);
 int tex_loc = glGetUniformLocation(shader->program, u_Texture);
 glUniform1i(tex_loc, 0);
 glActiveTexture(0);
 glBindTexture(GL_TEXTURE_2D, mesh->texture);
 
 
 for (int index = 0; index < kAttrib_Total; ++index) {
  if (shader->attrib_flags & kAttribFlag(index)) {
   glEnableVertexAttribArray(index);
  }
 }
 
 
 glDrawArrays(GL_TRIANGLES, 0, mesh->vertex_count);
 
 for (int index = 0; index < kAttrib_Total; ++index) {
  if (shader->attrib_flags & kAttribFlag(index)) {
   glDisableVertexAttribArray(index);
  }
 }
 glBindVertexArrayOES(0);
 
}

void ReleaseMesh(Mesh *mesh) {

 glDeleteBuffers(1, &mesh->vbo);
 if (mesh->index_count > 0) {
  glDeleteBuffers(1, &mesh->ibo);
 }
 glDeleteVertexArraysOES(1, &mesh->vao);
}



//void RenderText(char* font_path,
//                char* text ,
//                const Transform *transform,
//                const Shader *shader,
//                const Frustum *frustum) {
// 
// 
// /* Matrices used */
// Mat4 mvMat;
// Mat4 pMat;
// Mat4 mvpMat;
// 
// ModelViewMatrix(&mvMat, transform);
// PerspectiveMatrix(&pMat, frustum);
// mvpMat = GLKMatrix4Multiply(pMat, mvMat);
// 
// int mvp_loc = glGetUniformLocation(shader->program, u_Mvp);
// glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, mvpMat.m);
// 
// for (int index = 0; index < kAttrib_Total; ++index) {
//  if (shader->attrib_flags & kAttribFlag(index)) {
//   glEnableVertexAttribArray(index);
//  }
// }
// 
// sth_begin_draw(stash);
// sth_draw_text(stash, font, 24.0f, position.x, position.y, STH_RGBA(255, 0, 0, 255), text, &position.x);
// sth_end_draw(stash);
// 
// for (int index = 0; index < kAttrib_Total; ++index) {
//  if (shader->attrib_flags & kAttribFlag(index)) {
//   glDisableVertexAttribArray(index);
//  }
// }
// 
// sth_delete(stash);
//}

Mesh *CreateMeshFromText(Mesh *mesh, Font* font, const char* text) {
 FT_GlyphSlot  slot;
 FT_Matrix     matrix;                 /* transformation matrix */
 FT_Vector     pen;                    /* untransformed origin  */
 FT_Error      error;
 
 
 double        angle;
 int           target_height;
 int           n, num_chars;
 
 
 num_chars     = strlen( text );
 angle         = ( 0.0 / 360 ) * 3.14159 * 2;      /* use 0 degrees     */
 
 /* use 16pt at 100dpi */
 error = FT_Set_Char_Size( font->face, 16 * 64, 0,
                          100, 0 );                /* set character size */
 assert(!error);
 
 slot = font->face->glyph;
 
 /* set up matrix */
 matrix.xx = (FT_Fixed)( cos( angle ) * 0x10000L );
 matrix.xy = (FT_Fixed)(-sin( angle ) * 0x10000L );
 matrix.yx = (FT_Fixed)( sin( angle ) * 0x10000L );
 matrix.yy = (FT_Fixed)( cos( angle ) * 0x10000L );
 
 /* the pen position in 26.6 cartesian space coordinates; */
 /* start at (300,200) relative to the upper left corner  */
 pen.x = 300 * 64;
 pen.y = ( target_height - 200 ) * 64;
 
 for ( n = 0; n < num_chars; n++ )
 {
  /* set transformation */
  FT_Set_Transform( font->face, &matrix, &pen );
  
  /* load glyph image into the slot (erase previous one) */
  error = FT_Load_Char( font->face, text[n], FT_LOAD_RENDER );
  if ( error )
   continue;                 /* ignore errors */
  
  /* now, draw to our target surface (convert position) */
  draw_bitmap(image,
              &slot->bitmap,
              slot->bitmap_left,
              target_height - slot->bitmap_top );
  
  /* increment pen position */
  pen.x += slot->advance.x;
  pen.y += slot->advance.y;
  
 }
 
 show_image(image);
 
 
 return 0;
}
//EOF
