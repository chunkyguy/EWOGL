//
//  he_Image.h
//  Textures
//
//  Created by Sid on 06/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef he_Image_h
#define he_Image_h

typedef struct {
 void *pixels;
 size_t width;
 size_t height;
} he_Image;

/** Load a image from a file
 * @param buffer Buffer for the image to be loaded.
 * @param file_path Absolute path to the image file.
 * @return The texture object.
 */
he_Image *Image_Create(he_Image *buffer, const char *file_path);

/** Release the Image internal data */
void Image_Release(he_Image *texture);
#endif