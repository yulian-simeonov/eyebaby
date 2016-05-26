//
//  PageBase.h
//  EyeBaby
//

#import <UIKit/UIKit.h>

#import "Utils.h"
#import "TableUtils.h"
#import "BackgroundView.h"
#import "Config.h"

#define TAG_GET_SECTION(x)      (0x000000FF & ((NSInteger) x >> 8))
#define TAG_GET_INDEX(x)        (0x000000FF & ((NSInteger) x))
#define MAKE_TAG(section,index)  (((NSInteger) section << 8) | (NSInteger) index)

@interface PageBase : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>
{
    @protected
        int m_nTextInputMaxLen;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

-(void)initBackgroundView;
-(void)viewDidLoad;

-(UIAlertView*)alertPleaseWait:(NSString*)text;

-(void)messageBox:(NSString*)message title:(NSString*)title;
-(void)messageBoxConnectError;

-(void)promptYesNo:(NSString*)message title:(NSString*)title section:(NSInteger)section index:(NSInteger)index;
-(void)promptButtonsWithSection:(NSInteger)section index:(NSInteger)index buttons:(const char*)firstArg, ... NS_REQUIRES_NIL_TERMINATION;
- (void)promptTextInput:(NSString*)title section:(NSInteger)section index:(NSInteger)index text:(NSString*)text maxLength:(int)maxLength secure:(BOOL)secure;

-(void)onButtonInput:(NSInteger)button section:(NSInteger)section index:(NSInteger)index;
-(void)onTextInput:(NSString*)text section:(NSInteger)section index:(NSInteger)index;
-(void)onSwitchChange:(BOOL)value section:(NSInteger)section index:(NSInteger)index;
-(void)onSliderChange:(float)value section:(NSInteger)section index:(NSInteger)index;
-(void)onTwoStateChange:(NSInteger)value section:(NSInteger)section index:(NSInteger)index;
-(void)onThreeStateChange:(NSInteger)value section:(NSInteger)section index:(NSInteger)index;

-(UITableViewCell*)cellSwitch:(UITableView*)tableView caption:(NSString*)caption section:(NSInteger)section index:(NSInteger)index state:(BOOL)state;
-(UITableViewCell*)cellTwoState:(UITableView*)tableView caption:(NSString*)caption section:(NSInteger)section index:(NSInteger)index first:(NSString*)first second:(NSString*)second value:(NSInteger)value;
-(UITableViewCell*)cellThreeState:(UITableView*)tableView caption:(NSString*)caption section:(NSInteger)section index:(NSInteger)index value:(NSInteger)value;
-(UITableViewCell*)cellSlider:(UITableView*)tableView caption:(NSString*)caption section:(NSInteger)section index:(NSInteger)index value:(NSInteger)value maxvalue:(NSInteger)maxvalue;

@end
