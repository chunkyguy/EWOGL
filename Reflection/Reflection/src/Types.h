//
//  Types.h
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Camera_Types_h
#define Camera_Types_h

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

// Callback to allocate the color renderbuffer storage.
typedef struct {
	int(*callback)(void *context, void *layer);
	void *context;
	void *layer;
}RenderbufferStorage;

// Screen size
typedef struct {
	GLsizei width;
	GLsizei height;
}ScreenSize;

// Compiled shader program
typedef struct {
	GLuint vert_shader;
	GLuint frag_shader;
	GLuint program;
}Program;

// Renderable Mesh
typedef struct {
	GLuint vao;
	GLuint vbo;
	int tri_count;	// Number of triangles.
} Mesh;

// Camera
typedef struct {
	float fov; // Field of view.
	float aspect_ratio;
} Camera;

/**	@struct Transform
 Handle transformations of a coordinate system
 Every object has its own coordinate system in reference to some parent coordinate system.
 At the root level there is the Device's coordinate system (the world space) which is located at {0, 0, Screen::z}
 */
struct Transform_ {
	/** Get position in object space. */
	GLKVector3 position; //{x, y, z}
	GLKVector4 rotation;	//{x, y, z, angle}
	GLKVector3 scale;	//{x, y, z}
	const struct Transform_ *parent;
};
typedef struct Transform_ Transform;

#endif
