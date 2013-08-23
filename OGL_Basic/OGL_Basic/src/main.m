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
	renderbuffer_storage_.callback = &AllocateRenderbufferStorage;
	renderbuffer_storage_.context = 	self.context;
	renderbuffer_storage_.layer = self.layer;
	
	framebuffer_ = CreateFramebuffer(&renderbuffer_storage_);
	NSAssert(status, @"Creating framebuffer failed");
	
	// Set viewport
	glViewport(0, 0, (GLsizei)frame.size.width, (GLsizei)frame.size.height);
	
	// Load shader
	program_ = CompileShader("Shader.vsh", "Shader.fsh", &BindAttributes);
	
	// Set loop
	time_ = 0.0;
	self.link = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(loop)];
	[self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

	return self;
}

- (void)dealloc {
	DestroyFramebuffer(&framebuffer_);

	if([EAGLContext currentContext] == self.context)	{
		[EAGLContext setCurrentContext:nil];
	}
	self.context = nil;
	
    [super dealloc];
}

-(void)layoutSubviews {
	[EAGLContext setCurrentContext:self.context];
	DestroyFramebuffer(&framebuffer_);
	framebuffer_ = CreateFramebuffer(&renderbuffer_storage_);
	
	[self render];
}

- (void)render {
	//init if not already
	if(!setup_)	{
		Init();
		setup_ = YES;
	}
	
	//clear framebuffer
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer_.buffer);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	//update
	CFTimeInterval time = self.link.timestamp;
	CFTimeInterval dt = time - time_;
	Update(dt * 1000);
	time_ = time;

	// render
	Render(program_);
	
	//pass to EGL
	glBindRenderbuffer(GL_RENDERBUFFER, framebuffer_.renderbuffer[0]);
	[self.context presentRenderbuffer:GL_RENDERBUFFER];
	
	GLenum err = glGetError();
	if(err) {
		NSLog(@"%x error", err);
	}
}

-(void) loop {
	[self render];
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
