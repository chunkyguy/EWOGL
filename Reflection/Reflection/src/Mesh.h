//
//  Cube.h
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Camera_Cube_h
#define Camera_Cube_h
#include "Types.h"
Mesh *CreateMesh(Mesh *mesh,
                 const kCommonMesh mesh_type);

const Mesh *RenderMesh(const Mesh *mesh,   /*	The mesh to be rendered */
                const Transform *transform, /*	The transform. */
                const Shader *shader,	/*	The program in use. */
                const Perspective *perspective /* The perpective to be applied*/
);

/**
 *	Release resources for the mesh.
 *
 *	@param	mesh	 The mesh.
 */
void ReleaseMesh(Mesh *mesh);
#endif
