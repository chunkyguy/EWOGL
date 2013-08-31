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

typedef struct {
	Mesh mesh;
	Transform transform;
}Cube;

Cube cube_;
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
	
	// Load shader
	program_ = CompileShader("Shader.vsh", "Shader.fsh", &BindAttributes);
	
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
}

void TearDown() {
	glDisableVertexAttribArray(kAttribPosition);
	glDisableVertexAttribArray(kAttribNormal);
	
	TearDown_Mesh(cube_.mesh);
}

void Load() {
	glEnable(GL_DEPTH_TEST);

	cube_.mesh = CubeMesh();
	cube_.transform = Transform_Create(GLKVector3Make(0.0f, 0.0f, -5.0f),
									   GLKVector4Make(1.0f, 1.0f, 1.0f, GLKMathDegreesToRadians(45.0f)),
									   GLKVector3Make(1.0f, 1.0f, 1.0f),
									   NULL);
}

void Update(int dt) {
	//update
	cube_.transform.rotation.w += 0.01f;
	
	// Render
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	Render_Mesh(cube_.mesh, cube_.transform, program_, camera_);
}

