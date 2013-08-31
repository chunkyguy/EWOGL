//
//  Mesh.c
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "std_incl.h"
#include "Renderer.h"
#include "Transform.h"

void Render_Mesh(const Mesh mesh, const Transform transform, const Program program, const Camera camera) {
	/* Matrices used */
	GLKMatrix4 pMat = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(camera.fov), camera.aspect_ratio, 0.1f, 100.0f);
	GLKMatrix4 mvMat = Transform_GetMV(&transform);
	GLKMatrix3 nMat = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), 0);
	GLKMatrix4 mvpMat = GLKMatrix4Multiply(pMat, mvMat);
	
	/*	Bind the data to the associated uniform variable in the shader
	 First gets the location of that variable in the shader using its name
	 Then passes the matrix to that variable
	 */
	int mvp_loc = glGetUniformLocation(program.program, "u_Mvp");
	glUniformMatrix4fv(mvp_loc, 1, GL_FALSE, mvpMat.m);
	int n_loc = glGetUniformLocation(program.program, "u_N");
	glUniformMatrix3fv(n_loc, 1, GL_FALSE, nMat.m);
	
	// Bind the VAO
	glBindVertexArrayOES(mesh.vao);
	
	
	/*
	 Draws a non-indexed triangle array from the pointers previously given.
	 This function allows the use of other primitive types : triangle strips, lines, ...
	 For indexed geometry, use the function glDrawElements() with an index list.
	 */
	glDrawArrays(GL_TRIANGLES, 0, mesh.tri_count);
	
	// Unbind the VAO
	glBindVertexArrayOES(0);
}
//EOF
