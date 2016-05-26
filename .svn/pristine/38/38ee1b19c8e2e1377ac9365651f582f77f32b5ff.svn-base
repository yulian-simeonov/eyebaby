//
//  PageBase.m
//  EyeBaby
//

#import "PageBase.h"

@implementation PageBase

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)initBackgroundView
{
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[BackgroundView alloc] initWithFrame:CGRectZero];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBackgroundView];
}

//------------------------------------------------------------------------------
#pragma mark - Alert boxes

-(UIAlertView*)alertPleaseWait:(NSString*)text
{
    UIAlertView* pAlertView;
    UIActivityIndicatorView* pIndicator;

    // Alert view...
    pAlertView = [[UIAlertView alloc] initWithTitle:text message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [pAlertView show];

    // Activity indicator...
    pIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    pIndicator.center = CGPointMake(pAlertView.bounds.size.width / 2, pAlertView.bounds.size.height - 50);
    [pIndicator startAnimating];
    [pAlertView addSubview:pIndicator];
    
    // Done...
    return pAlertView;
}

-(void)messageBox:(NSString*)message title:(NSString*)title
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:OSTR_OK otherButtonTitles:nil];
    
    [alertView show];
}

-(void)messageBoxConnectError
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:OSTR_ALERT_CONNECTION_FAIL_TITLE message:OSTR_ALERT_CONNECTION_FAIL delegate:self cancelButtonTitle:OSTR_OK otherButtonTitles:nil];
    
    [alertView show];    
}

-(void)promptYesNo:(NSString*)message title:(NSString*)title section:(NSInteger)section index:(NSInteger)index
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:OSTR_NO otherButtonTitles:OSTR_YES, nil];   
    alertView.tag = MAKE_TAG(section, index);
    
    [alertView show];
}

- (void)promptButtonsWithSection:(NSInteger)section index:(NSInteger)index buttons:(const char*)firstArg, ...
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:OSTR_CANCEL otherButtonTitles:nil];
    alertView.tag = MAKE_TAG(section, index);
    
    va_list args;
    va_start(args, firstArg);
    for (const char* arg = firstArg; arg != nil; arg = va_arg(args, const char*))
    {
        [alertView addButtonWithTitle:[NSString stringWithCString:arg encoding:NSUTF8StringEncoding]];
    }
    va_end(args);
    
    [alertView show];
}

- (void)promptTextInput:(NSString*)title section:(NSInteger)section index:(NSInteger)index text:(NSString*)text maxLength:(int)maxLength secure:(BOOL)secure
{
    m_nTextInputMaxLen = maxLength;
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:OSTR_CANCEL otherButtonTitles:OSTR_OK, nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MAKE_TAG(section, index);
    
    UITextField* textField = [alertView textFieldAtIndex:0];
    textField.delegate = self;
    [textField setText:text];
    [textField setReturnKeyType:UIReturnKeyDefault];
    textField.secureTextEntry = secure;
    
    [alertView show];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIAlertView* alertView = (UIAlertView*) textField.superview;
    
    [alertView dismissWithClickedButtonIndex:1 animated:YES];
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= m_nTextInputMaxLen && range.length == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Clear current selection...
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
     
    // Process the button...
    switch (alertView.alertViewStyle)
    {
        case UIAlertViewStyleDefault:
        {
            [self onButtonInput:buttonIndex section:TAG_GET_SECTION(alertView.tag) index:TAG_GET_INDEX(alertView.tag)];
            break;
        }
            
        case UIAlertViewStylePlainTextInput:
        {
            UITextField* textField;
            
            if (buttonIndex != 1) return;
            
            textField = [alertView textFieldAtIndex:0];
            
            [self onTextInput:textField.text section:TAG_GET_SECTION(alertView.tag) index:TAG_GET_INDEX(alertView.tag)];
            
            break;
        }
            
        case UIAlertViewStyleSecureTextInput:
        case UIAlertViewStyleLoginAndPasswordInput:
            break;
    }
}

