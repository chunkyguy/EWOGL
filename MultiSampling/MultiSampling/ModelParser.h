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

///***/
//template <typename IN, typename OUT>
//OUT *Serialize(OUT *buffer, 				/* output buffer*/
//              const IN *array,			/* array of data to be serialized */
//              const size_t size)	/* size of array */
//{
//  OUT *bptr = buffer;
//  size_t offset = sizeof(IN);
//  for (int i = 0; i < size; ++i) {
//    memcpy(buffer + (offset * i), array[i].data, offset);
//  }
//  return bptr;
//}

#endif /* defined(__MultiSampling__ModelParser__) */
