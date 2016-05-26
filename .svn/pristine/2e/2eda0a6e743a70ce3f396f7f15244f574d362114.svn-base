//
//  CameraAudio.m
//  EyeBaby
//

#import "CameraAudio.h"

enum
{
    PARAM_MICROPHONE_ENABLED,
    PARAM_MICROPHONE_VOLUME,
#if CFG_SHOW_ADVANCED_DETAIL
    PARAM_AUDIO_BITRATE,
#endif
    
    NUM_MICROPHONE_PARAMS
};

@implementation CameraAudio

-(BOOL)initPage
{
    return [m_pCamera getAudioParams];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = OSTR_PAGE_AUDIO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_MICROPHONE_PARAMS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch ([indexPath indexAtPosition:1])
    {
        case PARAM_MICROPHONE_ENABLED:
            cell = [self cellSwitch:tableView caption:OSTR_PARAM_MICROPHONE_ENABLED section:0 index:PARAM_MICROPHONE_ENABLED state:m_pCamera.audioEnabled];
            break;  
            
        case PARAM_MICROPHONE_VOLUME:
            cell = [self cellSlider:tableView caption:OSTR_PARAM_MICROPHONE_VOLUME section:0 index:PARAM_MICROPHONE_VOLUME value:m_pCamera.audioVolume maxvalue:ORANTEK_CAMERA_MAX_VOLUME];
            break;
            
#if CFG_SHOW_ADVANCED_DETAIL
        case PARAM_AUDIO_BITRATE:
            cell = [TableUtils cellInfo:tableView caption:OSTR_PARAM_AUDIO_BITRATE text:[NSString stringWithFormat:@"%i kbps", m_pCamera.audioBitRate]];
            break;
#endif
  
    }
    
    return cell;
}

-(void)onSwitchChange:(BOOL)value section:(NSInteger)section index:(NSInteger)index
{    
    switch (index)
    {
        case PARAM_MICROPHONE_ENABLED:
            m_pCamera.audioEnabled = value;
            [m_pCamera asyncSetAudioParams];
            break;
    }
}

-(void)onSliderChange:(float)value section:(NSInteger)section index:(NSInteger)index
{
    switch (index)
    {
        case PARAM_MICROPHONE_VOLUME:
        {
            // Get volume value...
            int volume = (int)(value * (float) ORANTEK_CAMERA_MAX_VOLUME);
            if (volume < 0) volume = 0;
            if (volume > ORANTEK_CAMERA_MAX_VOLUME) volume = ORANTEK_CAMERA_MAX_VOLUME;
            
            // Set the volume...
            m_pCamera.audioVolume = volume;
            [m_pCamera asyncSetAudioParams];
            
            break;
        }
    }
}

@end
