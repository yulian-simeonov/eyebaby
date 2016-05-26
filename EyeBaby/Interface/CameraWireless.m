//
//  CameraWireless.m
//  EyeBaby
//

#import "CameraWireless.h"

enum
{
    SECTION_WIFI_SETTINGS,
    SECTION_DETECTED_NETWORKS,
    
    NUM_SECTIONS
};

enum
{
    PROMPT_USE_NETWORK
};

enum
{
    PARAM_SETTINGS_ENABLED,
    
    PARAM_SETTINGS_COUNT
};

@implementation CameraWireless

//------------------------------------------------------------------------------

- (void)onSearchSuccess:(id)sender
{
    m_pWirelessResults = [m_pCamera getWirelessResults];
    m_bSearching = NO;
    [self.tableView reloadData];
    
    if (m_pAlertView)
    {
        [m_pAlertView dismissWithClickedButtonIndex:0 animated:YES];
        m_pAlertView = nil;
    }
}

- (void)onSearchFailure:(id)sender
{
    m_pWirelessResults = nil;
    m_bSearching = NO;
    [self.tableView reloadData];
    
    if (m_pAlertView)
    {
        [m_pAlertView dismissWithClickedButtonIndex:0 animated:YES];
        m_pAlertView = nil;
    }
}

-(void)onCommandSuccess:(id)sender
{
    
}

-(void)onCommandFailure:(id)sender
{
    
}

-(void)doSearch
{
    m_pWirelessResults = nil;
    m_bSearching = YES;
    
    m_pAlertView = [self alertPleaseWait:OSTR_ALERT_SEARCHING_WIFI];
    
    [m_pCamera searchWireless];    
}

- (void)refreshTable
{
    if (!m_bSearching)
    {
        [self doSearch];
        [self.tableView reloadData];
    }
}

//------------------------------------------------------------------------------

