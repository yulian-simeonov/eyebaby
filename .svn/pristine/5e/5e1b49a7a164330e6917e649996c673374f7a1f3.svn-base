//
//  CameraLabels.m
//  EyeBaby
//

#import "CameraLabels.h"

@implementation CameraLabels

enum
{
    PARAM_IDENTITY_NAME,
    PARAM_IDENTITY_LOCATION,
    PARAM_IDENTITY_CONTACT,
    
    NUM_IDENTITY_PARAMS
};

-(BOOL)initPage
{
    return [m_pCamera getIdentityParams];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = OSTR_PAGE_LABELS;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_IDENTITY_PARAMS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch ([indexPath indexAtPosition:1])
    {
        case PARAM_IDENTITY_NAME:
            cell = [TableUtils cellTextEdit:tableView caption:OSTR_PARAM_IDENTITY_NAME text:m_pCamera.name];
            break;
            
        case PARAM_IDENTITY_LOCATION:
            cell = [TableUtils cellTextEdit:tableView caption:OSTR_PARAM_IDENTITY_LOCATION text:m_pCamera.location];                    
            break;
            
        case PARAM_IDENTITY_CONTACT:
            cell = [TableUtils cellTextEdit:tableView caption:OSTR_PARAM_IDENTITY_CONTACT text:m_pCamera.contact];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath indexAtPosition:1])
    {
        case PARAM_IDENTITY_NAME:
            [self promptTextInput:OSTR_PARAM_IDENTITY_NAME section:0 index:PARAM_IDENTITY_NAME text:m_pCamera.name maxLength:ORANTEK_IDENTITY_NAME_MAX secure:NO];
            break;
            
        case PARAM_IDENTITY_LOCATION:
            [self promptTextInput:OSTR_PARAM_IDENTITY_LOCATION section:0 index:PARAM_IDENTITY_LOCATION text:m_pCamera.location maxLength:ORANTEK_IDENTITY_LOCATION_MAX secure:NO];
            break;
            
        case PARAM_IDENTITY_CONTACT:
            [self promptTextInput:OSTR_PARAM_IDENTITY_CONTACT section:0 index:PARAM_IDENTITY_CONTACT text:m_pCamera.contact maxLength:ORANTEK_IDENTITY_CONTACT_MAX secure:NO];
            break;
    } 
}

-(void)onTextInput:(NSString*)text section:(NSInteger)section index:(NSInteger)index
{
    switch (index)
    {
        case PARAM_IDENTITY_NAME:
            m_pCamera.name = text;
            [m_pCamera asyncSetIdentity];
            [self.tableView reloadData];
            break;
            
        case PARAM_IDENTITY_LOCATION:
            m_pCamera.location = text;
            [m_pCamera asyncSetIdentity];
            [self.tableView reloadData];
            break;
            
        case PARAM_IDENTITY_CONTACT:
            m_pCamera.contact = text;
            [m_pCamera asyncSetIdentity];
            [self.tableView reloadData];
            break;
    }
}

@end
