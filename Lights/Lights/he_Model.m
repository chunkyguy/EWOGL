//
//  he_Model.m
//  Lights
//
//  Created by Sid on 26/12/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#include "he_Model.h"
#include "he_Shader.h"

/** Count various vertex attributes */
bool file_iterator_count(const char *word, const int wlen, void *m)
{
 /*blank word continue*/
 if (!word || !wlen) {
  return true;
 }
 
 he_Model *model = (he_Model *)m;
 if (strcmp(word, "v") == 0) {
  model->positionc++;
 } else if (strcmp(word, "vt") == 0) {
  model->texcoordc++;
 } else if (strcmp(word, "vn") == 0) {
  model->normalc++;
 } else if (strcmp(word, "f") == 0) {
  model->facec++;
 }
 
 return true;
}

typedef struct {
 he_Model *model;
 /*index of vertex attribute to be filled*/
 int vi, vti, vni, fi;
 int offset;
 enum {V, VT, VN, F} type;
} OBJParser;

 bool file_iterator_fill(const char *word, const int wlen, void *p)
 {
  /*blank word continue*/
  if (!word || !wlen) {
   return true;
  }
  
  OBJParser *parser = (OBJParser *)p;
  if (strcmp(word, "v") == 0) {
   parser->offset = 0;
   parser->vi++;
   parser->type = V;
  } else if (strcmp(word, "vt") == 0) {
   parser->offset = 0;
   parser->vi++;
   parser->type = VT;
  } else if (strcmp(word, "vn") == 0) {
   parser->offset = 0;
   parser->vi++;
   parser->type = VN;
  } else if (strcmp(word, "f") == 0) {
   parser->offset = 0;
   parser->fi++;
   parser->type = F;
  } else if (parser->offset < 3) {
   switch (parser->type) {
    case V:
     parser->model->positiond[parser->vi].v[parser->offset] = atof(word);
     break;
     
    case VT:
     parser->model->positiond[parser->vi].v[parser->offset] = atof(word);
     break;
    
    case VN:
     parser->model->positiond[parser->vi].v[parser->offset] = atof(word);
     break;
    
    case F: {
     GLushort face_val[3];
     sscanf(word, "%hu/%hu/%hu",&face_val[0], &face_val[1], &face_val[2]);
     parser->model->faced[parser->fi].abc[parser->offset].v = face_val[0]-1;
     parser->model->faced[parser->fi].abc[parser->offset].t = face_val[1]-1;
     parser->model->faced[parser->fi].abc[parser->offset].n = face_val[2]-1;
    } break;
   }
   parser->offset++;
  }

 return true;
}

static void clear_model(he_Model *model)
{
 model->positionc = 0;
 model->positiond = NULL;
 model->texcoordc = 0;
 model->texcoordd = NULL;
 model->normalc = 0;
 model->normald = NULL;
 model->facec = 0;
 model->faced = NULL;
}

he_Model *ModelCreate(he_Model *buffer, const he_File *file)
{
 clear_model(buffer);

 FileIterateByWords(file, file_iterator_count, (void *)buffer);
 buffer->positiond = malloc(buffer->positionc * sizeof(GLKVector3));
 buffer->texcoordd = malloc(buffer->texcoordc * sizeof(GLKVector3));
 buffer->normald = malloc(buffer->normalc * sizeof(GLKVector3));
 buffer->faced = malloc(buffer->facec * sizeof(he_Face));
 
 OBJParser parser;
 parser.model = buffer;
 parser.vi = 0;
 parser.vti = 0;
 parser.vni = 0;
 parser.fi = 0;
 FileIterateByWords(file, file_iterator_count, (void *)&parser);

 return buffer;
}


void ModelDestroy(he_Model *model)
{
 if (model->positiond) {
  free(model->positiond);
 }
 if (model->texcoordd) {
  free(model->texcoordd);
 }
 if (model->normald) {
  free(model->normald);
 }
 if (model->faced) {
  free(model->faced);
 }
}

he_Vertex *ModelDrawData(he_Vertex *vdatabuf, const he_Model *model)
{
 /*iterate through each face*/
 for (int f = 0; f < model->facec; f++) {
  he_Face *face = &model->faced[f];
  /*iterate through each vertex*/
  for (int v = 0; v < 3; ++v) {
   if (model->positiond) {
    vdatabuf[f].position = model->positiond[face->abc[v].v];
   }
   if (model->texcoordd) {
    vdatabuf[f].texcoord = model->positiond[face->abc[v].t];
   }
   if (model->normald) {
    vdatabuf[f].normal = model->positiond[face->abc[v].n];
   }
  }
 }
 
 return vdatabuf;
}


static GLKVector3 calculate_normal(const GLKVector3 a, const GLKVector3 b, const GLKVector3 c)
{
 GLKVector3 ab = GLKVector3Subtract(b, a);
 GLKVector3 ac = GLKVector3Subtract(c, a);
 GLKVector3 normal = GLKVector3CrossProduct(ab, ac);
 return GLKVector3Normalize(normal);
}

void CalculateVertexBasedNormals(he_Vertex *vdatabuf, const he_Model *model)
{
 /*iterate through each face*/
 for (int f = 0; f < model->facec; f++) {
  he_Face *face = &model->faced[f];
  GLKVector3 normal = calculate_normal(model->positiond[face->abc[0].v],
                                       model->positiond[face->abc[1].v],
                                       model->positiond[face->abc[2].v]);
  /*iterate through each vertex*/
  for (int v = 0; v < 3; ++v) {
   vdatabuf[f].normal = normal;
  }
 }
}

