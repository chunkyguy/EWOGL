//
//  File.cpp
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "File.h"
#include <cassert>

Reader::Reader(const char *path) :
handler_(fopen(path, "r")),
buffer_(NULL)
{
  assert(handler_);
  
  fseek(handler_, 0, SEEK_END);
  long fileSize = ftell(handler_);
  size_ = fileSize + 1;
  
  rewind(handler_);

  buffer_ = new char[size_];
  size_t readSize = fread(buffer_, 1, fileSize, handler_);
  assert(readSize == fileSize);
  buffer_[size_-1] = '\0';
}

Reader::~Reader()
{
  if (buffer_) {
    delete [] buffer_;
  }
  fclose(handler_);
}

const char *Reader::GetData() const
{
  return buffer_;
}
