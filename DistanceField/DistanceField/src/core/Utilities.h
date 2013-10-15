//
//  Utilities.h
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#ifndef OGL_Basic_Utilities_h
#define OGL_Basic_Utilities_h
/**
 *	Get absolute Bundle path
 *
 *	@param	absolute_path	The absolute path (Out)
 *	@param	filename	 The filename (In)
 */
char *BundlePath(char *absolute_path, const char *filename);

/**
 *	Read a file into buffer
 *
 *	@param	path	 The absolute path of the file. (In)
 *	@param	buffer The buffer (Out)
 */
char *ReadFile(char *buffer, const char *path);
#endif
