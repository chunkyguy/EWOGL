//
//  ShaderProgram.h
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__ShaderProgram__
#define __ShadowMapping__ShaderProgram__
#include <OpenGLES/ES2/gl.h>
#include "he_BitFlag.h"

#define kAttribPosition 	1
#define kAttribNormal			2

class ShaderProgram {
public:
  ShaderProgram();
  ~ShaderProgram();
  bool Init(const char *shPath[2], const he_BitFlag &attribFlags);

  GLuint GetProgram() const;
  
private:
  GLuint program_;
  bool init_;
};
#endif /* defined(__ShadowMapping__ShaderProgram__) */
