//
//  EncoderDemoViewController.m
//  Encoder Demo
//
//  Created by Geraint Davies on 11/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "VideoCaptureViewController.h"
#import "AppDelegate.h"

@implementation VideoCaptureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_connections = [[NSMutableArray alloc] init];
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket enableBroadcast:YES error:nil];
    
    tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [tcpSocket acceptOnPort:9096 error:nil];
    
    m_cameraServer = [[CameraServer alloc] init];
}

-(void)dealloc
{
    [super dealloc];
    [m_cameraServer release];
    [tcpSocket release];
    [udpSocket release];
    [m_connections release];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [JSWaiter ShowWaiter:self title:@"Starting up . . ." type:0];
    cameraPos = AVCaptureDevicePositionFront;
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(InitCameraAndSocket) userInfo:nil repeats:NO];
    m_bSignaling = true;
}

-(void)viewDidDisappear:(BOOL)animated
{
    m_bSignaling = false;
    if (m_cameraServer)
        [m_cameraServer shutdown];
}

-(void)InitCameraAndSocket
{
    [m_cameraServer startup:cameraPos];
    [self startPreview];
    [self SetflashBrightness:0.5f];
    [self SendServerData];
    [JSWaiter HideWaiter];
    
    if (m_cameraServer->m_serverManager->m_bRunning)
    {
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(Signaling) userInfo:nil repeats:NO];
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is not the most beautiful animation...
    AVCaptureVideoPreviewLayer* preview = [m_cameraServer getPreviewLayer];
    preview.frame = self.cameraView.bounds;
    if ([preview respondsToSelector:@selector(connection)])
    {
        if ([preview.connection isVideoOrientationSupported])
            [preview.connection setVideoOrientation:toInterfaceOrientation];
    }
}

- (void) startPreview
{
    AVCaptureVideoPreviewLayer* preview = [m_cameraServer getPreviewLayer];
    [preview removeFromSuperlayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:UIInterfaceOrientationPortrait];
    
    [self.cameraView.layer addSublayer:preview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)Signaling
{
    NSString* serverUrl = [m_cameraServer getURL];
    if (serverUrl)
        [self Broadcast:@"My iPad" IPAddress:serverUrl];
    if (m_bSignaling)
        [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(Signaling) userInfo:nil repeats:NO];
}

-(void)Broadcast:(NSString*)name IPAddress:(NSString*)ipAddr
{
    //Header Making
    uint32_t magic = htonl(0x01010000);
    uint16_t type = htons(0x0081);
    Byte header[32];
    memset(header, 0x00, 32);
    memcpy(header, &magic, sizeof(uint32_t));
    memcpy(header + sizeof(uint32_t), &type, sizeof(uint16_t));
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    uint16_t length;
    uint16_t modelType = htons(0x0085);
    NSString* strModelName = @"iOS device";
    
    uint16_t nameType = htons(0x0089);
    
    uint16_t ipType = htons(0x0101);
    
    int bufSize = sizeof(uint16_t) * 6 + strModelName.length + name.length + ipAddr.length + 32;
    char* pktBody = (char*)malloc(bufSize);
    
    memcpy(pktBody, header, 32); pktBody += 32;
    
    // Body
    memcpy(pktBody, &modelType, sizeof(uint16_t)); pktBody += sizeof(uint16_t);
    length = htons((uint16_t)strModelName.length);
    memcpy(pktBody, &length, sizeof(uint16_t)); pktBody += sizeof(uint16_t);
    memcpy(pktBody, [strModelName UTF8String], strModelName.length); pktBody += strModelName.length;
    
    memcpy(pktBody, &nameType, sizeof(uint16_t)); pktBody += sizeof(uint16_t);
    length = htons((uint16_t)name.length);
    memcpy(pktBody, &length, sizeof(uint16_t)); pktBody += sizeof(uint16_t);
    memcpy(pktBody, [name UTF8String], name.length); pktBody += name.length;
    
    memcpy(pktBody, &ipType, sizeof(uint16_t)); pktBody += sizeof(uint16_t);
    length = htons((uint16_t)ipAddr.length);
    memcpy(pktBody, &length, sizeof(uint16_t)); pktBody += sizeof(uint16_t);
    memcpy(pktBody, [ipAddr UTF8String], ipAddr.length); pktBody += ipAddr.length;
    
    pktBody -= bufSize;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    [udpSocket sendData:[NSData dataWithBytes:pktBody length:bufSize] toHost:@"255.255.255.255" port:33360 withTimeout:0.2f tag:1];
    free(pktBody);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UIView* sub in self.view.subviews)
        [sub setHidden:NO];
}

