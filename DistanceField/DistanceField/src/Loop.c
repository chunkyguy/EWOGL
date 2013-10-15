//
//  Loop.c
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "Loop.h"

#include "core/std_incl.h"

#include "core/Constants.h"
#include "core/Mesh.h"
#include "core/Transform.h"
#include "core/Console.h"
#include "core/Shader.h"
#include "core/Font.h"
#include "core/Utilities.h"

void Reshape(Context *context, GLsizei width, GLsizei height) {
 // Set perpective
 DefaultPerspective(&context->frustum);
 PerspectiveSize(&context->frustum, (float)width, (float)height);
 
 // Set viewport
 glViewport(0, 0, width, height);
 
 // Set world transform
 DefaultTransform(&context->world_trans);
 context->world_trans.position = GLKVector3Make(0.0f, 0.0f, -(kFrustum_Z_Far - kFrustum_Z_Near)/2.0f);
// context->world_trans.axis = GLKVector3Make(0.0f, 0.0f, 0.0f);
// context->world_trans.angle = 0.0f;
 //context->world_trans.scale.x = (float)height/(float)width;
 
}

void Unload(Context *context) {
 /* Reset gl states */
 glDisable(GL_DEPTH_TEST);
 
 ReleaseShader(&context->shader[0]);
 ReleaseShader(&context->shader[1]);
 ReleaseMesh(&context->mesh[0]);
 ReleaseMesh(&context->mesh[1]);
 ReleaseFont(&context->font);
 context = NULL;
}

bool Load(Context *context) {
 /* Compile shaders */
 context->shader[0].attrib_flags = kAttribFlag(kAttrib_Position) | kAttribFlag(kAttrib_Normal);
 CompileShader(&context->shader[0],
               "mesh_shader.vsh", "mesh_shader.fsh");

 context->shader[1].attrib_flags = kAttribFlag(kAttrib_Position) | kAttribFlag(kAttrib_Color) | kAttribFlag(kAttrib_TexCoords);
 CompileShader(&context->shader[1],
               "font_shader.vsh", "font_shader.fsh");
 
 /* Load font */
 char font_path[kBuffer1K];
 context->font.size = 14.0f;
 CreateFont(&context->font, BundlePath(font_path, "Eurostile.ttf"));

 /* Load mesh */
 CreateMesh(&context->mesh[0], kCommonMesh_Cube);
 CreateMeshFromText(&context->mesh[1], &context->font, "Sid");
 
  // Cube
 context->object.mesh = &context->mesh[0];
 DefaultTransform(&context->object.transform);
 context->object.transform.axis = GLKVector3Make(0.0f, 1.0f, 0.0f);
 context->object.transform.parent = &context->world_trans;
 context->object.color = GLKVector4Make(0.4f, 0.6f, 0.7f, 0.8f);
 
 /* Set gl states */
 glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
 glEnable(GL_DEPTH_TEST);
 
 return true;
}

void Update(Context *context, int dt) {
// char font_path[kBuffer1K];
// DrawText(BundlePath(font_path, "Eurostile.ttf"), "Sid");

 //update cube
 context->object.transform.angle += 1.0f;
 RenderMesh(context->object.mesh, &context->object.transform,
            &context->shader[0], &context->frustum, &context->object.color);
 
 RenderText(&context->mesh[1], &context->world_trans,
            &context->shader[1], &context->frustum);
}

