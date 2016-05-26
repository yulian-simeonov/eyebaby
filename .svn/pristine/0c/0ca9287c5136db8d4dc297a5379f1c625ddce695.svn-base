//
//  DFUViewController.m
//  DFURTSPPlayer
//
//  Created by Bogdan Furdui on 3/7/13.
//  Copyright (c) 2013 Bogdan Furdui. All rights reserved.
//

#import "MonitorViewController.h"
#import "RTSPPlayer.h"
#import "JSWaiter.h"

@implementation MonitorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
    }
    
    return self;
}

- (void)dealloc
{
	m_runThread = false;
    [video closeAudio];
    [video release];
	[imageView release];
    imageView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* btn = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                            target:self
                            action:@selector(barButtonClicked)];
    self.navigationItem.rightBarButtonItem = btn;
    
    
    
    [imageView setBackgroundColor:[UIColor blackColor]];
    imageView.transform = CGAffineTransformMakeRotation(-90 * M_PI / 180);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self StartClient];
}

-(void)StartClient
{
    m_runThread = true;
    [imageView setImage:nil];
    [imageView setBackgroundColor:[UIColor blackColor]];
//    [JSWaiter ShowWaiter:self title:@"Connecting . . ." type:0];
//    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(ConnectServer) userInfo:nil repeats:NO];
    [self ConnectServer];
    [self setTitle:m_pCameraProperties.name];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    m_runThread = false;
    if (video)
        [video closeAudio];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is not the most beautiful animation...
//    if (!video)
//        return;
//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
//    {
//        video.outputWidth = 480;
//        video.outputHeight = 320;
//    }
//    else
//    {
//        video.outputWidth = 320;
//        video.outputHeight = 480;
//    }
}

-(void)ConnectServer
{
    video = [[RTSPPlayer alloc] initWithVideo:m_pCameraProperties.ipAddress usesTcp:NO parent:self];
    video.outputWidth = 480;
    video.outputHeight = 320;

    if (video.sourceHeight == 0 && video.sourceWidth == 0)
    {
        [video release];
        video = nil;
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    lastFrameTime = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,
                                             (unsigned long)NULL), ^(void) {
        [self GetBuffer];
    });
//    [JSWaiter HideWaiter];
}

-(void)GetBuffer
{
    while (m_runThread) {
        if (![video stepFrame]) {
            [video closeAudio];
            [video release];
            video = nil;
            [self performSelectorOnMainThread:@selector(Back) withObject:nil waitUntilDone:NO];
            break;
        }
        sleep(0.01f);
    }
}

-(void)Back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)

-(void)displayNextFrame
{
    if (video.currentImage)
        imageView.image = video.currentImage;
}

-(void)setCameraProperties:(OrantekCameraProperties*)camera
{
    m_pCameraProperties = [camera retain];
}

- (void)barButtonClicked
{
    if([m_pCameraProperties.cameraModel isEqualToString:@"iOS device"])
    {
        iOSCameraSettingViewController* vw = [[iOSCameraSettingViewController alloc] initWithNibName:@"iOSCameraSettingViewController" bundle:nil];
        [vw setCameraProperties:m_pCameraProperties];
        [self.navigationController pushViewController:vw animated:YES];
        [vw release];
    }
    else
    {
        CameraPropertiesMenu* detailViewController = [[CameraPropertiesMenu alloc] initWithCam:m_pCameraProperties];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

@end
