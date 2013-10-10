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
#include "Transform.h"
#include "Console.h"

typedef struct {
 Mesh *mesh;
 Transform transform;
}Object;

Mesh g_Mesh[2]; // Cube, Square
Object g_Cube;
Object g_Mask;
Shader g_Shader;
Transform g_WorldTrans;
Perspective g_Perspective;

void BindAttributes(Shader *shader) {
 // Bind the custom vertex attribute "a_Position" to location VERTEX_ARRAY
 glBindAttribLocation(shader->program, kAttribPosition, "a_Position");
 glBindAttribLocation(shader->program, kAttribNormal, "a_Normal");
}

void SetUp(GLsizei width, GLsizei height) {
 // Set perpective
 DefaultPerspective(&g_Perspective);
 g_Perspective.size.x = width;
 g_Perspective.size.y = height;

 // Set viewport
 glViewport(0, 0, width, height);
 
 // Set world transform
 DefaultTransform(&g_WorldTrans);
 g_WorldTrans.position = GLKVector3Make(0.0f, 0.0f, -(g_Perspective.far-g_Perspective.near)/2.0f);
 g_WorldTrans.axis = GLKVector3Make(1.0f, 0.0f, 0.0f);
 g_WorldTrans.angle = 3.0f;
 
 /* Set default gl state*/
 glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
 glEnable(GL_DEPTH_TEST);
}

void TearDown() {
 glDisableVertexAttribArray(kAttribPosition);
 glDisableVertexAttribArray(kAttribNormal);
}


void Load() {
 /* Load shader */
 char shaderName_vsh[] = "Shader.vsh";
 char shaderName_fsh[] = "Shader.fsh";
 CompileShader(&g_Shader, shaderName_vsh, shaderName_fsh, BindAttributes);
 
 /* Load mesh */
 CreateMesh(&g_Mesh[0], kCommonMesh_Cube);
 CreateMesh(&g_Mesh[1], kCommonMesh_Square);
 
 // Cube
 g_Cube.mesh = &g_Mesh[0];
 DefaultTransform(&g_Cube.transform);
 g_Cube.transform.position.z = 40.0f;
 g_Cube.transform.axis = GLKVector3Make(0.0f, 1.0f, 0.0f);
 //g_Cube.transform.scale = GLKVector3Make(10.0f, 10.0f, 10.0f);
 g_Cube.transform.angle = 0.0f;
 g_Cube.transform.parent = &g_WorldTrans;
 
 // Mask
 g_Mask.mesh = &g_Mesh[1];
 DefaultTransform(&g_Mask.transform);
 g_Mask.transform.position.z = 40.0f;
 g_Mask.transform.axis = GLKVector3Make(1.0f, 0.0f, 0.0f);
 g_Mask.transform.angle = 90.0f;
 g_Mask.transform.scale = GLKVector3Make(3.0f, 3.0f, 3.0f);
 g_Mask.transform.parent = &g_WorldTrans;
}

void Unload() {
 ReleaseShader(&g_Shader);
 for (int i = 0; i < 2; ++i) {
  ReleaseMesh(&g_Mesh[i]);
 }
}

void Update(int dt) {
 //update
 g_Cube.transform.angle += 1.0f;

 // Render floor
 // glDisable(GL_DEPTH_TEST);
 // glEnable(GL_BLEND);
 // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 // RenderMesh(g_Mask.mesh, &g_Mask.transform, &g_Shader, &g_Perspective);
 // glDisable(GL_BLEND);
 // glEnable(GL_DEPTH_TEST);

 // Render cube
 g_Cube.transform.position.y = 1.1f;
 RenderMesh(g_Cube.mesh, &g_Cube.transform, &g_Shader, &g_Perspective);

 // Prepare the stencil buffer
 glEnable(GL_STENCIL_TEST);
 
 /* What to do with the test outcome.
  stencil fail: replace.
  stencil pass + depth fail: replace
  stencil+depth pass: replace
  */
 glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
 
 /*Set test conditions
  func: For now we need all values to be rendered to the stencil buffer.
  ref: compare with value 0xff. This is the minimum value that passes the test.
  mask: Apply AND with 0xff. Pass all values.
  */
 glStencilFunc(GL_ALWAYS, 0xff, 0xff);
 
 // Render the mask to stencil buffer
 /* Turn off depth and color buffers
  On stencil is enabled now.
  */
 glDepthMask(GL_FALSE);
 glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
 RenderMesh(g_Mask.mesh, &g_Mask.transform, &g_Shader, &g_Perspective);
 
 /* Turn depth and color buffers back on.
  */
 glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
 glDepthMask(GL_TRUE);
 
 // Render with stencil test
 /* What to do with the test outcome.
  stencil fail: keep.
  stencil pass + depth fail: keep
  stencil+depth pass: keep
  */
 glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
 
 /* Render with test conditions
  func: Only pass values wtih values equal to stored in stencil buffer
  ref: The minimum value to pass should be 0xff. only set values.
  mask: Apply AND with 0xff. Pass all values.
  */
 glStencilFunc(GL_EQUAL, 0xff, 0xff);
 
 // Render relfection
 Transform ref_trans = g_Cube.transform;
 ref_trans.position.y = -1.1f;
 RenderMesh(g_Cube.mesh, &ref_trans, &g_Shader, &g_Perspective);


 // Disable stencil test
 glDisable(GL_STENCIL_TEST);
}

