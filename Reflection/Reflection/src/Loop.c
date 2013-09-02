//
//  Loop.c
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "std_incl.h"

#include "Loop.h"
#include "Constants.h"
#include "Mesh.h"
#include "Renderer.h"
#include "Transform.h"

#define kMesh_Cube		0
#define kMesh_Square		1
#define kMesh_Triangle	2
#define kMesh_Total		3

typedef struct {
	Mesh *mesh;
	Transform transform;
}Object;

Mesh mesh_[kMesh_Total]; // Cube, Square
Object cube_[2];
Object mask_;
Program program_;
Camera camera_;

void BindAttributes(Program *program) {
	// Bind the custom vertex attribute "a_Position" to location VERTEX_ARRAY
	glBindAttribLocation(program->program, kAttribPosition, "a_Position");
	glBindAttribLocation(program->program, kAttribNormal, "a_Normal");
}

void SetUp(GLsizei width, GLsizei height) {
	// Set viewport
	glViewport(0, 0, width, height);

	// Set camera
	camera_.fov = 45.0f;
	camera_.aspect_ratio = (width > height) ? (float)height/(float)(width): (float)width/(float)(height);
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
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
	program_ = CompileShader(shaderName_vsh, shaderName_fsh, BindAttributes);
	mesh_[kMesh_Cube] = CubeMesh();
	mesh_[kMesh_Square] = SquareMesh();
	mesh_[kMesh_Triangle] = TriangleMesh();
	
	cube_[0].mesh = &mesh_[kMesh_Cube];
	cube_[0].transform = Transform_Create(GLKVector3Make(0.0f, 1.0f, -5.0f),
									   GLKVector4Make(1.0f, 1.0f, 1.0f, GLKMathDegreesToRadians(45.0f)),
									   GLKVector3Make(1.0f, 1.0f, 1.0f),
									   NULL);
	cube_[1].mesh = &mesh_[kMesh_Cube];
	cube_[1].transform = Transform_Create(GLKVector3Make(0.0f, -1.0f, -5.0f),
										  GLKVector4Make(1.0f, 1.0f, 1.0f, GLKMathDegreesToRadians(45.0f)),
										  GLKVector3Make(1.0f, 1.0f, 1.0f),
										  NULL);
	mask_.mesh = &mesh_[kMesh_Triangle];
	mask_.transform = Transform_Create(GLKVector3Make(0.0f, -0.55f, -2.5f),
										   GLKVector4Make(0.0f, 0.0f, 1.0f, GLKMathDegreesToRadians(180.0f)),
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
	cube_[0].transform.rotation.w += 0.01f;
	cube_[1].transform.rotation.w += 0.01f;
	//triangle_.transform.rotation.w += 0.01f;
	//triangle_.transform.scale = GLKVector3AddScalar(triangle_.transform.scale, sinf(dt*0.0001f));
	//triangle_.transform = cube_[1].transform;
	
	// Render
	Render_Mesh(*cube_[0].mesh, cube_[0].transform, program_, camera_);

//	// Prepare the stencil buffer
	glEnable(GL_STENCIL_TEST);
	glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
	glStencilFunc(GL_ALWAYS, 0xff, 0xff);
	// Render to stencil buffer
	glDepthMask(GL_FALSE);
	glColorMask(GL_TRUE, GL_FALSE, GL_TRUE, GL_FALSE);
	Render_Mesh(*mask_.mesh, mask_.transform, program_, camera_);
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	glDepthMask(GL_TRUE);
	// Render with stencil test
	glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
	glStencilFunc(GL_EQUAL, 0xff, 0xff);
	Render_Mesh(*cube_[1].mesh, cube_[1].transform, program_, camera_);
	glDisable(GL_STENCIL_TEST);
}

