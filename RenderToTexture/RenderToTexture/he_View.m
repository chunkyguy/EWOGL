//
//  he_View.m
//  RenderToTexture
//
//  Created by Sid on 07/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#import "he_View.h"

/** Print shader debug message
 *
 * @param glGetXiv
 * glGetShaderiv(GLuint shader, GLenum pname, GLint *params)
 * glGetProgramiv(GLuint program, GLenum pname, GLint *params)
 *
 * @param glXInfoLog
 * glGetShaderInfoLog(GLuint shader, GLsizei bufsize, GLsizei *length, GLchar *infolog)
 * glGetProgramInfoLog(GLuint program, GLsizei bufsize, GLsizei *length, GLchar *infolog)
 */
static void debug_shader(GLuint shader,
                         void(*glGetXiv)(GLuint object, GLenum pname, GLint *params),
                         void(*glXInfoLog)(GLuint object, GLsizei bufsize, GLsizei *length, GLchar *infolog))
{
 GLint logLength;
 glGetXiv(shader, GL_INFO_LOG_LENGTH, &logLength);
 if (logLength > 0) {
  GLchar *log = malloc(sizeof(GLchar) * logLength);
  glXInfoLog(shader, logLength, &logLength, log);
  printf("Shader compile log:\n%s\n", log);
  free(log);
 }
}

typedef void(^BindAttribs)(GLuint program);
static GLuint createProgram(const char *vsh_src, const char *fsh_src, BindAttribs bindAttribs)
{
 GLuint program = glCreateProgram();
 
 GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
 glShaderSource(vsh, 1, &vsh_src, NULL);
 glCompileShader(vsh);
 debug_shader(vsh, glGetShaderiv, glGetShaderInfoLog);
 glAttachShader(program, vsh);
 
 GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);
 glShaderSource(fsh, 1, &fsh_src, NULL);
 glCompileShader(fsh);
 debug_shader(fsh, glGetShaderiv, glGetShaderInfoLog);
 glAttachShader(program, fsh);

 bindAttribs(program);
 
 glLinkProgram(program);
 debug_shader(program, glGetProgramiv, glGetProgramInfoLog);

 glDetachShader(program, vsh);
 glDetachShader(program, fsh);
 glDeleteShader(vsh);
 glDeleteShader(fsh);
 
 return program;
}

static void drawTriangle(GLuint program, GLuint vbo, float angle, float depth)
{
 glUseProgram(program);
 glBindBuffer(GL_ARRAY_BUFFER, vbo);
 
 float tmvp[] = {
  cosf(angle),	-sinf(angle),	0.0f,	0.0f,
  sinf(angle),	cosf(angle),	0.0f,	0.0f,
  0.0f,			0.0f,			1.0f,	depth,
  0.0f,			0.0f,			0.0f,	1.0f
 };
 
 GLuint uMvp = glGetUniformLocation(program, "u_Mvp");
 glUniformMatrix4fv(uMvp, 1, GL_FALSE, tmvp);
 
 glDrawArrays(GL_TRIANGLES, 0, 3);
}

static void drawQuad(GLuint program, GLuint vbo, float depth)
{
 glUseProgram(program);
 glBindBuffer(GL_ARRAY_BUFFER, vbo);
 
 float qmvp[] = {
  1.0f,	0.0f, 0.0f,	0.0f,
  0.0f,	1.0f, 0.0f,	0.0f,
  0.0f,	0.0f, 1.0f,	depth,
  0.0f,	0.0f, 0.0f,	1.0f
 };
 
 GLuint uMvp = glGetUniformLocation(program, "u_Mvp");
 glUniformMatrix4fv(uMvp, 1, GL_FALSE, qmvp);
 GLuint uTex = glGetUniformLocation(program, "u_Tex");
 glUniform1i(uTex, 0);
 
 glDrawArrays(GL_TRIANGLES, 0, 6);
}


/* fbo types */
enum {
 kOnScreen,
 kOffScreen
};

/* draw types */
enum {
 kTriangle = 0,
 kQuad
};

