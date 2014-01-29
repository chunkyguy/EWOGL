//
//  he_View.m
//  ShadowMapping
//
//  Created by Sid on 28/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#import "he_View.h"
#import "AppEngine.h"

bool RenderbufferStorageCompletion(void *eaglContext, void *layer)
{
  return [(__bridge EAGLContext *)eaglContext renderbufferStorage:GL_RENDERBUFFER
                                                     fromDrawable:(__bridge CAEAGLLayer *)layer];
}

@interface he_View () {
  AppEngine _appEngine;
  CFTimeInterval _time;
}
@property (nonatomic, retain) EAGLContext *eaglContext;
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
    /* config the layer */
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                nil];
    
    /* create gl context */
    self.eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    assert(self.eaglContext);
    [EAGLContext setCurrentContext:self.eaglContext];

    /* start the App Engine */
    RenderbufferStorage rboStorage((__bridge void *)_eaglContext,
                                   (__bridge void *)layer,
                                   RenderbufferStorageCompletion);

    _appEngine.Init(rboStorage, GLKVector2Make(frame.size.width, frame.size.height));
    
    /* start the timer */
    self.displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(refresh)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _time = self.displayLink.timestamp;
  }
  return self;
}

- (void)refresh
{
  CFTimeInterval time = self.displayLink.timestamp;
  
  _appEngine.Update((unsigned int)(time - _time) * 1000);
  
  [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
  _time = time;
}
@end
