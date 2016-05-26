//
//  iOSCameraSettingViewController.m
//  EyeBaby
//
//  Created by     on 11/17/13.
//
//

#import "iOSCameraSettingViewController.h"
#import "AppDelegate.h"

@interface iOSCameraSettingViewController ()

@end

@implementation iOSCameraSettingViewController

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
    tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_serverInfo = nil;
    [tcpSocket connectToHost:m_pCameraProperties.ipAddress onPort:9096 error:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [tcpSocket disconnect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!m_serverInfo)
        return 0;
    else
        return m_serverInfo.allKeys.count - 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
        return 90;
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%d", indexPath.row]];
    if (!cell)
    {
        NSArray* xib = nil;
        NSString* strText = @"";
        TextCell* txtCell;
        switch (indexPath.row) {
            case 0:
                xib = [[NSBundle mainBundle] loadNibNamed:@"TextCell" owner:self options:nil];
                txtCell = (TextCell*)[xib objectAtIndex:0];
                [txtCell.lbl_name setText:@"Battery Percentage"];
                [txtCell.lbl_value setText:[NSString stringWithFormat:@"%.0f", ((NSNumber*)[m_serverInfo objectForKey:@"Battery Percentage"]).floatValue * 100]];
                cell = txtCell;
                break;
            case 1:
                xib = [[NSBundle mainBundle] loadNibNamed:@"TextCell" owner:self options:nil];
                txtCell = (TextCell*)[xib objectAtIndex:0];
                [txtCell.lbl_name setText:@"Server connected to Power"];
                UIDeviceBatteryState pluginStatus = [[m_serverInfo objectForKey:@"Server connected to Power"] intValue];
                if (pluginStatus == UIDeviceBatteryStateUnplugged)
                    strText = @"Not Connected";
                else if (pluginStatus == UIDeviceBatteryStateCharging || pluginStatus == UIDeviceBatteryStateFull)
                    strText = @"Connected";
                [txtCell.lbl_value setText:strText];
                cell = txtCell;
                break;
            case 2:
            {
                xib = [[NSBundle mainBundle] loadNibNamed:@"CameraCell" owner:self options:nil];
                CameraCell* cameraCell = (CameraCell*)[xib objectAtIndex:0];
                AVCaptureDevicePosition cameraPos = [[m_serverInfo objectForKey:@"Camera"] intValue];
                if (cameraPos == AVCaptureDevicePositionFront)
                    [cameraCell SetCameraValue:self isFront:YES];
                else if (cameraPos == AVCaptureDevicePositionBack)
                    [cameraCell SetCameraValue:self isFront:NO];
                cell = cameraCell;
            }
            break;
            case 3:
            {
                xib = [[NSBundle mainBundle] loadNibNamed:@"FlashCell" owner:self options:nil];
                flashCell = (FlashCell*)[xib objectAtIndex:0];
                AVCaptureTorchMode torchMode = [[m_serverInfo objectForKey:@"Flash Light"] intValue];
                BOOL turnOnFlash = false;
                if (torchMode == AVCaptureTorchModeOn)
                    turnOnFlash = true;
                [flashCell SetFlashInfo:self FlashOn:turnOnFlash Brightness:((NSNumber*)[m_serverInfo objectForKey:@"Flash Brightness"]).floatValue];
                AVCaptureDevicePosition cameraPos = [[m_serverInfo objectForKey:@"Camera"] intValue];
                if (cameraPos == AVCaptureDevicePositionFront)
                    [flashCell SetEnable:NO];
                else if (cameraPos == AVCaptureDevicePositionBack)
                    [flashCell SetEnable:YES];
                cell = flashCell;
                break;
            }
            case 4:
            {
                xib = [[NSBundle mainBundle] loadNibNamed:@"ScreenBrightnessCell" owner:self options:nil];
                ScreenBrightnessCell* screenBrightnessCell = (ScreenBrightnessCell*)[xib objectAtIndex:0];
                [screenBrightnessCell SetBrightnes:self brightness:((NSNumber*)[m_serverInfo objectForKey:@"Screen Brightness"]).floatValue];
                cell = screenBrightnessCell;
            }
                break;
            default:
                break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)setCameraProperties:(OrantekCameraProperties*)camera
{
    m_pCameraProperties = camera;
}

#pragma Settings Delegates
-(void)SetCameraPos:(id)sender
{
    UISegmentedControl* seg = (UISegmentedControl*)sender;
    NSDictionary* dic;
    if (seg.selectedSegmentIndex == 0)
    {
        dic = [NSDictionary dictionaryWithObject:@"front" forKey:@"CameraPos"];
        [flashCell SetEnable:NO];
    }
    else
    {
        dic = [NSDictionary dictionaryWithObject:@"back" forKey:@"CameraPos"];
        [flashCell SetEnable:YES];
    }
    [tcpSocket writeData:[APP GetDataFromDic:dic] withTimeout:5 tag:0];
}

-(void)SetScreenBrightness:(float)value
{
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:value] forKey:@"ScreenBrightness"];
    [tcpSocket writeData:[APP GetDataFromDic:dic] withTimeout:5 tag:1];
}

-(void)SetFlashInfo:(BOOL)turnOn brightness:(float)value
{
    NSString* strStatusValue = @"off";
    if (turnOn)
        strStatusValue = @"on";
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:strStatusValue, @"flash",
                         [NSNumber numberWithFloat:value], @"FlashBrightness",
                         nil];
    [tcpSocket writeData:[APP GetDataFromDic:dic] withTimeout:5 tag:2];
}

#pragma Socket Delegates
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
//	[tcpSocket connectToHost:m_pCameraProperties.ipAddress onPort:9096 error:nil];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"data was sent");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    m_serverInfo = [APP GetDicFromData:data];
    [m_table reloadData];
}
@end
