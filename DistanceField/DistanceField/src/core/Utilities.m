//
//  Utilities.m
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "std_incl.h"

#import <string.h>
#import <Foundation/Foundation.h>

#import "Utilities.h"
#import "Constants.h"

/**
 *	Split filename into file and extension.
 *
 *	@param	filename		The filename	 (In)
 *	@param	file			The file part (Out)
 *	@param	extn			The extension part (Out)
 */
static void split(const char *filename, char *file, char *extn) {
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


char *BundlePath(char *absolute_path, const char *filename) {
 char file[kBuffer1K] = {0};
 char extn[10] = {0};
 split(filename, file, extn);
 NSString *full_path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:[NSString stringWithUTF8String:extn]];
 assert(full_path);
 
 return strcpy(absolute_path, [full_path UTF8String]);
}

char *ReadFile(char *buffer, const char *path) {
 int count = 0;
 FILE *file = fopen(path, "r");
 while((fread((void*)&buffer[count], kBuffer1K, 1, file)) == 1) {
  count += kBuffer1K;
 }
 assert(!ferror(file));
 fclose(file);
 return buffer;
}
