//
//  EncoderDemoViewController.h
//  Encoder Demo
//
//  Created by Geraint Davies on 11/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "CameraServer.h"
#import "JSWaiter.h"
#import "RTSPServerManager.h"

@interface VideoCaptureViewController : UIViewController
{
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *tcpSocket;
    NSMutableArray* m_connections;
    AVCaptureDevicePosition cameraPos;
    IBOutlet UIButton* btn_camera;
    BOOL    m_bSignaling;
    CameraServer* m_cameraServer;
}

@property (strong, nonatomic) IBOutlet UIView *cameraView;

- (void) startPreview;
@end