@interface he_View () {
 GLuint _framebuffer[2];
 GLuint _color_renderbuffer[2];
 GLint _width;
 GLint _height;
 CFTimeInterval _time;
 GLuint _program[2];
 GLuint _vbo[2];
 GLuint _tex;
 float _angle;
 bool _snapshot;
}
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CADisplayLink *displayLink;
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
  /* Configure layer */
  CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
  
  /* should not retain backbuffer's contents when rendered
   * set color format to RGBA8
   */
  layer.opaque = YES;
  layer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
                               kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
  
  /* Create EAGLContext */
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  [EAGLContext setCurrentContext:self.context];
  
  /* Create framebuffers */
  glGenFramebuffers(2, _framebuffer);
  
  /* Create renderbuffers */
  glGenRenderbuffers(2, _color_renderbuffer);
  
  /* bind color renderbuffer to onScreen fbo */
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer[kOnScreen]);
  glBindRenderbuffer(GL_RENDERBUFFER, _color_renderbuffer[kOnScreen]);
  [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _color_renderbuffer[kOnScreen]);
  
  /* Get screen color buffer size */
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);

  /* bind color renderbuffer to offScreen fbo */
  glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer[kOffScreen]);
  glBindRenderbuffer(GL_RENDERBUFFER, _color_renderbuffer[kOffScreen]);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA, _width, _height);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _color_renderbuffer[kOffScreen]);
  
  /* bind texture to offscreen framebuffer */
  glGenTextures(1, &_tex);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, _tex);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _tex, 0);
  
  /* Set viewport */
  glViewport(0, 0, _width, _height);

  /* Create shaders */
  /* triangle shader */
  const GLchar *tvsh_src = "\
  attribute vec4 a_Position;\
  uniform mat4 u_Mvp;\
  void main()\
  {\
  gl_Position = u_Mvp * a_Position;\
  }";
  const GLchar *tfsh_src = "\
  void main()\
  {\
  gl_FragColor = vec4(0.0, 1.0, 0.0, 0.8);\
  }";
  _program[kTriangle] = createProgram(tvsh_src, tfsh_src, ^(GLuint program) {
   glBindAttribLocation(program, 0, "a_Position");
  });

  /* quad shader */
  const GLchar *qvsh_src = "\
  attribute vec4 a_Position;\
  attribute vec2 a_Texcoord;\
  varying lowp vec2 v_Texcoord;\
  uniform mat4 u_Mvp;\
  void main()\
  {\
   v_Texcoord = a_Texcoord;\
   gl_Position = u_Mvp * a_Position;\
  }";
  const GLchar *qfsh_src = "\
  varying lowp vec2 v_Texcoord;\
  uniform sampler2D u_Tex;\
  void main()\
  {\
   gl_FragColor = texture2D(u_Tex, v_Texcoord);\
  }";
  _program[kQuad] = createProgram(qvsh_src, qfsh_src, ^(GLuint program) {
   glBindAttribLocation(program, 0, "a_Position");
   glBindAttribLocation(program, 1, "a_Texcoord");
  });


  /* Create data */
  glGenBuffers(2, _vbo);
  
  /* create triangle data */
  glBindBuffer(GL_ARRAY_BUFFER, _vbo[kTriangle]);
  float triData[] = {
   -0.5f, -0.5f,
   0.5f, -0.5f,
   0.0f, 0.5f,
  };
  glBufferData(GL_ARRAY_BUFFER, sizeof(triData), triData, GL_STATIC_DRAW);
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, NULL);

  /* create quad data */
  glBindBuffer(GL_ARRAY_BUFFER, _vbo[kQuad]);
  float qdData[] = {
   -0.5f, -0.5f,  0.0f, 1.0f,
   0.5f, -0.5f,   1.0f, 1.0f,
   -0.5f, 0.5f,   0.0f, 0.0f,
   -0.5f, 0.5f,   0.0f, 0.0f,
   0.5f, -0.5f,   1.0f, 1.0f,
   0.5f, 0.5f,    1.0f, 0.0f
  };
  glBufferData(GL_ARRAY_BUFFER, sizeof(qdData), qdData, GL_STATIC_DRAW);
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 16, NULL);
  glEnableVertexAttribArray(1);
  glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 16, (const GLvoid *)4);
  
  /* Set default values */
  _time = 0;
  _angle = 0.0f;
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
  /* Start loop */
  self.displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(loop)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
 }
 return self;
}

- (void)dealloc
{
 /* Delete data */
 glDeleteBuffers(2, _vbo);
 
 /* Delete shaders */
 glDeleteProgram(_program[kTriangle]);
 glDeleteProgram(_program[kQuad]);
 
 /* Delete renderbuffers */
 glDeleteRenderbuffers(2, _color_renderbuffer);
 
 /* Delete framebuffers */
 glDeleteFramebuffers(2, _framebuffer);
 
 /* Release context */
 [EAGLContext setCurrentContext:nil];
}

- (void)loop
{
 CFTimeInterval t = self.displayLink.timestamp;
 CFTimeInterval dt = t - _time;
 [self update:dt];
 _time = t;
}

- (void)update:(CFTimeInterval)dt
{
 _angle += dt;
 if (_angle > M_PI * 2) {
  _angle = _angle - M_PI * 2;
 }

 /* render to texture */
 glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer[kOffScreen]);
 glBindRenderbuffer(GL_RENDERBUFFER, _color_renderbuffer[kOffScreen]);
 glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT);

 drawTriangle(_program[kTriangle], _vbo[kTriangle], _angle, 0.0f);
 
 /* render to screen */
 glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer[kOnScreen]);
 glBindRenderbuffer(GL_RENDERBUFFER, _color_renderbuffer[kOnScreen]);
 
 glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT);
 glBindTexture(GL_TEXTURE_2D, _tex);
 drawQuad(_program[kQuad], _vbo[kQuad], -15.0f);
 drawTriangle(_program[kTriangle], _vbo[kTriangle], _angle, -5.0f);

 [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
 _snapshot = true;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
 _snapshot = false;
}
@end
