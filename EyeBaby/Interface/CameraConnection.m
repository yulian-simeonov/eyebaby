//
//  CameraConnection.m
//  EyeBaby
//

#import "CameraConnection.h"
#import "Registry.h"

#include "Orantek.h"

enum
{
    SECTION_QUALITY,
    SECTION_ENCODING,
    SECTION_RTSP_TRANSPORT,
    
    SECTION_COUNT
};


enum
{
    PARAM_TCP,
    PARAM_UDP
};

@implementation CameraConnection

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = OSTR_PAGE_CONNECTION;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_RTSP_TRANSPORT: return 2;
        case SECTION_QUALITY: return 3;
        case SECTION_ENCODING: return Orantek_GetNumStreamTypes();
        default: return 0;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {            
        case SECTION_QUALITY:
            return OSTR_SECTION_CONNECTION_QUALITY;
            
        case SECTION_ENCODING:
            return OSTR_SECTION_CONNECTION_ENCODING;
     
        case SECTION_RTSP_TRANSPORT:
            return OSTR_SECTION_CONNECTION_TRANSPORT;

        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    NSString* pString;
    int n;
    
    NSString* cam_id = [m_pCamera getUniversalID];
    
    switch ([indexPath indexAtPosition:0])
    {
        case SECTION_RTSP_TRANSPORT:
            switch ([indexPath indexAtPosition:1])
            {
                case PARAM_UDP:
                {
                    pString = [Registry camera:cam_id getKeyString:OSTR_REGKEY_RTSP_TRANSPORT defaultVal:OSTR_REGKEY_RTSP_TRANSPORT_DEFAULT];
                                        
                    cell = [TableUtils cellTick:tableView caption:OSTR_PARAM_CONNECTION_UDP selected:[pString isEqualToString:OSTR_REGKEY_RTSP_TRANSPORT_UDP]];
                    break;
                }
                    
                case PARAM_TCP:
                {
                    pString = [Registry camera:cam_id getKeyString:OSTR_REGKEY_RTSP_TRANSPORT defaultVal:OSTR_REGKEY_RTSP_TRANSPORT_DEFAULT];
                    
                    cell = [TableUtils cellTick:tableView caption:OSTR_PARAM_CONNECTION_TCP selected:[pString isEqualToString:OSTR_REGKEY_RTSP_TRANSPORT_TCP]];
                    break;        
                }
            }
            
            break;
            
        case SECTION_QUALITY:
        {
            n = [Registry camera:cam_id getKeyInt:OSTR_REGKEY_STREAM_INDEX defaultVal:OSTR_REGKEY_STREAM_INDEX_DEFAULT];
            
            NSString* caption = OSTR_FIXME;
 
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    caption = OSTR_PARAM_QUALITY_HIGH_DEF;
                    break; 
                    
                case 1:
                    caption = OSTR_PARAM_QUALITY_STANDARD;
                    break; 
                    
                case 2:
                    caption = OSTR_PARAM_QUALITY_MOBILE;
                    break; 
            }
            
            cell = [TableUtils cellTick:tableView caption:caption selected:([indexPath indexAtPosition:1] == n)];
            
            break;
        }
            
        case SECTION_ENCODING:
        {
            const struct ORANTEK_STREAM_INFO* pStreamInfo;
            BOOL bSelected;
            
            // Get information about the stream...
            pStreamInfo = Orantek_GetStreamInfoForIndex([indexPath indexAtPosition:1]);
            if (!pStreamInfo) break;
            if (!pStreamInfo->title) break;
            
            // Get selected encoding...
            pString = [Registry camera:cam_id getKeyString:OSTR_REGKEY_STREAM_ENCODING defaultVal:OSTR_REGKEY_STREAM_ENCODING_DEFAULT];
            
            // Is it the same?
            bSelected = !strcmp(pStreamInfo->codec_name, [pString cStringUsingEncoding:NSASCIIStringEncoding]);
            
            // Create the cell... 
            cell = [TableUtils cellTick:tableView caption:[NSString stringWithCString:pStreamInfo->title encoding:NSUTF8StringEncoding] selected:bSelected];
            
            break;
        }
    }
    
    if (cell == nil)
    {
        cell = [TableUtils cellInfo:tableView caption:OSTR_FIXME text:nil];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cam_id = [m_pCamera getUniversalID];
    
    switch ([indexPath indexAtPosition:0])
    {
        case SECTION_RTSP_TRANSPORT:
            switch ([indexPath indexAtPosition:1])
            {
                case PARAM_TCP:
                    [Registry camera:cam_id setKeyString:OSTR_REGKEY_RTSP_TRANSPORT withValue:OSTR_REGKEY_RTSP_TRANSPORT_TCP];
                    [self.tableView reloadData];
                    break;
                    
                case PARAM_UDP:
                    [Registry camera:cam_id setKeyString:OSTR_REGKEY_RTSP_TRANSPORT withValue:OSTR_REGKEY_RTSP_TRANSPORT_UDP];
                    [self.tableView reloadData];
                    break;
            }
            break;
            
        case SECTION_QUALITY:
        {
            [Registry camera:cam_id setKeyInt:OSTR_REGKEY_STREAM_INDEX withValue:[indexPath indexAtPosition:1]];
            [self.tableView reloadData];
            break;
        }
            
        case SECTION_ENCODING:
        {
            const struct ORANTEK_STREAM_INFO* pStreamInfo;
            
            // Get information about the stream...
            pStreamInfo = Orantek_GetStreamInfoForIndex([indexPath indexAtPosition:1]);
            if (!pStreamInfo) break;
            if (!pStreamInfo->title) break;
            
            NSString* encoding = [NSString stringWithCString:pStreamInfo->codec_name encoding:NSASCIIStringEncoding];
            
            [Registry camera:cam_id setKeyString:OSTR_REGKEY_STREAM_ENCODING withValue:encoding];
            
            [self.tableView reloadData];
            break;
        }
    }
}

@end
