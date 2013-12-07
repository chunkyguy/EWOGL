//
//  WLViewController.m
//  Textures
//
//  Created by Sid on 06/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#import "WLViewController.h"
#import "he_Image.h"
#import "he_Sprite.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define FOV 65.0f /* field of view */
#define X_TILT -60.0f /* rotation around x-axis */
#define SPRITES_ROW 100
#define SPRITES_COL 8
#define DRAW_ORIGIN_Y -1.4f
#define DRAW_ORIGIN_X -3.0f

// Uniform index.
enum
{
 UNIFORM_MODELVIEWPROJECTION_MATRIX,
 UNIFORM_NORMAL_MATRIX,
 UNIFORM_TEXTURE,
 NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


@interface WLViewController () {
 GLuint _program;
 
 GLuint _vertexArray;
 GLuint _vertexBuffer;
 
 GLuint texture_;
 Image image_;
 
 Sprite sprite_[SPRITES_ROW*SPRITES_COL];
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation WLViewController

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

 // get all available extensions
 char *ogl_etxns = (char *)glGetString(GL_EXTENSIONS);
 for (int i = 0; i < strlen(ogl_etxns) && i < 1000; i++) {
   printf("%c",ogl_etxns[i] == ' ' ? '\n' : ogl_etxns[i]);
 }
 printf("\n");
 
 
 // set gl state
 glEnable(GL_DEPTH_TEST);
 glEnable(GL_BLEND);
 glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
 
 // load shader
 [self loadShaders];
 
 // load texture
 NSString *img_path = [[NSBundle mainBundle] pathForResource:@"Goomba" ofType:@"png"];
 Image_Create(&image_, [img_path cStringUsingEncoding:NSASCIIStringEncoding]);
 glGenTextures(1, &texture_);
 glBindTexture(GL_TEXTURE_2D, texture_);
 glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
 glTexImage2D(GL_TEXTURE_2D,
              0,
              GL_RGBA,
              image_.width, image_.height,
              0,
              GL_RGBA,
              GL_UNSIGNED_BYTE, image_.pixels);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
 /* check for GL_EXT_texture_filter_anisotropic extension */
//glEnable(GL_EXT_texture_filter_anisotropic);
// GLfloat max_anisotropicity;
// glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &max_anisotropicity);
// printf("max_anisotropicity: %f",max_anisotropicity);
// glTexParameterf(GL_TEXTURE_2D, GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, max_anisotropicity);

 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 glHint(GL_GENERATE_MIPMAP_HINT, GL_NICEST);

 
 glGenerateMipmap(GL_TEXTURE_2D);
 
 // load vertex data
 glGenVertexArraysOES(1, &_vertexArray);
 glBindVertexArrayOES(_vertexArray);
 
 glGenBuffers(1, &_vertexBuffer);
 glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
 
 GLfloat gCubeVertexData[] =
 {
  // Data layout for each line below is:
  // positionX, positionY, positionZ,
  // normalX, normalY, normalZ,
  // texcoordX, texcoordY
  0.5f, 0.5f, 0.5f,
  0.0f, 0.0f, 1.0f,
  1.0f, 0.0f,
  
  -0.5f, 0.5f, 0.5f,
  0.0f, 0.0f, 1.0f,
  0.0f, 0.0f,
  
  0.5f, -0.5f, 0.5f,
  0.0f, 0.0f, 1.0f,
  1.0f, 1.0f,

  0.5f, -0.5f, 0.5f,
  0.0f, 0.0f, 1.0f,
  1.0f, 1.0f,
  
  -0.5f, 0.5f, 0.5f,
  0.0f, 0.0f, 1.0f,
  0.0f, 0.0f,
  
  -0.5f, -0.5f, 0.5f,
  0.0f, 0.0f, 1.0f,
  0.0f, 1.0f,
 };
 glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
 
 glEnableVertexAttribArray(GLKVertexAttribPosition);
 glVertexAttribPointer(GLKVertexAttribPosition,
                       3, GL_FLOAT, GL_FALSE,
                       sizeof(GLfloat)*8, BUFFER_OFFSET(sizeof(GLfloat)*0));
 
 glEnableVertexAttribArray(GLKVertexAttribNormal);
 glVertexAttribPointer(GLKVertexAttribNormal,
                       3, GL_FLOAT, GL_FALSE,
                       sizeof(GLfloat)*8, BUFFER_OFFSET(sizeof(GLfloat)*3));
 

 glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
 glVertexAttribPointer(GLKVertexAttribTexCoord0,
                       2, GL_FLOAT, GL_FALSE,
                       sizeof(GLfloat)*8, BUFFER_OFFSET(sizeof(GLfloat)*6));
 
 glBindVertexArrayOES(0);
 
