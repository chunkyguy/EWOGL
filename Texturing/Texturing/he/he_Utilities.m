//
//  Utilities.m
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "he_std_incl.h"

#import <string.h>
#import <Foundation/Foundation.h>

#import "he_Utilities.h"
#import "he_Constants.h"

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


char *BundlePath(char *buffer, const char *filename) {
 char file[kBuffer256] = {0};
 char extn[10] = {0};
 split(filename, file, extn);
 NSString *full_path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:[NSString stringWithUTF8String:extn]];
 assert(full_path);
 
 return strcpy(buffer, [full_path UTF8String]);
}

char *ReadFile(char *buffer, const char *path) {
 FILE *file = fopen(path, "r");
 assert(file);
 
 int ch;
 char *bp = buffer;
 while ((ch = fgetc(file)) != EOF) {
  *bp++ = ch;
 }
 *bp = '\0';
 fclose(file);
 return buffer;
}

