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
 Vec4f color;
} Object;

Mesh g_Mesh[2]; // Cube, Square
Object g_Cube;
Object g_Mask;
Shader g_Shader;
Transform g_WorldTrans;
Frustum g_Frustum;

void Load() {
 /* Load shader */
 char shaderName_vsh[] = "Shader.vsh";
 char shaderName_fsh[] = "Shader.fsh";
 CompileShader(&g_Shader, shaderName_vsh, shaderName_fsh);
 
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
 g_Cube.color = GLKVector4Make(0.4f, 0.6f, 0.7f, 0.8f);
 
 // Mask
 g_Mask.mesh = &g_Mesh[1];
 DefaultTransform(&g_Mask.transform);
 g_Mask.transform.position = GLKVector3Make(0.0f, 2.0f, 40.0f);
 g_Mask.transform.axis = GLKVector3Make(1.0f, 0.0f, 0.0f);
 g_Mask.transform.angle = 90.0f;
 g_Mask.transform.scale = GLKVector3Make(2.0f, 2.0f, 1.0f);
 g_Mask.transform.parent = &g_WorldTrans;
 g_Mask.color = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.8f);
 
 /* Set gl states */
 glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
 glEnable(GL_DEPTH_TEST);
}

void Unload() {
 /* Reset gl states */
 glDisable(GL_DEPTH_TEST);
 
 ReleaseShader(&g_Shader);
 for (int i = 0; i < 2; ++i) {
  ReleaseMesh(&g_Mesh[i]);
 }
}


void Reshape(GLsizei width, GLsizei height) {
 // Set perpective
 DefaultPerspective(&g_Frustum);
// g_Frustum.dimension.x = width;
// g_Frustum.dimension.y = height;

 // Set viewport
 glViewport(0, 0, width, height);
 
 // Set world transform
 DefaultTransform(&g_WorldTrans);
 g_WorldTrans.position = GLKVector3Make(0.0f, 0.0f, -g_Frustum.dimension.z/2.0f);
 g_WorldTrans.axis = GLKVector3Make(1.0f, 0.0f, 0.0f);
 g_WorldTrans.angle = 3.0f;
 g_WorldTrans.scale.x = (float)height/(float)width;
 
}

void Update(int dt) {
 //update
 g_Cube.transform.angle += 1.0f;


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
 RenderMesh(g_Mask.mesh, &g_Mask.transform, &g_Shader, &g_Frustum, &g_Mask.color);
 
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
 ref_trans.position.y = 0.0f;
 RenderMesh(g_Cube.mesh, &ref_trans, &g_Shader, &g_Frustum, &g_Cube.color);

 // Disable stencil test
 glDisable(GL_STENCIL_TEST);

 
 // Render floor
 glDisable(GL_DEPTH_TEST);
 glEnable(GL_BLEND);
 glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 RenderMesh(g_Mask.mesh, &g_Mask.transform, &g_Shader, &g_Frustum, &g_Mask.color);
 glDisable(GL_BLEND);
 glEnable(GL_DEPTH_TEST);

 // Render cube
 g_Cube.transform.position.y = 2.0f;
 RenderMesh(g_Cube.mesh, &g_Cube.transform, &g_Shader, &g_Frustum, &g_Cube.color);

}

