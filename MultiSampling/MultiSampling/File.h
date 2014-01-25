//
//  File.h
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __MultiSampling__File__
#define __MultiSampling__File__
#include <cstdio>

class Reader {
public:
  Reader(const char *path);
  ~Reader();
  const char *GetData() const;
  
private:
  size_t size_;
  char *buffer_;
  FILE *handler_;
};
#endif /* defined(__MultiSampling__File__) */
