//
//  FlashCell.h
//  EyeBaby
//
//  Created by     on 11/17/13.
//
//

#import <UIKit/UIKit.h>
@class iOSCameraSettingViewController;

@interface FlashCell : UITableViewCell
{
    IBOutlet UISlider* m_slider;
    IBOutlet UISwitch* m_switch;
    iOSCameraSettingViewController* m_parent;
}
-(void)SetFlashInfo:(iOSCameraSettingViewController*)parent FlashOn:(BOOL)turnOn Brightness:(float)brightness;
-(void)SetEnable:(BOOL)enable;
@end
