//
//  CameraPropertiesMenu.m
//  EyeBaby
//

#import "CameraPropertiesMenu.h"

#import "CameraLabels.h"
#import "CameraWireless.h"
#import "CameraPicture.h"
#import "CameraAudio.h"
#import "CameraConnection.h"
#import "CameraAdvanced.h"

enum
{
    PARAM_SETTINGS_LABELS,
    PARAM_SETTINGS_WIRELESS,
    PARAM_SETTINGS_PICTURE,
    PARAM_SETTINGS_AUDIO,
    PARAM_SETTINGS_CONNECTION,
    PARAM_SETTINGS_ADVANCED,
    
    NUM_SETTINGS_PARAMS
};

@implementation CameraPropertiesMenu

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:OSTR_MENU_CAMERA_SETTINGS];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_SETTINGS_PARAMS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    // Configure the cell...
    switch ([indexPath indexAtPosition:1])
    {
        case PARAM_SETTINGS_LABELS:
            cell = [TableUtils cellLink:tableView caption:OSTR_PAGE_LABELS detail:nil];
            break;
            
        case PARAM_SETTINGS_WIRELESS:
            cell = [TableUtils cellLink:tableView caption:OSTR_PAGE_WIRELESS detail:nil];
            break;
            
        case PARAM_SETTINGS_PICTURE:
            cell = [TableUtils cellLink:tableView caption:OSTR_PAGE_PICTURE detail:nil];
            break;
            
        case PARAM_SETTINGS_AUDIO:
            cell = [TableUtils cellLink:tableView caption:OSTR_PAGE_AUDIO detail:nil];
            break;
            
        case PARAM_SETTINGS_CONNECTION:
            cell = [TableUtils cellLink:tableView caption:OSTR_PAGE_CONNECTION detail:nil];
            break;
            
        case PARAM_SETTINGS_ADVANCED:
            cell = [TableUtils cellLink:tableView caption:OSTR_PAGE_ADVANCED detail:nil];
            break;
    }
    
    if (cell == nil)
    {
        cell = [TableUtils cellInfo:tableView caption:@"???" text:@"???"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath indexAtPosition:1])
    {
        case PARAM_SETTINGS_LABELS:
        {
            CameraLabels* detailViewController = [[CameraLabels alloc] initWithCam:m_pCamera];
            
            if ([detailViewController initPage])
            {
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            else
            {
                [self messageBoxConnectError];
            }
            
            break;
        }
            
        case PARAM_SETTINGS_WIRELESS:
        {
            CameraWireless* detailViewController = [[CameraWireless alloc] initWithCam:m_pCamera];
            
            if ([detailViewController initPage])
            {
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            else
            {
                [self messageBoxConnectError];
            }
            
            break;
        }
            
        case PARAM_SETTINGS_PICTURE:
        {
            CameraPicture* detailViewController = [[CameraPicture alloc] initWithCam:m_pCamera];
            
            if ([detailViewController initPage])
            {
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            else
            {
                [self messageBoxConnectError];
            }
            
            break;
        }
            
        case PARAM_SETTINGS_AUDIO:
        {
            CameraAudio* detailViewController = [[CameraAudio alloc] initWithCam:m_pCamera];
            
            if ([detailViewController initPage])
            {
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            else
            {
                [self messageBoxConnectError];
            }
            
            break;
        }
            
        case PARAM_SETTINGS_CONNECTION:
        {
            CameraConnection* detailViewController = [[CameraConnection alloc] initWithCam:m_pCamera];
            

            [self.navigationController pushViewController:detailViewController animated:YES];
            
            break;
        }
            
        case PARAM_SETTINGS_ADVANCED:
        {
            CameraAdvanced* detailViewController = [[CameraAdvanced alloc] initWithCam:m_pCamera];
            
            if ([detailViewController initPage])
            {
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            else
            {
                [self messageBoxConnectError];
            }
            
            break;
        }
    }
}

@end
