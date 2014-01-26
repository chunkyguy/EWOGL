//
//  Trackball.h
//  MultiSampling
//
//  Created by Sid on 26/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __MultiSampling__Trackball__
#define __MultiSampling__Trackball__
#include <GLKit/GLKMath.h>

class Trackball {
public:
  Trackball(const float radius = 0.0f, const GLKVector2 &center = GLKVector2Make(0.0f, 0.0f));

  void SetRadius(const float radius);
  void SetCenter(const GLKVector2 &center);
  
  void TouchBegan(const GLKVector2 &touchPoint);
  void TouchEnded(const GLKVector2 &touchPoint);
  void TouchMoved(const GLKVector2 &touchPoint);
  
  const GLKQuaternion &GetOrientation() const;
  
private:
  
  GLKVector3 map_to_trackball(const GLKVector2 &point);
  
  float radius_;
  GLKVector2 center_;
  bool spinning_;
  GLKVector2 start_;
  GLKQuaternion orientation_;
  GLKQuaternion prevOrientation_;
};

#endif /* defined(__MultiSampling__Trackball__) */
