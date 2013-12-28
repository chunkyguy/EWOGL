//
//  he_Main.m
//  Lights
//
//  Created by Sid on 24/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "he_Main.h"

#include <stdio.h>
#include <OpenGLES/ES2/gl.h>
#include <GLKit/GLKMath.h>

#include "he_Shader.h"
#include "he_File.h"
#include "he_Utility.h"

#define MAX_SHADERS 1

typedef union {
 size_t size;
 void *ptr;
} Stride;

typedef union {
 struct {
  GLKVector3 position;
  GLKVector3 normal;
 };
 GLfloat data[6];
} Vertex;

typedef union {
 struct {
  GLushort va, vb, vc;
 };
 GLushort data[3];
} Face;

GLKMatrix4 p_mat_; /*projection matrix*/
GLuint shaders_[MAX_SHADERS]; /*list of shaders*/
GLuint vao_;
GLuint vbo_;
GLuint ibo_;
int curr_shi_; /*current shader index*/
float rotation_; /*in degrees*/
int index_count_;

static void load_shaders()
{
 struct ShaderInfo {
  const char *sh_fn[2];
  he_BitFlag flag;
 } sh_info[MAX_SHADERS] = {
  {{"Diffuse.vsh", "Diffuse.fsh"}, BF_Mask(kAttribPosition) | BF_Mask(kAttribNormal)}
 };
 
 
 for (int sh = 0; sh < MAX_SHADERS; ++sh) {
  he_File file[2];
  char fullpathbuf[2][1024];
  /*load files to memory*/
  for (int f = 0; f < 2; ++f) {
   printf("Shader: %s\n",sh_info[sh].sh_fn[f]);
   FileCreate(&file[f], BundlePath(fullpathbuf[f], sh_info[sh].sh_fn[f]));
  }
  
  /*create shader*/
  assert(file[0].buffer);
  assert(file[1].buffer);
  shaders_[sh] = ShaderCreate(file[0].buffer, file[1].buffer, sh_info[sh].flag);
  
  /*release files*/
  for (int f = 0; f < 2; ++f) {
   FileDestroy(&file[f]);
  }
 }
}

static void unload_shaders()
{
 for (int sh = 0; sh < MAX_SHADERS; ++sh) {
  ShaderDestroy(shaders_[sh]);
 }
}

static char *read_word(char *word, FILE *file)
{
 char *wptr = word;
 for (int ch = fgetc(file); ch != EOF && !isspace(ch); ch = fgetc(file)) {
  *word++ = ch;
 }
  *word++ = '\0';
 return wptr;
}

static void load_models()
{
 /* Read file */
 char path_buffer[1024];
 BundlePath(path_buffer, "teapot.obj");

 FILE *file = fopen(path_buffer, "r");
 int ch;

 int v_count = 0;
 int f_count = 0;
 while ((ch = fgetc(file)) != EOF) {
  if (ch == 'v') {
   v_count++;
  } else if (ch == 'f') {
   f_count++;
  }
 }
 
 rewind(file);
 
 /* Parse data */
 Vertex *vertex = calloc(v_count, sizeof(Vertex));
 Face *face = calloc(f_count, sizeof(Face));

 char word[256];
 int vertexi = 0;
 int facei = 0;
 
 while (!feof(file) && read_word(word, file)) {
  if (strcmp(word, "v") == 0) {
   vertex[vertexi].position = GLKVector3Make(atof(read_word(word, file)), atof(read_word(word, file)), atof(read_word(word, file)));
   vertex[vertexi].normal = GLKVector3Make(0.0f, 0.0f, 0.0f);
   //printf("%d:\t %c % .2f % .2f % .2f\n", vertexi, 'v', vertex[vertexi].position.x, vertex[vertexi].position.y, vertex[vertexi].position.z);
   vertexi++;
  } else if (strcmp(word, "f") == 0) {
   face[facei].va = atoi(read_word(word, file)) - 1;
   face[facei].vb = atoi(read_word(word, file)) - 1;
   face[facei].vc = atoi(read_word(word, file)) - 1;
   //printf("%d:\t%c %hu %hu %hu\n", facei, 'f', face[facei].va, face[facei].vb, face[facei].vc);
   facei++;
  }
 }
 
 fclose(file);
 
 /* Calculate normals for each face. */
 for (int i = 0; i < f_count; ++i) {
  Face f = face[i];
  Vertex a = vertex[f.va];
  Vertex b = vertex[f.vb];
  Vertex c = vertex[f.vc];
  
  GLKVector3 ab = GLKVector3Subtract(b.position, a.position);
  GLKVector3 ac = GLKVector3Subtract(c.position, a.position);
  GLKVector3 normal = GLKVector3CrossProduct(ab, ac);
  
  vertex[f.va].normal = GLKVector3Add(a.normal, normal);
  vertex[f.vb].normal = GLKVector3Add(b.normal, normal);
  vertex[f.vc].normal = GLKVector3Add(c.normal, normal);
 }
 
 /* normalize */
 for (int i = 0; i < v_count; ++i) {
  vertex[i].normal = GLKVector3Normalize(vertex[i].normal);
 }
 
 /* push data to GPU RAM */
 index_count_ = f_count * 3;
 
 glGenVertexArraysOES(1, &vao_);
 glBindVertexArrayOES(vao_);
 
 glGenBuffers(1, &vbo_);
 glBindBuffer(GL_ARRAY_BUFFER, vbo_);
 glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * v_count, (GLfloat *)vertex, GL_STATIC_DRAW);

 glGenBuffers(1, &ibo_);
 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo_);
 glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Face) * f_count, (GLushort *)face, GL_STATIC_DRAW);
 
 glEnableVertexAttribArray(kAttribPosition);
 glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
 
 Stride nstride;
 nstride.size = sizeof(GLKVector3);
 glEnableVertexAttribArray(kAttribNormal);
 glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), nstride.ptr);
 
 free(vertex);
 free(face);
 
 printf("Model: vertex = %d\t face = %d\n",v_count,f_count);
}

