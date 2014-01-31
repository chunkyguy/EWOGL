//
//  Light.h
//  ShadowMapping
//
//  Created by Sid on 31/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__Light__
#define __ShadowMapping__Light__

#include <GLKit/GLKMath.h>

class Light {
public:
  Light(const GLKVector4 &position = GLKVector4Make(0.0f, 0.0f, 1.0f, 0.0f),
        const GLKVector4 &color = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f));

  void SetPosition(const GLKVector4 &position);
  const GLKVector4 &GetPosition() const;
  
  void SetColor(const GLKVector4 &color);
  const GLKVector4 &GetColor() const;
  
private:
  GLKVector4 position_;
  GLKVector4 color_;
};

#endif /* defined(__ShadowMapping__Light__) */
