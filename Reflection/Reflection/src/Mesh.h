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
 *	Create cube mesh
 *	@return	A cube mesh.
 */
Mesh CubeMesh();

/**
 *	Create a square mesh.
 *	@return	A square mesh.
 */
Mesh SquareMesh();

/**
 *	Create a triangle mesh.
 *	@return	A triangle mesh.
 */
Mesh TriangleMesh();

/**
 *	Release resources for the mesh.
 *
 *	@param	mesh	 The mesh.
 */
void TearDown_Mesh(const Mesh mesh);
#endif
