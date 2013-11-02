//
//  Ludo.c
//  Ludo
//
//  Created by Sid on 26/10/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "Game.h"

#include "he/he_Constants.h"
#include "he/he_Utilities.h"
#include "he/he_Shader.h"
#include "he/he_Mesh.h"
#include "he/he_Transform.h"
#include "he/he_Types.h"

Shader texture_sh;;
World world;
Mesh board_mesh;
Transform board_trans[4];
Vec4f board_color[4] = {
 1.0, 0.0f, 0.0f, 1.0f, // red
 0.0, 1.0f, 0.0f, 1.0f, //green
 0.0, 0.0f, 1.0f, 1.0f, // blue
 1.0, 1.0f, 0.0f, 1.0f, // yellow
};

void Reshape(GLsizei width, GLsizei height) {
 DefaultPerspective(&world.f);
 if (width > height) {
  world.f.dimension.x = 1.0f;
  world.f.dimension.y = fabsf((float)height / (float)width);
 } else {
  world.f.dimension.x = fabsf((float)width / (float)height);
  world.f.dimension.y = 1.0f;
 }
}

void Unload() {
 ReleaseShader(&texture_sh);
}

void Load() {
 
 // CompileShader(&mesh_sh, "mesh.vsh", "mesh.fsh");
 texture_sh.attrib_flag = kShaderAttribMask(kAttribPosition) | kShaderAttribMask(kAttribNormal);
 CompileShader(&texture_sh, "Shader.vsh", "Shader.fsh");
 
 glEnable(GL_DEPTH_TEST);
 
 
 DefaultTransform(&world.t);
 world.t.position.z = -10.0f;
 world.t.axis = GLKVector3Make(0.0f, 1.0f, 0.0f);
 world.t.angle = 0.0f;
 
 for (int i = 0; i < 4; ++i) {
  DefaultTransform(&board_trans[i]);
  board_trans[i].parent = &world.t;
  board_trans[i].axis = GLKVector3Make(0.0f, 0.0f, 1.0f);
  board_trans[i].angle = 90*i;
 }
 
 
 board_trans[0].position = GLKVector3Make(4.5f, 0.0f, -2.5f);
 board_trans[1].position = GLKVector3Make(0.0f, 1.5f, -5.0f);
 board_trans[2].position = GLKVector3Make(-4.5f, 0.0f, -1.0f);
 board_trans[3].position = GLKVector3Make(0.0f, 0.0f, 0.0f);
 
 
 GLfloat vertex_data[] = {
  -0.5f, 0.5f, 0.0f,
  0.0f, 0.0f, 1.0f,
  
  -0.5f, -0.5f, 0.0f,
  0.0f, 0.0f, 1.0f,
  
  0.5f, 0.5f, 0.0f,
  0.0f, 0.0f, 1.0f,
  
  0.5f, -0.5f, 0.0f,
  0.0f, 0.0f, 1.0f,
 };

 glGenVertexArraysOES(1, &board_mesh.vao);
 glBindVertexArrayOES(board_mesh.vao);
 assert(board_mesh.vao);
 
 /* Generate + bind tGLK VBO */
 glGenBuffers(1, &board_mesh.vbo);
 glBindBuffer(GL_ARRAY_BUFFER, board_mesh.vbo);
 assert(board_mesh.vbo);
 
 /* Set tGLK buffer's data */
 glBufferData(GL_ARRAY_BUFFER, sizeof(vertex_data), vertex_data, GL_STATIC_DRAW);
 
 /* Sets tGLK vertex data to enabled attribute indices */
 GLsizei stride = sizeof(float) * 6;
 Offset position_offset;
 Offset normal_offset;
 position_offset.size = 0;
 normal_offset.size = 3 * sizeof(float);
 glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, position_offset.ptr);
 glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, stride, normal_offset.ptr);
 
 /* Unbind tGLK VAO */
 glBindVertexArrayOES(0);
}

void Update(int dt) {
 world.t.angle += dt * 0.01f;
}

void Render() {
 glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 
 Mat4 mvMat, pMat, mvpMat;
 Mat3 nMat;
 
 int mvp_loc = glGetUniformLocation(texture_sh.program, "u_Mvp");
 int n_loc = glGetUniformLocation(texture_sh.program, "u_N");
 int color_loc = glGetUniformLocation(texture_sh.program, "u_Color");
 
 glBindVertexArrayOES(board_mesh.vao);
 kShaderAttribEnable(texture_sh.attrib_flag);
 
 for (int i = 0; i < 4; ++i) {
  ModelViewMatrix(&mvMat, &board_trans[i]);
  NormalMatrix(&nMat, &mvMat);
  mvpMat = GLKMatrix4Multiply(*PerspectiveMatrix(&pMat, &world.f), mvMat);
  glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, mvpMat.m);
  glUniformMatrix3fv(n_loc, 1, GL_FALSE, nMat.m);
   glUniform4fv(color_loc, 1, &board_color[i].v[0]);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
 }
 kShaderAttribDisable(texture_sh.attrib_flag);
 glBindVertexArrayOES(0);
}
