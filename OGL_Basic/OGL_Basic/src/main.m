//
//  main.m
//  OGL_Basic
//
//  Created by Sid on 21/08/13.
//  Copyright (c) 2013 whackylabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

// How many times a second to refresh the screen
#define kRenderingFrequency 60.0

// For setting up perspective, define near, far, and angle of view
#define kZNear			0.01
#define kZFar			1000.0
#define kFieldOfView	45.0

// Macros
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

/**************************************************************************************************************
 *	MARK:	App
 ***************************************************************************************************************/
@interface AppView : UIView <UIApplicationDelegate> {
	// The pixel dimensions of the backbuffer
	GLint backingWidth_;
	GLint backingHeight_;
	
	EAGLContext *context_;
	GLuint viewRenderbuffer_, viewFramebuffer_;
	GLuint depthRenderbuffer_;
	NSTimer *animationTimer_;
	NSTimeInterval animationInterval_;
	
	BOOL setup_;
}
-(void)startAnimation;
-(void)stopAnimation;
-(void)drawView;
@end

@implementation AppView
+ (Class) layerClass {
	return [CAEAGLLayer class];
}

-(id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	NSAssert(self, @"Unable to init AppView");
	
	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
	
	// Configure it so that it is opaque, does not retain the contents of the backbuffer when displayed, and uses RGBA8888 color.
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
									nil];
	
	// Create our EAGLContext, and if successful make it current and create our framebuffer.
	context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	NSAssert(context_, @"Creating context failed");
	
	BOOL status = [EAGLContext setCurrentContext:context_];
	NSAssert(status, @"Setting current context failed");
	
	status = [self createFramebuffer];
	NSAssert(status, @"Creating framebuffer failed");
	
	// Default the animation interval to 1/60th of a second.
	animationInterval_ = 1.0 / kRenderingFrequency;

	return self;
}

- (void)dealloc {
	[self stopAnimation];
	
	if([EAGLContext currentContext] == context_)	{
		[EAGLContext setCurrentContext:nil];
	}
	
	[context_ release];
	context_ = nil;
	
    [super dealloc];
}

// Draw lifecycle
// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews {
	[EAGLContext setCurrentContext:context_];
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self drawView];
}

- (BOOL)createFramebuffer
{
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer_);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer_);
	NSAssert(viewFramebuffer_, @"Unable to create framebuffer");

	glGenRenderbuffersOES(1, &viewRenderbuffer_);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer_);
	NSAssert(viewRenderbuffer_, @"Unable to create renderbuffer");

	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen whereever the layer is (which corresponds with our view).
	BOOL status = [context_ renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	NSAssert(status, @"Unable to get renderbuffer storage");
	
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer_);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth_);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight_);
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &depthRenderbuffer_);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer_);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth_, backingHeight_);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer_);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer {
	glDeleteFramebuffersOES(1, &viewFramebuffer_);
	viewFramebuffer_ = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer_);
	viewRenderbuffer_ = 0;
	
	if(depthRenderbuffer_)	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer_);
		depthRenderbuffer_ = 0;
	}
}

- (void)startAnimation {
	animationTimer_ = [NSTimer scheduledTimerWithTimeInterval:animationInterval_ target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}

- (void)stopAnimation {
	[animationTimer_ invalidate];
	animationTimer_ = nil;
}

- (void)setAnimationInterval:(NSTimeInterval)interval {
	animationInterval_ = interval;
	
	if(animationTimer_)	{
		[self stopAnimation];
		[self startAnimation];
	}
}

// Updates the OpenGL view when the timer fires
- (void)drawView {
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context_];
	
	// If our drawing delegate needs to have the view setup, then call -setupView: and flag that it won't need to be called again.
	if(!setup_)
	{
		[self setup];
		setup_ = YES;
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer_);
	
	[self render];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer_);
	[context_ presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	GLenum err = glGetError();
	if(err)
		NSLog(@"%x error", err);
}

-(void) setup {
	
}

-(void) render {
	glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

@end

/**************************************************************************************************************
 *	MARK:	App
 ***************************************************************************************************************/
@interface App : UIResponder <UIApplicationDelegate> {
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AppView *mainview;
@end

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
