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
#import "he_Image.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface he_ViewController () {
 GLuint _program;
 
 GLKMatrix4 _modelViewProjectionMatrix;
 // GLKMatrix3 _normalMatrix;
 float _rotation;
 
 GLuint _vertexArray;
 GLuint _vertexBuffer;
 GLuint _texture;
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
 
 //_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
 
 _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
 
 _rotation += self.timeSinceLastUpdate * 0.05f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
 glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 
 glBindVertexArrayOES(_vertexArray);
 glBindTexture(GL_TEXTURE_2D, _texture);
 glUseProgram(_program);
 
 GLuint u_Mvp = glGetUniformLocation(_program, "u_Mvp");
 glUniformMatrix4fv(u_Mvp, 1, 0, _modelViewProjectionMatrix.m);
// GLuint u_N = glGetUniformLocation(_program, "u_N");
// glUniformMatrix3fv(u_N, 1, 0, _normalMatrix.m);
 GLuint u_Tex = glGetUniformLocation(_program, "u_Tex");
 glUniform1i(u_Tex, 0);
 
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
 he_BitFlag attrib_flag = BF_Mask(kAttribPosition) |  BF_Mask(kAttribTexcoord) |
 BF_Mask(kAttribTangent) | BF_Mask(kAttribBinormal) | BF_Mask(kAttribNormal);
 _program = ShaderCreate(vsh_src, fsh_src, attrib_flag);
}

- (void)unloadShaders
{
 ShaderDestroy(_program);
}

#pragma mark - Textures
- (void)loadTextures
{
 he_Image normal_img;
 NSString *img_file = [[NSBundle mainBundle] pathForResource:@"TangentSpaceNormals" ofType:@"png"];
 Image_Create(&normal_img, [img_file UTF8String]);
 glGenTextures(1, &_texture);
 glBindTexture(GL_TEXTURE_2D, _texture);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, normal_img.width, normal_img.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, normal_img.pixels);
 Image_Release(&normal_img);
 
 assert(_texture);
}

- (void)unloadTextures
{
 glDeleteTextures(1, &_texture);
}

#pragma mark -  Models
- (void)calc_triangle_tangents:(GLKVector3 *)tangents
                      vertices:(const GLKVector3 *)vertices
                     texCoords:(const GLKVector2 *)texCoords
{
 GLKVector3 dv1 = GLKVector3Subtract(vertices[1], vertices[0]);
 GLKVector3 dv2 = GLKVector3Subtract(vertices[2], vertices[0]);
 GLKVector2 dt1 = GLKVector2Subtract(texCoords[1], texCoords[0]);
 GLKVector2 dt2 = GLKVector2Subtract(texCoords[2], texCoords[0]);

 float r = 1.0f/(dt1.x * dt2.y - dt1.y * dt2.x);
 /* tangent = (dv1 x dt2.y - dv2 x dt1.y) x r */
 tangents[0] = GLKVector3MultiplyScalar(GLKVector3Subtract(GLKVector3MultiplyScalar(dv1, dt2.y), GLKVector3MultiplyScalar(dv2, dt1.y)), r);
 /* binormal = (dv2 x dt1.x - dv1 x dt2.x) x r */
 tangents[1] = GLKVector3MultiplyScalar(GLKVector3Subtract(GLKVector3MultiplyScalar(dv2, dt1.x), GLKVector3MultiplyScalar(dv1, dt2.x)), r);
}

#define TEX_MIN_UV 0.4f
#define TEX_MAX_UV 0.6f

