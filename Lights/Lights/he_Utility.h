//
//  he_Utility.h
//  Lights
//
//  Created by Sid on 26/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

/** All iOS specific utility functions*/

#ifndef he_Utility_h
#define he_Utility_h

/**
 * Get absolute Bundle path
 * @param	absolute_path_buf	The absolute path buffer
 * @param	filename	 The filename
 * @return Pointer to passed buffer.
 */
char *BundlePath(char *absolute_path_buf, const char *filename);

#endif