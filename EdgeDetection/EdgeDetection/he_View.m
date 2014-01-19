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
//#import "he_Image.h"

#define kResourcePath(file, extn) ([[[NSBundle mainBundle] pathForResource:file ofType:extn] UTF8String])

/** MARK: Types */
enum {
 kFBO_OnScreen,
 kFBO_OffScreen
};

enum {
 kShader_Diffuse,
 // kShader_Texture,
 kShader_Edge
};

enum {
 kGeometry_Teapot,
 kGeometry_Quad,
};

/* Map exactly in the shader locations */
enum {
 kAttrib_Position = 0,
 kAttrib_Normal = 1,
 kAttrib_Texcoord = 2
};

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

/** Load file in heap memory
 * Don't forget to free when done
 */
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

/** Read file word by word
 * @return Pointer to the word. Good for chaining
 */
static char *read_word(char *word, FILE *file)
{
 char *wptr = word;
 for (int ch = fgetc(file); ch != EOF && !isspace(ch); ch = fgetc(file)) {
  *word++ = ch;
 }
 *word++ = '\0';
 return wptr;
}

/** @return index count */
static int loadQuad(GLuint vao, GLuint vbo, GLuint ibo)
{
 GLfloat quad_data[] = {
  -0.5f, -0.5f, 0.0f,   0.0f, 1.0f,
  0.5f, -0.5f, 0.0f,    1.0f, 1.0f,
  -0.5f, 0.5f, 0.0f,     0.0f, 0.0f,
  0.5f, 0.5f, 0.0f,     1.0f, 0.0f
 };
 GLushort quad_index[] = {0,1,2,3};

 /* push data to GPU RAM */
 glBindVertexArrayOES(vao);
 
 glBindBuffer(GL_ARRAY_BUFFER, vbo);
 glBufferData(GL_ARRAY_BUFFER, sizeof(quad_data), quad_data, GL_STATIC_DRAW);

 glEnableVertexAttribArray(kAttrib_Position);
 glVertexAttribPointer(kAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, 0);
 
 Stride texcoord_offset;
 texcoord_offset.size = sizeof(GLfloat) * 3;
 glEnableVertexAttribArray(kAttrib_Texcoord);
 glVertexAttribPointer(kAttrib_Texcoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, texcoord_offset.ptr);
 
 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
 glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(quad_index), quad_index, GL_STATIC_DRAW);
 
 glDisableVertexAttribArray(kAttrib_Position);
 glDisableVertexAttribArray(kAttrib_Texcoord);

 return sizeof(quad_index)/sizeof(quad_index[0]);
}

/** load model data from OBJ file into the GPU memory
 * returns index_count
 */
static int loadModelFromFile(GLuint vao, GLuint vbo, GLuint ibo, const char *path)
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
 glBindVertexArrayOES(vao);
 
 glBindBuffer(GL_ARRAY_BUFFER, vbo);
 glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * v_count, (GLfloat *)vertex, GL_STATIC_DRAW);
 
 glEnableVertexAttribArray(kAttrib_Position);
 glVertexAttribPointer(kAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
 
 Stride nstride;
 nstride.size = sizeof(GLKVector3);
 glEnableVertexAttribArray(kAttrib_Normal);
 glVertexAttribPointer(kAttrib_Normal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), nstride.ptr);

 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
 glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Face) * f_count, (GLushort *)face, GL_STATIC_DRAW);

 free(vertex);
 free(face);
 
 glDisableVertexAttribArray(kAttrib_Position);
 glDisableVertexAttribArray(kAttrib_Normal);
 
 printf("Model: vertex = %d\t face = %d\n",v_count,f_count);
 return f_count * 3;
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

/** Sprinke any where */
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

