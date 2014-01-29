//
//  Camera.cpp
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Camera.h"

Camera::Camera(const GLKVector3 &position, const GLKVector3 &focus, const GLKVector3 &up) :
position_(position),
focus_(focus),
up_(up),
viewMatrix_(GLKMatrix4Identity)
{
  update_view();
}

void Camera::SetPosition(const GLKVector3 &position)
{
  position_ = position;
  update_view();
}

void Camera::SetFocus(const GLKVector3 &focus)
{
  focus_ = focus;
  update_view();
}

void Camera::SetUp(const GLKVector3 &up)
{
  up_ = up;
  update_view();
}

void Camera::update_view()
{
  viewMatrix_ = GLKMatrix4MakeLookAt(position_.x, position_.y, position_.z,
                                     focus_.x, focus_.y, focus_.z,
                                     up_.x, up_.y, up_.z);
}

const GLKMatrix4 &Camera::GetViewMatrix() const
{
  return viewMatrix_;
}
