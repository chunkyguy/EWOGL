//
//  BitFlag.h
//  Asteroids
//
//  Created by Sid on 17/11/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef Asteroids_BitFlag_h
#define Asteroids_BitFlag_h

/** Convert an index to a bit flag
 And to operatons on the bit flag
 */

typedef unsigned int he_BitFlag;

/** Convert an index i to a bit mask
 @param i The index value (could be index of an array or anything)
 @return The new mask.
 */
#define BF_Mask(i) (0x1 << i)

/** Test whether the index i is set in the bit flag f
 @param f The bitflag
 @param i The index
 @return true if set, else false
 */
#define BF_IsSet(f, i) ((f & BF_Mask(i)) == BF_Mask(i))

/** Set the flag
 @param f the bit flag.
 @param i the index
 @return the new bit flag
 */
#define BF_Set(f, i) (f |= BF_Mask(i))

/** Reset the flag
 @param f the bit flag.
 @param i the index
 @return the new bit flag
 */
#define BF_Reset(f, i) (f &= ~BF_Mask(i))

/** Toggle the flag
 @param f the bit flag.
 @param i the index
 @return the new bit flag
 */
#define BF_Toggle(f, i) (f ^= BF_Mask(i))

/** Clear the flag.
 @return the flag.
 */
#define BF_Clear (f) (f = 0x0)

#endif
