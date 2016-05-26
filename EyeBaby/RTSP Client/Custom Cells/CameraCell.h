//
//  CameraCell.h
//  EyeBaby
//
//  Created by     on 11/17/13.
//
//

#import <UIKit/UIKit.h>
@class iOSCameraSettingViewController;

@interface CameraCell : UITableViewCell
{
    IBOutlet UISegmentedControl* seg_camera;
    iOSCameraSettingViewController* m_parent;
}
-(void)SetCameraValue:(iOSCameraSettingViewController*)parent isFront:(BOOL)front;
@end
