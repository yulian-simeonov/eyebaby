//
//  GLView.m
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "GLView.h"

@implementation GLView

@synthesize delegate;

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(BOOL)initOpenGL
{    
    // Set up layer...
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat, nil];
    
    // Try OpenGL ES 2.0 context...
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (context == NULL)
    {
        // Try OpenGL ES 1.x context...
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (context == NULL)
        {
            return NO;
        }
    }
    
    // Make the context current...
    if (![EAGLContext setCurrentContext:context])
    {
        return NO;
    }
    
    // Done...
    return YES;
}

-(void)createFramebuffer
{
    glGenFramebuffersOES(1, &viewFrameBuffer);
    glGenRenderbuffersOES(1, &viewRenderBuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFrameBuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderBuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES,viewRenderBuffer);
}

-(void)destroyFramebuffer
{    
    if (viewRenderBuffer != 0)
    {
        glDeleteRenderbuffersOES(1, &viewRenderBuffer);    
        viewRenderBuffer = 0;
    }
    
    if (viewFrameBuffer != 0)
    {
        glDeleteFramebuffersOES(1, &viewFrameBuffer);
        viewFrameBuffer = 0;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if (![self initOpenGL])
        {
            return nil;
        }
    }
    return self;
}

-(void)initView
{
    [EAGLContext setCurrentContext:context];
    [delegate onInitialize:self];
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

-(void)shutdownView
{
    [EAGLContext setCurrentContext:context];
    [delegate onShutdown:self];
}

-(void)drawView
{   
    [EAGLContext setCurrentContext:context];
    [delegate onDisplay:self];    
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

-(void)makeCurrent
{
    [EAGLContext setCurrentContext:context];
}

-(void)layoutSubviews
{    
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [delegate onReshape:self];
    [delegate onDisplay:self];
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

-(void)dealloc
{    
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
}

@end
