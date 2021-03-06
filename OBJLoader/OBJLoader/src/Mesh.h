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
/**
 *	Static Mesh
 */
typedef enum {
	kMesh_Cube, kMesh_Square, kMesh_Triangle
}StaticMesh;

/**
 *	Create a static mesh.
 *
 *	@param	mesh_type	Mesh type.
 *
 *	@return	Mesh
 */
Mesh CreatStaticMesh(StaticMesh mesh_type);

/**
 *	Create a mesh from file.
 *
 *	@param	filename	 filename.
 *
 *	@return	Mesh.
 */
Mesh CreateMeshFromFile(const char *filename);

/**
 *	Release resources for the mesh.
 *
 *	@param	mesh	 The mesh.
 */
void TearDown_Mesh(const Mesh mesh);
#endif
