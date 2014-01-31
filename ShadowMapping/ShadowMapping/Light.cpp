//
//  Light.cpp
//  ShadowMapping
//
//  Created by Sid on 31/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "Light.h"

Light::Light(const GLKVector4 &position, const GLKVector4 &color) :
position_(position),
color_(color)
{}

void Light::SetPosition(const GLKVector4 &position)
{
  position_ = position;
}

const GLKVector4 &Light::GetPosition() const
{
  return position_;
}

void Light::SetColor(const GLKVector4 &color)
{
  color_ = color;
}

const GLKVector4 &Light::GetColor() const
{
  return color_;
}
