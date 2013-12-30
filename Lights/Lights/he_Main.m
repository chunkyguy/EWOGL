//
//  he_Main.m
//  Lights
//
//  Created by Sid on 24/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "he_Main.h"

#include <stdio.h>
#include <GLKit/GLKMath.h>

#include "he_Availability.h"
#include "he_Shader.h"
#include "he_File.h"
#include "he_Utility.h"

#define kUniformLightPosition	1
#define kUniformLightColor		2
#define kUniformMaterialColor	3
#define kUniformMaterialGloss	4
#define kUniformN				5
#define kUniformMv				6
#define kUniformMvp				7

#define MAX_ALLOWED_SHADERS 32
/*MARK: vars*/
struct ShaderInfo {
 GLuint shader;
 char name[256];
 char sh_fn[2][256];
 he_BitFlag aflag; /*bitwise attribute flags*/
 he_BitFlag uflag; /*bitwise uniform flags*/
} shInfo_[MAX_ALLOWED_SHADERS];
unsigned int max_shaders_;


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

struct LightAttribute {
 GLKVector4 position;
 GLKVector4 color;
} light_;

struct Material {
 GLKVector4 color;
 float gloss;
} material_;

GLKMatrix4 pMat; /*projection*/

GLuint vao_;
GLuint vbo_;
GLuint ibo_;
int curr_shi_; /*current shader index*/
float rotation_; /*in degrees*/
int index_count_;

/* MARK: shaders*/
static void new_shader_info(const int index,
                            const char *name,
                            const char *vsh_name,
                            const char *fsh_name,
                            const he_BitFlag aflag,
                            const he_BitFlag uflag)
{
 assert(index < MAX_ALLOWED_SHADERS);
 
 strcpy(shInfo_[index].name, name);
 strcpy(shInfo_[index].sh_fn[0], vsh_name);
 strcpy(shInfo_[index].sh_fn[1], fsh_name);
 shInfo_[index].aflag = aflag;
 shInfo_[index].uflag = uflag;
}

