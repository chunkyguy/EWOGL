//
//  main.m
//  OGL_Basic
//
//  Created by Sid on 21/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "main.h"

#include "Loop.h"
#include "Constants.h"

/**************************************************************************************************************
 *	MARK:	Callbacks + Functions
 ***************************************************************************************************************/
int AllocateRenderbufferStorage(void *context, void *layer) {
	return [(EAGLContext*)context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)layer] ? T: F;
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
	SetUp((GLsizei)frame.size.width, (GLsizei)frame.size.height);
	self.link = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(render)];
	[self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

	return self;
}

- (void)dealloc {
	TearDown();
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
	
	//update
	CFTimeInterval time = self.link.timestamp;
	CFTimeInterval dt = time - time_;
	Update(dt * 1000);
	time_ = time;
	
	//pass the color renderbuffer to EGL
	glBindRenderbuffer(GL_RENDERBUFFER, frame_buffer_.renderbuffer[0]);
	[self.context presentRenderbuffer:GL_RENDERBUFFER];

	// check for errors
	GLenum err = glGetError();
	NSAssert(!err, @"%x error", err);
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
	// Allocate a framebuffer
	glGenFramebuffers(1, &(frame_buffer_.buffer));
	glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer_.buffer);
	assert(frame_buffer_.buffer);	/* Unable to create framebuffer */
	
	// Allocate renderbuffers
	glGenRenderbuffers(2, frame_buffer_.renderbuffer);
	
	//	Attach a color renderbuffer
	glBindRenderbuffer(GL_RENDERBUFFER, frame_buffer_.renderbuffer[0]);
	assert(frame_buffer_.renderbuffer[0]);	/* Unable to create renderbuffer */
	//	Get storage of color renderbuffer from EGL context
	BOOL status = [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
	assert(status);		/* Unable to get renderbuffer storage */
	//bind color renderbuffer
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, frame_buffer_.renderbuffer[0]);
	
	//	Get size of color buffer. Should be same every other renderbuffer
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &(frame_buffer_.width));
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &(frame_buffer_.height));
	
	// Attach depth renderbuffer
	glBindRenderbuffer(GL_RENDERBUFFER, frame_buffer_.renderbuffer[1]);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, frame_buffer_.width, frame_buffer_.height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, frame_buffer_.renderbuffer[1]);
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)	{
		assert(0); /* failed to make complete framebuffer object */
	}
}

/**
 *	Clean up any buffers we have allocated.
 *
 *	@param	frame_buffer	 The reference to framebuffer object.
 */
-(void) destroyFramebuffer {
	glDeleteRenderbuffers(2, frame_buffer_.renderbuffer);
	glDeleteFramebuffers(1, &(frame_buffer_.buffer));
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
