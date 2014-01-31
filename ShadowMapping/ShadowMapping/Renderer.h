//
//  Renderer.h
//  ShadowMapping
//
//  Created by Sid on 30/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__Renderer__
#define __ShadowMapping__Renderer__
#include <GLKit/GLKMath.h>
#include <OpenGLES/ES2/gl.h>

struct Renderer {
  GLuint program;
  
  GLKMatrix4 view;
  GLKMatrix4 projection;
  
  GLKMatrix4 shadowView;
  GLKMatrix4 shadowProjection;
  
  int pass;
};


#endif /* defined(__ShadowMapping__Renderer__) */
