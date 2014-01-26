//
//  RenderingEngine.cpp
//  MultiSampling
//
//  Created by Sid on 23/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "RenderingEngine.h"
#include <OpenGLES/ES2/glext.h>

void RenderingEngine2::bind_msaa_framebuffer(const GLuint fbo, const GLuint crbo, const GLuint drbo)
{
  /* bind multisample framebuffer */
  glBindFramebuffer(GL_FRAMEBUFFER, fbo);
  
  /* bind multisample color renderbuffer */
  glBindRenderbuffer(GL_RENDERBUFFER, crbo);
  glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, bufferWidth_, bufferHeight_);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, crbo);
  
  /* bind multisample depth buffer */
  glBindRenderbuffer(GL_RENDERBUFFER, drbo);
  glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, bufferWidth_, bufferHeight_);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, drbo);
  
  assert (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
}

void RenderingEngine2::resolve_msaa(const GLuint readFBO, const GLuint writeFBO)
{
#if defined (MSAA_ENABLED)

  glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, readFBO);
  glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, writeFBO);
  glResolveMultisampleFramebufferAPPLE();
  
  GLenum discardAttachments[] = {
    GL_COLOR_ATTACHMENT0,
    GL_DEPTH_ATTACHMENT
  };
  glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, discardAttachments);
  
#else
  
  GLenum discardAttachments[] = {
    GL_DEPTH_ATTACHMENT
  };
  glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discardAttachments);
  
#endif

}
