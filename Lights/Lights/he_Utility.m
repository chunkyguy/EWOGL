//
//  he_Utility.m
//  Lights
//
//  Created by Sid on 26/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "he_Utility.h"
#import <Foundation/Foundation.h>

/**
 *	Split filename into file and extension.
 *
 *	@param	filename		The filename	 (In)
 *	@param	file			The file part (Out)
 *	@param	extn			The extension part (Out)
 */
static void split(const char *filename, char *file, char *extn)
{
 char *fp = file;
 char *split_pt = strrchr(filename, '.');
 
 for (const char *f = filename; *f != '\0'; ++f) {
  if (f == split_pt) {
   *fp = '\0';
   fp = extn;
  } else {
   *fp++ = *f;
  }
 }
 *fp = '\0';
}


char *BundlePath(char *absolute_path, const char *filename)
{
 char file[256] = {0};
 char extn[10] = {0};
 split(filename, file, extn);
 @autoreleasepool {
  NSString *full_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:filename]];
  assert(full_path);
  strcpy(absolute_path, [full_path UTF8String]);
 }
 return absolute_path;
}
