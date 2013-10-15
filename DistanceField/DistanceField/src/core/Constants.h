//
//  Constants.h
//  OGL_Basic
//
//  Created by Sid on 22/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef OGL_Basic_Constants_h
#define OGL_Basic_Constants_h
/*******************************************************************************
 * MARK:	GL Attributes locations
 ******************************************************************************/
#define kAttribFlag(a_Index) 	(0x1 << a_Index)
#define kAttrib_Position	0
#define kAttrib_Normal		1
#define kAttrib_Color		2
#define kAttrib_TexCoords	3
#define kAttrib_Total		4

/*******************************************************************************
 * MARK:	Shader Attributes/Varying/Uniforms strings
 ******************************************************************************/
static const char *AttribNames [] = {
 "a_Position",
 "a_Normal",
 "a_Color",
 "a_TexCoords"
};

#define v_Color 	"v_Color"

#define u_Mvp 		"u_Mvp"
#define u_N 		"u_N"
#define u_Color 	"u_Color"
#define u_Texture	"u_Texture"

/*******************************************************************************
 * MARK:	Buffer constants
*******************************************************************************/
#define kBuffer256			(0x1 << 8)	/* 256 bytes: 	Usage: filenames */
#define kBuffer512			(0x1 << 9)	/* 512 bytes*/
#define kBuffer1K			(0x1 << 10)	/* 1,024 bytes: Usage: paths */
#define kBuffer2K			(0x1 << 11)	/* 2,048 bytes*/
#define kBuffer4K			(0x1 << 12)	/* 4,096 bytes: Usage: shader code */
#define kBuffer8K			(0x1 << 13)	/* 8,192 bytes*/
#define kBuffer16K			(0x1 << 14)	/* 16,384 bytes*/
#define kBuffer32K			(0x1 << 15)	/* 32,768 bytes*/
#define kBuffer64K			(0x1 << 16) /* 65,536 bytes */

/*******************************************************************************
 * MARK:	Test Errors
 * Use only when something new is added
 *******************************************************************************/
#define TEST_ERR_FRAMEBUFFER 	/* Test the framebuffer status*/
#define TEST_ERR_SHADER			/* Test any shader error */
#define TEST_ERR_ANY			/* Test any gl error */

#endif

