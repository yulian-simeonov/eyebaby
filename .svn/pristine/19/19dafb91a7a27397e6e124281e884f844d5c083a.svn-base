//
//  CameraPicture.m
//  EyeBaby
//

#import "CameraPicture.h"

enum
{
    SECTION_PICTURE,
    SECTION_NIGHT_VISION,
    
    NUM_SECTIONS
};

enum
{
    PARAM_PICTURE_FLIP_HORIZONTAL,
    PARAM_PICTURE_FLIP_VERTICAL,
    PARAM_PICTURE_MOONLIGHT_MODE,   
    PARAM_PICTURE_LIGHT_FREQ,
    PARAM_PICTURE_POWER_LIGHT,
    
    NUM_PICTURE_PARAMS
};

enum
{
    PARAM_NIGHTVIS_INFRARED,
    PARAM_NIGHTVIS_BLACKWHITE,
    
    NUM_NIGHTVIS_PARAMS
};

@implementation CameraPicture

-(BOOL)initPage
{
    if (![m_pCamera getVideoParams]) return NO;
    if (![m_pCamera getFlipVideoParams]) return NO;
    if (![m_pCamera getPowerLEDParams]) return NO;
    if (![m_pCamera getNightVisionParams]) return NO;
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = OSTR_PAGE_PICTURE;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_PICTURE:
            return NUM_PICTURE_PARAMS;
            
        case SECTION_NIGHT_VISION:
            return NUM_NIGHTVIS_PARAMS;
            
        default:
            return 0;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_PICTURE:
            return OSTR_SECTION_PICTURE;
            
        case SECTION_NIGHT_VISION:
            return OSTR_SECTION_NIGHT_VISION;
            
        default:
            return OSTR_FIXME;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    // Configure the cell...
    switch ([indexPath indexAtPosition:0])
    {
        case SECTION_PICTURE:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case PARAM_PICTURE_FLIP_HORIZONTAL:
                    cell = [self cellSwitch:tableView caption:OSTR_PARAM_PICTURE_FLIP_HORIZONTAL section:SECTION_PICTURE  index:PARAM_PICTURE_FLIP_HORIZONTAL state:m_pCamera.videoFlipHorizontal];
                    break;
                    
                case PARAM_PICTURE_FLIP_VERTICAL:
                    cell = [self cellSwitch:tableView caption:OSTR_PARAM_PICTURE_FLIP_VERTICAL section:SECTION_PICTURE index:PARAM_PICTURE_FLIP_VERTICAL state:m_pCamera.videoFlipVertical];
                    break;
                    
                case PARAM_PICTURE_MOONLIGHT_MODE:
                    cell = [self cellThreeState:tableView caption:OSTR_PARAM_PICTURE_MOONLIGHT_MODE section:SECTION_PICTURE index:PARAM_PICTURE_MOONLIGHT_MODE value:m_pCamera.videoMoonlightMode];
                    break;

                case PARAM_PICTURE_LIGHT_FREQ:
                    cell = [self cellTwoState:tableView caption:OSTR_PARAM_PICTURE_LIGHT_FREQ section:SECTION_PICTURE index:PARAM_PICTURE_LIGHT_FREQ first:OSTR_LIGHT_50 second:OSTR_LIGHT_60 value:(m_pCamera.videoLightFrequency > 50 ? 1 : 0)];
                    break;
                    
                case PARAM_PICTURE_POWER_LIGHT:
                    cell = [self cellSwitch:tableView caption:OSTR_PARAM_PICTURE_POWER_LIGHT section:SECTION_PICTURE index:PARAM_PICTURE_POWER_LIGHT state:m_pCamera.powerLED];
                    break;
            }
            break;
        }
            
        case SECTION_NIGHT_VISION:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case PARAM_NIGHTVIS_INFRARED:
                    cell = [self cellThreeState:tableView caption:OSTR_PARAM_NIGHTVIS_INFRARED section:SECTION_NIGHT_VISION index:PARAM_NIGHTVIS_INFRARED value:m_pCamera.nightIfraredLED];
                    break;
                    
                case PARAM_NIGHTVIS_BLACKWHITE:
                    cell = [self cellThreeState:tableView caption:OSTR_PARAM_NIGHTVIS_BLACKWHITE section:SECTION_NIGHT_VISION index:PARAM_NIGHTVIS_BLACKWHITE value:m_pCamera.nightBlackWhite];
                    break;
            }
            break;
        }            
    }
    
    return cell;
}

-(void)onSwitchChange:(BOOL)value section:(NSInteger)section index:(NSInteger)index
{
    switch (section)
    {
        case SECTION_PICTURE:
        {
            switch (index)
            {
                case PARAM_PICTURE_FLIP_HORIZONTAL:
                    m_pCamera.videoFlipHorizontal = value;
                    [m_pCamera asyncSetVideoFlip];
                    break;
                    
                case PARAM_PICTURE_FLIP_VERTICAL:
                    m_pCamera.videoFlipVertical = value;
                    [m_pCamera asyncSetVideoFlip];
                    break;
                    
                case PARAM_PICTURE_POWER_LIGHT:
                    m_pCamera.powerLED = value;
                    [m_pCamera asyncSetPowerLED];
                    break;
            }
            break;
        }
    }
}

-(void)onTwoStateChange:(NSInteger)value section:(NSInteger)section index:(NSInteger)index
{
    switch (section)
    {
        case SECTION_PICTURE:
            switch (index)
            {
                case PARAM_PICTURE_LIGHT_FREQ:
                {
                    int freq;
                    
                    if (value == 1) freq = 60;
                    else freq = 50;
                    
                    if (m_pCamera.videoLightFrequency != freq)
                    {
                        m_pCamera.videoLightFrequency = freq;
                        [m_pCamera asyncSetVideoParams];
                    }
                    break;
                }
            }
            break;
    }
}

-(void)onThreeStateChange:(NSInteger)value section:(NSInteger)section index:(NSInteger)index
{
    switch (section)
    {
        case SECTION_PICTURE:
        {
            switch (index)
            {
                case PARAM_PICTURE_MOONLIGHT_MODE:
                    m_pCamera.videoMoonlightMode = (int) value;
                    [m_pCamera asyncSetVideoParams];
                    break;
            }
            break;
        }
            
        case SECTION_NIGHT_VISION:
        {            
            switch (index)
            {
                case PARAM_NIGHTVIS_INFRARED:
                    m_pCamera.nightIfraredLED = (int) value;
                    [m_pCamera asyncSetNightVision];
                    break;
                    
                case PARAM_NIGHTVIS_BLACKWHITE:
                    m_pCamera.nightBlackWhite = (int) value;
                    [m_pCamera asyncSetNightVision];
                    break;
            }
            break;
        }
    }
}

@end
