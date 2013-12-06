//
//  he_Image.m
//  Textures
//
//  Created by Sid on 06/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "he_Image.h"

Image *Image_Create(Image *buffer, const char *file_path) {
 NSString *path_str = [NSString stringWithCString:file_path encoding:NSASCIIStringEncoding];
 UIImage *image = [UIImage imageWithContentsOfFile:path_str];
 assert(image);
 buffer->width = CGImageGetWidth(image.CGImage);
 buffer->height = CGImageGetHeight(image.CGImage);
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 buffer->pixels = malloc(buffer->height * buffer->width * 4 * sizeof(char));	/*4 bytes per pixel RGBA*/
 CGContextRef context = CGBitmapContextCreate(buffer->pixels,
                                              buffer->width,
                                              buffer->height,
                                              8, 				/*bits per component*/
                                              4 * sizeof(char) * buffer->width, /*bytes per row */
                                              colorSpace,
                                              kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
 CGColorSpaceRelease(colorSpace);
 CGContextClearRect(context, CGRectMake(0, 0, buffer->width, buffer->height));
 CGContextDrawImage(context, CGRectMake( 0, 0, buffer->width, buffer->height), image.CGImage );
 
 //free up
 CGContextRelease(context);
 return buffer;
}

void Image_Release(Image *image) {
 free(image->pixels);
 image = NULL;
}
