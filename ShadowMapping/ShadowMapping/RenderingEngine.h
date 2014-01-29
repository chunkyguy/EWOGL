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
#include <OpenGLES/ES2/gl.h>

class ShaderProgram;
class IGeometry;
class Camera;

struct Renderer {
  GLKMatrix4 view;
  GLKMatrix4 projection;
  GLuint program;
};

class RenderingEngine {
public:
  RenderingEngine();
  
  bool Init(const GLKVector2 &screenSize);
  
  void Draw(const ShaderProgram *shader, const IGeometry *geometry, const Camera *camera);
  
private:
  GLKVector2 screenSize_;
  Renderer renderer_;
  bool init_;
};
#endif /* defined(__ShadowMapping__RenderingEngine__) */
