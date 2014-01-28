//
//  he_View.m
//  Blur
//
//  Created by Sid on 26/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#import "he_View.h"
#include <assert.h>
#include <GLKit/GLKMath.h>
#include <OpenGLES/EAGLDrawable.h>
#include <OpenGLES/ES2/gl.h>
#include "he_Image.h"

#define MAX_BLUR 5.0f

typedef struct {
  struct {
    int um4k_Modelviewproj;
    int us2k_Tex0;
  } uniforms;
  GLuint object;
} TextureShader;

typedef struct {
  struct {
    int um4k_Modelviewproj;
    int us2k_Tex0;
    int uf1k_OneOverWidth;
    int uf1k_OneOverHeight;
    int uf5k_Weight0;
    int uf5k_Weight1;
    int uf5k_Weight2;
    int uf5k_Weight3;
    int uf5k_Weight4;
    int uf5k_PixelOffset1;
    int uf5k_PixelOffset2;
    int uf5k_PixelOffset3;
    int uf5k_PixelOffset4;
    int ub1k_IsBlurDirectionX;
  } uniforms;
  GLuint object;
} BlurShader;

static float GaussianFilter(const float x, const float sigma)
{
  float twoSigmaSqr = 2.0f * sigma * sigma;
  float num = powf(M_E, -(x*x)/twoSigmaSqr);
  float den = sqrtf(M_PI * twoSigmaSqr);
  return num/den;
}

@interface he_View () {
  GLuint _onscreenFramebuffer;
  GLuint _onscreenColorRenderbuffer;
  GLuint _offscreenFramebufferX;
  GLuint _offscreenColorRenderbufferX;
  GLuint _offscreenFramebufferY;
  GLuint _offscreenColorRenderbufferY;
  TextureShader _textureProgram;
  BlurShader _blurProgram;
  CFTimeInterval _time;
  GLuint _readTexture;
  GLuint _writeTextureX;
  GLuint _writeTextureY;
  GLint _fboWidth;
  GLint _fboHeight;
  float _blurIntensity;
}
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, retain) CADisplayLink *displayLink;
@end

@implementation he_View

+ (Class) layerClass
{
  return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    
    NSMutableDictionary *propDict = [NSMutableDictionary dictionary];
    [propDict setObject:[NSNumber numberWithBool:NO] forKey:kEAGLDrawablePropertyRetainedBacking];
    [propDict setObject:kEAGLColorFormatRGBA8 forKey:kEAGLDrawablePropertyColorFormat];
//    [NSDictionary dictionaryWithObjectsAndKeys:
//                              [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
//                              kEAGLColorFormatSRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    layer.drawableProperties = propDict;

    self.context = nil;
    if ([@"7.0" compare:[[UIDevice currentDevice] systemVersion] options:NSNumericSearch] != NSOrderedDescending) {
      self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    }
    if (!self.context) {
      self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    assert(self.context);
    [EAGLContext setCurrentContext:self.context];
    
    [self createFramebuffer];
    [self createReadTexture];
    [self createShader];
    [self createGeometry];

    self.displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(updateAndDraw)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _time = self.displayLink.timestamp;
    
    _blurIntensity = MAX_BLUR / 2.0f;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 50.0f, self.bounds.size.width, 30.0f)];
    [slider addTarget:self action:@selector(updateIntensity:) forControlEvents:UIControlEventValueChanged];
    [slider setValue:_blurIntensity/MAX_BLUR animated:YES];
    [self addSubview:slider];
  }
  return self;
}

- (void)updateIntensity:(UISlider *)sender
{
  if (!sender.value) { // Don't use 0.0
    return;
  }
  _blurIntensity = sender.value * MAX_BLUR;
}

- (void) dealloc
{
  [self destroyFramebuffer];
  [self destroyGeometry];
  [self destroyShader];
  [self destroyTexture];
}

