//
//  ShaderProgram.h
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __MultiSampling__ShaderProgram__
#define __MultiSampling__ShaderProgram__
#include <OpenGLES/ES2/gl.h>
#include "he_BitFlag.h"

class ShaderProgram {
public:
  ShaderProgram(const char *vshFilePath, const char *fshFilePath, const he_BitFlag &attribFlags);
  ~ShaderProgram();
  GLuint GetProgram() const;
  
private:
  GLuint compile_shader(GLenum shaderType, const char *path);
  bool debug_shader(GLuint shader,
                    void(*glGetXiv)(GLuint object, GLenum pname, GLint *params),
                    void(*glXInfoLog)(GLuint object, GLsizei bufsize, GLsizei *length, GLchar *infolog));
  
  GLuint program_;
};
#endif /* defined(__MultiSampling__ShaderProgram__) */
