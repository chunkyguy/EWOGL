//
//  he_Model.h
//  Lights
//
//  Created by Sid on 26/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#ifndef he_Model_h
#define he_Model_h

#include <GLKit/GLKMath.h>

#include "he_File.h"
#include "he_BitFlag.h"

typedef struct {
 GLKVector3 position;
 GLKVector3 texcoord;
 GLKVector3 normal;
} he_Vertex;

/*index of vertex texcoord normal of each vertex in the triangle*/
typedef struct {
 struct {
  int v, t, n;
 } abc[3];
} he_Face;

typedef struct {
 /*position info*/
 int positionc;
 GLKVector3 *positiond;

 /*texture coordinate info */
 int texcoordc;
 GLKVector3 *texcoordd;

 /*normal info */
 int normalc;
 GLKVector3 *normald;
 
 /*face info*/
 int facec;
 he_Face *faced;
} he_Model;

/** Create a new model from OBJ file
 * @param buffer The buffer where the he_Model object lives
 * @param file The OBJ file
 * @return The pointer to model.
 */
he_Model *ModelCreate(he_Model *buffer, const he_File *file);

/** Release any resources attached with the model*/
void ModelDestroy(he_Model *model);

/** Create and return draw data
 * @param vdatabuf Vertex data buffer
 * @param model The model
 * @return pointer to vdatabuf
 * note The vdatabuf can be created in heap as
 *  vdata = malloc(model->facec * sizeof(he_Vertex) * 3);
 */
he_Vertex *ModelDrawData(he_Vertex *vdatabuf, const he_Model *model);

/** Fill normals data
 * @param vdatabuf Vertex data buffer
 * @param model The model
 */
void CalculateVertexBasedNormals(he_Vertex *vdatabuf, const he_Model *model);

#endif