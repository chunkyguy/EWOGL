//
//  ModelParser.h
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __MultiSampling__ModelParser__
#define __MultiSampling__ModelParser__
#include <GLKit/GLKMath.h>
#include <OpenGLES/ES2/glext.h>

typedef union {
  struct {
    GLKVector3 position;
    GLKVector3 normal;
  };
  GLfloat data[6];
} Vertex;

typedef union {
  struct {
    GLushort va, vb, vc;
  };
  GLushort data[3];
} Face;

/** Parse a model file. Only OBJ files at the moment. 
 * The OBJ file is not even the standard OBJ files you get from Maya or similar apps.
 * The surface normals are calculated on the fly.
 */
class ModelParser {
public:
  
  ModelParser(const char *filePath);
  ~ModelParser();

  int GetIndexCount() const;
  int GetVertexCount() const;
  int GetFaceCount() const;
  Vertex *GetVertexData() const;
  Face *GetFaceData() const;
  
private:
  Vertex *vertex_;
  int vertexCount_;
  Face *face_;
  int faceCount_;
};

#endif /* defined(__MultiSampling__ModelParser__) */
