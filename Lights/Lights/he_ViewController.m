//
//  he_ViewController.m
//  Lights
//
//  Created by Sid on 24/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#import "he_ViewController.h"

#include "he_Availability.h"
#import "he_Main.h"

@interface he_ViewController () {
 UILabel *lbl;
}
@property (strong, nonatomic) EAGLContext *context;
- (void)setupGL;
- (void)tearDownGL;
@end

@implementation he_ViewController

- (void)viewDidLoad
{
 [super viewDidLoad];

#if defined (GL_ES_VERSION_3_0)
 self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
 printf("Rendering API: ES3\n");
#elif defined (GL_ES_VERSION_2_0)
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  printf("Rendering API: ES2\n");
#else
 #error Rendering API: NONE
#endif
 
 GLKView *view = (GLKView *)self.view;
 view.context = self.context;
 view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
 
 lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, 200, 40)];
 lbl.textAlignment = UITextAlignmentLeft;
 lbl.backgroundColor = [UIColor clearColor];
 lbl.text = @"Shading";
 [self.view addSubview:lbl];
 
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
 lbl.text = [NSString stringWithUTF8String:Info()];
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
 lbl.text = [NSString stringWithUTF8String:Info()];
}
@end