#pragma mark - Framebuffer
- (void) createFramebuffer
{
  glGenFramebuffers(1, &_onscreenFramebuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, _onscreenFramebuffer);
  
  glGenRenderbuffers(1, &_onscreenColorRenderbuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _onscreenColorRenderbuffer);
  [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _onscreenColorRenderbuffer);

  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_fboWidth);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_fboHeight);

  assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);

  glGenFramebuffers(1, &_offscreenFramebufferX);
  glBindFramebuffer(GL_FRAMEBUFFER, _offscreenFramebufferX);

  glGenRenderbuffers(1, &_offscreenColorRenderbufferX);
  glBindRenderbuffer(GL_RENDERBUFFER, _offscreenColorRenderbufferX);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, _fboWidth, _fboHeight);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _offscreenColorRenderbufferX);
  _writeTextureX = [self createTexture];
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _fboWidth, _fboHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _writeTextureX, 0);

  glGenFramebuffers(1, &_offscreenFramebufferY);
  glBindFramebuffer(GL_FRAMEBUFFER, _offscreenFramebufferY);
  
  glGenRenderbuffers(1, &_offscreenColorRenderbufferY);
  glBindRenderbuffer(GL_RENDERBUFFER, _offscreenColorRenderbufferY);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, _fboWidth, _fboHeight);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _offscreenColorRenderbufferY);
  _writeTextureY = [self createTexture];
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _fboWidth, _fboHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _writeTextureY, 0);

  glViewport(0, 0, _fboWidth, _fboHeight);
  
  assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
  assert(glGetError() == GL_NO_ERROR);
}

- (void)destroyFramebuffer
{
  glDeleteRenderbuffers(1, &_onscreenColorRenderbuffer);
  glDeleteFramebuffers(1, &_onscreenFramebuffer);
  glDeleteRenderbuffers(1, &_offscreenColorRenderbufferX);
  glDeleteFramebuffers(1, &_offscreenFramebufferX);
  glDeleteRenderbuffers(1, &_offscreenColorRenderbufferY);
  glDeleteFramebuffers(1, &_offscreenFramebufferY);
}

#pragma mark - Shader

- (GLuint)createShader:(NSString *)name withCompletion:(void (^)(GLuint) )attribCompletion
{
  GLuint program = glCreateProgram();
  
	NSString *vFile = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
  const char *vSrc = [[NSString stringWithContentsOfFile:vFile encoding:NSUTF8StringEncoding error:nil] UTF8String];
  GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vsh, 1, &vSrc, NULL);
  glCompileShader(vsh);
  assert([self debugShader:@"Vertex" forObject:vsh]);
  glAttachShader(program, vsh);
  
  NSString *fFile = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
  const char *fSrc = [[NSString stringWithContentsOfFile:fFile encoding:NSUTF8StringEncoding error:nil] UTF8String];
  GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fsh, 1, &fSrc, NULL);
  glCompileShader(fsh);
  assert([self debugShader:@"Frag" forObject:fsh]);
  glAttachShader(program, fsh);

  attribCompletion(program);
  
  glLinkProgram(program);
  assert([self debugPrograForObject:program]);
  
  
  glDetachShader(program, vsh);
  glDetachShader(program, fsh);
  glDeleteShader(vsh);
  glDeleteShader(fsh);
  
  assert(glGetError() == GL_NO_ERROR);
  return program;
}

