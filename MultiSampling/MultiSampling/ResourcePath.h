//
//  ResourcePath.h
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//
#ifndef __MultiSampling__ResourcePath__
#define __MultiSampling__ResourcePath__
#include <cstddef>

/** Provide a buffer of size bufsz to be filled with the absolute path for the filename 
 * returns a pointer to the buffer or NULL if operation failed.
 */
const char *BundlePath(char *buffer,
                       const size_t bufsz,
                       const char *filename);

#endif

