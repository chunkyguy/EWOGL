//
//  he_File.h
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__he_File__
#define __ShadowMapping__he_File__

#include <cstdio>

class File {
public:
  File(const char *path);
  ~File();

  const char *GetData() const;
  
private:
  char *buffer_;
  std::FILE *handle_;
  std::size_t size_;
};

#endif /* defined(__ShadowMapping__he_File__) */
