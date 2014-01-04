//
//  he_ViewController.m
//  Cubemap
//
//  Created by Sid on 02/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#import "he_ViewController.h"
#import "he_Image.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum {
 u_M = 0,
 u_N,
 u_Mvp,
 u_EyePosition,
 u_Material_ref_index,
 u_Material_relection,
 u_CubeTex,
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

typedef struct {
 GLuint vao;
 GLuint vbo;
 GLuint ibo;
 int indexCount;
} he_iModel;

typedef struct {
 GLuint vao;
 GLuint vbo;
 int indexCount;
} he_Model;

typedef union {
 size_t size;
 void *ptr;
} Stride;

typedef union {
 struct {
  GLKVector3 position;
  GLKVector3 normal;
 };
 GLfloat data[6];
} Vertex;

typedef union {
 struct {
  GLushort va, vb, vc;
 };
 GLushort data[3];
} Face;

static char *read_word(char *word, FILE *file)
{
 char *wptr = word;
 for (int ch = fgetc(file); ch != EOF && !isspace(ch); ch = fgetc(file)) {
  *word++ = ch;
 }
 *word++ = '\0';
 return wptr;
}

void loadModelFromFile(he_iModel *model, const char *path)
{
 FILE *file = fopen(path, "r");
 int ch;
 
 int v_count = 0;
 int f_count = 0;
 while ((ch = fgetc(file)) != EOF) {
  if (ch == 'v') {
   v_count++;
  } else if (ch == 'f') {
   f_count++;
  }
 }
 
 rewind(file);
 
 /* Parse data */
 Vertex *vertex = calloc(v_count, sizeof(Vertex));
 Face *face = calloc(f_count, sizeof(Face));
 
 char word[256];
 int vertexi = 0;
 int facei = 0;
 
 while (!feof(file) && read_word(word, file)) {
  if (strcmp(word, "v") == 0) {
   vertex[vertexi].position = GLKVector3Make(atof(read_word(word, file)), atof(read_word(word, file)), atof(read_word(word, file)));
   vertex[vertexi].normal = GLKVector3Make(0.0f, 0.0f, 0.0f);
   //printf("%d:\t %c % .2f % .2f % .2f\n", vertexi, 'v', vertex[vertexi].position.x, vertex[vertexi].position.y, vertex[vertexi].position.z);
   vertexi++;
  } else if (strcmp(word, "f") == 0) {
   face[facei].va = atoi(read_word(word, file)) - 1;
   face[facei].vb = atoi(read_word(word, file)) - 1;
   face[facei].vc = atoi(read_word(word, file)) - 1;
   //printf("%d:\t%c %hu %hu %hu\n", facei, 'f', face[facei].va, face[facei].vb, face[facei].vc);
   facei++;
  }
 }
 
 fclose(file);
 
 /* Calculate normals for each face. */
 for (int i = 0; i < f_count; ++i) {
  Face f = face[i];
  Vertex a = vertex[f.va];
  Vertex b = vertex[f.vb];
  Vertex c = vertex[f.vc];
  
  GLKVector3 ab = GLKVector3Subtract(b.position, a.position);
  GLKVector3 ac = GLKVector3Subtract(c.position, a.position);
  GLKVector3 normal = GLKVector3CrossProduct(ab, ac);
  
  vertex[f.va].normal = GLKVector3Add(a.normal, normal);
  vertex[f.vb].normal = GLKVector3Add(b.normal, normal);
  vertex[f.vc].normal = GLKVector3Add(c.normal, normal);
 }
 
 /* normalize */
 for (int i = 0; i < v_count; ++i) {
  vertex[i].normal = GLKVector3Normalize(vertex[i].normal);
 }
 
 /* push data to GPU RAM */
 model->indexCount = f_count * 3;
 
 glGenVertexArraysOES(1, &model->vao);
 glBindVertexArrayOES(model->vao);
 
 glGenBuffers(1, &model->vbo);
 glBindBuffer(GL_ARRAY_BUFFER, model->vbo);
 glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * v_count, (GLfloat *)vertex, GL_STATIC_DRAW);
 
 glGenBuffers(1, &model->ibo);
 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, model->ibo);
 glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Face) * f_count, (GLushort *)face, GL_STATIC_DRAW);
 
 glEnableVertexAttribArray(ATTRIB_VERTEX);
 glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
 
 Stride nstride;
 nstride.size = sizeof(GLKVector3);
 glEnableVertexAttribArray(ATTRIB_NORMAL);
 glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), nstride.ptr);
 
 free(vertex);
 free(face);
 
 glBindVertexArrayOES(0);

 printf("Model: vertex = %d\t face = %d\n",v_count,f_count);
}

