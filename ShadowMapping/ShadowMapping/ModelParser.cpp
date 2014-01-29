//
//  ModelParser.cpp
//  MultiSampling
//
//  Created by Sid on 24/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#include "ModelParser.h"

#include <cstdio>
#include <iostream>

/** Read file word by word
 * @return Pointer to the word. Good for chaining
 */
namespace {
  char *read_word(char *word, FILE *file)
  {
    char *wptr = word;
    for (int ch = fgetc(file); ch != EOF && !isspace(ch); ch = fgetc(file)) {
      *word++ = ch;
    }
    *word++ = '\0';
    return wptr;
  }
}

ModelParser::ModelParser(const char *filePath) :
vertex_(NULL),
vertexCount_(0),
face_(NULL),
faceCount_(0)
{
  /*open file*/
  int ch;
  FILE *file = fopen(filePath, "r");
  assert(file);
  
  /*count number of vertices and faces*/
  while ((ch = fgetc(file)) != EOF) {
    if (ch == 'v') {
      vertexCount_++;
    } else if (ch == 'f') {
      faceCount_++;
    }
  }
  
  rewind(file);
  
  /* Parse data */
  vertex_ = new Vertex[vertexCount_];
  face_ = new Face[faceCount_];
  
  char word[256];
  int vertexi = 0;
  int facei = 0;
  
  while (!feof(file) && read_word(word, file)) {
    if (strcmp(word, "v") == 0) {
      vertex_[vertexi].position = GLKVector3Make(atof(read_word(word, file)), atof(read_word(word, file)), atof(read_word(word, file)));
      vertex_[vertexi].normal = GLKVector3Make(0.0f, 0.0f, 0.0f);
      vertexi++;
    } else if (strcmp(word, "f") == 0) {
      face_[facei].va = atoi(read_word(word, file)) - 1;
      face_[facei].vb = atoi(read_word(word, file)) - 1;
      face_[facei].vc = atoi(read_word(word, file)) - 1;
      facei++;
    }
  }
  
  fclose(file);
  
  /* Calculate normals for each face. */
  for (int i = 0; i < faceCount_; ++i) {
    Face f = face_[i];
    Vertex a = vertex_[f.va];
    Vertex b = vertex_[f.vb];
    Vertex c = vertex_[f.vc];
    
    GLKVector3 ab = GLKVector3Subtract(b.position, a.position);
    GLKVector3 ac = GLKVector3Subtract(c.position, a.position);
    GLKVector3 normal = GLKVector3CrossProduct(ab, ac);
    
    vertex_[f.va].normal = GLKVector3Add(a.normal, normal);
    vertex_[f.vb].normal = GLKVector3Add(b.normal, normal);
    vertex_[f.vc].normal = GLKVector3Add(c.normal, normal);
  }
  
  /* normalize */
  for (int i = 0; i < vertexCount_; ++i) {
    vertex_[i].normal = GLKVector3Normalize(vertex_[i].normal);
  }
}

ModelParser::~ModelParser()
{
  delete [] vertex_;
  delete [] face_;
}

int ModelParser::GetIndexCount() const
{
  return faceCount_ * 3;
}

int ModelParser::GetVertexCount() const
{
  return vertexCount_;
}

int ModelParser::GetFaceCount() const
{
  return faceCount_;
}

Vertex *ModelParser::GetVertexData() const
{
  return vertex_;
}

Face *ModelParser::GetFaceData() const
{
  return face_;
}

