//
//  ScreenBrightnessCell.m
//  EyeBaby
//
//  Created by     on 11/17/13.
//
//

#import "ScreenBrightnessCell.h"
#import "iOSCameraSettingViewController.h"

@implementation ScreenBrightnessCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)SetBrightnes:(iOSCameraSettingViewController*)parent brightness:(float)value
{
    m_parent = parent;
    [m_slider setValue:value];
}

-(IBAction)OnValueChanged
{
    [m_parent SetScreenBrightness:m_slider.value];
}
@end
