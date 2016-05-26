//
//  MainMenu.m
//  EyeBaby
//

#import "MainMenu.h"
#import "CameraView.h"
#import "AboutView.h"
#import "TableUtils.h"
#import "Config.h"
#import "MonitorViewController.h"

//------------------------------------------------------------------------------

#define TIMER_SEACH_CAMERA  1.0
#define TIMER_UPDATE_TABLE  0.5

enum
{
    MENU_SECTION_CAMERAS,
    MENU_SECTION_OPTIONS,
    
    MENU_NUM_SECTIONS
};

enum
{
    MENU_OPTIONS_HELP,
    MENU_OPTIONS_ABOUT,
    
    MENU_OPTIONS_NUM_ITEMS
};

//------------------------------------------------------------------------------

@implementation MainMenu

//------------------------------------------------------------------------------
#pragma mark - Camera Search

-(void)onCameraSearchTimer
{  
    if (!m_pCameraSearch) return;

    [m_pCameraSearch sendSearchRequest];
}

-(void)onUpdateTableTimer
{
    if (!m_pCameraSearch) return;
    
    if ([m_pCameraSearch hasChanged])
    {
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:MENU_SECTION_CAMERAS] withRowAnimation:UITableViewRowAnimationNone];
    }    
}

//------------------------------------------------------------------------------

- (void)cameraSearchEnable
{
    TRACE(@"Enabling camera search.");
    
    // Check object state...
    if (!m_pCameraSearch)
    {
        TRACE(@"No camera object!");
        return;
    }
    
    // Clear the list of cameras...
    [m_pCameraSearch clear];
    
    // Signal table view to update itself...
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:MENU_SECTION_CAMERAS] withRowAnimation:UITableViewRowAnimationNone];
    
    // Start camera search timer...
    if (!m_searchTimer)
    {
        m_searchTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_SEACH_CAMERA target:self selector:@selector(onCameraSearchTimer) userInfo:nil repeats:YES];
    }
    
    // Start update table timer...
    if (!m_updateTableTimer)
    {
        m_updateTableTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_UPDATE_TABLE target:self selector:@selector(onUpdateTableTimer) userInfo:nil repeats:YES];        
    }
    
    // Start a search...
    [m_pCameraSearch startListening];
    [m_pCameraSearch sendSearchRequest];    
}

- (void)cameraSearchDisable
{
    TRACE(@"Disabling camera search.");
    
    // Stop listening...
    if (m_pCameraSearch)
    {
        [m_pCameraSearch stopListeningAndWait:NO];
    }
         
    // Terminate table timer...
    if (m_updateTableTimer)
    {
        [m_updateTableTimer invalidate];
        m_updateTableTimer = nil;
    }
    
    // Terminate search timer...
    if (m_searchTimer)
    {
        [m_searchTimer invalidate];
        m_searchTimer = nil;
    }    
}

//------------------------------------------------------------------------------
#pragma mark - View life cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        m_pCameraSearch = nil;
        m_searchTimer = nil;
        m_updateTableTimer = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Title...
    [self setTitle:OSTR_PRODUCT_NAME];

    // Refresh button...
    UIBarButtonItem* btn = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                            target:self
                            action:@selector(refreshTable)];
    self.navigationItem.rightBarButtonItem = btn;
    
    // Camera search...
    m_pCameraSearch = [[OrantekCameraSearch alloc] init];
}

- (void)applicationDidEnterBackground:(id)obj
{
    [self cameraSearchDisable];
}

- (void)applicationWillEnterForeground:(id)obj
{
    [self cameraSearchEnable];
    
    // Clear table selection...
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Enable camera search function...
    [self cameraSearchEnable];
    
    // Observe app events...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove event observation...
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Disable camera search...
    [self cameraSearchDisable];
}