 // sprite
 float startY = DRAW_ORIGIN_Y;
 float startX = DRAW_ORIGIN_X;
 for (int r = 0; r < SPRITES_ROW; ++r) {
  for (int c = 0; c < SPRITES_COL; ++c) {
   assert(r*SPRITES_COL+c < (SPRITES_ROW*SPRITES_COL));
   sprite_[r*SPRITES_COL+c].position = GLKVector3Make(startX+c*1.0f, startY+r*1.0f, -1.5f);
  }
 }
}

- (void)tearDownGL
{
 [EAGLContext setCurrentContext:self.context];
 
 glDeleteBuffers(1, &_vertexBuffer);
 glDeleteVertexArraysOES(1, &_vertexArray);
 
 if (_program) {
  glDeleteProgram(_program);
  _program = 0;
 }
 
 // unload texture
 Image_Release(&image_);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
 float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
 GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(FOV), aspect, 0.1f, 100.0f);
 
 GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
 baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, GLKMathDegreesToRadians(X_TILT), 1.0f, 0.0f, 0.0f);
 

 
 glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 
 glBindVertexArrayOES(_vertexArray);
 
 // Render the object again with ES2
 glUseProgram(_program);
 
 glActiveTexture(GL_TEXTURE0);
 glBindTexture(GL_TEXTURE_2D, texture_);
 glUniform1i(uniforms[UNIFORM_TEXTURE], 0);

 for (int i = 0; i < (SPRITES_ROW*SPRITES_COL); ++i) {
  GLKMatrix4 sprite_mvMatrix;
  Sprite_MVMatrix(&sprite_mvMatrix, &sprite_[i]);
  GLKMatrix4 world_mvMatrix = GLKMatrix4Multiply(baseModelViewMatrix, sprite_mvMatrix);
  
  GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, world_mvMatrix);
  glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
  
  GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(world_mvMatrix), NULL);
  glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
  
  glDrawArrays(GL_TRIANGLES, 0, 6);
 }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
 GLuint vertShader, fragShader;
 NSString *vertShaderPathname, *fragShaderPathname;
 
 // Create shader program.
 _program = glCreateProgram();
 
 // Create and compile vertex shader.
 vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
 if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
  NSLog(@"Failed to compile vertex shader");
  return NO;
 }
 
 // Create and compile fragment shader.
 fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
 if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
  NSLog(@"Failed to compile fragment shader");
  return NO;
 }
 
 // Attach vertex shader to program.
 glAttachShader(_program, vertShader);
 
 // Attach fragment shader to program.
 glAttachShader(_program, fragShader);
 
 // Bind attribute locations.
 // This needs to be done prior to linking.
 glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
 glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
 glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "a_texcoord");
 
 // Link program.
 if (![self linkProgram:_program]) {
  NSLog(@"Failed to link program: %d", _program);
  
  if (vertShader) {
   glDeleteShader(vertShader);
   vertShader = 0;
  }
  if (fragShader) {
   glDeleteShader(fragShader);
   fragShader = 0;
  }
  if (_program) {
   glDeleteProgram(_program);
   _program = 0;
  }
  
  return NO;
 }
 
 // Get uniform locations.
 uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
 uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
 uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "u_tex");
 
 // Release vertex and fragment shaders.
 if (vertShader) {
  glDetachShader(_program, vertShader);
  glDeleteShader(vertShader);
 }
 if (fragShader) {
  glDetachShader(_program, fragShader);
  glDeleteShader(fragShader);
 }
 
 return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
 GLint status;
 const GLchar *source;
 
 source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
 if (!source) {
  NSLog(@"Failed to load vertex shader");
  return NO;
 }
 
 *shader = glCreateShader(type);
 glShaderSource(*shader, 1, &source, NULL);
 glCompileShader(*shader);
 
#if defined(DEBUG)
 GLint logLength;
 glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
 if (logLength > 0) {
  GLchar *log = (GLchar *)malloc(logLength);
  glGetShaderInfoLog(*shader, logLength, &logLength, log);
  NSLog(@"Shader compile log:\n%s", log);
  free(log);
 }
#endif
 
 glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
 if (status == 0) {
  glDeleteShader(*shader);
  return NO;
 }
 
 return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
 GLint status;
 glLinkProgram(prog);
 
#if defined(DEBUG)
 GLint logLength;
 glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
 if (logLength > 0) {
  GLchar *log = (GLchar *)malloc(logLength);
  glGetProgramInfoLog(prog, logLength, &logLength, log);
  NSLog(@"Program link log:\n%s", log);
  free(log);
 }
#endif
 
 glGetProgramiv(prog, GL_LINK_STATUS, &status);
 if (status == 0) {
  return NO;
 }
 
 return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
 GLint logLength, status;
 
 glValidateProgram(prog);
 glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
 if (logLength > 0) {
  GLchar *log = (GLchar *)malloc(logLength);
  glGetProgramInfoLog(prog, logLength, &logLength, log);
  NSLog(@"Program validate log:\n%s", log);
  free(log);
 }
 
 glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
 if (status == 0) {
  return NO;
 }
 
 return YES;
}

@end