static void load_shaders()
{
 max_shaders_ = 0;
 
 /*Diffuse per vertex*/
 new_shader_info(max_shaders_++, "DiffusePerVertex",
                 "Diffuse.vsh", "Diffuse.fsh",
                 BF_Mask(kAttribPosition) |
                 BF_Mask(kAttribNormal),
                 BF_Mask(kUniformLightPosition) |
                 BF_Mask(kUniformMaterialColor) |
                 BF_Mask(kUniformN) |
                 BF_Mask(kUniformMv) |
                 BF_Mask(kUniformMvp));

 /*Diffuse per fragment*/
 new_shader_info(max_shaders_++, "DiffusePerFrag",
                 "DiffusePF.vsh", "DiffusePF.fsh",
                 BF_Mask(kAttribPosition) |
                 BF_Mask(kAttribNormal),
                 BF_Mask(kUniformLightPosition) |
                 BF_Mask(kUniformMaterialColor) |
                 BF_Mask(kUniformN) |
                 BF_Mask(kUniformMv) |
                 BF_Mask(kUniformMvp));


 /*ADS per vertex*/
 new_shader_info(max_shaders_++, "ADSPerVertex",
                 "ADS.vsh", "ADS.fsh",
                 BF_Mask(kAttribPosition) |
                 BF_Mask(kAttribNormal),
                 BF_Mask(kUniformLightPosition) |
                 BF_Mask(kUniformLightColor) |
                 BF_Mask(kUniformMaterialColor) |
                 BF_Mask(kUniformMaterialGloss) |
                 BF_Mask(kUniformN) |
                 BF_Mask(kUniformMv) |
                 BF_Mask(kUniformMvp));

 /*ADS per frag*/
 new_shader_info(max_shaders_++, "ADSPerFrag",
                 "ADSPF.vsh", "ADSPF.fsh",
                 BF_Mask(kAttribPosition) |
                 BF_Mask(kAttribNormal),
                 BF_Mask(kUniformLightPosition) |
                 BF_Mask(kUniformLightColor) |
                 BF_Mask(kUniformMaterialColor) |
                 BF_Mask(kUniformMaterialGloss) |
                 BF_Mask(kUniformN) |
                 BF_Mask(kUniformMv) |
                 BF_Mask(kUniformMvp));

 /*Toon per vertex*/
 new_shader_info(max_shaders_++, "ToonPerVertex",
                 "Toon.vsh", "Toon.fsh",
                 BF_Mask(kAttribPosition) |
                 BF_Mask(kAttribNormal),
                 BF_Mask(kUniformLightPosition) |
                 BF_Mask(kUniformLightColor) |
                 BF_Mask(kUniformMaterialColor) |
                 BF_Mask(kUniformMaterialGloss) |
                 BF_Mask(kUniformN) |
                 BF_Mask(kUniformMv) |
                 BF_Mask(kUniformMvp));

 /*Toon per fragment*/
 new_shader_info(max_shaders_++, "ToonPerFrag",
                 "ToonPF.vsh", "ToonPF.fsh",
                 BF_Mask(kAttribPosition) |
                 BF_Mask(kAttribNormal),
                 BF_Mask(kUniformLightPosition) |
                 BF_Mask(kUniformLightColor) |
                 BF_Mask(kUniformMaterialColor) |
                 BF_Mask(kUniformMaterialGloss) |
                 BF_Mask(kUniformN) |
                 BF_Mask(kUniformMv) |
                 BF_Mask(kUniformMvp));
 
 /*Double sided per vertex*/
 new_shader_info(max_shaders_++, "DoubleSided",
                 "DoubleSided.vsh", "DoubleSided.fsh",
                 BF_Mask(kAttribPosition) |
                 BF_Mask(kAttribNormal),
                 BF_Mask(kUniformLightPosition) |
                 BF_Mask(kUniformLightColor) |
                 BF_Mask(kUniformMaterialColor) |
                 BF_Mask(kUniformMaterialGloss) |
                 BF_Mask(kUniformN) |
                 BF_Mask(kUniformMv) |
                 BF_Mask(kUniformMvp));

 /*Flat not available for GLSL 120*/
#if defined (GL_ES_VERSION_3_0)
 new_shader_info(max_shaders_++, "Flat",
                 "Flat.vsh", "Flat.fsh",
                 BF_Mask(kAttribPosition) |
                 BF_Mask(kAttribNormal),
                 BF_Mask(kUniformLightPosition) |
                 BF_Mask(kUniformMaterialColor) |
                 BF_Mask(kUniformN) |
                 BF_Mask(kUniformMv) |
                 BF_Mask(kUniformMvp));
#endif

 for (int sh = 0; sh < max_shaders_; ++sh) {
  he_File file[2];
  char fullpathbuf[2][1024];
  /*load files to memory*/
  for (int f = 0; f < 2; ++f) {
   FileCreate(&file[f], BundlePath(fullpathbuf[f], shInfo_[sh].sh_fn[f]));
  }
  
  /*create shader*/
  assert(file[0].buffer);
  assert(file[1].buffer);
  printf("Shader: %s %s\n",shInfo_[sh].sh_fn[0], shInfo_[sh].sh_fn[1]);
  shInfo_[sh].shader = ShaderCreate(file[0].buffer, file[1].buffer, shInfo_[sh].aflag);
  
  /*release files*/
  for (int f = 0; f < 2; ++f) {
   FileDestroy(&file[f]);
  }
 }
}

static void unload_shaders()
{
 for (int sh = 0; sh < max_shaders_; ++sh) {
  ShaderDestroy(shInfo_[sh].shader);
 }
}

void TouchEnd()
{
 curr_shi_ = (curr_shi_ + 1)%max_shaders_;
}

/*MARK: model*/

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

/*MARK: load/unload*/
void StartUp()
{
 printf("%s\n%s\n",glGetString(GL_VERSION), glGetString(GL_SHADING_LANGUAGE_VERSION));
 printf("loading shaders ...\n");
 load_shaders();
 
 printf("loading models ...\n");
 load_models();
 
 /*default GL state*/
 printf("readying GL states ...\n");
 glEnable(GL_DEPTH_TEST);
 curr_shi_ = max_shaders_-1;
 rotation_ = 90.0f;
}

