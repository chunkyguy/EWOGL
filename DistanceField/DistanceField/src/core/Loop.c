//
//  Loop.c
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "std_incl.h"
#include "Loop.h"

#include "Shader.h"
#include "Constants.h"
#include "Mesh.h"
#include "Renderer.h"
#include "Transform.h"
#include "../font/Font.h"
#include "Utilities.h"

#define kMesh_Cube		0
#define kMesh_Square		1
#define kMesh_Triangle	2
#define kMesh_Total		4

typedef struct {
	Mesh *mesh;
	Transform transform;
}Object;

Mesh mesh_[kMesh_Total]; // Cube, Square
Object object_[3];
Program program_;
Camera camera_;

void BindAttributes(Program *program) {
	// Bind the custom vertex attribute "a_Position" to location VERTEX_ARRAY
	glBindAttribLocation(program->program, kAttribPosition, "a_Position");
	glBindAttribLocation(program->program, kAttribNormal, "a_Normal");
}

void SetUp(GLsizei width, GLsizei height) {
	// load font
	char path_buffer[kBuffer(10)];
	BundlePath("Eurostile.ttf", path_buffer);
	font_main(path_buffer, "sid");

	// Set viewport
	glViewport(0, 0, width, height);

	// Set camera
	camera_.fov = 45.0f;
	camera_.aspect_ratio = (width > height) ? (float)height/(float)(width): (float)width/(float)(height);
	
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	glEnable(GL_DEPTH_TEST);
}

void TearDown() {
	glDisableVertexAttribArray(kAttribPosition);
	glDisableVertexAttribArray(kAttribNormal);
}

void Load() {
	// Load shader
	char shaderName_vsh[] = "Shader.vsh";
	char shaderName_fsh[] = "Shader.fsh";

//	char arr[] = {'1', '2', '3', '\0'};
//	program_ = Bullshit(arr, arr, BullshitCB);
//	Bullshit_print(&program_);
	
	program_ = CompileShader(shaderName_vsh, shaderName_fsh, BindAttributes);

	// Load mesh
	mesh_[kMesh_Cube] = CreatStaticMesh(kMesh_Cube);
	mesh_[kMesh_Square] = CreatStaticMesh(kMesh_Square);
	mesh_[kMesh_Triangle] = CreatStaticMesh(kMesh_Triangle);
	
	object_[0].mesh = &mesh_[kMesh_Square];
	object_[0].transform = Transform_Create(GLKVector3Make(0.5f, -1.1f, -10.0f),
										  GLKVector4Make(0.0f, 0.0f, 1.0f, GLKMathDegreesToRadians(45.0f)),
										  GLKVector3Make(1.0f, 1.0f, 1.0f),
										  NULL);
	object_[1].mesh = &mesh_[kMesh_Triangle];
	object_[1].transform = Transform_Create(GLKVector3Make(-0.5f, -0.3f, -8.0f),
										   GLKVector4Make(0.0f, 0.0f, 1.0f, GLKMathDegreesToRadians(45.0f)),
										   GLKVector3Make(1.0f, 1.0f, 1.0f),
										   NULL);
	object_[2].mesh = &mesh_[kMesh_Cube];
	object_[2].transform = Transform_Create(GLKVector3Make(0.0f, 0.0f, -6.0f),
											GLKVector4Make(0.0f, 1.0f, 0.0f, GLKMathDegreesToRadians(0.0f)),
											GLKVector3Make(1.0f, 1.0f, 1.0f),
											NULL);

}

void Unload() {
	ReleaseShader(program_);
	for (int i = 0; i < kMesh_Total; ++i) {
		TearDown_Mesh(mesh_[i]);
	}
}

void Update(int dt) {
	//update
	for (int i = 0; i < 3; ++i) {
		object_[i].transform.rotation.w += 0.01f;
	}
		//triangle_.transform.rotation.w += 0.01f;
	//triangle_.transform.scale = GLKVector3AddScalar(triangle_.transform.scale, sinf(dt*0.0001f));
	//triangle_.transform = cube_[1].transform;
	
	// Render
	for (int i = 0; i < 3; ++i) {
		Render_Mesh(*object_[i].mesh, object_[i].transform, program_, camera_);
	}

//	// Prepare the stencil buffer
//	glEnable(GL_STENCIL_TEST);
//	glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
//	glStencilFunc(GL_ALWAYS, 0xff, 0xff);
//	// Render to stencil buffer
//	glDepthMask(GL_FALSE);
//	glColorMask(GL_TRUE, GL_FALSE, GL_TRUE, GL_FALSE);
//	Render_Mesh(*mask_.mesh, mask_.transform, program_, camera_);
//	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
//	glDepthMask(GL_TRUE);
//	// Render with stencil test
//	glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
//	glStencilFunc(GL_EQUAL, 0xff, 0xff);
//	Render_Mesh(*cube_[1].mesh, cube_[1].transform, program_, camera_);
//	glDisable(GL_STENCIL_TEST);
}

