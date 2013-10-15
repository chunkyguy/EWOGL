//
//  Cube.h
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Camera_Cube_h
#define Camera_Cube_h
#include "HE_Types.h"
Mesh *CreateMesh(Mesh *mesh,
                 const kCommonMesh mesh_type);


Mesh *CreateMeshFromFile(Mesh *mesh, const char *filename);

Mesh *CreateMeshFromText(Mesh *mesh, Font* font, const char* text);

const Mesh *RenderMesh(const Mesh *mesh,   /*	The mesh to be rendered */
                       const Transform *transform, /*	The transform. */
                       const Shader *shader,	/*	The program in use. */
                       const Frustum *frustum, /* The perpective to be applied */
                       const Vec4f *color
                       );

void RenderText(const Mesh *mesh,   /*	The mesh to be rendered */
                const Transform *transform, /*	The transform. */
                const Shader *shader,	/*	The program in use. */
                const Frustum *frustum); /* The perpective to be applied*/

/**
 *	Release resources for the mesh.
 *
 *	@param	mesh	 The mesh.
 */
void ReleaseMesh(Mesh *mesh);

#endif
