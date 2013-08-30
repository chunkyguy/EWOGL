//
//  main.h
//  OGL_Basic
//
//  Created by Sid on 23/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#ifndef OGL_Basic_main_h
#define OGL_Basic_main_h

#include "Shader.h"

/**************************************************************************************************************
 *	MARK:	Callbacks + Functions
 ***************************************************************************************************************/
/**
 *	Callback for the
 *
 *	@param	context	The EAGLContext.
 *	@param	layer	The CALayer
 *
 *	@return	TURE on command successful, else FALSE
 */
int AllocateRenderbufferStorage(void *context, void *layer);

/**************************************************************************************************************
 *	MARK:	App
 ***************************************************************************************************************/
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

#import "Framebuffer.h"

@interface AppView : UIView <UIApplicationDelegate> {
	Framebuffer framebuffer_;
	RenderbufferStorage renderbuffer_storage_;
	Program program_;
	CFTimeInterval time_;
	BOOL setup_;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) CADisplayLink *link;

/**
 *	Override this method to support OpenGL commands.
 *
 *	@return	EAGL layer.
 */
+ (Class) layerClass;

/**
 *	Init.
 *
 *	@param	frame	The frame of the main view.
 *
 *	@return	the View capable of rendering OpenGL commands.
 */
-(id) initWithFrame:(CGRect)frame;

/**
 *	Destructor.
 */
- (void)dealloc;

/**
 *	This method is invoked everytime the layout changes.
 *	Recreate the framebuffer with new dimensions.
 */
-(void)layoutSubviews;

/**
 *	Issue the render command.
 */
-(void)render;

/**
 *	Issue the loop command.
 */
-(void) loop;

@end


/**************************************************************************************************************
 *	MARK:	App
 ***************************************************************************************************************/
#import <UIKit/UIKit.h>

@interface App : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AppView *mainview;
@end


/**************************************************************************************************************
 *	MARK:	main
 ***************************************************************************************************************/
int main(int argc, char *argv[]);
#endif