//static void unload_models(he_iModel *model)
//{
// glDeleteBuffers(1, &model->ibo);
// glDeleteBuffers(1, &model->vbo);
// glDeleteVertexArraysOES(1, &model->vao);
//}

#define MAX_SHADERS 3

@interface he_ViewController () {
 GLuint _program[MAX_SHADERS];
 int _curr_shader;
 
 float _rotation;
 
 he_Model cube_;
 he_iModel teapot_;
 GLuint texture_;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (void)loadShaders;
- (BOOL)loadShaderAtIndex:(int)index
              vshFilename:(NSString *)vshFilename
              fshFilename:(NSString *)fshFilename;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
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
 [self loadTexture];
 [self loadBufferData];
 
 glEnable(GL_DEPTH_TEST);
 _rotation = GLKMathDegreesToRadians(90);
}

- (void)tearDownGL
{
 [EAGLContext setCurrentContext:self.context];

 [self unloadBufferData];
 [self unloadTexture];
 [self unloadShaders];

 glDisable(GL_DEPTH_TEST);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
 _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)print:(const char *)message values:(float *)val count:(int)count
{
 printf("%s\n",message);
 for (int i = 0; i < count; ++i) {
  printf("% 3.2f%s",val[i], (i+1)%4?"  ":"\n");
 }
 printf("\n");
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
 glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 
 glUseProgram(_program[0]);

 glActiveTexture(GL_TEXTURE0);
 glBindTexture(GL_TEXTURE_CUBE_MAP, texture_);
 uniforms[u_CubeTex] = glGetUniformLocation(_program[_curr_shader], "u_CubeTex");
 glUniform1i(uniforms[u_CubeTex], 0);

 
 GLKMatrix4 modelViewMatrix, modelViewProjectionMatrix, projectionMatrix;
 GLKMatrix3 modelMatrix3, normalMatrix;
 GLKVector4 eyeObjectSpace;

 float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

 glBindVertexArrayOES(cube_.vao);
 modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0f, -6.0f);
 if (_curr_shader == 0) {
  modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
 }
 modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 12.0f, 12.0f, 12.0f);
 modelMatrix3 = GLKMatrix4GetMatrix3(modelViewMatrix);
 normalMatrix = GLKMatrix3InvertAndTranspose(modelMatrix3, NULL);
 eyeObjectSpace = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
 modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
 
 uniforms[u_M] = glGetUniformLocation(_program[_curr_shader], "u_M");
 glUniformMatrix4fv(uniforms[u_M], 1, GL_FALSE, modelViewMatrix.m);
 uniforms[u_EyePosition] = glGetUniformLocation(_program[_curr_shader], "u_EyePosition");
 glUniform3fv(uniforms[u_EyePosition], 1, eyeObjectSpace.v);
 uniforms[u_N] = glGetUniformLocation(_program[_curr_shader], "u_N");
 glUniformMatrix3fv(uniforms[u_N], 1, 0, normalMatrix.m);
 uniforms[u_Mvp] = glGetUniformLocation(_program[_curr_shader], "u_Mvp");
 glUniformMatrix4fv(uniforms[u_Mvp], 1, 0, modelViewProjectionMatrix.m);
 
 glDrawArrays(GL_TRIANGLES, 0, cube_.indexCount);

 if (_curr_shader) {
  glUseProgram(_program[_curr_shader]);

  glBindVertexArrayOES(teapot_.vao);
  modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0f, -10.0f);
  modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
  modelMatrix3 = GLKMatrix4GetMatrix3(modelViewMatrix);
  normalMatrix = GLKMatrix3InvertAndTranspose(modelMatrix3, NULL);
  eyeObjectSpace = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
  modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

  if (_curr_shader == 2) {
   float n1 = 1.6f; //glass
   float n2 = 1.0f; //air
   uniforms[u_Material_ref_index] = glGetUniformLocation(_program[_curr_shader], "u_Material.ref_index");
   glUniform1f(uniforms[u_Material_ref_index], n2/n1);
   uniforms[u_Material_relection] = glGetUniformLocation(_program[_curr_shader], "u_Material.relection");
   glUniform1f(uniforms[u_Material_relection], 0.1f);
  }
  glUniformMatrix4fv(uniforms[u_M], 1, GL_FALSE, modelViewMatrix.m);
  glUniform3fv(uniforms[u_EyePosition], 1, eyeObjectSpace.v);
  glUniformMatrix3fv(uniforms[u_N], 1, 0, normalMatrix.m);
  glUniformMatrix4fv(uniforms[u_Mvp], 1, 0, modelViewProjectionMatrix.m);
  
  glDrawElements(GL_TRIANGLES, teapot_.indexCount, GL_UNSIGNED_SHORT, NULL);
 }
}

