//
//  he_View.m
//  MultiSampling
//
//  Created by Sid on 23/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#import "he_View.h"

#include "RenderingEngine.h"
#include "AppEngine.h"

struct GLContext {
  EAGLContext *eagl_context;
  CAEAGLLayer *layer;
};

bool RenderbufferStorageCallback(void *context)
{
  GLContext *c = (GLContext *)context;
  return [c->eagl_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:c->layer];
}

@interface he_View () {
  AppEngine *app_;
  CFTimeInterval time_;
}
@property (nonatomic, retain) EAGLContext *glContext;
@property (nonatomic, retain) CADisplayLink *displayLink;
@end

@implementation he_View

+ (Class)layerClass
{
  return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    /* config layer */
    CAEAGLLayer *gl_layer = (CAEAGLLayer *)self.layer;
    gl_layer.opaque = YES;
    gl_layer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @NO,
                                    kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
    /* create gl context */
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    RenderingEngine *renderer = NULL;
    
    if (!self.glContext) {
      self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
      [EAGLContext setCurrentContext:self.glContext];
      renderer = new RenderingEngine2;
    } else {
      [EAGLContext setCurrentContext:self.glContext];
      renderer = new RenderingEngine3;
    }
    GLContext context = {_glContext, gl_layer};
    renderer->Init(&RenderbufferStorageCallback, &context);
    NSAssert(self.glContext, @"OpenGL unavailable");

    app_ = new AppEngine(static_cast<int>(frame.size.width),
                         static_cast<int>(frame.size.height),
                         renderer);
    
    
    /* start timer */
    self.displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(draw)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    time_ = self.displayLink.timestamp;
  }
  return self;
}

- (void)dealloc
{
  delete app_;
}

- (void)draw
{
  CFTimeInterval time = self.displayLink.timestamp;
  app_->UpdateAndDraw(static_cast<unsigned int>((time - time_) * 1000));
  [self.glContext presentRenderbuffer:GL_RENDERBUFFER];  
  time_ = time;
}

- (GLKVector2)getTouchPoint:(NSSet *)touches
{
  UITouch *touch = [touches anyObject];
  CGPoint touchPoint = [touch locationInView:self];
  return GLKVector2Make(touchPoint.x - CGRectGetWidth(self.bounds)/2.0f,
                        CGRectGetHeight(self.bounds)/2.0f - touchPoint.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  app_->TouchBegan([self getTouchPoint:touches]);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  app_->TouchEnd([self getTouchPoint:touches]);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  app_->TouchMove([self getTouchPoint:touches]);
}

@end
