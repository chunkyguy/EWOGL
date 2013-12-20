//
//  he_Shader.m
//  NormalMapping
//
//  Created by Sid on 20/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "he_Shader.h"

#include <assert.h>

GLuint ShaderCreate(const char *vsh_src, const char *fsh_src, const he_BitFlag attrib_flags)
{
 /* create shader program */
 GLuint program = glCreateProgram();
 assert(program);
 
 /* compile vertex shader */
 GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
 assert(vsh);
 glShaderSource(vsh, 1, &vsh_src, 0);
 glCompileShader(vsh);
 glAttachShader(program, vsh);
 
 /* compile frag shader */
 GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);
 assert(fsh);
 glShaderSource(fsh, 1, &fsh_src, 0);
 glCompileShader(fsh);
 glAttachShader(program, fsh);

 /* bind attributes*/
 if (attrib_flags & BF_Mask(kAttribPosition)) {
  glBindAttribLocation(program, kAttribPosition, "a_Position");
 }
 if (attrib_flags & BF_Mask(kAttribNormal)) {
  glBindAttribLocation(program, kAttribNormal, "a_Normal");
 }
 if (attrib_flags & BF_Mask(kAttribColor)) {
  glBindAttribLocation(program, kAttribColor, "a_Color");
 }
 if (attrib_flags & BF_Mask(kAttribTexcoord)) {
  glBindAttribLocation(program, kAttribTexcoord, "a_Texcoord");
 }
 
 /* link */
 glLinkProgram(program);
 
 /* release tmp resources */
 glDetachShader(program, vsh);
 glDeleteShader(vsh);
 glDetachShader(program, fsh);
 glDeleteShader(fsh);

 return program;
}

void ShaderDestroy(GLuint shader)
{
 glDeleteProgram(shader);
}
