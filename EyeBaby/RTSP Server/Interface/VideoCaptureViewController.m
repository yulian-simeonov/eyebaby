//
//  EncoderDemoViewController.m
//  Encoder Demo
//
//  Created by Geraint Davies on 11/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "VideoCaptureViewController.h"
#import "CameraServer.h"
#import "RTSPServer.h"

@implementation VideoCaptureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket enableBroadcast:YES error:nil];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(Signaling) userInfo:Nil repeats:NO];
    
    [[CameraServer server] startup];
    [self startPreview];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is not the most beautiful animation...
    AVCaptureVideoPreviewLayer* preview = [[CameraServer server] getPreviewLayer];
    preview.frame = self.cameraView.bounds;
    [[preview connection] setVideoOrientation:toInterfaceOrientation];
}

- (void) startPreview
{
    AVCaptureVideoPreviewLayer* preview = [[CameraServer server] getPreviewLayer];
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
    [self Broadcast:@"iOS device" IPAddress:[RTSPServer getIPAddress]];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(Signaling) userInfo:Nil repeats:NO];
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
    char* pktBody = malloc(bufSize);
    
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
    
    [udpSocket sendData:[NSData dataWithBytes:pktBody length:bufSize] toHost:@"255.255.255.255" port:33360 withTimeout:2 tag:1];
}
@end
