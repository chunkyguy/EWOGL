//
//  he_Path.m
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#import "he_Path.h"
#import <Foundation/Foundation.h>

bool GetBundlePath(char *buffer, const size_t bufsz, const char *filename)
{
  bool success = true;
  
  @autoreleasepool {
    NSString *path = [[[NSBundle mainBundle] resourcePath]
                      stringByAppendingPathComponent:[NSString stringWithUTF8String:filename]];
    if (!path || [path length] > bufsz) {
      success = false;
    } else {
      strcpy(buffer, [path UTF8String]);
    }
  }

  return success;
}
