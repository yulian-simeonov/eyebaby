//
//  TableUtils.m
//  EyeBaby
//

#import "TableUtils.h"
#import "Config.h"

#define CELL_SELECTION_STYLE    UITableViewCellSelectionStyleGray

@implementation TableUtils

+ (UITableViewCell *)cellLink:(UITableView *)tableView caption:(NSString*)caption detail:(NSString*)detail
{
    static NSString* CellIdentifier = @"CellLink";
    UITableViewCell* cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = CELL_SELECTION_STYLE;
    }
    
    if (caption)
    {
        [cell.textLabel setText:[NSString stringWithString:caption]];
    }
    else
    {
        [cell.textLabel setText:@""];
    }
    
    if (detail)
    {
        [cell.detailTextLabel setText:[NSString stringWithString:detail]];
    }
    else
    {
        [cell.detailTextLabel setText:@""];  
    }
    
    return cell;
}

+ (UITableViewCell *)cellSearching:(UITableView *)tableView
{
    static NSString* CellIdentifier = @"CellSearching";
    UITableViewCell* cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.textLabel setText:OSTR_SEARCHING];
        
        UIActivityIndicatorView* subview = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        subview.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [subview startAnimating];
        
        cell.accessoryView = subview;
    }
    
    return cell;
}

+ (UITableViewCell *)cellTextEdit:(UITableView *)tableView caption:(NSString*)caption text:(NSString*)text
{
    static NSString* CellIdentifier = @"CellProperty";
    UITableViewCell* cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.textLabel setText:caption];
    [cell.detailTextLabel setText:text];
    
    return cell;
}

+ (UITableViewCell *)cellInfo:(UITableView *)tableView caption:(NSString*)caption text:(NSString*)text
{
    static NSString* CellIdentifier = @"CellInformation";
    UITableViewCell* cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (caption)
    {
        [cell.textLabel setText:caption];
    }
    else
    {
        [cell.textLabel setText:@""];
    }
    
    if (text)
    {
        [cell.detailTextLabel setText:text];
    }
    else
    {
        [cell.detailTextLabel setText:@""];
    }
    
    return cell;
}

+ (UITableViewCell *)cellTwoState:(UITableView *)tableView caption:(NSString*)caption first:(NSString*)first second:(NSString*)second tag:(NSInteger)tag value:(int)value target:(id)target action:(SEL)action
{
    static NSString* CellIdentifier = @"CellTwoState";
    UITableViewCell* cell;
    
    // Create or reuse cell...
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Set cell caption...
    [cell.textLabel setText:caption];
    
    // Create a segmented control...
    UISegmentedControl* pSlider = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:first, second, nil]];
    
    pSlider.segmentedControlStyle = UISegmentedControlStyleBar;
    pSlider.tag = tag;
    
    // Set default value...
    if (value < 0) value = 0;
    if (value > 2) value = 2;
    pSlider.selectedSegmentIndex = (NSUInteger) value;
    
    // Target...
    [pSlider addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    
    // Set the segmented control as cell's accessory view...
    cell.accessoryView = pSlider;    
    
    // Done...
    return cell;    
}

+ (UITableViewCell *)cellThreeState:(UITableView *)tableView caption:(NSString*)caption first:(NSString*)first second:(NSString*)second third:(NSString*)third tag:(NSInteger)tag value:(int)value target:(id)target action:(SEL)action
{
    static NSString* CellIdentifier = @"CellThreeState";
    UITableViewCell* cell;
    
    // Create or reuse cell...
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Set cell caption...
    [cell.textLabel setText:caption];

    // Create a segmented control...
    UISegmentedControl* pSlider = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:first, second, third, nil]];

    pSlider.segmentedControlStyle = UISegmentedControlStyleBar;
    pSlider.tag = tag;
    
    // Set default value...
    if (value < 0) value = 0;
    if (value > 2) value = 2;
    pSlider.selectedSegmentIndex = (NSUInteger) value;
    
    // Target...
    [pSlider addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    
    // Set the segmented control as cell's accessory view...
    cell.accessoryView = pSlider;    
    
    // Done...
    return cell;    
}

+ (UITableViewCell *)cellSwitch:(UITableView *)tableView caption:(NSString*)caption tag:(NSInteger)tag state:(BOOL)state target:(id)target action:(SEL)action
{
    static NSString* CellIdentifier = @"CellSwitch";
    UITableViewCell* cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.textLabel setText:caption];
    
    UISwitch* pSwitch = [[UISwitch alloc] init];
    [pSwitch addTarget:target action:action forControlEvents:UIControlEventValueChanged];

    pSwitch.on = state;
    pSwitch.tag = tag;

    cell.accessoryView = pSwitch;

    return cell;
}

+ (UITableViewCell *)cellSlider:(UITableView *)tableView caption:(NSString*)caption tag:(NSInteger)tag value:(int)value maxvalue:(int)maxvalue target:(id)target action:(SEL)action
{
    static NSString* CellIdentifier = @"CellSlider";
    UITableViewCell* cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.textLabel setText:caption];
    
    UISlider* pSlider = [[UISlider alloc] init];
    
    pSlider.tag = tag;
    pSlider.continuous = NO;
    pSlider.value = (float) value / (float) maxvalue;
    
    [pSlider addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    
    cell.accessoryView = pSlider;
        
    return cell;
}

+ (UITableViewCell *)cellWirelessNetwork:(UITableView*)tableView name:(NSString*)name signal:(int)signal selected:(BOOL)selected
{
    static NSString* CellIdentifier = @"CellWifiNetwork";
    UITableViewCell* cell;
    
    // Allocate cell...
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = CELL_SELECTION_STYLE;
    }

    // Check mark...
    if (selected)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Network name...
    if (name)
    {
        [cell.textLabel setText:[NSString stringWithString:name]];
    }
    else
    {
        [cell.textLabel setText:@"Unidentified Network"];
    }

    // Signal strength...
    if (signal < 1) signal = 1;
    if (signal > 5) signal = 5;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"signal%d.png", signal]];
    
    // Done...
    return cell;
}

+ (UITableViewCell *)cellTick:(UITableView*)tableView caption:(NSString*)caption selected:(BOOL)selected
{
    static NSString* CellIdentifier = @"CellTick";
    UITableViewCell* cell;
    
    // Allocate cell...
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Check mark...
    if (selected)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Caption...
    if (caption)
    {
        [cell.textLabel setText:[NSString stringWithString:caption]];
    }
    else
    {
        [cell.textLabel setText:@""];
    }
    
    // Done...
    return cell;
}

@end
