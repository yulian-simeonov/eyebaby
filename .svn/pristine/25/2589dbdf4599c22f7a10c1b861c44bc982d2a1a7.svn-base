//
//  CameraView.mm
//  EyeBaby
//

#import "OGLUtils.h"
#include "glutils.h"

#import "CameraView.h"
#import "CameraPropertiesMenu.h"
#import "Registry.h"
#import "Config.h"

#define ACTIVITY_VIEW_SIZE              128
#define ACTIVITY_VIEW_LABEL_HEIGHT      64

#define WAIT_COUNT (2 * 4)      // 2 seconds

//------------------------------------------------------------------------------

@implementation CameraView

//------------------------------------------------------------------------------

-(void)start
{
    if (!m_videoStreamController)
    {
        // Allocate the controller...
        m_videoStreamController = [[VideoStreamController alloc] init];  

        // Set up the stream...
        if (m_pCameraProperties)
        {
            NSString* cam_id = [m_pCameraProperties getUniversalID];
            
            NSString* codec = [Registry camera:cam_id getKeyString:OSTR_REGKEY_STREAM_ENCODING defaultVal:OSTR_REGKEY_STREAM_ENCODING_DEFAULT];
            
            int nStreamNumber = [Registry camera:cam_id getKeyInt:OSTR_REGKEY_STREAM_INDEX defaultVal:OSTR_REGKEY_STREAM_INDEX_DEFAULT];
            
            NSString* transport = [Registry camera:cam_id getKeyString:OSTR_REGKEY_RTSP_TRANSPORT defaultVal:OSTR_REGKEY_RTSP_TRANSPORT_DEFAULT];
            
            NSString* username = [Registry camera:cam_id getKeyString:OSTR_REGKEY_USERNAME defaultVal:OSTR_REGKEY_USERNAME_DEFAULT];
            NSString* password = [Registry camera:cam_id getKeyString:OSTR_REGKEY_PASSWORD defaultVal:OSTR_REGKEY_PASSWORD_DEFAULT];
            
            [m_videoStreamController setStreamInfo:Orantek_GetStreamInfoForName([codec cStringUsingEncoding:NSASCIIStringEncoding])];
            [m_videoStreamController setStreamNumber:nStreamNumber];
            [m_videoStreamController setTransportProtocol:transport];
            [m_videoStreamController setUsername:username password:password];
            [m_videoStreamController setAddress:m_pCameraProperties.ipAddress];
        }
        else
        {
            [m_videoStreamController setStreamInfo:NULL];
        }
        
        // Start the thread...
        [m_videoStreamController start];     
        
        // Display update timer...
        m_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayUpdate)];
        [m_displayLink setFrameInterval:2];
        [m_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];        
    }
}

-(void)stop
{
    if (m_videoStreamController)
    {
        [m_displayLink invalidate];
        m_displayLink = nil;
        
        [m_videoStreamController stop];
        m_videoStreamController = nil;
    }
}

-(void)centerActivityView
{
    CGRect rect = self.view.frame;
    int x, y;
    
    x = (rect.size.width - ACTIVITY_VIEW_SIZE) / 2;
    y = (rect.size.height - ACTIVITY_VIEW_SIZE) / 2;
    rect.origin.x = x;
    rect.origin.y = y;
    rect.size.width = ACTIVITY_VIEW_SIZE;
    rect.size.height = ACTIVITY_VIEW_SIZE;
    
    [m_popupConnecting setFrame:rect];
}

//------------------------------------------------------------------------------
#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        m_nWaitCounter = WAIT_COUNT;
        m_bRotating = NO;
        m_pCameraProperties = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setCameraProperties:(OrantekCameraProperties*)camera
{
    m_pCameraProperties = camera;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    TRACE(@"Received memory warning!");
}

