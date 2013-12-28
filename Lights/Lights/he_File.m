//
//  Utilities.m
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "he_File.h"

#include <string.h>

he_File *FileCreate(he_File *fbuf, const char *path)
{
 FILE *file = fopen(path, "r");
 if (!file) {
  return NULL; /*unable to open file*/
 }
 
 /*get file size*/
 fseek(file, 0, SEEK_END);
 fbuf->len = ftell(file);
 fbuf->buffer = calloc(fbuf->len, sizeof(char));
 rewind(file);

 /*copy file*/
 if (fread(fbuf->buffer, 1, fbuf->len, file) != fbuf->len) {
  FileDestroy(fbuf);
  fbuf = NULL;
 }

 /*release file*/
 fclose(file);
 return fbuf;
}

void FileDestroy(he_File *file)
{
 free(file->buffer);
 file->buffer = NULL;
 file->len = 0;
}

void FileIterateByWords(const he_File *file,
                        bool (*witr)(const char *word, const int word_len, void *context),
                        void *context)
{
 char w[256];
 int wi = 0;
 char ch;
 bool done = false;
 
 for (size_t cc = 0; !done && cc < file->len; ++cc) {
  ch = file->buffer[cc];
  if (isspace(ch)) {
   w[wi] = '\0';
   done = witr(w, wi, context);
   wi = 0;
  } else {
   w[wi++] = ch;
  }
 }
}
