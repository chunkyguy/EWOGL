//
//  Framebuffer.c
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include <stdio.h>
#include <assert.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "Framebuffer.h"

Framebuffer CreateFramebuffer(RenderbufferStorage *renderbuffer_storage) {

	Framebuffer frame_buffer;
	
	// Allocate a framebuffer
	glGenFramebuffers(1, &(frame_buffer.buffer));
	glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer.buffer);
	assert(frame_buffer.buffer);	/* Unable to create framebuffer */
	
	// Allocate renderbuffers
	glGenRenderbuffers(2, frame_buffer.renderbuffer);
	
	//	Attach a color renderbuffer
	glBindRenderbuffer(GL_RENDERBUFFER, frame_buffer.renderbuffer[0]);
	assert(frame_buffer.renderbuffer[0]);	/* Unable to create renderbuffer */
	//	Get storage of color renderbuffer from EGL context
	int status = renderbuffer_storage->callback(renderbuffer_storage->context, renderbuffer_storage->layer);
	assert(status);		/* Unable to get renderbuffer storage */
	//bind color renderbuffer
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, frame_buffer.renderbuffer[0]);

	//	Get size of color buffer. Should be same every other renderbuffer
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &(frame_buffer.width));
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &(frame_buffer.height));
	
	// Attach depth renderbuffer
	glBindRenderbuffer(GL_RENDERBUFFER, frame_buffer.renderbuffer[1]);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, frame_buffer.width, frame_buffer.height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, frame_buffer.renderbuffer[1]);
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)	{
		assert(0); /* failed to make complete framebuffer object */
	}
	return frame_buffer;
}

// Clean up any buffers we have allocated.
void DestroyFramebuffer(Framebuffer *frame_buffer) {
	glDeleteRenderbuffers(2, frame_buffer->renderbuffer);
	glDeleteFramebuffers(1, &(frame_buffer->buffer));
	frame_buffer = 0;
}
