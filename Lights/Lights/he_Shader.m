//
//  he_Shader.m
//  NormalMapping
//
//  Created by Sid on 20/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "he_Shader.h"

#include <assert.h>

/** Print shader debug message
 *
 * @param glGetXiv
 * glGetShaderiv(GLuint shader, GLenum pname, GLint *params)
 * glGetProgramiv(GLuint program, GLenum pname, GLint *params)
 *
 * @param glXInfoLog
 * glGetShaderInfoLog(GLuint shader, GLsizei bufsize, GLsizei *length, GLchar *infolog)
 * glGetProgramInfoLog(GLuint program, GLsizei bufsize, GLsizei *length, GLchar *infolog)
 */
static void debug_shader(GLuint shader,
                         void(*glGetXiv)(GLuint object, GLenum pname, GLint *params),
                         void(*glXInfoLog)(GLuint object, GLsizei bufsize, GLsizei *length, GLchar *infolog))
{
 GLint logLength;
 glGetXiv(shader, GL_INFO_LOG_LENGTH, &logLength);
 if (logLength > 0) {
  GLchar *log = malloc(sizeof(GLchar) * logLength);
  glXInfoLog(shader, logLength, &logLength, log);
  printf("Shader compile log:\n%s\n", log);
  free(log);
 }
}

GLuint ShaderCreate(const char *vsh_src, const char *fsh_src, const he_BitFlag attrib_flags)
{
 /* create shader program */
 GLuint program = glCreateProgram();
 assert(program);
 
 /* compile vertex shader */
 printf("Compiling vsh...\n");
 GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
 assert(vsh);
 glShaderSource(vsh, 1, &vsh_src, 0);
 glCompileShader(vsh);
#if defined (DEBUG)
 debug_shader(vsh, glGetShaderiv, glGetShaderInfoLog);
#endif
 glAttachShader(program, vsh);
 
 /* compile frag shader */
 printf("Compiling fsh...\n");
 GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);
 assert(fsh);
 glShaderSource(fsh, 1, &fsh_src, 0);
 glCompileShader(fsh);
#if defined (DEBUG)
 debug_shader(fsh, glGetShaderiv, glGetShaderInfoLog);
#endif
 glAttachShader(program, fsh);

 /* bind attributes*/
 if (BF_IsSet(attrib_flags, kAttribPosition)) {
  glBindAttribLocation(program, kAttribPosition, "a_Position");
 }
 if (BF_IsSet(attrib_flags, kAttribColor)) {
  glBindAttribLocation(program, kAttribColor, "a_Color");
 }
 if (BF_IsSet(attrib_flags, kAttribTexcoord)) {
  glBindAttribLocation(program, kAttribTexcoord, "a_Texcoord");
 }
// if (attrib_flags & BF_Mask(kAttribTBN)) {
//  glBindAttribLocation(program, kAttribTBN, "a_Tbn");
// }
 if (BF_IsSet(attrib_flags, kAttribTangent)) {
  glBindAttribLocation(program, kAttribTangent, "a_Tangent");
 }
 if (BF_IsSet(attrib_flags, kAttribBinormal)) {
  glBindAttribLocation(program, kAttribBinormal, "a_Binormal");
 }
 if (BF_IsSet(attrib_flags, kAttribNormal)) {
  glBindAttribLocation(program, kAttribNormal, "a_Normal");
 }

#if defined (GL_ES_VERSION_3_0)
 //glBindFragDataLocation(program, 0, "FragColor");
#endif
 
 /* link */
 printf("Linking...\n");
 glLinkProgram(program);
#if defined (DEBUG)
 debug_shader(program, glGetProgramiv, glGetProgramInfoLog);
#endif
 
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
