//
//  he_File.cpp
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "he_File.h"
#include <cassert>

File::File(const char *path) :
buffer_(NULL),
handle_(fopen(path, "r")),
size_(0)
{
  assert(handle_);
  
  fseek(handle_, 0L, SEEK_END);
  size_ = ftell(handle_);
  
  rewind(handle_);
  
  buffer_ = new char[size_+1];
  fread(buffer_, 1, size_, handle_);
  buffer_[size_] = '\0';
}

File::~File()
{
  if (handle_) {
    fclose(handle_);
  }
  if (buffer_) {
    delete [] buffer_;
  }
}

const char *File::GetData() const
{
  return buffer_;
}
