//
//  ResourcePath.m
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "ResourcePath.h"

const char *BundlePath(char *buffer,
                       const size_t bufsz,
                       const char *filename)
{
  const char *bptr = NULL;
  
  @autoreleasepool {
    NSString *absPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:filename]];
    
    size_t absPathLen = [absPath length];
    if (absPathLen > bufsz) {
      return NULL;
    }
  
    bptr = strncpy(buffer, [absPath UTF8String], absPathLen);
    buffer[absPathLen] = '\0';
  }
  
  return bptr;
}
