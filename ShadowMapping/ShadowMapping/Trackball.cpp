//
//  Trackball.cpp
//  MultiSampling
//
//  Created by Sid on 26/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Trackball.h"
#include "he_Quaternion.h"

Trackball::Trackball(const float radius, const GLKVector2 &center) :
radius_(radius),
center_(center),
spinning_(false),
start_(GLKVector2Make(0.0f, 0.0f)),
orientation_(GLKQuaternionIdentity),
prevOrientation_(GLKQuaternionIdentity)
{}

void Trackball::TouchBegan(const GLKVector2 &touchPoint)
{
  start_ = touchPoint;
  spinning_ = true;
  prevOrientation_ = orientation_;
}

void Trackball::TouchEnded(const GLKVector2 &touchPoint)
{
  spinning_ = false;
}

void Trackball::TouchMoved(const GLKVector2 &touchPoint)
{
  if (!spinning_) {
    return;
  }
  
  GLKVector3 start = map_to_trackball(start_);
  GLKVector3 end = map_to_trackball(touchPoint);
  orientation_ = QuaternionRotate(QuaternionFromVectors(start, end), prevOrientation_);
}

GLKVector3 Trackball::map_to_trackball(const GLKVector2 &point)
{
  /* vector from center to point */
  GLKVector2 v = GLKVector2Subtract(point, center_);
  
  /* assume effective radius a little shorter than actual
   * so that the Z axis can be taken into account
   * Therefore, this code is actually clamping the touch point to a trackball of effective radius
   */
  float effRadius = radius_ - 1.0f;

  /*clamp vector to trackball surface using effective radius */
  if (GLKVector2Length(v) > effRadius) {
    float angle = atan2f(v.y, v.x);
    v = GLKVector2MultiplyScalar(GLKVector2Make(cosf(angle), sinf(angle)), effRadius);
  }

  /* using pythogorus theorm to calculate the Z axis */
  float tvecLen = GLKVector2Length(v);
  float z = sqrtf(radius_ * radius_ - tvecLen * tvecLen);
  return GLKVector3Normalize(GLKVector3Make(v.x, v.y, z));
}

const GLKQuaternion &Trackball::GetOrientation() const
{
  return orientation_;
}

void Trackball::SetRadius(const float radius)
{
  radius_ = radius;
}

void Trackball::SetCenter(const GLKVector2 &center)
{
  center_ = center;
}

