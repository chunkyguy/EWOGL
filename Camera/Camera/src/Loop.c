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
                                    GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(1.0f), 0.0f, 1.0f, 0.0f),
                                    //									   GLKVector4Make(1.0f, 1.0f, 1.0f, GLKMathDegreesToRadians(45.0f)),
                                    GLKVector3Make(1.0f, 1.0f, 1.0f),
                                    NULL);
}


void Update(int dt) {
 //update
// static int time = 0; //in msecs
// time += 30;
// if (time > 1000) {
//  time = 0;
// }
// GLKQuaternion start = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0.0f), 1.0f, 0.0f, 0.0f);
// GLKQuaternion end = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(360.0f), 1.0f, 0.0f, 0.0f);
// cube_.transform.orientation = GLKQuaternionSlerp(start, end, (float)time/1000.0f);

 float curr_angle = GLKMathRadiansToDegrees(GLKQuaternionAngle(cube_.transform.orientation));
 float next_angle = curr_angle + 1.0f;
 if (next_angle >= 359.0f) {
  next_angle = 1.0f;
 }
 printf("next_angle: %.2f\n",next_angle);
 GLKVector3 curr_axis = GLKQuaternionAxis(cube_.transform.orientation);
 GLKQuaternion rotatedQuaternion = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(next_angle), curr_axis.v[0], curr_axis.v[1], curr_axis.v[2]);
 // GLKQuaternion rotatedQuaternion = GLKQuaternionMake(curr_axis.v[0], curr_axis.v[1], curr_axis.v[2], GLKMathDegreesToRadians(curr_angle+1.0f));

 //GLKQuaternion new_orient = GLKQuaternionMakeWithAngleAndVector3Axis(GLKMathDegreesToRadians(next_angle), curr_axis);
 
 cube_.transform.orientation = GLKQuaternionMultiply(GLKQuaternionMultiply(cube_.transform.orientation, rotatedQuaternion), GLKQuaternionInvert(cube_.transform.orientation));

 // cube_.transform.orientation = GLKQuaternionMultiply(rotatedQuaternion, cube_.transform.orientation);

 
//cube_.transform.orientation = GLKQuaternionMultiply(GLKQuaternionMultiply(cube_.transform.orientation, rotatedQuaternion), GLKQuaternionConjugate(cube_.transform.orientation));
// GLKQuaternionNormalize(cube_.transform.orientation);
 // cube_.transform.orientation.s += 0.01f;
 //	cube_.transform.rotation.w += 0.01f;
 
 // Render
 glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 Render_Mesh(cube_.mesh, cube_.transform, program_, camera_);
}

