//
//  Debugger.cpp
//  ShadowMapping
//
//  Created by Sid on 30/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Debugger.h"
#include <cstdio>
#include <OpenGLES/ES2/gl.h>

int DebugGL()
{
  int errCount = 0;
  for (GLenum err = glGetError(); err != GL_NO_ERROR; err = glGetError(), errCount++) {
    switch (err) {
      case GL_INVALID_ENUM: printf("GL_INVALID_ENUM\n"); break;
      case GL_INVALID_VALUE: printf("GL_INVALID_VALUE\n"); break;
      case GL_INVALID_OPERATION: printf("GL_INVALID_OPERATION\n"); break;
      case GL_INVALID_FRAMEBUFFER_OPERATION: printf("GL_INVALID_FRAMEBUFFER_OPERATION\n"); break;
      case GL_OUT_OF_MEMORY: printf("GL_OUT_OF_MEMORY\n"); break;
      default: printf("UNKNOWN\n");       break;
    }
  }
  return errCount;
}