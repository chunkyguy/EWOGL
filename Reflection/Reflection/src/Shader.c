//
//  Shader.c
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "std_incl.h"
#include "Shader.h"
#include "Utilities.h"
#include "Constants.h"


Shader *CompileShader(Shader *shader,
                      const char *vsh_filename,
                      const char *fsh_filename,
                      BindAttribs bind_attribs) {
 char vsh_src[kBuffer20] = {0};
 char fsh_src[kBuffer20] = {0};
 char path_buffer[kBuffer10] = {0};
 
 BundlePath(vsh_filename, path_buffer);
 ReadFile(path_buffer, vsh_src);
 
 BundlePath(fsh_filename, path_buffer);
 ReadFile(path_buffer, fsh_src);
 
 return CompileShaderSource(shader, vsh_src, fsh_src, bind_attribs);
}

Shader *CompileShaderSource(Shader *shader,
                            const char *vsh_src,
                            const char *fsh_src,
                            BindAttribs bind_attribs) {
 
 Shader sh;
 GLint bShaderCompiled;
 
 // Loads the vertex shader
 sh.vert_shader = glCreateShader(GL_VERTEX_SHADER);
 assert(sh.vert_shader);
 
 glShaderSource(sh.vert_shader, 1, (const char**)&vsh_src, NULL);
 glCompileShader(sh.vert_shader);
 
 glGetShaderiv(sh.vert_shader, GL_COMPILE_STATUS, &bShaderCompiled);
 if (!bShaderCompiled)	{
  char info_log[kBuffer20] = {0};
  int info_log_len, chars_written;
  glGetShaderiv(sh.vert_shader, GL_INFO_LOG_LENGTH, &info_log_len);
  glGetShaderInfoLog(sh.vert_shader, info_log_len, &chars_written, info_log);
  printf("Failed to compile vertex shader: %s\n", info_log);
  assert(0);
 }
 
 // Create the fragment shader object
 sh.frag_shader = glCreateShader(GL_FRAGMENT_SHADER);
 assert(sh.frag_shader);
 
 glShaderSource(sh.frag_shader, 1, (const char**)&fsh_src, NULL);
 glCompileShader(sh.frag_shader);
 
 glGetShaderiv(sh.frag_shader, GL_COMPILE_STATUS, &bShaderCompiled);
 if (!bShaderCompiled) {
  char info_log[kBuffer20] = {0};
  int info_log_len, chars_written;
  
  glGetShaderiv(sh.frag_shader, GL_INFO_LOG_LENGTH, &info_log_len);
  glGetShaderInfoLog(sh.frag_shader, info_log_len, &chars_written, info_log);
  printf("Failed to compile fragment shader: %s\n", info_log);
  assert(0);
 }
 
 // Create the shader program
 sh.program = glCreateProgram();
 assert(sh.program);
 
 // Attach the fragment and vertex shaders to it
 glAttachShader(sh.program, sh.vert_shader);
 glAttachShader(sh.program, sh.frag_shader);
 
 //Bind attributes
 bind_attribs(&sh);
 
 
 // Link the program
 glLinkProgram(sh.program);
 
 // Check if linking succeeded in the same way we checked for compilation success
 GLint bLinked;
 glGetProgramiv(sh.program, GL_LINK_STATUS, &bLinked);
 if (!bLinked) {
  char info_log[kBuffer20] = {0};
  int info_log_len, chars_written;
  
  glGetProgramiv(sh.program, GL_INFO_LOG_LENGTH, &info_log_len);
  glGetProgramInfoLog(sh.program, info_log_len, &chars_written, info_log);
  printf("Failed to link program: %s\n", info_log);
  assert(0);
 }
 
 // Actually use the created program
 glUseProgram(sh.program);
 
 return memcpy(shader, &sh, sizeof(sh));
}

void ReleaseShader(Shader *shader) {
 glDetachShader(shader->program, shader->vert_shader);
 glDeleteShader(shader->vert_shader);
 
 glDetachShader(shader->program, shader->frag_shader);
 glDeleteShader(shader->frag_shader);
 
 glDeleteProgram(shader->program);
 shader = NULL;
}

