//
//  ShaderProgram.cpp
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "ShaderProgram.h"
#include <cassert>
#include <iostream>
#include "he_File.h"

class ShaderDebugger {
public:
  enum Type {kShader, kProgram};
  
  ShaderDebugger(const GLuint object, Type type) :
  object_(object)
  {
    if (type == kShader) {
      Getiv = glGetShaderiv;
      GetInfoLog = glGetShaderInfoLog;
    } else {
      Getiv = glGetProgramiv;
      GetInfoLog = glGetProgramInfoLog;
    }
  }
  
  bool operator()()
  {
    GLint logLength;
    Getiv(object_, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength) {
      GLchar *log = new GLchar[logLength];
      GetInfoLog(object_, logLength, &logLength, log);
      std::cout << "GLSL: " << log << std::endl;
      delete [] log;
      return false;
    }
    return true;
  }
  
private:
  const GLuint object_;
  void (*Getiv)(GLuint, GLenum, GLint *);
  void (*GetInfoLog)(GLuint, GLint, GLint*, GLchar*);
};


ShaderProgram::ShaderProgram() :
init_(false)
{}

bool ShaderProgram::Init(const char *shPath[2], const he_BitFlag &attribFlags)
{
  program_ = glCreateProgram();

  GLuint sh[2];
  sh[0] = glCreateShader(GL_VERTEX_SHADER);
  sh[1] = glCreateShader(GL_FRAGMENT_SHADER);
  
  for (int i = 0; i < 2; ++i) {
    File file(shPath[i]);
    const char *src = file.GetData();
    glShaderSource(sh[i], 1, &src, nullptr);
    glCompileShader(sh[i]);
    assert(ShaderDebugger(sh[i], ShaderDebugger::kShader)());
    glAttachShader(program_, sh[i]);
  }

  if (BF_IsSet(attribFlags, kAttribPosition)) {
    glBindAttribLocation(program_, kAttribPosition, "av4o_Position");
  }
  if (BF_IsSet(attribFlags, kAttribNormal)) {
    glBindAttribLocation(program_, kAttribNormal, "av3o_Normal");
  }

  glLinkProgram(program_);
  assert(ShaderDebugger(program_, ShaderDebugger::kProgram)());

  for (int i = 0; i < 2; ++i) {
    glDetachShader(program_, sh[i]);
    glDeleteShader(sh[i]);
  }
  
  init_ = true;
  return init_;
}

ShaderProgram::~ShaderProgram()
{
  if (!init_) {
    return;
  }

  glDeleteProgram(program_);
}

GLuint ShaderProgram::GetProgram() const
{
  return program_;
}