static void unload_models()
{
 glDeleteBuffers(1, &ibo_);
 glDeleteBuffers(1, &vbo_);
 glDeleteVertexArraysOES(1, &vao_);
}

void StartUp()
{
 printf("loading shaders ...\n");
 load_shaders();
 
 printf("loading models ...\n");
 load_models();
 
 /*default GL state*/
 printf("readying GL states ...\n");
 glEnable(GL_DEPTH_TEST);
 curr_shi_ = 0;
 rotation_ = 90.0f;
}

void ShutDown()
{
 glDisable(GL_DEPTH_TEST);
 
 unload_shaders();
 unload_models();
}

void Reshape(int w, int h)
{
 p_mat_ = GLKMatrix4MakePerspective(45.0f, (float)w/(float)h, 0.1f, 100.0f);
}

void Update(int dt)
{
 rotation_ += 0.5f;
 if (rotation_ > 360.0f) {
  rotation_ = 0.0f;
 }
}

void Render()
{
 glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 
 glUseProgram(shaders_[curr_shi_]);
 glBindVertexArrayOES(vao_);

 GLKMatrix4 baseMV = GLKMatrix4MakeTranslation(0.0f, 0.0f, -10.0f);
 baseMV = GLKMatrix4Rotate(baseMV, GLKMathDegreesToRadians(rotation_), 1.0f, 0.0f, 0.0f);
 
 GLKMatrix4 teapotMv = GLKMatrix4MakeTranslation(0.0f, 0.0f, -2.0f);
 teapotMv = GLKMatrix4Rotate(teapotMv, GLKMathDegreesToRadians(rotation_), 0.0f, 1.0f, 0.0f);
 teapotMv = GLKMatrix4Multiply(baseMV, teapotMv); /*eye space*/

 GLuint mv_loc = glGetUniformLocation(shaders_[curr_shi_], "u_Mv");
 glUniformMatrix4fv(mv_loc, 1, GL_FALSE, teapotMv.m);

 GLKMatrix3 teapotN = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(teapotMv), NULL);
 GLuint n_loc = glGetUniformLocation(shaders_[curr_shi_], "u_N");
 glUniformMatrix3fv(n_loc, 1, GL_FALSE, teapotN.m);
 
 GLuint p_loc = glGetUniformLocation(shaders_[curr_shi_], "u_P");
 glUniformMatrix4fv(p_loc, 1, GL_FALSE, p_mat_.m);

 GLKMatrix4 teapotMvp = GLKMatrix4Multiply(p_mat_, teapotMv);
 GLuint mvp_loc = glGetUniformLocation(shaders_[curr_shi_], "u_Mvp");
 glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, teapotMvp.m);

 GLKVector4 light = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
 //light = GLKMatrix4MultiplyVector4(baseMV, light);
 GLuint light_loc = glGetUniformLocation(shaders_[curr_shi_], "u_Light");
 glUniform4fv(light_loc, 1, light.v);
 
 glDrawElements(GL_TRIANGLES, index_count_, GL_UNSIGNED_SHORT, NULL);
 // glDrawArrays(GL_TRIANGLES, 0, index_count_);
}

