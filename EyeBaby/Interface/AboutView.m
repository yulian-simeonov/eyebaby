//
//  AboutView.m
//  EyeBaby
//

#import "AboutView.h"
#import "TableUtils.h"
#import "ffmpeg_utils.h"

enum
{
    SECTION_EYEBABY,
#if CFG_SHOW_FFMPEG
    SECTION_FFMPEG,
#endif
    
    SECTION_COUNT
};

enum
{
    PARAM_EYEBABY_VERSION,
    
    PARAM_EYEBABY_COUNT
};

enum
{
    PARAM_FFMPEG_LICENSE,
    PARAM_FFMPEG_VERSION_AVCODEC,
    PARAM_FFMPEG_VERSION_AVFORMAT,
    PARAM_FFMPEG_VERSION_AVUTIL,
    
    PARAM_FFMPEG_COUNT
};

@implementation AboutView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // FIXME!!!
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Title...
    [self setTitle:OSTR_MENU_ABOUT];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_EYEBABY:
            return PARAM_EYEBABY_COUNT;
            
#if CFG_SHOW_FFMPEG
        case SECTION_FFMPEG:
            return PARAM_FFMPEG_COUNT;
#endif
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch ([indexPath indexAtPosition:0])
    {
        case SECTION_EYEBABY:
            switch ([indexPath indexAtPosition:1])
            {
                case PARAM_EYEBABY_VERSION:
                {
                    NSDictionary* dict = [[NSBundle mainBundle] infoDictionary];
                    cell = [TableUtils
                            cellInfo:tableView
                            caption:OSTR_VERSION
                            text:[NSString stringWithFormat:@"%@ (%@)"
#ifdef DEBUG
                                  @" DEBUG"
#endif
                                  ,
                                  [dict objectForKey:@"CFBundleShortVersionString"],
                                  [dict objectForKey:@"CFBundleVersion"] ]];
                    break;
                }
            }
            break;
 
#if CFG_SHOW_FFMPEG
        case SECTION_FFMPEG:
            switch ([indexPath indexAtPosition:1])
            {
                case PARAM_FFMPEG_LICENSE:
                {
                    NSString* text = [NSString stringWithFormat:@"%s", avutil_license()];
                    
                    cell = [TableUtils cellInfo:tableView caption:OSTR_LICENSE text:text];
                    break;
                }
                    
                case PARAM_FFMPEG_VERSION_AVCODEC:
                {
                    NSString* text = [NSString stringWithFormat:@"%d.%d.%d", LIBAVCODEC_VERSION_MAJOR, LIBAVCODEC_VERSION_MINOR, LIBAVCODEC_VERSION_MICRO];
                    
                    cell = [TableUtils cellInfo:tableView caption:@"Version: avcodec" text:text];
                    break;
                }
                
                case PARAM_FFMPEG_VERSION_AVFORMAT:
                {
                    NSString* text = [NSString stringWithFormat:@"%d.%d.%d", LIBAVFORMAT_VERSION_MAJOR, LIBAVFORMAT_VERSION_MINOR, LIBAVFORMAT_VERSION_MICRO];
                    
                    cell = [TableUtils cellInfo:tableView caption:@"Version: avformat" text:text];
                    break;
                }
                    
                case PARAM_FFMPEG_VERSION_AVUTIL:
                {
                    NSString* text = [NSString stringWithFormat:@"%d.%d.%d", LIBAVUTIL_VERSION_MAJOR, LIBAVUTIL_VERSION_MINOR, LIBAVUTIL_VERSION_MICRO];
                    
                    cell = [TableUtils cellInfo:tableView caption:@"Version: avutil" text:text];
                    break;
                }    
            }
            break;
#endif
    }
    
    
    if (!cell)
    {
        cell = [TableUtils cellInfo:tableView caption:OSTR_FIXME text:OSTR_FIXME];
    }
    
    // Done...
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_EYEBABY:
            return @"eyebaby";
            
#if CFG_SHOW_FFMPEG
        case SECTION_FFMPEG:
            return @"FFmpeg";
#endif
            
        default:
            return OSTR_FIXME;
    }
}

@end
