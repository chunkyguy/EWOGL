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
 *	@param	filename	 The filename (In)
 *	@param	absolute_path	The absolute path (Out)
 */
void BundlePath(const char *filename, char *absolute_path);

/**
 *	Read a file into buffer
 *
 *	@param	path	 The absolute path of the file. (In)
 *	@param	buffer The buffer (Out)
 */
void ReadFile(const char *path, char *buffer);
#endif
