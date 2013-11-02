//
//  HEViewController.m
//  Texturing
//
//  Created by Sid on 24/10/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#import "HEViewController.h"
#include "Game.h"
#include "he/he_Constants.h"

@interface HEViewController () {
}
@property (strong, nonatomic) EAGLContext *context;
- (void)setupGL;
- (void)tearDownGL;
@end

@implementation HEViewController

- (void)viewDidLoad {
 [super viewDidLoad];
 
 self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
 
 if (!self.context) {
  NSLog(@"Failed to create ES context");
 }
 
 GLKView *view = (GLKView *)self.view;
 view.context = self.context;
 view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
 view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
 
 [self setupGL];
}

- (void)dealloc {
 [self tearDownGL];
 
 if ([EAGLContext currentContext] == self.context) {
  [EAGLContext setCurrentContext:nil];
 }
}

- (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 
 if ([self isViewLoaded] && ([[self view] window] == nil)) {
  self.view = nil;
  
  [self tearDownGL];
  
  if ([EAGLContext currentContext] == self.context) {
   [EAGLContext setCurrentContext:nil];
  }
  self.context = nil;
 }
}

- (void)setupGL {
 [EAGLContext setCurrentContext:self.context];
 Load();
}

- (void)tearDownGL {
 [EAGLContext setCurrentContext:self.context];
 Unload();
}

- (void)update {
 Reshape(self.view.bounds.size.width, self.view.bounds.size.height);
 Update(self.timeSinceLastUpdate * 1000);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
 Render();
}

-(void)testFramebuffer {
 // check for errors
#if defined (TEST_ERR_FRAMEBUFFER)
 GLenum fb_status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
 switch (fb_status) {
  case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: printf("Framebuffer error:\nany of the framebuffer attachment points are framebuffer incomplete.\n"); assert(0); break;
  case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: printf("Framebuffer error:\nthe framebuffer does not have at least one image attached to it.\n"); assert(0); break;
  case GL_FRAMEBUFFER_UNSUPPORTED: printf("Framebuffer error:\nthe combination of internal formats of the attached images violates an implementation-dependent set of restrictions.\n"); assert(0); break;
  case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS: printf("Framebuffer error:\nframebuffer dimensions error.\n"); assert(0); break;
   //		case GL_FRAMEBUFFER_UNDEFINED: printf("target is the default framebuffer, but the default framebuffer does not exist.\n"); assert(0); break;
   //		case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: printf("the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for any color attachment point(s) named by GL_DRAWBUFFERi.\n"); assert(0); break;
   //		case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER: printf("GL_READ_BUFFER is not GL_NONE and the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for the color attachment point named by GL_READ_BUFFER.\n"); assert(0); break;
   //		case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: printf("the value of GL_RENDERBUFFER_SAMPLES is not the same for all attached renderbuffers; if the value of GL_TEXTURE_SAMPLES is the not same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value	of GL_RENDERBUFFER_SAMPLES does not match the value of GL_TEXTURE_SAMPLES.\n"); assert(0); break;
   //		case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: printf("the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not the same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not GL_TRUE for all attached textures.\n"); assert(0); break;
   //		case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: printf("any framebuffer attachment is layered, and any populated attachment is not layered, or if all populated color attachments are not from textures of the same target.\n"); assert(0); break;
  case GL_FRAMEBUFFER_COMPLETE: printf("Framebuffer ready\n"); break;
  default: printf("Framebuffer error: Status unknown: %d\n",fb_status); assert(0); break;
 }
#endif
}

@end
