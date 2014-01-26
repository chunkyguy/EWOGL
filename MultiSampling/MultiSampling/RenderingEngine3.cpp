//
//  RenderingEngine.cpp
//  MultiSampling
//
//  Created by Sid on 23/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "RenderingEngine.h"
#include <OpenGLES/ES3/gl.h>

void RenderingEngine3::bind_msaa_framebuffer(const GLuint fbo, const GLuint crbo, const GLuint drbo)
{
  /* bind multisample framebuffer */
  glBindFramebuffer(GL_FRAMEBUFFER, fbo);
  
  /* bind multisample color renderbuffer */
  glBindRenderbuffer(GL_RENDERBUFFER, crbo);
  glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_RGBA8, bufferWidth_, bufferHeight_);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, crbo);
  
  /* bind multisample depth buffer */
  glBindRenderbuffer(GL_RENDERBUFFER, drbo);
  glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, bufferWidth_, bufferHeight_);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, drbo);
  
  assert (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
}

void RenderingEngine3::resolve_msaa(const GLuint readFBO, const GLuint writeFBO)
{
#if defined (MSAA_ENABLED)
  glBindFramebuffer(GL_READ_FRAMEBUFFER, readFBO);
  glBindFramebuffer(GL_DRAW_FRAMEBUFFER, writeFBO);
  glBlitFramebuffer(0, 0, bufferWidth_, bufferHeight_, 0, 0, bufferWidth_, bufferHeight_, GL_COLOR_BUFFER_BIT, GL_LINEAR);
  
  GLenum discardAttachments[] = {
    GL_COLOR_ATTACHMENT0,
    GL_DEPTH_ATTACHMENT
  };
  glInvalidateFramebuffer(GL_READ_FRAMEBUFFER, 2, discardAttachments);
  
#else
  
  GLenum discardAttachments[] = {
    GL_DEPTH_ATTACHMENT
  };
  glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, discardAttachments);
  
#endif  
}