void ShutDown()
{
 glDisable(GL_DEPTH_TEST);
 
 unload_shaders();
 unload_models();
}

/*MARK: loop*/
void Reshape(int w, int h)
{
 pMat = GLKMatrix4MakePerspective(45.0f, (float)w/(float)h, 0.1f, 100.0f);
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
 
 glUseProgram(shInfo_[curr_shi_].shader);
 glBindVertexArrayOES(vao_);
 
 /*pass light attributes to shaders*/
 light_.position = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
 light_.color = GLKVector4Make(0.7f, 0.6f, 0.3f, 1.0f);
 if (BF_IsSet(shInfo_[curr_shi_].uflag, kUniformLightPosition)) {
  GLuint loc = glGetUniformLocation(shInfo_[curr_shi_].shader, "u_LightPosition");
  glUniform4fv(loc, 1, light_.position.v);
 }
 if (BF_IsSet(shInfo_[curr_shi_].uflag, kUniformLightColor)) {
  GLuint loc = glGetUniformLocation(shInfo_[curr_shi_].shader, "u_LightColor");
  glUniform4fv(loc, 1, light_.color.v);
 }

 /*pass material attributes to shaders*/
 material_.color = GLKVector4Make(0.2f, 0.4f, 0.6f, 1.0f);
 material_.gloss = 10.0f;
 if (BF_IsSet(shInfo_[curr_shi_].uflag, kUniformMaterialColor)) {
  GLuint loc = glGetUniformLocation(shInfo_[curr_shi_].shader, "u_MaterialColor");
  glUniform4fv(loc, 1, material_.color.v);
 }
 if (BF_IsSet(shInfo_[curr_shi_].uflag, kUniformMaterialGloss)) {
  GLuint loc = glGetUniformLocation(shInfo_[curr_shi_].shader, "u_MaterialGloss");
  glUniform1f(loc, material_.gloss);
 }

 /*pass transform matrices to shaders*/
 GLKMatrix4 baseMv = GLKMatrix4MakeTranslation(0.0f, 0.0f, -10.0f);
 baseMv = GLKMatrix4Rotate(baseMv, GLKMathDegreesToRadians(0), 1.0f, 0.0f, 0.0f);
 
 /*pass transform matrices to shaders*/
 GLKMatrix4 teapotMv = GLKMatrix4MakeTranslation(0.0f, 0.0f, -2.0f);
 teapotMv = GLKMatrix4Rotate(teapotMv, GLKMathDegreesToRadians(rotation_), 1.0f, 1.0f, 0.0f);
 teapotMv = GLKMatrix4Multiply(baseMv, teapotMv); /*eye space*/
 if (BF_IsSet(shInfo_[curr_shi_].uflag, kUniformMv)) {
  GLuint mv_loc = glGetUniformLocation(shInfo_[curr_shi_].shader, "u_Mv");
  glUniformMatrix4fv(mv_loc, 1, GL_FALSE, teapotMv.m);
 }
 
 GLKMatrix3 teapotN = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(teapotMv), NULL);
 if (BF_IsSet(shInfo_[curr_shi_].uflag, kUniformN)) {
  GLuint n_loc = glGetUniformLocation(shInfo_[curr_shi_].shader, "u_N");
  glUniformMatrix3fv(n_loc, 1, GL_FALSE, teapotN.m);
 }
 
 GLKMatrix4 teapotMvp = GLKMatrix4Multiply(pMat, teapotMv);
 if (BF_IsSet(shInfo_[curr_shi_].uflag, kUniformMvp)) {
  GLuint mvp_loc = glGetUniformLocation(shInfo_[curr_shi_].shader, "u_Mvp");
  glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, teapotMvp.m);
 }
 
 glDrawElements(GL_TRIANGLES, index_count_, GL_UNSIGNED_SHORT, NULL);
}

const char *Info()
{
 return shInfo_[curr_shi_].name;
}
