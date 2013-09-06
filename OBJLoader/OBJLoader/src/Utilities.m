//
//  Utilities.m
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "std_incl.h"
#include "Utilities.h"

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


void BundlePath(const char *filename, char *absolute_path) {
	char file[kBuffer(5)] = {0};
	char extn[kBuffer(5)] = {0};
	split(filename, file, extn);
	NSString *full_path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:[NSString stringWithUTF8String:extn]];
	assert(full_path);
	
	strcpy(absolute_path, [full_path UTF8String]);
}

FileInfo ReadFile(const char *path, char *buffer) {
	FILE *file = fopen(path, "r");
	assert(file);
	
	FileInfo fi = {0, 0};
	int ch;
	while ((ch = fgetc(file)) != EOF) {
		*buffer++ = ch;
		if (ch == '\n') {
			fi.lines++;
		}
		fi.words++;
	}
	*buffer = '\0';
	fclose(file);
	return fi;
}

