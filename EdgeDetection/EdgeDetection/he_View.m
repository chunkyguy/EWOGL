//
//  he_View.m
//  EdgeDetection
//
//  Created by Sid on 17/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#import "he_View.h"
#import <GLKit/GLKMath.h>
#import "he_Quaternion.h"

#define kAttrib_Position 0
#define kAttrib_Normal 1

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

static char *load_file_heap(const char *filepath)
{
 /*open file*/
 FILE *f = fopen(filepath, "r");
 
 /*calc file size*/
 fseek(f, 0L, SEEK_END);
 size_t fsz = ftell(f);
 
 rewind(f);
 
 /*read data into memory*/
 size_t buffsz = fsz + 1;
 char *buffer = malloc(sizeof(char) * buffsz);
 size_t datasz = fread(buffer, 1, fsz, f);
 buffer[datasz] = '\0';

 /*close file*/
 fclose(f);
 return buffer;
}

static char *read_word(char *word, FILE *file)
{
 char *wptr = word;
 for (int ch = fgetc(file); ch != EOF && !isspace(ch); ch = fgetc(file)) {
  *word++ = ch;
 }
 *word++ = '\0';
 return wptr;
}

static void loadModelFromFile(GLuint *vao, GLuint *vbo, GLuint *ibo, GLuint *index_count, const char *path)
{
 /*open file*/
 int ch;
 FILE *file = fopen(path, "r");

 /*count number of vertices and faces*/
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
   vertexi++;
  } else if (strcmp(word, "f") == 0) {
   face[facei].va = atoi(read_word(word, file)) - 1;
   face[facei].vb = atoi(read_word(word, file)) - 1;
   face[facei].vc = atoi(read_word(word, file)) - 1;
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
 *index_count = f_count * 3;
 
 glGenVertexArraysOES(1, vao);
 glBindVertexArrayOES(*vao);
 
 glGenBuffers(1, vbo);
 glBindBuffer(GL_ARRAY_BUFFER, *vbo);
 glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * v_count, (GLfloat *)vertex, GL_STATIC_DRAW);
 
 glGenBuffers(1, ibo);
 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, *ibo);
 glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Face) * f_count, (GLushort *)face, GL_STATIC_DRAW);
 
 glEnableVertexAttribArray(kAttrib_Position);
 glVertexAttribPointer(kAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
 
 Stride nstride;
 nstride.size = sizeof(GLKVector3);
 glEnableVertexAttribArray(kAttrib_Normal);
 glVertexAttribPointer(kAttrib_Normal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), nstride.ptr);
 
 free(vertex);
 free(face);
 
 glBindVertexArrayOES(0);
 
 printf("Model: vertex = %d\t face = %d\n",v_count,f_count);
}

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
  printf("GLSL log:\n%s\n", log);
  free(log);
 }
}

static void debug_gl()
{
 GLenum err;
 char *error;
 while ((err = glGetError()) != GL_NO_ERROR) {
  switch(err) {
   case GL_INVALID_OPERATION:      error="INVALID_OPERATION";      break;
   case GL_INVALID_ENUM:           error="INVALID_ENUM";           break;
   case GL_INVALID_VALUE:          error="INVALID_VALUE";          break;
   case GL_OUT_OF_MEMORY:          error="OUT_OF_MEMORY";          break;
   case GL_INVALID_FRAMEBUFFER_OPERATION:  error="INVALID_FRAMEBUFFER_OPERATION";  break;
  }
  printf("GL error[%d]: %s\n",err,error);
 }
}

@interface he_View () {
 GLuint _fbo; /*framebuffer*/
 GLuint _crbo; /*color renderbuffer*/
 GLuint _drbo; /*depth renderbuffer*/
 
 CFTimeInterval _time;
 
 GLuint _shader;
 
 GLuint _vao;
 GLuint _vbo;
 GLuint _ibo;
 GLuint _index_count;
 
 GLuint _light_loc;
 GLuint _color_loc;
 GLuint _n_loc;
 GLuint _mvp_loc;
 
