//
//  HE_Types.h
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Camera_Types_h
#define Camera_Types_h
#include "std_incl.h"
#include "Ganit.h"
#include <ft2build.h>
#include FT_FREETYPE_H

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
/* Compiled shader program */
typedef struct {
 GLuint vert_shader;
 GLuint frag_shader;
 GLuint program;
 u_int attrib_flags;
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
                        //This is the default rendering behavior. Set as -1 if rendering as glDrawArrays()
 GLuint texture;
} Mesh;

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
typedef Vec2f Frustum;	/*width, height*/

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

/*******************************************************************************
 MARK: Font
 *******************************************************************************/
typedef struct {
 FT_Library    library;
 FT_Face       face;
 float size;
} Font;

/*******************************************************************************
 MARK: Texture
 *******************************************************************************/
typedef struct {
 Vec2i size;
 void *pixels;
} Texture;
#endif