- (void)loadModels
{
 GLfloat cubeVertexData[] =
 {
  /* Data layout for each line below is:
   positionXYZ, 			 tangentXYZ, binormalXYZ,normalXYZ,		texXY*/
  0.5f, -0.5f, -0.5f,        1,1,1, 1,1,1, 	1.0f, 0.0f, 0.0f,		TEX_MAX_UV, TEX_MIN_UV,
  0.5f, 0.5f, -0.5f,         1,1,1,	1,1,1,	1.0f, 0.0f, 0.0f,		TEX_MAX_UV, TEX_MAX_UV,
  0.5f, -0.5f, 0.5f,         1,1,1,	1,1,1,	1.0f, 0.0f, 0.0f,		TEX_MIN_UV, TEX_MIN_UV,
  0.5f, -0.5f, 0.5f,         1,1,1,	1,1,1,	1.0f, 0.0f, 0.0f,		TEX_MIN_UV, TEX_MIN_UV,
  0.5f, 0.5f, -0.5f,         1,1,1,	1,1,1,	1.0f, 0.0f, 0.0f,		TEX_MAX_UV, TEX_MAX_UV,
  0.5f, 0.5f, 0.5f,          1,1,1,	1,1,1,	1.0f, 0.0f, 0.0f,		TEX_MIN_UV, TEX_MAX_UV,
  
  0.5f, 0.5f, -0.5f,         1,1,1,	1,1,1,	0.0f, 1.0f, 0.0f,		TEX_MAX_UV, TEX_MAX_UV,
  -0.5f, 0.5f, -0.5f,        1,1,1,	1,1,1,	0.0f, 1.0f, 0.0f,		TEX_MIN_UV, TEX_MAX_UV,
  0.5f, 0.5f, 0.5f,          1,1,1,	1,1,1,	0.0f, 1.0f, 0.0f,		TEX_MAX_UV, TEX_MIN_UV,
  0.5f, 0.5f, 0.5f,          1,1,1,	1,1,1,	0.0f, 1.0f, 0.0f,		TEX_MAX_UV, TEX_MIN_UV,
  -0.5f, 0.5f, -0.5f,        1,1,1,	1,1,1,	0.0f, 1.0f, 0.0f,		TEX_MIN_UV, TEX_MAX_UV,
  -0.5f, 0.5f, 0.5f,         1,1,1,	1,1,1,	0.0f, 1.0f, 0.0f,		TEX_MIN_UV, TEX_MIN_UV,
  
  -0.5f, 0.5f, -0.5f,        1,1,1,	1,1,1,	-1.0f, 0.0f, 0.0f,		TEX_MIN_UV, TEX_MAX_UV,
  -0.5f, -0.5f, -0.5f,       1,1,1,	1,1,1,	-1.0f, 0.0f, 0.0f,		TEX_MIN_UV, TEX_MIN_UV,
  -0.5f, 0.5f, 0.5f,         1,1,1,	1,1,1,	-1.0f, 0.0f, 0.0f,		TEX_MAX_UV, TEX_MAX_UV,
  -0.5f, 0.5f, 0.5f,         1,1,1,	1,1,1,	-1.0f, 0.0f, 0.0f,		TEX_MAX_UV, TEX_MAX_UV,
  -0.5f, -0.5f, -0.5f,       1,1,1,	1,1,1,	-1.0f, 0.0f, 0.0f,		TEX_MIN_UV, TEX_MIN_UV,
  -0.5f, -0.5f, 0.5f,        1,1,1,	1,1,1,	-1.0f, 0.0f, 0.0f,		TEX_MAX_UV, TEX_MIN_UV,
  
  -0.5f, -0.5f, -0.5f,       1,1,1,	1,1,1,	0.0f, -1.0f, 0.0f,		TEX_MIN_UV, TEX_MIN_UV,
  0.5f, -0.5f, -0.5f,        1,1,1,	1,1,1,	0.0f, -1.0f, 0.0f,		TEX_MAX_UV, TEX_MIN_UV,
  -0.5f, -0.5f, 0.5f,        1,1,1,	1,1,1,	0.0f, -1.0f, 0.0f,		TEX_MIN_UV, TEX_MAX_UV,
  -0.5f, -0.5f, 0.5f,        1,1,1,	1,1,1,	0.0f, -1.0f, 0.0f,		TEX_MIN_UV, TEX_MAX_UV,
  0.5f, -0.5f, -0.5f,        1,1,1,	1,1,1,	0.0f, -1.0f, 0.0f,		TEX_MAX_UV, TEX_MIN_UV,
  0.5f, -0.5f, 0.5f,         1,1,1,	1,1,1,	0.0f, -1.0f, 0.0f,		TEX_MAX_UV, TEX_MAX_UV,
  
  0.5f, 0.5f, 0.5f,          1,1,1,	1,1,1,	0.0f, 0.0f, 1.0f,		TEX_MAX_UV, TEX_MAX_UV,
  -0.5f, 0.5f, 0.5f,         1,1,1,	1,1,1,	0.0f, 0.0f, 1.0f,		TEX_MIN_UV, TEX_MAX_UV,
  0.5f, -0.5f, 0.5f,         1,1,1,	1,1,1,	0.0f, 0.0f, 1.0f,		TEX_MAX_UV, TEX_MIN_UV,
  0.5f, -0.5f, 0.5f,         1,1,1,	1,1,1,	0.0f, 0.0f, 1.0f,		TEX_MAX_UV, TEX_MIN_UV,
  -0.5f, 0.5f, 0.5f,         1,1,1,	1,1,1,	0.0f, 0.0f, 1.0f,		TEX_MIN_UV, TEX_MAX_UV,
  -0.5f, -0.5f, 0.5f,        1,1,1,	1,1,1,	0.0f, 0.0f, 1.0f,		TEX_MIN_UV, TEX_MIN_UV,
  
  0.5f, -0.5f, -0.5f,        1,1,1,	1,1,1,	0.0f, 0.0f, -1.0f,		TEX_MIN_UV, TEX_MIN_UV,
  -0.5f, -0.5f, -0.5f,       1,1,1,	1,1,1,	0.0f, 0.0f, -1.0f,		TEX_MAX_UV, TEX_MIN_UV,
  0.5f, 0.5f, -0.5f,         1,1,1,	1,1,1,	0.0f, 0.0f, -1.0f,		TEX_MIN_UV, TEX_MAX_UV,
  0.5f, 0.5f, -0.5f,         1,1,1,	1,1,1,	0.0f, 0.0f, -1.0f,		TEX_MIN_UV, TEX_MAX_UV,
  -0.5f, -0.5f, -0.5f,       1,1,1,	1,1,1,	0.0f, 0.0f, -1.0f,		TEX_MAX_UV, TEX_MIN_UV,
  -0.5f, 0.5f, -0.5f,        1,1,1,	1,1,1,	0.0f, 0.0f, -1.0f,		TEX_MAX_UV, TEX_MAX_UV
 };

/*for each triangle calculate tangent and binormal
 each triangle index has associated floats 14 = (3 + 3 + 3 + 3 + 2) (position, tangent, binormal, normal, texcoord)
 */
 for (int t = 0; t < sizeof(cubeVertexData)/sizeof(cubeVertexData[0]); t += (14*3)) {
  GLKVector3 tangent[2];
  GLKVector3 position[3];
  GLKVector2 texcoord[3];
  
  /*extract position and texcoord for all 3 points on a triangle*/
  for (int p = 0; p < 3; ++p) {
   memcpy(position[p].v, cubeVertexData+t+(p*14), sizeof(GLKVector3));
   memcpy(texcoord[p].v, cubeVertexData+t+(p*14)+12, sizeof(GLKVector2));
  }
  
  /*calculate tangent and binormal*/
  [self calc_triangle_tangents:tangent vertices:position texCoords:texcoord];
  
  /*replace tangent and binormal with placeholder values*/
  for (int p = 0; p < 3; ++p) {
   memcpy(cubeVertexData+t+(p*14)+3, tangent[0].v, sizeof(GLKVector3));
   memcpy(cubeVertexData+t+(p*14)+6, tangent[1].v, sizeof(GLKVector3));
  }
 }

 for (int i = 0; i < sizeof(cubeVertexData)/sizeof(cubeVertexData[0]); i += 14) {
  printf("% 0.2f,% 0.2f,% 0.2f\t",cubeVertexData[i+0],cubeVertexData[i+1],cubeVertexData[i+2]);
  printf("% 0.2f,% 0.2f,% 0.2f\t",cubeVertexData[i+3],cubeVertexData[i+4],cubeVertexData[i+5]);
  printf("% 0.2f,% 0.2f,% 0.2f\t",cubeVertexData[i+6],cubeVertexData[i+7],cubeVertexData[i+8]);
  printf("% 0.2f,% 0.2f,% 0.2f\t",cubeVertexData[i+9],cubeVertexData[i+10],cubeVertexData[i+11]);
  printf("% 0.2f,% 0.2f       \n",cubeVertexData[i+12],cubeVertexData[i+13]);
 }
 
 glGenVertexArraysOES(1, &_vertexArray);
 glBindVertexArrayOES(_vertexArray);
 
 glGenBuffers(1, &_vertexBuffer);
 glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
 glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertexData), cubeVertexData, GL_STATIC_DRAW);
 
 glEnableVertexAttribArray(kAttribPosition);
 glVertexAttribPointer(kAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float)*(14), BUFFER_OFFSET(0));
