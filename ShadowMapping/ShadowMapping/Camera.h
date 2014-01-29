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
  Camera(const GLKVector3 &position = GLKVector3Make(0.0f, 0.0f, 5.0f),
         const GLKVector3 &focus = GLKVector3Make(0.0f, 0.0f, 0.0f),
         const GLKVector3 &up = GLKVector3Make(0.0f, 1.0f, 0.0f));
  
  void SetPosition(const GLKVector3 &position);
  void SetFocus(const GLKVector3 &focus);
  void SetUp(const GLKVector3 &up);
  
  const GLKMatrix4 &GetViewMatrix() const;
  
private:
  void update_view();
  
  GLKVector3 position_;
  GLKVector3 focus_;
  GLKVector3 up_;
  GLKMatrix4 viewMatrix_;
};

#endif /* defined(__ShadowMapping__Camera__) */
