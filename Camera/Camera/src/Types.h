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
typedef struct {
	GLuint buffer;
	GLuint renderbuffer[2];
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
#endif
