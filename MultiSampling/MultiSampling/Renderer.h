//
//  Renderer.h
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef MultiSampling_Renderer_h
#define MultiSampling_Renderer_h
#include <GLKit/GLKMath.h>

/** The rendering context to be passed around the Geometry for rendering purpose */
struct Renderer {
  GLuint program;
  GLKMatrix4 projection;
};

#endif
