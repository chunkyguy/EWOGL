//
//  ShaderProgram.cpp
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "ShaderProgram.h"

#include <cassert>
#include <iostream>

#include "File.h"
#include "Constants.h"

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
bool ShaderProgram::debug_shader(GLuint shader,
                         void(*glGetXiv)(GLuint object, GLenum pname, GLint *params),
                         void(*glXInfoLog)(GLuint object, GLsizei bufsize, GLsizei *length, GLchar *infolog))
{
  GLint logLength;
  glGetXiv(shader, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = new GLchar [logLength];
    glXInfoLog(shader, logLength, &logLength, log);
    std::cout << "GLSL log:\n" << log << std::endl;
    delete [] log;
    return false;
  }
  return true;
}

GLuint ShaderProgram::compile_shader(GLenum shaderType, const char *path)
{
  GLuint sh = glCreateShader(shaderType);
  Reader file(path);
  const GLchar *src = file.GetData();
  glShaderSource(sh, 1, &src, NULL);
  glCompileShader(sh);

  assert(debug_shader(sh, glGetShaderiv, glGetShaderInfoLog));
  return sh;
}

ShaderProgram::ShaderProgram(const char *vshFilePath,
                             const char *fshFilePath,
                             const he_BitFlag &attribFlags) :
program_(glCreateProgram())
{
  GLuint vsh = compile_shader(GL_VERTEX_SHADER, vshFilePath);
  GLuint fsh = compile_shader(GL_FRAGMENT_SHADER, fshFilePath);
  glAttachShader(program_, vsh);
  glAttachShader(program_, fsh);

  // Bind attributes
  if (BF_IsSet(attribFlags, kAttribPosition)) {
    glBindAttribLocation(program_, kAttribPosition, "av4o_Position");
  }
  if (BF_IsSet(attribFlags, kAttribNormal)) {
    glBindAttribLocation(program_, kAttribNormal, "av3o_Normal");
  }

  glLinkProgram(program_);
  assert(debug_shader(program_, glGetProgramiv, glGetProgramInfoLog));
  
  glDetachShader(program_, vsh);
  glDetachShader(program_, fsh);
  glDeleteShader(vsh);
  glDeleteShader(fsh);
}

ShaderProgram::~ShaderProgram()
{
  glDeleteProgram(program_);
}

GLuint ShaderProgram::GetProgram() const
{
  return program_;
}
