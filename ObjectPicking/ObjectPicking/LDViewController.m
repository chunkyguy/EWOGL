//
//  LDViewController.m
//  ObjectPicking
//
//  Created by Sid on 22/02/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#import "LDViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

static void print(const char *pre, float *f, int size)
{
  if (pre){
	  printf("%s",pre);
  }
  for (int i = 0; i < size; ++i) {
    printf("% 0.3f%c",f[i], ((i+1)%4)?' ':'\n');
  }
  printf("\n");
}

// Uniform index.
enum
{
  UNIFORM_MODELVIEW_MATRIX,
  UNIFORM_MODELVIEWPROJECTION_MATRIX,
  UNIFORM_NORMAL_MATRIX,
  UNIFORM_COLOR,
  NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
  ATTRIB_VERTEX,
  ATTRIB_NORMAL,
  NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[216] =
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

@interface LDViewController () {
  GLuint _program;
  
  GLKMatrix4 _model[2];
  GLKMatrix4 _view;
  GLKMatrix4 _projection;

  float _rotation;
  GLKVector4 _color[2];
  
  GLuint _vertexArray;
  GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation LDViewController

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
  
  glEnable(GL_DEPTH_TEST);
  
  glGenVertexArraysOES(1, &_vertexArray);
  glBindVertexArrayOES(_vertexArray);
  
  glGenBuffers(1, &_vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
  
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
  glEnableVertexAttribArray(GLKVertexAttribNormal);
  glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
  
  glBindVertexArrayOES(0);

  for (int i = 0; i < 2; ++i) {
	  [self changeColor:i];
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
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)changeColor:(int)index
{
  _color[index] = GLKVector4Make(rand()/(float)RAND_MAX, rand()/(float)RAND_MAX, rand()/(float)RAND_MAX, 1.0f);
}

- (void)update
{
  float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
  _projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
  
  
  _view = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
  _view = GLKMatrix4Rotate(_view, _rotation, 0.0f, 1.0f, 0.0f);
//_view = GLKMatrix4Identity;
  
  _model[0] = GLKMatrix4MakeTranslation(0.0f, 0.0f, -2.0f);
  _model[0] = GLKMatrix4Rotate(_model[0], _rotation, 1.0f, 1.0f, 1.0f);

  _model[1] = GLKMatrix4MakeTranslation(0.0f, 0.0f, 2.0f);
  _model[1] = GLKMatrix4Rotate(_model[1], _rotation, 1.0f, 1.0f, 1.0f);

  _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
  glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  glBindVertexArrayOES(_vertexArray);
  
  // Render the object again with ES2
  glUseProgram(_program);

  for (int i = 0; i < 2; ++i) {
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(_view, _model[i]);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(_projection, modelViewMatrix);
    GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, GL_FALSE, modelViewMatrix.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform4fv(uniforms[UNIFORM_COLOR], 1, _color[i].v);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
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
  uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_program, "modelViewMatrix");
  uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
  uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
  uniforms[UNIFORM_COLOR] = glGetUniformLocation(_program, "diffuseColor");
  
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

#pragma mark - ray intersection
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint tPt = [touch locationInView:self.view];
  GLKVector2 touchPoint = GLKVector2Make(tPt.x, tPt.y);

  for (int i = 0; i < 2; ++i) {
    GLKMatrix4 mvp = GLKMatrix4Multiply(_projection, GLKMatrix4Multiply(_view, _model[i]));
    if ([self hitTest:mvp atPoint:touchPoint]) {
      [self changeColor:i];
    }
  }
}

- (BOOL)hitTest:(GLKMatrix4)mvp atPoint:(GLKVector2)touch
{
  /* calculate window size */
  GLKVector2 winSize = GLKVector2Make(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));

  /* touch point in window space */
  GLKVector2 point = GLKVector2Make(touch.x, winSize.y-touch.y);

  /* touch point in viewport space */
  GLKVector2 pointNDC = GLKVector2SubtractScalar(GLKVector2MultiplyScalar(GLKVector2Divide(point, winSize), 2.0f), 1.0f);
  print("point: ", pointNDC.v, 2);

  /* touch point in 3D for both near and far planes */
  GLKVector4 win[2];
  win[0] = GLKVector4Make(pointNDC.x, pointNDC.y, -1.0f, 1.0f);
  win[1] = GLKVector4Make(pointNDC.x, pointNDC.y, 1.0f, 1.0f);
  print("win0: ", win[0].v, 4);
  print("win1: ", win[1].v, 4);

  /* inverse of model-view-projection matrix
   * This takes the touch points to the object space
   */
  print("mvp:\n", mvp.m, 16);
  bool success;
  GLKMatrix4 invMVP = GLKMatrix4Invert(mvp, &success);
  print("inv-mvp:\n", invMVP.m, 16);
  assert(success);

  /* ray at near and far plane in the object space */
  GLKVector4 ray[2];
  ray[0] = GLKMatrix4MultiplyVector4(invMVP, win[0]);
  ray[1] = GLKMatrix4MultiplyVector4(invMVP, win[1]);

  /* covert rays from homogenous coordsys to cartesian coordsys */
  ray[0] = GLKVector4DivideScalar(ray[0], ray[0].w);
  ray[1] = GLKVector4DivideScalar(ray[1], ray[1].w);

  /* direction of the ray */
  GLKVector4 rayDir = GLKVector4Normalize(GLKVector4Subtract(ray[1], ray[0]));

  print("ray org: ", ray[0].v, 4);
  print("ray dir: ", rayDir.v, 4);

  return [self hitTestSphere:0.5f withRayOrigin:GLKVector3MakeWithArray(ray[0].v)
                rayDirection:GLKVector3MakeWithArray(rayDir.v)];
}

/*
 * Let sphere is x^2 + y^2 + z^2 = r^2
 * P^2 - r^2 = 0; where P = {x, y, z}
 * Let ray is o + dt = 0; where o is ray origin, d is normalized direction and t is variable
 * Finding points on sphere where ray hits it by
 * (o + dt)^2 - r^2 = 0
 * o^2 + (dt)^2 + 2odt - r^2 = 0
 * f(t) = (d^2)t^2 + (2od)t + (o^2 - r^2) = 0
 * this is a quadratic equation in for ax^2 + bx + c = 0
 * Determinant of the quadratic equation is 
 * det = b^2 - 4ac
 * if 	det < 0; no roots
 * elif	dt == 0; one root
 * elif dt > 0; two roots
 * In our equation the values of a, b, c are
 * a = d^2 = 1; as d is a normalized vector and dot(d, d) = 1
 * b = 2od
 * c = o^2 - r^2
 */
- (BOOL)hitTestSphere:(float)radius
        withRayOrigin:(GLKVector3)rayOrigin
         rayDirection:(GLKVector3)rayDir
{
  float b = GLKVector3DotProduct(rayOrigin, rayDir) * 2.0f;
  float c = GLKVector3DotProduct(rayOrigin, rayOrigin) - radius*radius;
  printf("b^2-4ac = %f x %f = %f\n",b*b, 4.0f*c, b*b - 4*c);
  return b*b >= 4.0f*c;
}

@end
