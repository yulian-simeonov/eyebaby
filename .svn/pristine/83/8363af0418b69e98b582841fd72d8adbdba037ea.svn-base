//
//  ViewController.m
//  EyeBaby
//

#import "ViewController.h"
#import "CameraPageBase.h"
#import "MainMenu.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_bRegularPop = NO;
	
    // Set style...
    self.navigationBar.barStyle = UIBarStyleBlack;

    // Set initial page...
    UIViewController* p = [[MainMenu alloc] initWithStyle:UITableViewStyleGrouped];
    [self pushViewController:p animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#if 0
-(UIViewController*)popViewControllerAnimated:(BOOL)animated
{    
    UIViewController* p;

    m_bBlockRecursion = YES;
    p = [super popViewControllerAnimated:animated];
    m_bBlockRecursion = NO;
    
    return p;
}

-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    BOOL bPop = YES;
 
    NSLog(@"navigationBar:shouldPopItem: called");
    
    // Perform a regular pop operation...
    if (m_bRegularPop)
    {
        m_bRegularPop = NO;
        return YES;
    }

    // Get the current top view controller...
    UIViewController* p = self.topViewController;
    if (!p) return NO;
    
    // Ask the view controller if it should be popped...
    if ([p isKindOfClass:[CameraPageBase class]])
    {
        CameraPageBase* pPage = (CameraPageBase*) p;
                
        if (pPage)
        {
            bPop = [pPage shouldPop];
        }
    }
    
    // Pop...
    if (bPop)
    {
        NSLog(@"Performing regular pop.");
        m_bRegularPop = YES;
        
        if (!m_bBlockRecursion)
        {
            [self popViewControllerAnimated:YES];
        }
        else
        {
            NSLog(@"Recursive scenario blocked.");
        }
    }
    
    // Done...
    return NO;
}
#endif

@end
