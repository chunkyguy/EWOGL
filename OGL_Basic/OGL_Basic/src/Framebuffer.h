//
//  Framebuffer.h
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef OGL_Basic_Framebuffer_h
#define OGL_Basic_Framebuffer_h

struct Framebuffer_ {
	GLuint buffer;
	GLuint renderbuffer[2];
	GLint width;
	GLint height;
};
typedef struct Framebuffer_ Framebuffer;

struct RenderbufferStorage_ {
	int(*callback)(void *context, void *layer);
	void *context;
	void *layer;
};
typedef struct RenderbufferStorage_ RenderbufferStorage;

int CreateFramebuffer(RenderbufferStorage *renderbuffer_storage, Framebuffer *frame_buffer);
void DestroyFramebuffer(Framebuffer *frame_buffer);

#endif