//------------------------------------------------------------------------------
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_bIsActive = NO;

    // Set up the navigation controller...
    UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"14-gear"] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonClicked)];
    self.navigationItem.rightBarButtonItem = btn;

    // OpenGL view...
    m_glView = [[GLView alloc] init];
    m_glView.delegate = self;
    self.view = m_glView;
    
    // Hud view...
    m_popupConnecting = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ACTIVITY_VIEW_SIZE, ACTIVITY_VIEW_SIZE)];
    m_popupConnecting.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    m_popupConnecting.layer.cornerRadius = 10.0f;
    m_popupConnecting.hidden = YES;
    
    // Activity view...
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityView setFrame:CGRectMake(0, 0, ACTIVITY_VIEW_SIZE, ACTIVITY_VIEW_SIZE - (ACTIVITY_VIEW_LABEL_HEIGHT / 3))];
    activityView.layer.cornerRadius = 10.0;
    [activityView startAnimating];
    [m_popupConnecting addSubview:activityView];
    
    // Caption...
    UILabel* caption = [[UILabel alloc] initWithFrame:CGRectMake(0, ACTIVITY_VIEW_SIZE - ACTIVITY_VIEW_LABEL_HEIGHT, ACTIVITY_VIEW_SIZE, ACTIVITY_VIEW_LABEL_HEIGHT)];
    caption.backgroundColor = [UIColor clearColor];
    caption.textColor = [UIColor whiteColor];
    caption.adjustsFontSizeToFitWidth = YES;
    caption.textAlignment = NSTextAlignmentCenter;
    caption.font = [UIFont boldSystemFontOfSize:18.0f];
    caption.text = OSTR_ALERT_CONNECTING;
    [m_popupConnecting addSubview:caption];
    
    [self.view addSubview:m_popupConnecting];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    TRACE(@"viewDidUnload called.");
}

-(void)viewWillAppear:(BOOL)animated
{
    m_bIsActive = YES;
    
    // Initialize the view...
    [m_glView initView];
    
    // Get details from the camera...
    if (m_pCameraProperties)
    {
        [self setTitle:m_pCameraProperties.name];
    }
    
#if CFG_NO_SLEEP
    [UIApplication sharedApplication].idleTimerDisabled = YES; 
#endif
    
    [self start];
    [self centerActivityView];
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    TRACE(@"viewWillDisappear called.");
    
    m_bIsActive = NO;
    
    [m_timer invalidate];
    m_timer = nil;
    
    [self stop];
    
#if CFG_NO_SLEEP
    [UIApplication sharedApplication].idleTimerDisabled = NO;
#endif
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    TRACE(@"viewDidDisappear called.");
    
    // Shutdown the view...
    [m_glView shutdownView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    m_bRotating = YES;
    m_popupConnecting.hidden = YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self centerActivityView];
                  
    if (m_nWaitCounter > WAIT_COUNT)
    {
        m_popupConnecting.hidden = NO;
    }
    
    m_bRotating = NO;
}

//------------------------------------------------------------------------------
#pragma mark - Event handlers

-(void)appEnterBackground
{
    if (m_bIsActive)
    {
        [self stop];
    }
}

-(void)appEnterForeground
{
    if (m_bIsActive)
    {
        [self start];
    }
}

- (void)barButtonClicked
{
    CameraPropertiesMenu* detailViewController = [[CameraPropertiesMenu alloc] initWithCam:m_pCameraProperties];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)onTimer
{
    if (m_bRotating) return;
    
    if (m_nWaitCounter > WAIT_COUNT)
    {
        m_popupConnecting.hidden = NO;
    }
    else
    {
        ++m_nWaitCounter;
    }
}

-(void)onDisplayUpdate
{
    BOOL bRedraw = NO;
    
    // Check stream controller...
    if (!m_videoStreamController) return;
    
    // Grab the next frame, if one is available...
    bRedraw = [m_videoStreamController getNextFrame:&m_Renderer];
    
    // Redraw...
    if (bRedraw)
    {
        // Redraw the view...
        [m_glView drawView];
        
        // Disable the activity view...
        m_nWaitCounter = 0;
        m_popupConnecting.hidden = YES;
    }
}

//------------------------------------------------------------------------------
#pragma mark - GLViewDelegate implementation

-(void)onInitialize:(id)view
{
    NSString* source_vs;
    NSString* source_fs;
    
    source_vs = [OGLUtils loadShader:@"Shader" ext:@"vsh"];
    source_fs = [OGLUtils loadShader:@"Shader" ext:@"fsh"];

    // Initialize the renderer...
    if (!m_Renderer.Initialize([source_vs UTF8String], [source_fs UTF8String]))
    {
        TRACE(@"Failed to initialize renderer.");
    }
}

-(void)onShutdown:(id)view
{
    TRACE("onShutdown called.");
    m_Renderer.Shutdown();
}

-(void)onReshape:(id)view
{
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(void)onDisplay:(id)view
{
    GLfloat width, height;
    
    // Get screen dimensions...
    width = (GLfloat) self.view.frame.size.width;
    height = (GLfloat) self.view.frame.size.height;
    
    // Render...
    m_Renderer.Render(width, height);
}

//------------------------------------------------------------------------------

@end