- (id)initWithCam:(OrantekCameraProperties *)camera
{
    self = [super initWithCam:camera];
    
    if (self)
    {
        m_bSearching = NO;
        m_pWirelessResults = nil;
        m_pWirelessInfo = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchSuccess:) name:OrantekWirelessSearchSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchFailure:) name:OrantekWirelessSearchFail object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCommandSuccess:) name:OrantekCommandSucceeded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCommandFailure:) name:OrantekCommandFailed object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)initPage
{
    return [m_pCamera getWirelessEnabled];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Title...
    self.title = OSTR_PAGE_WIRELESS;
    
    // Refresh button...
    UIBarButtonItem* btn = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                            target:self
                            action:@selector(refreshTable)];
    self.navigationItem.rightBarButtonItem = btn;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    m_bSearching = NO;
    
    TRACE(@"Getting wireless parameters.");
    [m_pCamera getWirelessParams];
    TRACE(@"Got wireless parameters.");
    
    // Initiate automatic search...
    if (m_pCamera.wifiEnabled)
    {
        [self doSearch];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {      
        case SECTION_WIFI_SETTINGS:
            return PARAM_SETTINGS_COUNT;
            
        case SECTION_DETECTED_NETWORKS:
        {
            if (m_pWirelessResults && [m_pWirelessResults count] > 0)
            {
                return [m_pWirelessResults count];
            }
            else
            {
                return 1;
            }
        }
            
        default:
            return 0;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_WIFI_SETTINGS:
            return OSTR_WIFI_SECTION_SETTINGS;
            
        case SECTION_DETECTED_NETWORKS:
            return OSTR_WIFI_CHOOSE_NETWORK;
            
        default:
            return nil;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {            
        case SECTION_DETECTED_NETWORKS:
            if (m_bSearching)
            {
                return OSTR_TIP_WIFI_SEARCHING;
            }
            else
            {
                return OSTR_TIP_WIFI_FOUND;   
            }
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch ([indexPath indexAtPosition:0])
    {
        case SECTION_WIFI_SETTINGS:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case PARAM_SETTINGS_ENABLED:
                    cell = [TableUtils cellTextEdit:tableView caption:OSTR_WIFI_ENABLED_STATE text:(m_pCamera.wifiEnabled ? OSTR_ENABLED : OSTR_DISABLED)];
                    break;
            }
            break;
        }
            
        case SECTION_DETECTED_NETWORKS:
        {
            if (m_pWirelessResults && [m_pWirelessResults count] > 0)
            {
                int i = [indexPath indexAtPosition:1];
                if (i < 0 || i >= [m_pWirelessResults count])
                {
                    cell = [TableUtils cellInfo:tableView caption:OSTR_FIXME text:nil];
                }
                else
                {
                    OrantekWirelessInfo* pInfo = [m_pWirelessResults objectAtIndex:i];
                    
                    cell = [TableUtils cellWirelessNetwork:tableView name:pInfo.SSID signal:pInfo.Signal selected:[pInfo compareSSID:m_pCamera.wifiSSID]];
                }
            }
            else
            {
                if (m_bSearching)
                {
                    cell = [TableUtils cellSearching:tableView];
                }
                else
                {
                    cell = [TableUtils cellInfo:tableView caption:OSTR_TIP_NO_NETWORKS text:nil];
                }
            }
            
            break;
        }
    }
    
    if (cell == nil)
    {
        cell = [TableUtils cellInfo:tableView caption:OSTR_FIXME text:OSTR_FIXME];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath indexAtPosition:0])
    {
        case SECTION_DETECTED_NETWORKS:
            if (m_pWirelessResults && [m_pWirelessResults count] > 0)
            {
                m_pWirelessInfo = [m_pWirelessResults objectAtIndex:[indexPath indexAtPosition:1]];
                
                if (m_pWirelessInfo)
                {
                    NSString* password;
                    
                    if ([m_pWirelessInfo compareSSID:m_pCamera.wifiSSID])
                    {
                        password = m_pCamera.wifiWPAKEY;
                    }
                    else
                    {
                        password = @"";
                    }
                    
                    [self promptTextInput:OSTR_WIFI_ENTER_PASSWORD section:SECTION_DETECTED_NETWORKS index:PROMPT_USE_NETWORK text:password maxLength:ORANTEK_WPA_PASSWORD_MAX secure:YES];
                }
            }
            break;
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath indexAtPosition:0])
    {
        case SECTION_WIFI_SETTINGS:
            switch ([indexPath indexAtPosition:1])
            {
                case PARAM_SETTINGS_ENABLED:
                    if (m_pCamera.wifiEnabled)
                    {
                        [self promptYesNo:OSTR_WIFI_POPUP_DISABLE_TEXT title:OSTR_WIFI_POPUP_DISABLE_TITLE section:SECTION_WIFI_SETTINGS index:PARAM_SETTINGS_ENABLED];
                    }
                    else
                    {
                        [self promptYesNo:OSTR_WIFI_POPUP_ENABLE_TEXT title:OSTR_WIFI_POPUP_ENABLE_TITLE section:SECTION_WIFI_SETTINGS index:PARAM_SETTINGS_ENABLED];
                    }
                    break;
            }
            break;
    }
}

-(void)onTextInput:(NSString *)text section:(NSInteger)section index:(NSInteger)index
{    
    if (m_pWirelessInfo)
    {
        // Set wifi details...
        [m_pCamera assignWirelessParams:m_pWirelessInfo password:text];

        /*
            Show popup while updating wireless params
        */
        
        // Send out update...
        [m_pCamera asyncSetWireless];

        // Refresh the table...
        [self.tableView reloadData];
    }
}

-(void)onButtonInput:(NSInteger)button section:(NSInteger)section index:(NSInteger)index
{
    switch (section)
    {
        case SECTION_WIFI_SETTINGS:
            switch (index)
            {
                case PARAM_SETTINGS_ENABLED:
                    if (button == 1)
                    {
                        if (m_pCamera.wifiEnabled)
                        {
                            m_pCamera.wifiEnabled = NO;
                            [m_pCamera asyncSetWirelessEnabled];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                        else
                        {
                            m_pCamera.wifiEnabled = YES;
                            [m_pCamera asyncSetWirelessEnabled];
                            [self.tableView reloadData];
                            [self doSearch];
                        }
                    }
                    break;
            }
    }
}

@end
