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
                      const char *fsh_filename) {
 
 char vsh_src[kBuffer4K] = {0};
 char fsh_src[kBuffer4K] = {0};
 char path_buffer[kBuffer1K] = {0};
 
 return CompileShaderSource(shader,
                            ReadFile(vsh_src, BundlePath(path_buffer, vsh_filename)),
                            ReadFile(fsh_src, BundlePath(path_buffer, fsh_filename)));
}

Shader *CompileShaderSource(Shader *shader,
                            const char *vsh_src,
                            const char *fsh_src) {
 
 Shader sh;
 
 sh.attrib_flags = shader->attrib_flags;
 
 // Loads the vertex shader
 sh.vert_shader = glCreateShader(GL_VERTEX_SHADER);
 assert(sh.vert_shader);
 
 glShaderSource(sh.vert_shader, 1, (const char**)&vsh_src, NULL);
 glCompileShader(sh.vert_shader);

#if defined (TEST_ERR_SHADER)
 GLint bShaderCompiled;
 glGetShaderiv(sh.vert_shader, GL_COMPILE_STATUS, &bShaderCompiled);
 if (!bShaderCompiled)	{
  char info_log[kBuffer1K] = {0};
  int info_log_len, chars_written;
  glGetShaderiv(sh.vert_shader, GL_INFO_LOG_LENGTH, &info_log_len);
  glGetShaderInfoLog(sh.vert_shader, info_log_len, &chars_written, info_log);
  printf("Failed to compile vertex shader: %s\n", info_log);
  assert(0);
 }
#endif
 
 // Create the fragment shader object
 sh.frag_shader = glCreateShader(GL_FRAGMENT_SHADER);
 assert(sh.frag_shader);
 
 glShaderSource(sh.frag_shader, 1, (const char**)&fsh_src, NULL);
 glCompileShader(sh.frag_shader);
 
#if defined (TEST_ERR_SHADER)
 glGetShaderiv(sh.frag_shader, GL_COMPILE_STATUS, &bShaderCompiled);
 if (!bShaderCompiled) {
  char info_log[kBuffer1K] = {0};
  int info_log_len, chars_written;
  
  glGetShaderiv(sh.frag_shader, GL_INFO_LOG_LENGTH, &info_log_len);
  glGetShaderInfoLog(sh.frag_shader, info_log_len, &chars_written, info_log);
  printf("Failed to compile fragment shader: %s\n", info_log);
  assert(0);
 }
#endif
 
 // Create the shader program
 sh.program = glCreateProgram();
 assert(sh.program);
 
 // Attach the fragment and vertex shaders to it
 glAttachShader(sh.program, sh.vert_shader);
 glAttachShader(sh.program, sh.frag_shader);
 
 //Bind attributes
 for (int index = 0; index < kAttrib_Total; ++index) {
  if (sh.attrib_flags && kAttribFlag(index)) {
   glBindAttribLocation(sh.program, index, AttribNames[index]);
  }
 }

 // Link the program
 glLinkProgram(sh.program);
 
 // Check if linking succeeded in the same way we checked for compilation success
#if defined (TEST_ERR_SHADER)
 GLint bLinked;
 glGetProgramiv(sh.program, GL_LINK_STATUS, &bLinked);
 if (!bLinked) {
  char info_log[kBuffer1K] = {0};
  int info_log_len, chars_written;
  
  glGetProgramiv(sh.program, GL_INFO_LOG_LENGTH, &info_log_len);
  glGetProgramInfoLog(sh.program, info_log_len, &chars_written, info_log);
  printf("Failed to link program: %s\n", info_log);
  assert(0);
 }
#endif
 
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