typedef void (^BindAttribute)(GLuint shader);
static GLuint compileShader(const char *vsh_fpath, const char *fsh_fpath, BindAttribute bindAttribs)
{
 const char *file = NULL;
 printf("Compiling vertex shader ...\n");
 GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
 file = load_file_heap(vsh_fpath);
 assert(strlen(file));
 glShaderSource(vsh, 1, &file, NULL);
 free((char *)file);
 glCompileShader(vsh);
 debug_shader(vsh, glGetShaderiv, glGetShaderInfoLog);
 assert(vsh);
 
 printf("Compiling frag shader ...\n");
 GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);
 file = load_file_heap(fsh_fpath);
 assert(strlen(file));
 glShaderSource(fsh, 1, &file, NULL);
 free((char *)file);
 glCompileShader(fsh);
 debug_shader(fsh, glGetShaderiv, glGetShaderInfoLog);
 assert(fsh);
 
 printf("Creating shader program ...\n");
 GLuint shader = glCreateProgram();
 glAttachShader(shader, vsh);
 glAttachShader(shader, fsh);

 bindAttribs(shader);
 glLinkProgram(shader);
 debug_shader(shader, glGetProgramiv, glGetProgramInfoLog);
 
 glDetachShader(shader, vsh);
 glDetachShader(shader, fsh);
 glDeleteShader(vsh);
 glDeleteShader(fsh);
 
 debug_gl();
 return shader;
}

@interface he_View () {
 GLuint _fbo[2]; /*framebuffer*/
 GLuint _rbo[3]; /*2 color + 1 depth renderbuffer*/
 
 GLuint _tex0;
 // GLuint _tex1;
 
 CFTimeInterval _time;
 
 GLuint _shader[2];
 
 GLuint _vao[2]; /*vertex array objects*/
 GLuint _vbo[4]; /*vertex buffer objects + index objects */
 GLuint _index_count[2];
 
 GLint _width;
 GLint _height;
 
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
  [self createFramebuffersFromDrawable:layer];

  /*load shaders*/
  [self loadShaders];

  /*load model*/
  [self loadModels];
  
  /*load textures*/
  //[self loadTextures];
  
  /*set default values*/
  glViewport(0, 0, _width, _height);
  _spinning = false;
  _trackballRadius = _width / 3;
  _center = GLKVector2Make(_width/2, _height/2);
  _orientation = GLKQuaternionIdentity;
  
  /*start loop*/
  printf("Starting loop ...\n");
  _time = self.displayLink.timestamp;
  self.displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(loop)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
 }
 return self;
}

- (void)createFramebuffersFromDrawable:(CAEAGLLayer *)layer
{
 printf("Creating framebuffer ...\n");
 glGenFramebuffers(2, _fbo);
 glGenRenderbuffers(3, _rbo);

 /*create on-screen FBO*/
 glBindFramebuffer(GL_FRAMEBUFFER, _fbo[kFBO_OnScreen]);
 glBindRenderbuffer(GL_RENDERBUFFER, _rbo[kFBO_OnScreen]);
 [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
 glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _rbo[kFBO_OnScreen]);
 
 glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
 glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
// _width = 640;
// _height = 1136;
 
 /*create off-screen FBO*/
 glBindFramebuffer(GL_FRAMEBUFFER, _fbo[kFBO_OffScreen]);
 glBindRenderbuffer(GL_RENDERBUFFER, _rbo[kFBO_OffScreen]);
 glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, _width, _height);
 glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _rbo[kFBO_OffScreen]);
 glBindRenderbuffer(GL_RENDERBUFFER, _rbo[kFBO_OffScreen+1]);
 glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
 glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rbo[kFBO_OffScreen+1]);

 /*create off-screen texture*/
 glActiveTexture(GL_TEXTURE0);
 glGenTextures(1, &_tex0);
 glBindTexture(GL_TEXTURE_2D, _tex0);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
 glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
 glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _tex0, 0);

 assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
 debug_gl();
}