#pragma mark -  OpenGL ES 2 shader compilation
- (void)loadShaders
{
 BOOL status;
 status = [self loadShaderAtIndex:0
             vshFilename:@"skybox"
             fshFilename:@"skybox"];
 NSAssert(status, @"skybox compilation failed!");

 status = [self loadShaderAtIndex:1
             vshFilename:@"reflection"
             fshFilename:@"reflection"];
 NSAssert(status, @"reflection compilation failed!");

 status = [self loadShaderAtIndex:2
             vshFilename:@"refraction"
             fshFilename:@"refraction"];
 NSAssert(status, @"refraction compilation failed!");

 _curr_shader = 0;
}

- (BOOL)loadShaderAtIndex:(int)index
              vshFilename:(NSString *)vshFilename
              fshFilename:(NSString *)fshFilename
{
 GLuint vertShader, fragShader;
 NSString *vertShaderPathname, *fragShaderPathname;
 
 // Create shader program.
 _program[index] = glCreateProgram();
 
 // Create and compile vertex shader.
 NSLog(@"compiling: %@.vsh ...",vshFilename);
 vertShaderPathname = [[NSBundle mainBundle] pathForResource:vshFilename ofType:@"vsh"];
 if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
  NSLog(@"Failed to compile vertex shader");
  return NO;
 }
 
 // Create and compile fragment shader.
 NSLog(@"compiling: %@.fsh ...",fshFilename);
 fragShaderPathname = [[NSBundle mainBundle] pathForResource:fshFilename ofType:@"fsh"];
 if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
  NSLog(@"Failed to compile fragment shader");
  return NO;
 }
 
 // Attach vertex shader to program.
 glAttachShader(_program[index], vertShader);
 
 // Attach fragment shader to program.
 glAttachShader(_program[index], fragShader);
 
 // Bind attribute locations.
 // This needs to be done prior to linking.
 glBindAttribLocation(_program[index], ATTRIB_VERTEX, "a_Position");
 glBindAttribLocation(_program[index], ATTRIB_NORMAL, "a_Normal");
 
 // Link program.
 if (![self linkProgram:_program[index]]) {
  NSLog(@"Failed to link program: %d", _program[index]);
  
  if (vertShader) {
   glDeleteShader(vertShader);
   vertShader = 0;
  }
  if (fragShader) {
   glDeleteShader(fragShader);
   fragShader = 0;
  }
  if (_program[index]) {
   glDeleteProgram(_program[index]);
   _program[index] = 0;
  }
  
  return NO;
 }
 
 // Release vertex and fragment shaders.
 if (vertShader) {
  glDetachShader(_program[index], vertShader);
  glDeleteShader(vertShader);
 }
 if (fragShader) {
  glDetachShader(_program[index], fragShader);
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

- (void)unloadShaders
{
 for (int i = 0; i < MAX_SHADERS; ++i) {
 if (_program[i]) {
  glDeleteProgram(_program[i]);
  _program[i] = 0;
 }
 }
}

#pragma mark - Texture
- (void)loadTexture
{
 NSString *img_path;
 he_Image image;
 
 glGenTextures(1, &texture_);
 glBindTexture(GL_TEXTURE_CUBE_MAP, texture_);
 
 img_path = [[NSBundle mainBundle] pathForResource:@"posx" ofType:@"jpg"];
 Image_Create(&image, [img_path UTF8String]);
 glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X, 0, GL_RGBA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.pixels);
 Image_Release(&image);
 
 img_path = [[NSBundle mainBundle] pathForResource:@"negx" ofType:@"jpg"];
 Image_Create(&image, [img_path UTF8String]);
 glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 0, GL_RGBA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.pixels);
 Image_Release(&image);

 img_path = [[NSBundle mainBundle] pathForResource:@"posy" ofType:@"jpg"];
 Image_Create(&image, [img_path UTF8String]);
 glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 0, GL_RGBA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.pixels);
 Image_Release(&image);
 
 img_path = [[NSBundle mainBundle] pathForResource:@"negy" ofType:@"jpg"];
 Image_Create(&image, [img_path UTF8String]);
 glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, GL_RGBA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.pixels);
 Image_Release(&image);
 
 img_path = [[NSBundle mainBundle] pathForResource:@"posz" ofType:@"jpg"];
 Image_Create(&image, [img_path UTF8String]);
 glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, GL_RGBA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.pixels);
 Image_Release(&image);
 
 img_path = [[NSBundle mainBundle] pathForResource:@"negz" ofType:@"jpg"];
 Image_Create(&image, [img_path UTF8String]);
 glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, GL_RGBA, image.width, image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.pixels);
 Image_Release(&image);
 
 glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
 glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
 glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)unloadTexture
{
 glDeleteTextures(1, &texture_);
 texture_ = 0;
}

