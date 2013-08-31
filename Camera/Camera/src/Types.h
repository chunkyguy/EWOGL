//
//  Types.h
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Camera_Types_h
#define Camera_Types_h

// The Framebuffer object
struct Framebuffer_ {
	GLuint buffer;
	GLuint renderbuffer[2];
	GLint width;
	GLint height;
};
typedef struct Framebuffer_ Framebuffer;

// Callback to allocate the color renderbuffer storage.
struct RenderbufferStorage_ {
	int(*callback)(void *context, void *layer);
	void *context;
	void *layer;
};
typedef struct RenderbufferStorage_ RenderbufferStorage;

// Screen size
struct ScreenSize_ {
	GLsizei width;
	GLsizei height;
};
typedef struct ScreenSize_ ScreenSize;

// Compiled shader program
struct Program_ {
	GLuint vert_shader;
	GLuint frag_shader;
	GLuint program;
};
typedef struct Program_ Program;

#endif