- (void)createShader
{
  /* create texture shader */
  _textureProgram.object = [self createShader:@"TextureShader" withCompletion:^(GLuint program) {
    glBindAttribLocation(program, 0, "av4o_Position");
    glBindAttribLocation(program, 1, "av2o_Texcoord");
  }];
  _textureProgram.uniforms.um4k_Modelviewproj = glGetUniformLocation(_textureProgram.object, "um4k_Modelviewproj");
  _textureProgram.uniforms.us2k_Tex0 = glGetUniformLocation(_textureProgram.object, "us2k_Tex0");
  
  /* create blur shader */
  _blurProgram.object = [self createShader:@"BlurShader" withCompletion:^(GLuint program) {
    glBindAttribLocation(program, 0, "av4o_Position");
    glBindAttribLocation(program, 1, "av2o_Texcoord");
  }];
  _blurProgram.uniforms.um4k_Modelviewproj = glGetUniformLocation(_blurProgram.object, "um4k_Modelviewproj");
  _blurProgram.uniforms.us2k_Tex0 = glGetUniformLocation(_blurProgram.object, "us2k_Tex0");
  _blurProgram.uniforms.uf1k_OneOverWidth = glGetUniformLocation(_blurProgram.object, "uf1k_OneOverWidth");
  _blurProgram.uniforms.uf1k_OneOverHeight = glGetUniformLocation(_blurProgram.object, "uf1k_OneOverHeight");
  _blurProgram.uniforms.uf5k_Weight0 = glGetUniformLocation(_blurProgram.object, "uf5k_Weight0");
  _blurProgram.uniforms.uf5k_Weight1 = glGetUniformLocation(_blurProgram.object, "uf5k_Weight1");
  _blurProgram.uniforms.uf5k_Weight2 = glGetUniformLocation(_blurProgram.object, "uf5k_Weight2");
  _blurProgram.uniforms.uf5k_Weight3 = glGetUniformLocation(_blurProgram.object, "uf5k_Weight3");
  _blurProgram.uniforms.uf5k_Weight4 = glGetUniformLocation(_blurProgram.object, "uf5k_Weight4");
  _blurProgram.uniforms.uf5k_PixelOffset1 = glGetUniformLocation(_blurProgram.object, "uf5k_PixelOffset1");
  _blurProgram.uniforms.uf5k_PixelOffset2 = glGetUniformLocation(_blurProgram.object, "uf5k_PixelOffset2");
  _blurProgram.uniforms.uf5k_PixelOffset3 = glGetUniformLocation(_blurProgram.object, "uf5k_PixelOffset3");
  _blurProgram.uniforms.uf5k_PixelOffset4 = glGetUniformLocation(_blurProgram.object, "uf5k_PixelOffset4");
  _blurProgram.uniforms.ub1k_IsBlurDirectionX = glGetUniformLocation(_blurProgram.object, "ub1k_IsBlurDirectionX");
}

- (void)destroyShader
{
  glDeleteProgram(_textureProgram.object);
  glDeleteProgram(_blurProgram.object);
}

- (BOOL)debugShader:(NSString *)shader forObject:(GLuint)object
{
  GLint logLength;
  glGetShaderiv(object, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetShaderInfoLog(object, logLength, &logLength, log);
    NSLog(@"%@ Shader compile log:\n%s", shader, log);
    free(log);
    return NO;
  }
  return YES;
}

- (BOOL)debugPrograForObject:(GLuint)object
{
  GLint logLength;
  glGetProgramiv(object, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(object, logLength, &logLength, log);
    NSLog(@"Program compile log:\n%s", log);
    free(log);
    return NO;
  }
  return YES;
}

#pragma mark - Geometry
- (void)createGeometry
{
}

- (void)destroyGeometry
{
  
}

#pragma mark - Texture
- (GLuint)createTexture
{
  GLuint texture;

  glActiveTexture(GL_TEXTURE0);
  
  glGenTextures(1, &texture);
  glBindTexture(GL_TEXTURE_2D, texture);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  return texture;
}

- (void)createReadTexture
{
  Image img;
  NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"3am_256" ofType:@"jpeg"];
  Image_Create(&img, [imgPath UTF8String]);

  _readTexture = [self createTexture];
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)img.width, (GLsizei)img.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, img.pixels);

  Image_Release(&img);

  assert(glGetError() == GL_NO_ERROR);
}

- (void)destroyTexture
{
  glDeleteTextures(1, &_readTexture);
  glDeleteTextures(1, &_writeTextureX);
  glDeleteTextures(1, &_writeTextureY);
}

#pragma mark - Loop