//------------------------------------------------------------------------------
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MENU_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case MENU_SECTION_CAMERAS:
        {
            int count;
            
            count = [m_pCameraSearch count];
            if (count < 1) return 1;
            else return count;            
        }
            
        case MENU_SECTION_OPTIONS:
            return MENU_OPTIONS_NUM_ITEMS;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
        
    // Configure the cell...
    switch ([indexPath indexAtPosition:0])
    {
        case MENU_SECTION_CAMERAS:
        {
            int i = [indexPath indexAtPosition:1];
            
            OrantekCameraProperties* camera;
            
            camera = [m_pCameraSearch get:i];
            if (camera == nil)
            {
                cell = [TableUtils cellSearching:tableView];
            }
            else
            {
                cell = [TableUtils cellLink:tableView caption:camera.name detail:camera.ipAddress];
            }
            
            break;
        }

        case MENU_SECTION_OPTIONS:
            switch ([indexPath indexAtPosition:1])
            {                    
                case MENU_OPTIONS_HELP:
                    cell = [TableUtils cellLink:tableView caption:OSTR_MENU_HELP detail:@""];
                    break;
                    
                case MENU_OPTIONS_ABOUT:
                    cell = [TableUtils cellLink:tableView caption:OSTR_MENU_ABOUT detail:@""];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    // Done...
    return cell;
}

//------------------------------------------------------------------------------
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath indexAtPosition:0])
    {
        case MENU_SECTION_CAMERAS:
        {
            OrantekCameraProperties* camera;
            
            // Locate the camera properties...
            camera = [m_pCameraSearch get:[indexPath indexAtPosition:1]];
            if (camera == nil) return;
            
            // Check that the camera is still alive...
            if (![camera stillConnected])
            {
                [self messageBox:OSTR_ALERT_CAMERA_DISCONNECT_MSG title:OSTR_ALERT_CAMERA_DISCONNECT_TITLE];
                [self refreshTable];
                break;
            }

            // Initialize the detail view controller...
            if ([camera.cameraModel isEqualToString:@"iOS device"])
            {
                MonitorViewController* vw = nil;
                if (IS_IPAD)
                    vw = [[MonitorViewController alloc] initWithNibName:@"MonitorViewController_ipad" bundle:nil];
                else if (IS_IPHONE_4)
                    vw = [[MonitorViewController alloc] initWithNibName:@"MonitorViewController_480h" bundle:nil];
                else
                    vw = [[MonitorViewController alloc] initWithNibName:@"MonitorViewController" bundle:nil];
                
                [vw setCameraProperties:camera];
                [self.navigationController pushViewController:vw animated:YES];
            }
            else
            {
                CameraView *detailViewController;
                detailViewController = [[CameraView alloc] init];
                [detailViewController setCameraProperties:camera];
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            // Done...
            break;
        }
            
        case MENU_SECTION_OPTIONS:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case MENU_OPTIONS_HELP:
                {
#if CFG_HELP_URI_DEVICEID
                    NSString* str_url = [NSString stringWithFormat:@"%@?id=%@", OSTR_URL_HELP, [[UIDevice currentDevice] uniqueIdentifier] ];
#else
                    NSString* str_url = OSTR_URL_HELP;
#endif
                    
                    NSURL* url = [[NSURL alloc] initWithString:str_url];
                    [[UIApplication sharedApplication] openURL:url];
                    break;
                }
                    
                case MENU_OPTIONS_ABOUT:
                {
                    AboutView *detailViewController = [[AboutView alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:detailViewController animated:YES];
                    
                    break;
                }
                    
            }
            
            break;
        }
    }

}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case MENU_SECTION_CAMERAS:
            return OSTR_HEADING_CAMERAS;
            
        case MENU_SECTION_OPTIONS:
            return OSTR_HEADING_OPTIONS;
    }
    
    return nil;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case MENU_SECTION_CAMERAS:
            return OSTR_TIP_CONNECTCAMS;
            
        case MENU_SECTION_OPTIONS:
            return nil;
    }
    
    return nil;
}

- (void)refreshTable
{
    if (m_pCameraSearch)
    {
        [m_pCameraSearch clear];
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:MENU_SECTION_CAMERAS] withRowAnimation:UITableViewRowAnimationNone];
    
        [m_pCameraSearch stopListeningAndWait:YES];
        
        [m_pCameraSearch startListening];
        [m_pCameraSearch sendSearchRequest];
    }
}

@end
