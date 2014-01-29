//
//  RenderingEngine.h
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__RenderingEngine__
#define __ShadowMapping__RenderingEngine__
#include <GLKit/GLKMath.h>

class ShaderProgram;

class RenderingEngine {
public:
  RenderingEngine();
  
  bool Init(const GLKVector2 &screenSize);
  
  void BindShader(const ShaderProgram *shader);
  void DrawFrame();
  
private:
  const ShaderProgram *shader_;
  GLKVector2 screenSize_;
  bool init_;
};
#endif /* defined(__ShadowMapping__RenderingEngine__) */
