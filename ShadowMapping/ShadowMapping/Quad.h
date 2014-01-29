//
//  Quad.h
//  ShadowMapping
//
//  Created by Sid on 29/01/14.
//  Copyright (c) 2014 whackylabs. All rights reserved.
//

#ifndef __ShadowMapping__Quad__
#define __ShadowMapping__Quad__
#include "IGeometry.h"

class Quad : public IGeometry {
public:
  ~Quad();
  bool Init();

  virtual void Update(const unsigned int dt);
  virtual void Draw(const Renderer *renderer) const;
  
private:
  bool init_;
};

#endif /* defined(__ShadowMapping__Quad__) */
