//
//  iOSCameraSettingViewController.h
//  EyeBaby
//
//  Created by     on 11/17/13.
//
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVCaptureDevice.h"
#import "OrantekCameraProperties.h"
#import "GCDAsyncSocket.h"
#import "TextCell.h"
#import "CameraCell.h"
#import "ScreenBrightnessCell.h"
#import "FlashCell.h"

@interface iOSCameraSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    GCDAsyncSocket *tcpSocket;
    OrantekCameraProperties*    m_pCameraProperties;
    NSDictionary* m_serverInfo;
    IBOutlet UITableView* m_table;
    FlashCell* flashCell;
}
-(void)setCameraProperties:(OrantekCameraProperties*)camera;
-(void)SetCameraPos:(id)sender;
-(void)SetScreenBrightness:(float)value;
-(void)SetFlashInfo:(BOOL)turnOn brightness:(float)value;
@end
