//
//  he_ViewController.m
//  NormalMapping
//
//  Created by Sid on 20/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#import "he_ViewController.h"
#import "he_Shader.h"
#import "he_BitFlag.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface he_ViewController () {
 GLuint _program;
 
 GLKMatrix4 _modelViewProjectionMatrix;
 GLKMatrix3 _normalMatrix;
 float _rotation;
 
 GLuint _vertexArray;
 GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (void)loadShaders;
- (void)loadTextures;
- (void)loadModels;
- (void)loadDefaultGLStates;
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

 [self loadShaders];
 [self loadTextures];
 [self loadModels];
 [self loadDefaultGLStates];
}

- (void)tearDownGL
{
 [EAGLContext setCurrentContext:self.context];

 [self unloadModels];
 [self unloadTextures];
 [self unloadShaders];
 [self unloadDefaultGLStates];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
 float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
 GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
 
 
 GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
 baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
 
 // Compute the model view matrix for the object rendered with ES2
 GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
 modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
 modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
 
 _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
 
 _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
 
 _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
 glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 
 glBindVertexArrayOES(_vertexArray);
 
 // Render the object again with ES2
 glUseProgram(_program);
 
 GLuint u_Mvp = glGetUniformLocation(_program, "u_Mvp");
 glUniformMatrix4fv(u_Mvp, 1, 0, _modelViewProjectionMatrix.m);
 GLuint u_N = glGetUniformLocation(_program, "u_N");
 glUniformMatrix3fv(u_N, 1, 0, _normalMatrix.m);
 
 glDrawArrays(GL_TRIANGLES, 0, 36);
}

#pragma mark - shaders
- (void)loadShaders
{
 NSString *vsh_file = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
 const char *vsh_src = [[NSString stringWithContentsOfFile:vsh_file
                                                  encoding:NSUTF8StringEncoding error:nil] UTF8String];
 NSString *fsh_file = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
 const char *fsh_src = [[NSString stringWithContentsOfFile:fsh_file
                                                  encoding:NSUTF8StringEncoding error:nil] UTF8String];
 he_BitFlag attrib_flag = BF_Mask(kAttribPosition) | BF_Mask(kAttribNormal);
 _program = ShaderCreate(vsh_src, fsh_src, attrib_flag);
}

- (void)unloadShaders
{
 ShaderDestroy(_program);
}

#pragma mark - Textures
- (void)loadTextures
{}

- (void)unloadTextures
{}

#pragma mark -  Models
- (void)loadModels
{
 GLfloat cubeVertexData[216] =
 {
  // Data layout for each line below is:
  // positionX, positionY, positionZ,     normalX, normalY, normalZ,
  0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
  
  0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
  0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
  0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
  
  -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
  
  -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
  0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
  0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
  
  0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
  0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
  0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
  
  0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
  -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
  0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
  0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
  -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
 };

 glGenVertexArraysOES(1, &_vertexArray);
 glBindVertexArrayOES(_vertexArray);
 
 glGenBuffers(1, &_vertexBuffer);
 glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
 glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertexData), cubeVertexData, GL_STATIC_DRAW);
 
 glEnableVertexAttribArray(GLKVertexAttribPosition);
 glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
 glEnableVertexAttribArray(GLKVertexAttribNormal);
 glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
 
 glBindVertexArrayOES(0);
}

- (void)unloadModels
{
 glDeleteBuffers(1, &_vertexBuffer);
 glDeleteVertexArraysOES(1, &_vertexArray);
}
#pragma mark - Default GL state
- (void)loadDefaultGLStates
{
 glEnable(GL_DEPTH_TEST);
}

- (void)unloadDefaultGLStates
{
 glDisable(GL_DEPTH_TEST);
}
@end