-(void)onButtonInput:(NSInteger)button section:(NSInteger)section index:(NSInteger)index
{
    TRACE(@"Button input: %d, (%d:%d)", button, section, index);
}

-(void)onTextInput:(NSString*)text section:(NSInteger)section index:(NSInteger)index
{
    TRACE(@"ERROR: onTextInput default.");
}

-(void)onSwitchChange:(BOOL)value section:(NSInteger)section index:(NSInteger)index
{
    TRACE(@"ERROR: onSwitchChange default.");
}

-(void)onSliderChange:(float)value section:(NSInteger)section index:(NSInteger)index
{
    TRACE(@"ERROR: onSliderChange default.");
}

-(void)onTwoStateChange:(NSInteger)value section:(NSInteger)section index:(NSInteger)index
{
    TRACE(@"ERROR: onTwoStateChange default.");
}

-(void)onThreeStateChange:(NSInteger)value section:(NSInteger)section index:(NSInteger)index
{
    TRACE(@"ERROR: onThreeStateChange default.");
}

-(void)eventSwitchChange:(id)sender
{
    UISwitch* pSwitch = (UISwitch*) sender;
    
    if (pSwitch)
    {
        [self onSwitchChange:pSwitch.on section:TAG_GET_SECTION(pSwitch.tag) index:TAG_GET_INDEX(pSwitch.tag)];
    }
}

-(void)eventSliderChange:(id)sender
{    
    UISlider* pSlider = (UISlider*) sender;
    
    if (pSlider)
    {
        [self onSliderChange:pSlider.value section:TAG_GET_SECTION(pSlider.tag) index:TAG_GET_INDEX(pSlider.tag)];
    }
}

-(void)eventTwoStateChange:(id)sender
{
    UISegmentedControl* pThreeState = (UISegmentedControl*) sender;
    
    if (pThreeState)
    {
        [self onTwoStateChange:pThreeState.selectedSegmentIndex section:TAG_GET_SECTION(pThreeState.tag) index:TAG_GET_INDEX(pThreeState.tag)];
    }
}

-(void)eventThreeStateChange:(id)sender
{
    UISegmentedControl* pThreeState = (UISegmentedControl*) sender;
    
    if (pThreeState)
    {
        [self onThreeStateChange:pThreeState.selectedSegmentIndex section:TAG_GET_SECTION(pThreeState.tag) index:TAG_GET_INDEX(pThreeState.tag)];
    }
}

-(UITableViewCell*)cellSwitch:(UITableView*)tableView caption:(NSString*)caption section:(NSInteger)section index:(NSInteger)index state:(BOOL)state
{
    return [TableUtils cellSwitch:tableView caption:caption tag:MAKE_TAG(section, index) state:state target:self action:@selector(eventSwitchChange:)];
}

-(UITableViewCell*)cellTwoState:(UITableView*)tableView caption:(NSString*)caption section:(NSInteger)section index:(NSInteger)index first:(NSString*)first second:(NSString*)second value:(NSInteger)value
{
    return [TableUtils cellTwoState:tableView caption:caption first:first second:second tag:MAKE_TAG(section, index) value:value target:self action:@selector(eventTwoStateChange:)];
}

-(UITableViewCell*)cellThreeState:(UITableView*)tableView caption:(NSString*)caption section:(NSInteger)section index:(NSInteger)index value:(NSInteger)value
{
    return [TableUtils cellThreeState:tableView caption:caption first:OSTR_OFF second:OSTR_ON third:OSTR_AUTO tag:MAKE_TAG(section, index) value:value target:self action:@selector(eventThreeStateChange:)];
}

-(UITableViewCell*)cellSlider:(UITableView*)tableView caption:(NSString*)caption section:(NSInteger)section index:(NSInteger)index value:(NSInteger)value maxvalue:(NSInteger)maxvalue
{
    return [TableUtils cellSlider:tableView caption:caption tag:MAKE_TAG(section, index) value:value maxvalue:maxvalue target:self action:@selector(eventSliderChange:)];
}

@end