- (void)loadShaders
{
 /* diffuse shader */
 _shader[kShader_Diffuse] = compileShader(kResourcePath(@"he_Shader",@"vsh"),
                                          kResourcePath(@"he_Shader",@"fsh"),
                                          ^(GLuint shader) {
                                           glBindAttribLocation(shader, kAttrib_Position, "a_Position");
                                           glBindAttribLocation(shader, kAttrib_Normal, "a_Normal");
                                          });

 /* texture shader */
// _shader[kShader_Texture] = compileShader(kResourcePath(@"he_TextureShader",@"vsh"),
//                                          kResourcePath(@"he_TextureShader",@"fsh"),
//                                          ^(GLuint shader) {
//                                           glBindAttribLocation(shader, kAttrib_Position, "a_Position");
//                                           glBindAttribLocation(shader, kAttrib_Texcoord, "a_Texcoord");
//                                          });
 /* edge detection shader */
 _shader[kShader_Edge] = compileShader(kResourcePath(@"he_EdgeDetectionShader",@"vsh"),
                                          kResourcePath(@"he_EdgeDetectionShader",@"fsh"),
                                          ^(GLuint shader) {
                                           glBindAttribLocation(shader, kAttrib_Position, "a_Position");
                                           glBindAttribLocation(shader, kAttrib_Texcoord, "a_Texcoord");
                                          });

}

- (void)loadModels
{
 printf("Loading model ...\n");
 glGenVertexArraysOES(2, _vao);
 glGenBuffers(4, _vbo);
 _index_count[kGeometry_Teapot] = loadModelFromFile(_vao[kGeometry_Teapot],
                                                    _vbo[kGeometry_Teapot],
                                                    _vbo[kGeometry_Teapot+2],
                                                    kResourcePath(@"teapot", @"obj"));
 
 _index_count[kGeometry_Quad] = loadQuad(_vao[kGeometry_Quad], _vbo[kGeometry_Quad], _vbo[kGeometry_Quad+2]);
}

//- (void)loadTextures
//{
// he_Image img;
// Image_Create(&img, kResourcePath(@"sample", @"png"));
// 
// glGenTextures(1, &_tex1);
// glBindTexture(GL_TEXTURE_2D, _tex1);
// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
// glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, img.width, img.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, img.pixels);
// 
// Image_Release(&img);
//}

#pragma mark - Loop
- (void)loop
{
 CFTimeInterval time = self.displayLink.timestamp;
 //CFTimeInterval dt = time - _time;

 [self renderPass1];
 [self renderPass2];
 
 glDisableVertexAttribArray(kAttrib_Position);
 glDisableVertexAttribArray(kAttrib_Normal);
 glDisableVertexAttribArray(kAttrib_Texcoord);
 
 _time = time;
}

- (void)drawTeapot
{
 glUseProgram(_shader[kShader_Diffuse]);
 
 glBindVertexArrayOES(_vao[kGeometry_Teapot]);
 
 glEnableVertexAttribArray(kAttrib_Position);
 glEnableVertexAttribArray(kAttrib_Normal);
 
 GLuint u_N = glGetUniformLocation(_shader[kShader_Diffuse], "u_N");
 GLuint u_Mvp = glGetUniformLocation(_shader[kShader_Diffuse], "u_Mvp");
 struct Light {
  GLuint p; /*light position in eye space. Must be normalized*/
  GLuint d; /*diffuse color*/
  GLuint s; /*specular color*/
  GLuint gloss; /*glossiness (1,200)*/
 } u_Light;

 u_Light.p = glGetUniformLocation(_shader[kShader_Diffuse], "u_Light.p");
 u_Light.d = glGetUniformLocation(_shader[kShader_Diffuse], "u_Light.d");
 u_Light.s = glGetUniformLocation(_shader[kShader_Diffuse], "u_Light.s");
 u_Light.gloss = glGetUniformLocation(_shader[kShader_Diffuse], "u_Light.gloss");
 
 GLKMatrix4 pMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),
                                             self.bounds.size.width/self.bounds.size.height, 0.01f, 100.0f);
 GLKMatrix4 tMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -10.0f);
 //GLKMatrix4 rMat = GLKMatrix4Identity;
 GLKMatrix4 rMat = GLKMatrix4MakeWithQuaternion(_orientation);
 GLKMatrix4 mvMat = GLKMatrix4Multiply(tMat, rMat);
 GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
 glUniformMatrix3fv(u_N, 1, GL_FALSE, nMat.m);
 GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
 glUniformMatrix4fv(u_Mvp, 1, GL_FALSE, mvpMat.m);
 glUniform3f(u_Light.p, 0.0f, 0.0f, 1.0f); /* position of sun */
 glUniform3f(u_Light.d, 255.0f/255.0f, 240.0f/255.0f, 173.0f/255.0f); /* color of sun's light */
 glUniform3f(u_Light.s, 1.0f, 1.0f, 1.0f);
 glUniform1f(u_Light.gloss, 60.0f);
 
 glDrawElements(GL_TRIANGLES, _index_count[kGeometry_Teapot], GL_UNSIGNED_SHORT, NULL);
}

