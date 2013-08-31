//
//  Mesh.h
//  Camera
//
//  Created by Sid on 31/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Camera_Mesh_h
#define Camera_Mesh_h
#include "Types.h"
/**
 *	Render an arbitary mesh.
 *
 *	@param	mesh The mesh to be rendered
 *	@param	program	The program in use.
 *	@param	camera	The current camera configuration.
 */
void Render_Mesh(const Mesh mesh, const Program program, const Camera camera);
#endif
