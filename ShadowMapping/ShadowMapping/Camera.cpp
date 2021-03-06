//
//  Camera.cpp
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Camera.h"

Camera::  Camera(const float fov,
                 const float aspectRatio,
                 const float near,
                 const float far,
                 const GLKVector3 &position,
                 const GLKVector3 &focus,
                 const GLKVector3 &up,
                 const GLKVector3 &lightDir,
                 const GLKVector4 &lightColor
                 ) :
fov_(fov),
aspectRatio_(aspectRatio),
near_(near),
far_(far),
position_(position),
focus_(focus),
up_(up),
lightDirection_(lightDir),
lightColor_(lightColor),
viewMatrix_(GLKMatrix4Identity),
projectionMatrix_(GLKMatrix4Identity)
{
  update_view();
  update_projection();
}

void Camera::SetFOV(const float fov)
{
  fov_ = fov;
  update_projection();
}

void Camera::SetAspectRatio(const float aspectRatio)
{
  aspectRatio_ = aspectRatio;
  update_projection();
}

void Camera::SetNear(const float near)
{
  near_ = near;
  update_projection();
}

void Camera::SetFar(const float far)
{
  far_ = far;
  update_projection();
}


void Camera::SetPosition(const GLKVector3 &position)
{
  position_ = position;
  update_view();
}

const GLKVector3 &Camera::Position() const
{
  return position_;
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

void Camera::SetLightDirection(const GLKVector3 &lDir)
{
  lightDirection_ = lDir;
}

const GLKVector3 &Camera::LightDirection() const
{
  return lightDirection_;
}

void Camera::SetLightColor(const GLKVector4 &lClr)
{
  lightColor_ = lClr;
}

const GLKVector4 &Camera::LightColor() const
{
  return lightColor_;
}


void Camera::update_view()
{
  viewMatrix_ = GLKMatrix4MakeLookAt(position_.x, position_.y, position_.z,
                                     focus_.x, focus_.y, focus_.z,
                                     up_.x, up_.y, up_.z);
}

void Camera::update_projection()
{
  projectionMatrix_ = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fov_), aspectRatio_, near_, far_);
}

const GLKMatrix4 &Camera::ViewMatrix() const
{
  return viewMatrix_;
}

const GLKMatrix4 &Camera::ProjectionMatrix() const
{
  return projectionMatrix_;
}
