//
//  CameraCell.m
//  EyeBaby
//
//  Created by     on 11/17/13.
//
//

#import "CameraCell.h"
#import "iOSCameraSettingViewController.h"

@implementation CameraCell

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

-(void)SetCameraValue:(iOSCameraSettingViewController*)parent isFront:(BOOL)front
{
    [seg_camera addTarget:m_parent action:@selector(SetCameraPos:) forControlEvents:UIControlEventValueChanged];
    if (front)
        [seg_camera setSelectedSegmentIndex:0];
    else
        [seg_camera setSelectedSegmentIndex:1];
}
@end
