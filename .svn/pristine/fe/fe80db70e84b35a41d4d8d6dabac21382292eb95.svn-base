//
//  CameraAdvanced.m
//  EyeBaby
//

#import "CameraAdvanced.h"

enum
{
    PARAM_INFO_CAMERA_MODEL,
    PARAM_INFO_IP_ADDRESS,
    PARAM_INFO_MAC_ADDRESS,
    PARAM_INFO_FIRMWARE,
    
    NUM_INFO_PARAMS
};

@implementation CameraAdvanced

-(BOOL)initPage
{
    return [m_pCamera getFirmwareParams];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = OSTR_PAGE_ADVANCED;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_INFO_PARAMS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch ([indexPath indexAtPosition:1])
    {
        case PARAM_INFO_CAMERA_MODEL:
            cell = [TableUtils cellInfo:tableView caption:OSTR_PARAM_INFO_CAMERA_MODEL text:m_pCamera.cameraModel];
            break;
            
        case PARAM_INFO_IP_ADDRESS:
            cell = [TableUtils cellInfo:tableView caption:OSTR_PARAM_INFO_IP_ADDRESS text:m_pCamera.ipAddress];
            break;
            
        case PARAM_INFO_MAC_ADDRESS:
            cell = [TableUtils cellInfo:tableView caption:OSTR_PARAM_INFO_MAC_ADDRESS text:m_pCamera.macAddress];
            break;
            
        case PARAM_INFO_FIRMWARE:
            cell = [TableUtils cellInfo:tableView caption:OSTR_PARAM_INFO_FIRMWARE text:m_pCamera.firmwareVersion];
            break;
    }
    
    return cell;
}

@end
