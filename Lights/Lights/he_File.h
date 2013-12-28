//
//  Utilities.h
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#ifndef he_File_h
#define he_File_h

typedef struct {
 char *buffer;
 size_t len;
} he_File;

/**
 * Read a file into memory
 * @param fbuf The he_File object buffer.
 * @param path The absolute path of the file.
 * @return he_File object or NULL if error
 */
he_File *FileCreate(he_File *fbuf, const char *path);

/** Release the he_File object */
void FileDestroy(he_File *file);

/** Iterate through the file word by word
 * @param context The additional argument that passes back with the callback.
 * @param file The file.
 * @param witr Function pointer that provides the word to caller.
 * word: The word
 * word_len: The length of the word
 * iterates as long as the file has content or the callback returns true.
 */
void FileIterateByWords(const he_File *file,
                        bool (*witr)(const char *word, const int word_len, void *context),
                        void *context);

#endif