#pragma mark - Buffer data
- (void)loadBufferData
{
 [self loadCube];
 /* Read file */
 char path_buffer[1024];
 strcpy(path_buffer, [[[NSBundle mainBundle] pathForResource:@"teapot" ofType:@"obj"] UTF8String]);
 loadModelFromFile(&teapot_, path_buffer);
}

- (void)unloadBufferData
{
 glDeleteBuffers(1, &cube_.vbo);
 glDeleteVertexArraysOES(1, &cube_.vao);

 glDeleteBuffers(1, &teapot_.ibo);
 glDeleteBuffers(1, &teapot_.vbo);
 glDeleteVertexArraysOES(1, &teapot_.vao);
}

- (void)loadCube
{
 GLfloat gCubeVertexData[] =
 {
  // Data layout for each line below is:
  // position{XYZ},			normal{XYZ},
  0.5f, -0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, -0.5f,         -1.0f, 0.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, -0.5f,          -1.0f, 0.0f, 0.0f,
  0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
  
  0.5f, 0.5f, -0.5f,         0.0f, -1.0f, 0.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
  0.5f, 0.5f, 0.5f,          0.0f, -1.0f, 0.0f,
  0.5f, 0.5f, 0.5f,          0.0f, -1.0f, 0.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
  
  -0.5f, 0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, -0.5f,       1.0f, 0.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
  -0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, -0.5f,       1.0f, 0.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        1.0f, 0.0f, 0.0f,
  
  -0.5f, -0.5f, -0.5f,       0.0f, 1.0f, 0.0f,
  0.5f, -0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, 1.0f, 0.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, 1.0f, 0.0f,
  0.5f, -0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
  0.5f, -0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
  
  0.5f, 0.5f, 0.5f,          0.0f, 0.0f, -1.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, -1.0f,
  0.5f, -0.5f, 0.5f,         0.0f, 0.0f, -1.0f,
  0.5f, -0.5f, 0.5f,         0.0f, 0.0f, -1.0f,
  -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, -1.0f,
  -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, -1.0f,
  
  0.5f, -0.5f, -0.5f,        0.0f, 0.0f, 1.0f,
  -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, 1.0f,
  0.5f, 0.5f, -0.5f,         0.0f, 0.0f, 1.0f,
  0.5f, 0.5f, -0.5f,         0.0f, 0.0f, 1.0f,
  -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, 1.0f,
  -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, 1.0f
 };
 
 glGenVertexArraysOES(1, &cube_.vao);
 glBindVertexArrayOES(cube_.vao);
 
 glGenBuffers(1, &cube_.vbo);
 glBindBuffer(GL_ARRAY_BUFFER, cube_.vbo);
 glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
 
 glEnableVertexAttribArray(GLKVertexAttribPosition);
 glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
 glEnableVertexAttribArray(GLKVertexAttribNormal);
 glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
 
 cube_.indexCount = 36;
 
 glBindVertexArrayOES(0);
}

#pragma mark - Events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
 _curr_shader = (_curr_shader + 1) % MAX_SHADERS;
}
@end
