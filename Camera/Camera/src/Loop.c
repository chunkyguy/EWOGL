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

Program program_;
Mesh cube_;

void BindAttributes(Program *program) {
	// Bind the custom vertex attribute "a_Position" to location VERTEX_ARRAY
	glBindAttribLocation(program->program, kAttribPosition, "a_Position");
	glBindAttribLocation(program->program, kAttribNormal, "a_Normal");
}

void SetUp(GLsizei width, GLsizei height) {
	//	// Set viewport
	glViewport(0, 0, width, height);

	// Load shader
	program_ = CompileShader("Shader.vsh", "Shader.fsh", &BindAttributes);
	
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
}

void TearDown() {
	glDisableVertexAttribArray(kAttribPosition);
	glDisableVertexAttribArray(kAttribNormal);
	
	TearDown_Mesh(cube_);
}

void Load() {
	glEnable(GL_DEPTH_TEST);

	cube_ = CubeMesh();
}

void Update(int dt) {
	// Render
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	Render_Mesh(cube_, program_);
}

