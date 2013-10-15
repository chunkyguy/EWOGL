/* example1.c                                                      */
/*                                                                 */
/* This small program shows how to print a rotated string with the */
/* FreeType 2 library.                                             */
#include "Font.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "std_incl.h"
#include "Utilities.h"
#include "Constants.h"

#define FONT_FREETYPE

#if defined (FONT_FREETYPE)
#include <ft2build.h>
#include FT_FREETYPE_H

Font *CreateFont(Font *font, const char *path) {
 FT_Error error = FT_Init_FreeType( &font->library );              /* initialize library */
 assert(!error);

 error = FT_New_Face( font->library, path, 0, &font->face );/* create face object */
 assert(!error);

 return font;
}

void ReleaseFont(Font *font) {
 FT_Done_Face    ( font->face );
 FT_Done_FreeType( font->library );
 font = NULL;
}

#else
#include "../fontstash/fontstash.h"

Font *CreateFont(Font *font, const char *path, const Vec2i *size) {
 font->stash = sth_create(size->x, size->y);
 font->size = 14.0f;
 font->ID = sth_add_font(font->stash, path);
 return font;
}

void ReleaseFont(Font *font) {
 sth_delete(font->stash);
 font = NULL;
}

#endif
/* EOF */
