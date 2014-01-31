//
//  Cube.h
//  ShadowMapping
//
//  Created by Sid on 31/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__Cube__
#define __ShadowMapping__Cube__

#include <OpenGLES/ES3/gl.h>

#include "IGeometry.h"

class Cube : public IGeometry {
public:
  ~Cube();
  bool Init();
  virtual void Update(const unsigned int dt);
  virtual void Draw(const Renderer *renderer) const;

private:
  bool init_;
  int vertexCount_;
  GLuint vao_;
  GLuint vbo_;
};

#endif /* defined(__ShadowMapping__Cube__) */