- (void)drawScene
{
  
  glUseProgram(_textureProgram.object);
  
  glBindTexture(GL_TEXTURE_2D, _readTexture);
  
  GLfloat vertexPositionData[] = {
    -0.5f, -0.5f, 0.0f,
    0.5f, -0.5f, 0.0f,
    -0.5f, 0.5f, 0.0f,
    0.5f, 0.5f, 0.0f,
  };
  
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(vertexPositionData[0]) * 3, vertexPositionData);
  
  GLfloat vertexTexData[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f
  };
  
  glEnableVertexAttribArray(1);
  glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(vertexTexData[0]) * 2, vertexTexData);
  
  GLKMatrix4 mvMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
  GLKMatrix4 pMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f), self.bounds.size.width/self.bounds.size.height, 0.1f, 100.0f);
  GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
  
  glUniformMatrix4fv(_textureProgram.uniforms.um4k_Modelviewproj, 1, GL_FALSE, mvpMat.m);
  glUniform1i(_textureProgram.uniforms.us2k_Tex0, 0);
  
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)drawProcessedImageDirectionX:(BOOL)directionX
{
  float weights[5];
  float sigma = _blurIntensity;
  float sum = 0.0f;

  /* compute Gaussian weights */
  for (int i = 0; i < 5; ++i) {
    weights[i] = GaussianFilter(i, sigma);
    sum += weights[i];
  }
  
  /* normalize */
  for (int i = 0; i < 5; ++i) {
    weights[i] /= sum;
  }
  
  glUseProgram(_blurProgram.object);
  
  glBindTexture(GL_TEXTURE_2D, (directionX) ? _writeTextureX : _writeTextureY);
  
  GLfloat vertexPositionData[] = {
    -0.5f, -0.5f, 0.0f,
    0.5f, -0.5f, 0.0f,
    -0.5f, 0.5f, 0.0f,
    0.5f, 0.5f, 0.0f,
  };
  
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(vertexPositionData[0]) * 3, vertexPositionData);
  
  GLfloat vertexTexData[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f
  };
  
  glEnableVertexAttribArray(1);
  glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(vertexTexData[0]) * 2, vertexTexData);
  
  GLKMatrix4 mvMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
  mvMat = GLKMatrix4Scale(mvMat, 2.0f, -2.0f, 2.0f);
  GLKMatrix4 pMat = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f, 1.0f, 0.1f, 100.0f);
  GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);

  glUniformMatrix4fv(_blurProgram.uniforms.um4k_Modelviewproj, 1, GL_FALSE, mvpMat.m);
  glUniform1i(_blurProgram.uniforms.us2k_Tex0, 0);
  glUniform1f(_blurProgram.uniforms.uf1k_OneOverWidth, (1.0f/_fboWidth));
  glUniform1f(_blurProgram.uniforms.uf1k_OneOverHeight, (1.0f/_fboHeight));
  glUniform1f(_blurProgram.uniforms.uf5k_Weight0, weights[0]);
  glUniform1f(_blurProgram.uniforms.uf5k_Weight1, weights[1]);
  glUniform1f(_blurProgram.uniforms.uf5k_Weight2, weights[2]);
  glUniform1f(_blurProgram.uniforms.uf5k_Weight3, weights[3]);
  glUniform1f(_blurProgram.uniforms.uf5k_Weight4, weights[4]);
  glUniform1f(_blurProgram.uniforms.uf5k_PixelOffset1, 1.0);
  glUniform1f(_blurProgram.uniforms.uf5k_PixelOffset2, 2.0);
  glUniform1f(_blurProgram.uniforms.uf5k_PixelOffset3, 3.0);
  glUniform1f(_blurProgram.uniforms.uf5k_PixelOffset4, 4.0);
  glUniform1i(_blurProgram.uniforms.ub1k_IsBlurDirectionX, directionX ? GL_TRUE : GL_FALSE);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)updateAndDraw
{
  CFTimeInterval time = self.displayLink.timestamp;

  
  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
  
  // Pass 1
  glBindFramebuffer(GL_FRAMEBUFFER, _offscreenFramebufferX);
  glClear(GL_COLOR_BUFFER_BIT);
  
  [self drawScene];

  // Pass 2
  glBindFramebuffer(GL_FRAMEBUFFER, _offscreenFramebufferY);
  glClear(GL_COLOR_BUFFER_BIT);

  [self drawProcessedImageDirectionX:YES];

  // Pass 3
  glBindFramebuffer(GL_FRAMEBUFFER, _onscreenFramebuffer);
  glClear(GL_COLOR_BUFFER_BIT);

  [self drawProcessedImageDirectionX:NO];
  
  glBindRenderbuffer(GL_RENDERBUFFER, _onscreenColorRenderbuffer);
  [self.context presentRenderbuffer:GL_RENDERBUFFER];
  
  _time = time;

  assert(glGetError() == GL_NO_ERROR);
}
@end