// glEnableVertexAttribArray(kAttribTBN);
// glVertexAttribPointer(kAttribTBN, 9, GL_FLOAT, GL_FALSE, sizeof(float)*(14), BUFFER_OFFSET(3));
 glEnableVertexAttribArray(kAttribTangent);
 glVertexAttribPointer(kAttribTangent, 3, GL_FLOAT, GL_FALSE, sizeof(float)*(14), BUFFER_OFFSET(sizeof(float)*(3)));
 glEnableVertexAttribArray(kAttribBinormal);
 glVertexAttribPointer(kAttribBinormal, 3, GL_FLOAT, GL_FALSE, sizeof(float)*(14), BUFFER_OFFSET(sizeof(float)*(6)));
 glEnableVertexAttribArray(kAttribNormal);
 glVertexAttribPointer(kAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(float)*(14), BUFFER_OFFSET(sizeof(float)*(9)));
 glEnableVertexAttribArray(kAttribTexcoord);
 glVertexAttribPointer(kAttribTexcoord, 2, GL_FLOAT, GL_FALSE, sizeof(float)*(14), BUFFER_OFFSET(sizeof(float)*(12)));
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
 glActiveTexture(0);
}

- (void)unloadDefaultGLStates
{
 glDisable(GL_DEPTH_TEST);
}
@end
