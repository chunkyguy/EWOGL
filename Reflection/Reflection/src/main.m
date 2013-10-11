//
//  main.m
//  OGL_Basic
//
//  Created by Sid on 21/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//
#include "std_incl.h"

#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>

#import "main.h"

#include "Loop.h"
#include "Constants.h"

/**************************************************************************************************************
 *	MARK:	Callbacks + Functions
 ***************************************************************************************************************/
bool AllocateRenderbufferStorage(void *context, void *layer) {
	return [(EAGLContext*)context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)layer] ? true: false;
}
/**************************************************************************************************************
 *	MARK:	App
 ***************************************************************************************************************/
@implementation AppView
@synthesize link;

+ (Class) layerClass {
	return [CAEAGLLayer class];
}

-(id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	NSAssert(self, @"Unable to init AppView");
	
	/* Init EAGL */
	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;	
	// Configure it so that it is opaque, does not retain the contents of the backbuffer when displayed, and uses RGBA8888 color.
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
									nil];
	
	/* Create context for rendering OpenGL ES 2*/
	self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
	NSAssert(self.context, @"Creating context failed");
	
	BOOL status = [EAGLContext setCurrentContext:self.context];
	NSAssert(status, @"Setting current context failed");
	
	// Create framebuffer
	[self createFramebuffer];
		
	// Set loop
	time_ = 0.0;
	self.link = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(render)];
	[self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

	return self;
}

- (void)dealloc {
	if(load_)	{
		Unload();
	}
	
	[self destroyFramebuffer];
	
	if([EAGLContext currentContext] == self.context)	{
		[EAGLContext setCurrentContext:nil];
	}
	self.context = nil;
	
    [super dealloc];
}

-(void)layoutSubviews {
	[EAGLContext setCurrentContext:self.context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	
	[self render];
}


- (void)render {
	//init if not already
	if(!load_)	{
		Load();
		load_ = YES;
	}

	//clear framebuffer
	glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer_.buffer);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

	//update
	CFTimeInterval time = self.link.timestamp;
	CFTimeInterval dt = time - time_;
	Update(dt * 1000);
	time_ = time;
	
	//pass the color renderbuffer to EGL
	glBindRenderbuffer(GL_RENDERBUFFER, frame_buffer_.renderbuffer[kRenderbuffer_Color]);
	[self.context presentRenderbuffer:GL_RENDERBUFFER];

	// check for errors
#if defined (TEST_ERR_ANY)
	GLenum err = glGetError();
	NSAssert(!err, @"%x error", err);
#endif
}

/********************************************************************************
 MARK: Framebuffer
 *******************************************************************************/
/**
 *	Create a framebuffer.
 *
 *	@param	renderbuffer_storage	 The color renderbuffer storage callback.
 *
 *	@return	Framebuffer object.
 */
-(void) createFramebuffer {
	// Create a framebuffer
	glGenFramebuffers(1, &(frame_buffer_.buffer));
	glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer_.buffer);
	assert(frame_buffer_.buffer);	/* Unable to create framebuffer */
	
	// Create renderbuffers
	glGenRenderbuffers(kRenderbuffer_Total, frame_buffer_.renderbuffer);

	/* Steps for attaching renderbuffers
		1. Bind renderbuffer.
		2. Allocate storage.
		3. Attach to framebuffer.
	 */

	//	Attach a color renderbuffer
	glBindRenderbuffer(GL_RENDERBUFFER, frame_buffer_.renderbuffer[kRenderbuffer_Color]);
	assert(frame_buffer_.renderbuffer[kRenderbuffer_Color]);
	//	Get storage of color renderbuffer from EGL context
	BOOL status = [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
	assert(status);		/* Unable to get renderbuffer storage */
	//bind color renderbuffer
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, frame_buffer_.renderbuffer[kRenderbuffer_Color]);
	
	//	Get size of color buffer. Should be same every other renderbuffer
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &(frame_buffer_.width));
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &(frame_buffer_.height));
	
	// Attach depth+stencil renderbuffer
	glBindRenderbuffer(GL_RENDERBUFFER, frame_buffer_.renderbuffer[kRenderbuffer_DepthStencil]);
	assert(frame_buffer_.renderbuffer[kRenderbuffer_DepthStencil]);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, frame_buffer_.width, frame_buffer_.height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, frame_buffer_.renderbuffer[kRenderbuffer_DepthStencil]);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, frame_buffer_.renderbuffer[kRenderbuffer_DepthStencil]);

	// check for errors
#if defined (TEST_ERR_FRAMEBUFFER)
	switch (glCheckFramebufferStatus(GL_FRAMEBUFFER)) {
		case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: printf("Framebuffer error:\nany of the framebuffer attachment points are framebuffer incomplete.\n"); assert(0); break;
		case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: printf("Framebuffer error:\nthe framebuffer does not have at least one image attached to it.\n"); assert(0); break;
		case GL_FRAMEBUFFER_UNSUPPORTED: printf("Framebuffer error:\nthe combination of internal formats of the attached images violates an implementation-dependent set of restrictions.\n"); assert(0); break;
		case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS: printf("Framebuffer error:\nframebuffer dimensions error.\n"); assert(0); break;
			//		case GL_FRAMEBUFFER_UNDEFINED: printf("target is the default framebuffer, but the default framebuffer does not exist.\n"); assert(0); break;
			//		case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: printf("the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for any color attachment point(s) named by GL_DRAWBUFFERi.\n"); assert(0); break;
			//		case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER: printf("GL_READ_BUFFER is not GL_NONE and the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for the color attachment point named by GL_READ_BUFFER.\n"); assert(0); break;
			//		case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: printf("the value of GL_RENDERBUFFER_SAMPLES is not the same for all attached renderbuffers; if the value of GL_TEXTURE_SAMPLES is the not same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value	of GL_RENDERBUFFER_SAMPLES does not match the value of GL_TEXTURE_SAMPLES.\n"); assert(0); break;
			//		case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: printf("the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not the same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not GL_TRUE for all attached textures.\n"); assert(0); break;
			//		case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: printf("any framebuffer attachment is layered, and any populated attachment is not layered, or if all populated color attachments are not from textures of the same target.\n"); assert(0); break;
		case GL_FRAMEBUFFER_COMPLETE: printf("Framebuffer ready\n"); break;
	}
#endif
 
	SetUp((GLsizei)frame_buffer_.width, (GLsizei)frame_buffer_.height);
}

/**
 *	Clean up any buffers we have allocated.
 *
 *	@param	frame_buffer	 The reference to framebuffer object.
 */
-(void) destroyFramebuffer {
	glDeleteRenderbuffers(kRenderbuffer_Total, frame_buffer_.renderbuffer);
	glDeleteFramebuffers(1, &(frame_buffer_.buffer));
	
	TearDown();
}

@end

/**************************************************************************************************************
 *	MARK:	App
 ***************************************************************************************************************/
@implementation App
@synthesize window;
@synthesize mainview;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	CGRect frame = [[UIScreen mainScreen] bounds];
	
	self.window = [[[UIWindow alloc] initWithFrame:frame] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];

	self.mainview = [[[AppView alloc] initWithFrame:frame] autorelease];
	[self.window addSubview:self.mainview];
	
    [self.window makeKeyAndVisible];
		
    return YES;
}

-(void) dealloc {
	self.window = nil;
	self.mainview = nil;

	[super dealloc];
}
- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end

/**************************************************************************************************************
 *	MARK:	main
 ***************************************************************************************************************/
int main(int argc, char *argv[]) {
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([App class]));
	}
}
