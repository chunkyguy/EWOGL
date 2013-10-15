//
// Copyright (c) 2013 Adam Petrone adampetrone83@gmail.com
// Copyright (c) 2011 Andreas Krinke andreas.krinke@gmx.de
// Copyright (c) 2009 Mikko Mononen memon@inside.org
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.
//

#pragma once

#define STH_RGBA( r, g, b, a ) (((a&255)<<24) | ((b&255) <<16) | ((g&255)<<8) | r)
#define STH_UINT_FROM_RGBA( i, c ) c[3] = ((i>>24)&255); c[2] = ((i>>16)&255); c[1] = ((i>>8)&255); c[0] = (i&255);

#ifdef __cplusplus
extern "C" {
#endif

/*
	returns: 0 on failure
*/
typedef unsigned int (*fn_generate_texture)(int width, int height, void * pixels);

/*
	update a region of a texture
*/
typedef void (*fn_update_texture)(unsigned int texture_id, int origin_x, int origin_y, int width, int height, void * pixels);

/*
	delete a texture
*/
typedef void (*fn_delete_texture)(unsigned int texture_id);


/*
	texture_id: 		the id of the texture to use when drawing
	data:				interleaved array of vertex data
	uv_offset:			offset in data array to uv coordinates
	color_offset:		offset in data array to color
	stride: 			the stride of the data array: 2*float + 2*float
	vertex_count:		the number of vertices
*/
typedef void (*fn_draw_with_texture)(unsigned int texture_id, void * data, int uv_offset, int color_offset, int stride, int vertex_count);

struct sth_render_callbacks
{
	fn_generate_texture generate_texture;
	fn_update_texture update_texture;
	fn_delete_texture delete_texture;
	
	fn_draw_with_texture draw_with_texture;
};

void sth_set_ccw_triangles(void);

void sth_set_render_callbacks(struct sth_render_callbacks * callbacks);

struct sth_stash* sth_create(int cachew, int cacheh);

int sth_add_font(struct sth_stash* stash, const char* path);
int sth_add_font_from_memory(struct sth_stash* stash, unsigned char* buffer);

int  sth_add_bitmap_font(struct sth_stash* stash, int ascent, int descent, int line_gap);
void sth_add_glyph(struct sth_stash* stash, int idx, unsigned int id, const char* s,  /* @rlyeh: function does not return int */
                  short size, short base, int x, int y, int w, int h,
                  float xoffset, float yoffset, float xadvance);

void sth_begin_draw(struct sth_stash* stash);
void sth_end_draw(struct sth_stash* stash);

void sth_draw_text(struct sth_stash* stash,
				   int idx, float size,
				   float x, float y, unsigned int color, const char* string, float* dx);
	
void sth_dim_text(struct sth_stash* stash, int idx, float size, const char* string,
				  float* minx, float* miny, float* maxx, float* maxy);

void sth_vmetrics(struct sth_stash* stash,
				  int idx, float size,
				  float* ascender, float* descender, float * lineh);

void sth_delete(struct sth_stash* stash);

void sth_reset_internal_data( void );
	
#ifdef __cplusplus
}; // extern "C"
#endif