 GLKQuaternion _orientation;
 GLKQuaternion _prev_orientation;
 BOOL _spinning;
 GLKVector2 _touch_start;
 float _trackballRadius;
 GLKVector2 _center;
}
@property (nonatomic, retain) EAGLContext *context;
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
  /*config layer*/
  CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
  layer.opaque = YES;
  // These properties are recommended, but they're already default.
  //  layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
  //                              [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
  //                               kEAGLColorFormatSRGBA8, kEAGLDrawablePropertyColorFormat, nil];
  
  /*create context*/
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  [EAGLContext setCurrentContext:_context];
  
  /*create framebuffer*/
  printf("Creating framebuffer ...\n");
  glGenFramebuffers(1, &_fbo);
  glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
  
  /*create color renderbuffer*/
  glGenRenderbuffers(1, &_crbo);
  glBindRenderbuffer(GL_RENDERBUFFER, _crbo);
  [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _crbo);

  GLint w, h;
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &w);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &h);
  
  /*create depth renderbuffer*/
  glGenRenderbuffers(1, &_drbo);
  glBindRenderbuffer(GL_RENDERBUFFER, _drbo);
  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, w, h);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _drbo);
  assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
  debug_gl();

  /*set viewport*/
  glViewport(0, 0, w, h);

  /*load shaders*/
  
  const char *file = NULL;
  printf("Compiling vertex shader ...\n");
  GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
  file = load_file_heap([[[NSBundle mainBundle] pathForResource:@"he_Shader" ofType:@"vsh"] UTF8String]);
  assert(strlen(file));
  glShaderSource(vsh, 1, &file, NULL);
  free((char *)file);
  glCompileShader(vsh);
  debug_shader(vsh, glGetShaderiv, glGetShaderInfoLog);
  assert(vsh);
  
  printf("Compiling frag shader ...\n");
  GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);
  file = load_file_heap([[[NSBundle mainBundle] pathForResource:@"he_Shader" ofType:@"fsh"] UTF8String]);
   assert(strlen(file));
  glShaderSource(fsh, 1, &file, NULL);
   free((char *)file);
  glCompileShader(fsh);
  debug_shader(fsh, glGetShaderiv, glGetShaderInfoLog);
  assert(fsh);
  
  printf("Creating shader program ...\n");
  _shader = glCreateProgram();
  glAttachShader(_shader, vsh);
  glAttachShader(_shader, fsh);
  
  glBindAttribLocation(_shader, kAttrib_Position, "a_Position");
  glBindAttribLocation(_shader, kAttrib_Normal, "a_Normal");
  glLinkProgram(_shader);
  debug_shader(_shader, glGetProgramiv, glGetProgramInfoLog);

  _light_loc = glGetUniformLocation(_shader, "u_Light");
  _color_loc = glGetUniformLocation(_shader, "u_Color");
  _n_loc = glGetUniformLocation(_shader, "u_N");
  _mvp_loc = glGetUniformLocation(_shader, "u_Mvp");
  
  glDetachShader(_shader, vsh);
  glDetachShader(_shader, fsh);
  glDeleteShader(vsh);
  glDeleteShader(fsh);
  
  glUseProgram(_shader);
  debug_gl();

  /*load model*/
  printf("Loading model ...\n");
  loadModelFromFile(&_vao, &_vbo, &_ibo, &_index_count,
                    [[[NSBundle mainBundle] pathForResource:@"teapot" ofType:@"obj"] UTF8String]);
  glBindVertexArrayOES(_vbo);

  /*set default values*/
  glEnable(GL_DEPTH_TEST);
  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
  _spinning = false;
  _trackballRadius = w / 3;
  _center = GLKVector2Make(w/2, h/2);
  _orientation = GLKQuaternionIdentity;
  
  /*start loop*/
  printf("Starting loop ...\n");
  _time = self.displayLink.timestamp;
  self.displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(loop)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
 }
 return self;
}

- (void)loop
{
 CFTimeInterval time = self.displayLink.timestamp;
 //CFTimeInterval dt = time - _time;
 
 glBindRenderbuffer(GL_RENDERBUFFER, _crbo);
 
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

 GLKMatrix4 pMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),
                                             self.bounds.size.width/self.bounds.size.height, 0.01f, 100.0f);
 GLKMatrix4 tMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -10.0f);
 //GLKMatrix4 rMat = GLKMatrix4Identity;
 GLKMatrix4 rMat = GLKMatrix4MakeWithQuaternion(_orientation);
 GLKMatrix4 mvMat = GLKMatrix4Multiply(tMat, rMat);
 GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
 glUniformMatrix3fv(_n_loc, 1, GL_FALSE, nMat.m);
 GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
 glUniformMatrix4fv(_mvp_loc, 1, GL_FALSE, mvpMat.m);
 glUniform3f(_light_loc, 1.0f, 1.0f, 1.0f); /* position of sun */
 glUniform3f(_color_loc, 255.0f/255.0f, 240.0f/255.0f, 173.0f/255.0f); /* color of sun's light */
 
 glDrawElements(GL_TRIANGLES, _index_count, GL_UNSIGNED_SHORT, NULL);

 [_context presentRenderbuffer:GL_RENDERBUFFER];
 
 _time = time;
}

#pragma mark - Trackball
- (GLKVector3)mapToTrackball:(GLKVector2)touchPoint
{
 GLKVector2 touchVector = GLKVector2Subtract(touchPoint, _center);
 /*convert to OpenGL coords*/
 touchVector.y *= -1;
 
 /* assume effective radius a little shorter than actual
  * so that the Z axis can be taken into account
  * Therefore, this code is actually clamping the touch point to a trackball of effective radius
  */
 float eff_radius = _trackballRadius - 1.0f;
 
 /*clamp vector to trackball surface using effective radius */
 if (GLKVector2Length(touchVector) > eff_radius) {
  float angle = atan2f(touchVector.y, touchVector.x);
  touchVector = GLKVector2MultiplyScalar(GLKVector2Make(cosf(angle), sinf(angle)), eff_radius);
 }
 
 /* using pythogorus theorm to calculate the Z axis */
 float tvec_len = GLKVector2Length(touchVector);
 float z = sqrtf(_trackballRadius * _trackballRadius - tvec_len * tvec_len);
 return GLKVector3Normalize(GLKVector3Make(touchVector.x, touchVector.y, z));
}

/*finger down*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
 _spinning = YES;
 _prev_orientation = _orientation;
 UITouch *touch = [touches anyObject];
 CGPoint touch_point = [touch locationInView:self];
 _touch_start = GLKVector2Make(touch_point.x, touch_point.y);
}

/*finger up*/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
 _spinning = NO;
}

/*finger move*/
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
 if (!_spinning) {
  return;
 }
 
 UITouch *touch = [touches anyObject];
 CGPoint touch_point = [touch locationInView:self];

 GLKVector3 start = [self mapToTrackball:_touch_start];
 GLKVector3 end = [self mapToTrackball:GLKVector2Make(touch_point.x, touch_point.y)];
 
 GLKQuaternion delta = QuaternionFromVectors(start, end);
 _orientation = QuaternionRotate(delta, _prev_orientation);
}


@end