- (void)drawQuad
{
 glUseProgram(_shader[kShader_Edge]);
 
 glBindVertexArrayOES(_vao[kGeometry_Quad]);

 glBindTexture(GL_TEXTURE_2D, _tex0);

 glEnableVertexAttribArray(kAttrib_Position);
 glEnableVertexAttribArray(kAttrib_Texcoord);
 
 GLuint u_Mvp = glGetUniformLocation(_shader[kShader_Edge], "u_Mvp");
 GLuint u_Tex0 = glGetUniformLocation(_shader[kShader_Edge], "u_Tex0");
 GLuint u_OneOverScreenX = glGetUniformLocation(_shader[kShader_Edge], "u_OneOverScreenX");
 GLuint u_OneOverScreenY = glGetUniformLocation(_shader[kShader_Edge], "u_OneOverScreenY");
 struct {
  GLuint a;
  GLuint b;
  GLuint threshold;
 } u_Color;
 u_Color.a = glGetUniformLocation(_shader[kShader_Edge], "u_Color.a");
 u_Color.b = glGetUniformLocation(_shader[kShader_Edge], "u_Color.b");
 u_Color.threshold = glGetUniformLocation(_shader[kShader_Edge], "u_Color.threshold");

 GLKMatrix4 pMat = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -1.0f, 1.0f, 0.1f, 1.1f);
 GLKMatrix4 tMat = GLKMatrix4MakeTranslation(0.0f, 0.0f, -0.1f);
 /*because _width, _height = 320 x 568
  * also, flip the y-coord as texture data is coming from GPU ram
  */
 GLKMatrix4 sMat = GLKMatrix4MakeScale(2.0f, -2.0f, 2.0f);
 GLKMatrix4 mvMat = GLKMatrix4Multiply(tMat, sMat);
 GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
 glUniformMatrix4fv(u_Mvp, 1, GL_FALSE, mvpMat.m);
 glUniform1i(u_Tex0, 0);
 glUniform1f(u_OneOverScreenX, 1.0f/_width);
 glUniform1f(u_OneOverScreenY, 1.0f/_height);
 glUniform4f(u_Color.a, 1.0f, 1.0f, 1.0f, 1.0f);
 glUniform4f(u_Color.b, 0.0f, 0.0f, 0.0f, 1.0f);
 glUniform1f(u_Color.threshold, 0.06f);
 glDrawElements(GL_TRIANGLE_STRIP, _index_count[kGeometry_Quad], GL_UNSIGNED_SHORT, NULL);
}

/* Render the geometry to texture */
- (void)renderPass1
{

 glBindFramebuffer(GL_FRAMEBUFFER, _fbo[kFBO_OffScreen]);
 glBindRenderbuffer(GL_RENDERBUFFER, _rbo[kFBO_OffScreen]);
 
 glEnable(GL_DEPTH_TEST);
 glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 [self drawTeapot];
 glDisable(GL_DEPTH_TEST);
}

/* Render texture to quad on screen */
- (void)renderPass2
{

 glBindFramebuffer(GL_FRAMEBUFFER, _fbo[kFBO_OnScreen]);
 glBindRenderbuffer(GL_RENDERBUFFER, _rbo[kFBO_OnScreen]);
 
 glClearColor(1.0f, 1.0f, 0.0f, 1.0f);
 glClear(GL_COLOR_BUFFER_BIT);
 [self drawQuad];
 //[self drawTeapot];
 
 [_context presentRenderbuffer:GL_RENDERBUFFER];
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
