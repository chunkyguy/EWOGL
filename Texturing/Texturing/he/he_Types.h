//
//  Types.h
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Camera_Types_h
#define Camera_Types_h
#include "he_std_incl.h"

/*******************************************************************************
 MARK: Maths
 *******************************************************************************/
typedef GLKVector2 Vec2f;
typedef GLKVector3 Vec3f;
typedef GLKVector4 Vec4f;
typedef GLKMatrix2 Mat2;
typedef GLKMatrix3 Mat3;
typedef GLKMatrix4 Mat4;

typedef union {
 struct {int x, y; };
 int v[2];
} Vec2i;

typedef struct {
 struct {int x, y, z; };
 int v[3];
} Vec3i;

typedef struct {
 struct {int x, y, z, w; };
 int v[4];
} Vec4i;

/*******************************************************************************
 MARK: Framebuffer
 *******************************************************************************/
// The Framebuffer object
#define kRenderbuffer_Color				0
#define kRenderbuffer_DepthStencil		1
#define kRenderbuffer_Total				2
typedef struct {
 GLuint buffer;
 GLuint renderbuffer[kRenderbuffer_Total]; //Color buffer, depth buffer, stencil buffer
 GLint width;
 GLint height;
}Framebuffer;

/*******************************************************************************
 MARK: RenderbufferStorage
 *******************************************************************************/
// Callback to allocate the color renderbuffer storage.
typedef struct {
 int(*callback)(void *context, void *layer);
 void *context;
 void *layer;
} RenderbufferStorage;

/*******************************************************************************
 MARK: Shader
 *******************************************************************************/
/* mask to fit all attributes into a single int */
#define kShaderAttribMask(attrib) 	(0x1 << attrib)

/* test for each attribute type and enable/disable */
#define kShaderAttribEnable(attrib_flag)\
if (attrib_flag & kShaderAttribMask(kAttribPosition)) {\
 glEnableVertexAttribArray(kAttribPosition);\
}\
if (attrib_flag & kShaderAttribMask(kAttribNormal)) {\
 glEnableVertexAttribArray(kAttribNormal);\
}

#define kShaderAttribDisable(attrib_flag)\
if (attrib_flag & kShaderAttribMask(kAttribPosition)) {\
 glDisableVertexAttribArray(kAttribPosition);\
}\
if (attrib_flag & kShaderAttribMask(kAttribNormal)) {\
 glDisableVertexAttribArray(kAttribNormal);\
}



// Compiled shader program
typedef struct {
 GLuint vert_shader;
 GLuint frag_shader;
 GLuint program;
 int attrib_flag;
} Shader;

/*******************************************************************************
 MARK: Mesh
 *******************************************************************************/

typedef enum {
 kCommonMesh_Triangle, kCommonMesh_Square, kCommonMesh_Cube
} kCommonMesh;

// Renderable Mesh
typedef struct {
 GLuint vao;			// Vertex array object
 GLuint vbo;			// Vertex buffer object
 int vertex_count;	// Number of vertices.
 GLuint ibo;			// Index buffer object (if available)
 int index_count;		// Number of indices.
                        //This is the default rendering behavior.
                        //Set as -1 if rendering as glDrawArrays()
 GLenum primitive;	// Triangles, fan, strip, lines or points
} Mesh;

typedef union {
 GLvoid *ptr;
 size_t size;
} Offset;

typedef struct {
 int rows;
 int cols;
} Grid;

/*******************************************************************************
 MARK: Transform
 *******************************************************************************/
/**	@struct Transform
 Handle transformations of a coordinate system
 Every object has its own coordinate system in reference to some parent coordinate system.
 At the root level there is the Device's coordinate system (the world space) which is located at {0, 0, Screen::z}
 */
#define kTransformMask_Translation 	(0x1 << 0)
#define kTransformMask_Rotation		(0x1 << 1)
#define kTransformMask_Scaling		(0x1 << 2)
struct Transform_ {
 /** Get position in object space. */
 Vec3f position; //{x, y, z}
 Vec3f axis;	//{x, y, z}
 float angle;
 Vec3f scale;	//{x, y, z}
 const struct Transform_ *parent;
 unsigned int mask_flag;
};
typedef struct Transform_ Transform;

/*******************************************************************************
 MARK: Frustum
 *******************************************************************************/
typedef struct {
 Vec3f dimension;	/*width, height, depth */
 float nearZ;
} Frustum;

/*******************************************************************************
 MARK: Vertex
 *******************************************************************************/

typedef union {
 struct {
  Vec3f position;
  Vec3f normal;
 };
 float data[6];
} Vertex;

typedef union {
 GLushort data[3];
} Face;


typedef struct {
 Frustum f;
 Transform t;
} World;

typedef struct {
 Mesh *m;
 Transform t;
 Vec4f color;
} Cube;

#endif
