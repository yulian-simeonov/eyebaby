//
//  SelectionViewController.m
//  EyeBaby
//
//  Created by     on 11/15/13.
//
//

#import "SelectionViewController.h"
#import "MainMenu.h"
#import "VideoCaptureViewController.h"

@interface SelectionViewController ()

@end

@implementation SelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)OnClick:(id)sender
{
    int tag = ((UIButton*)sender).tag;    
    if (tag == 1)
    {
        self.navigationController.navigationBarHidden = NO;
        MainMenu* vw = [[MainMenu alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vw animated:YES];
    }
    else
    {
        VideoCaptureViewController* vw = nil;
        if (IS_IPAD)
            vw = [[VideoCaptureViewController alloc] initWithNibName:@"VideoCaptureViewController_ipad" bundle:nil];
        else if (IS_IPHONE_4)
            vw = [[VideoCaptureViewController alloc] initWithNibName:@"VideoCaptureViewController_480h" bundle:nil];
        else
            vw = [[VideoCaptureViewController alloc] initWithNibName:@"VideoCaptureViewController" bundle:nil];
        
        [self.navigationController pushViewController:vw animated:YES];
    }
}
@end
