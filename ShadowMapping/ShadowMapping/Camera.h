//
//  Camera.h
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__Camera__
#define __ShadowMapping__Camera__

#include <GLKit/GLKMath.h>

class Camera {
public:
  Camera(const float fov = 60.0f,
         const float aspectRatio = 1.0f,
         const float near = 0.1f,
         const float far = 100.0f,
         const GLKVector3 &position = GLKVector3Make(0.0f, 0.0f, 5.0f),
         const GLKVector3 &focus = GLKVector3Make(0.0f, 0.0f, 0.0f),
         const GLKVector3 &up = GLKVector3Make(0.0f, 1.0f, 0.0f),
         const GLKVector3 &lightDirection = GLKVector3Make(0.0f, 0.0f, 1.0f),
         const GLKVector4 &lightColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)
         );

  /** In degrees */
  void SetFOV(const float fov);
  void SetAspectRatio(const float aspectRatio);
  void SetNear(const float near);
  void SetFar(const float far);
  
  void SetPosition(const GLKVector3 &position);
  const GLKVector3 &Position() const;
  void SetFocus(const GLKVector3 &focus);
  void SetUp(const GLKVector3 &up);

  void SetLightDirection(const GLKVector3 &lDir);
  const GLKVector3 &LightDirection() const;
  
  void SetLightColor(const GLKVector4 &lClr);
  const GLKVector4 &LightColor() const;
  
  const GLKMatrix4 &ViewMatrix() const;
  const GLKMatrix4 &ProjectionMatrix() const;
  
private:
  void update_view();
  void update_projection();
  
  float fov_;
  float aspectRatio_;
  float near_;
  float far_;
  
  GLKVector3 position_;
  GLKVector3 focus_;
  GLKVector3 up_;
  
  GLKVector3 lightDirection_;
  GLKVector4 lightColor_;
  
  GLKMatrix4 viewMatrix_;
  GLKMatrix4 projectionMatrix_;
};

#endif /* defined(__ShadowMapping__Camera__) */
