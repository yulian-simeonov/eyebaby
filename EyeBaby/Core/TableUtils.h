//
//  TableUtils.h
//  EyeBaby
//

#import <Foundation/Foundation.h>

@interface TableUtils : NSObject

+ (UITableViewCell *)cellLink:(UITableView *)tableView caption:(NSString*)caption detail:(NSString*)detail;

+ (UITableViewCell *)cellSearching:(UITableView *)tableView;

+ (UITableViewCell *)cellTextEdit:(UITableView *)tableView caption:(NSString*)caption text:(NSString*)text;

+ (UITableViewCell *)cellInfo:(UITableView *)tableView caption:(NSString*)caption text:(NSString*)text;

+ (UITableViewCell *)cellTwoState:(UITableView *)tableView caption:(NSString*)caption first:(NSString*)first second:(NSString*)second tag:(NSInteger)tag value:(int)value target:(id)target action:(SEL)action;

+ (UITableViewCell *)cellThreeState:(UITableView *)tableView caption:(NSString*)caption first:(NSString*)first second:(NSString*)second third:(NSString*)third tag:(NSInteger)tag value:(int)value target:(id)target action:(SEL)action;

+ (UITableViewCell *)cellSwitch:(UITableView *)tableView caption:(NSString*)caption tag:(NSInteger)tag state:(BOOL)state target:(id)target action:(SEL)action;

+ (UITableViewCell *)cellSlider:(UITableView *)tableView caption:(NSString*)caption tag:(NSInteger)tag value:(int)value maxvalue:(int)maxvalue target:(id)target action:(SEL)action;

+ (UITableViewCell *)cellWirelessNetwork:(UITableView*)tableView name:(NSString*)name signal:(int)signal selected:(BOOL)selected;

+ (UITableViewCell *)cellTick:(UITableView*)tableView caption:(NSString*)caption selected:(BOOL)selected;

@end
