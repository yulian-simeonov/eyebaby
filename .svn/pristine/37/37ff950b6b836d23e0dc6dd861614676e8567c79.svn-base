//
//  FlashCell.m
//  EyeBaby
//
//  Created by     on 11/17/13.
//
//

#import "FlashCell.h"
#import "iOSCameraSettingViewController.h"

@implementation FlashCell

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

-(void)SetFlashInfo:(iOSCameraSettingViewController*)parent FlashOn:(BOOL)turnOn Brightness:(float)brightness
{
    m_parent = parent;
    [m_slider setValue:brightness];
    [m_switch setOn:turnOn];
    if (m_switch.on)
        [m_slider setEnabled:YES];
    else
        [m_slider setEnabled:NO];
}

-(IBAction)OnChangeEvent:(id)sender
{
    if (m_switch.on)
        [m_slider setEnabled:YES];
    else
        [m_slider setEnabled:NO];
    [m_parent SetFlashInfo:m_switch.on brightness:m_slider.value];
}

-(void)SetEnable:(BOOL)enable
{
    [m_slider setEnabled:enable];
    [m_switch setEnabled:enable];
}
@end