-(IBAction)OnHide:(id)sender
{
    for(UIView* sub in self.view.subviews)
        [sub setHidden:YES];
}

-(IBAction)OnStop:(id)sender
{
   [[[[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to stop the baby station?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	// This method is executed on the socketQueue (not the main thread)
    @synchronized(m_connections)
    {
        [m_connections addObject:newSocket];
    }
    [self SendServerData];
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
}

-(void)SendServerData
{
    for(GCDAsyncSocket* socket in m_connections)
    {
        NSDictionary* sendData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[[UIDevice currentDevice] batteryLevel]], @"Battery Percentage",
                                  [NSNumber numberWithInt:[[UIDevice currentDevice] batteryState]], @"Server connected to Power",
                                  [NSNumber numberWithInt:cameraPos], @"Camera",
                                  [NSNumber numberWithFloat:[UIScreen mainScreen].brightness], @"Screen Brightness",
                                  [NSNumber numberWithInt:m_cameraServer->dev.torchMode], @"Flash Light",
                                  [NSNumber numberWithFloat:m_cameraServer->dev.torchLevel], @"Flash Brightness",
                                  nil];
        [socket writeData:[APP GetDataFromDic:sendData] withTimeout:5 tag:0];
    }
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"disconnected");
    @synchronized(m_connections)
    {
        [m_connections removeObject:sock];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"data was sent");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSDictionary* dic = [APP GetDicFromData:data];
    if (!dic)
        return;
    
    if([dic.allKeys containsObject:@"CameraPos"])
    {
        if ([[dic valueForKey:@"CameraPos"] isEqualToString:@"front"])
            cameraPos = AVCaptureDevicePositionFront;
        else if ([[dic valueForKey:@"CameraPos"] isEqualToString:@"back"])
            cameraPos = AVCaptureDevicePositionBack;
        [self performSelectorOnMainThread:@selector(setCameraType) withObject:Nil waitUntilDone:NO];
    }
    else if ([[dic allKeys] containsObject:@"ScreenBrightness"])
    {
        [[UIScreen mainScreen] setBrightness:[[dic valueForKey:@"ScreenBrightness"] floatValue]];
    }
    else if ([[dic allKeys] containsObject:@"flash"])
    {
        if ([[dic valueForKey:@"flash"] isEqualToString:@"on"])
        {
            [self SetflashBrightness:[[dic valueForKey:@"FlashBrightness"] floatValue]];
        }
        else
            [self toggleFlashlight:NO];
    }
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)toggleFlashlight:(BOOL)turnOn
{
    AVCaptureDevice* device = m_cameraServer->dev;
    if ([device hasTorch])
    {
        if ([device lockForConfiguration:nil])
        {
            if (device.torchMode == AVCaptureTorchModeOff && turnOn)
            {
                if ([device isTorchModeSupported:AVCaptureTorchModeOn])
                    [device setTorchMode:AVCaptureTorchModeOn];
            }
            else if (device.torchMode == AVCaptureTorchModeOn && !turnOn)
            {
                if ([device isTorchModeSupported:AVCaptureTorchModeOff])
                    [device setTorchMode:AVCaptureTorchModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

-(void)SetflashBrightness:(float)val
{
    if (val == 0)
        return;
    AVCaptureDevice* device = m_cameraServer->dev;
    if ([device hasTorch])
    {
        if ([device lockForConfiguration:nil])
        {
            if ([device isTorchModeSupported:AVCaptureTorchModeOn])
                [device setTorchModeOnWithLevel:val error:nil];
            [device unlockForConfiguration];
        }
    }
}

-(IBAction)OnChangeCamera:(id)sender
{
    if (cameraPos == AVCaptureDevicePositionFront)
        cameraPos = AVCaptureDevicePositionBack;
    else
        cameraPos = AVCaptureDevicePositionFront;
    [self setCameraType];
}

-(void)setCameraType
{
    [m_cameraServer shutdown];
    if (cameraPos == AVCaptureDevicePositionBack)
    {
        [btn_camera setTitle:@"Use Front Camera" forState:UIControlStateNormal];
    }
    else
    {
        [btn_camera setTitle:@"Use Back Camera" forState:UIControlStateNormal];
    }
    [JSWaiter ShowWaiter:self title:@"Changing Camera . . ." type:0];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(InitCameraAndSocket) userInfo:nil repeats:NO];
}
@end