//
//  he_ViewController.m
//  Lights
//
//  Created by Sid on 24/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#import "he_ViewController.h"
#import "he_Main.h"

@interface he_ViewController ()
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;
@end

@implementation he_ViewController

- (void)viewDidLoad
{
 [super viewDidLoad];
 
 self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
 
 if (!self.context) {
  NSLog(@"Failed to create ES context");
 }
 
 GLKView *view = (GLKView *)self.view;
 view.context = self.context;
 view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
 
 [self setupGL];
}

- (void)dealloc
{
 [self tearDownGL];
 
 if ([EAGLContext currentContext] == self.context) {
  [EAGLContext setCurrentContext:nil];
 }
}

- (void)didReceiveMemoryWarning
{
 [super didReceiveMemoryWarning];
 
 if ([self isViewLoaded] && ([[self view] window] == nil)) {
  self.view = nil;
  
  [self tearDownGL];
  
  if ([EAGLContext currentContext] == self.context) {
   [EAGLContext setCurrentContext:nil];
  }
  self.context = nil;
 }
 
 // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
 [EAGLContext setCurrentContext:self.context];
 StartUp();
}

- (void)tearDownGL
{
 [EAGLContext setCurrentContext:self.context];
 ShutDown();
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
 Reshape(self.view.bounds.size.width, self.view.bounds.size.height);
 Update(self.timeSinceLastUpdate * 1000);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
 Render();
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
 TouchEnd();
}
@end
