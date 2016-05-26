//
//  DFUViewController.h
//  DFURTSPPlayer
//
//  Created by Bogdan Furdui on 3/7/13.
//  Copyright (c) 2013 Bogdan Furdui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrantekCameraProperties.h"
#import "CameraPropertiesMenu.h"
#import "iOSCameraSettingViewController.h"

@class RTSPPlayer;

@interface MonitorViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    RTSPPlayer *video;
	float lastFrameTime;
    NSString* m_ipAddress;
    OrantekCameraProperties*    m_pCameraProperties;
    
    BOOL        m_runThread;
}
-(void)setCameraProperties:(OrantekCameraProperties*)camera;
-(void)displayNextFrame;
@end
