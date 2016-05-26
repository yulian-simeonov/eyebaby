//
//  AppDelegate.m
//  EyeBaby
//

#import "AppDelegate.h"
#import "SelectionViewController.h"
#import "Utils.h"
#import "Config.h"


//#define ENABLE_PUSH_NOTIFICATIONS

@implementation AppDelegate

@synthesize window = _window;

#pragma Audio Device Init

void interruptionListener(	void *	inClientData,
						  UInt32	inInterruptionState)
{
    //	RecordSessionController *THIS = (RecordSessionController*)inClientData;
    //	if (inInterruptionState == kAudioSessionBeginInterruption)
    //	{
    //		if (THIS->aqRecorder->IsRunning())
    //			[THIS stopRecord];
    //	}
}

void propListener(	void *                  inClientData,
				  AudioSessionPropertyID	inID,
				  UInt32                  inDataSize,
				  const void *            inData)
{
    //	RecordSessionController *THIS = (RecordSessionController*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			// stop the queue if we had a non-policy route change
            //			if (THIS->aqRecorder->IsRunning())
            //				[THIS stopRecord];
		}
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32)) {
            //			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
            //			THIS->recordButton.enabled = (isAvailable > 0) ? YES : NO;
		}
	}
}

- (void)RecordSessionInitialize
{
	OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
    //	if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
    //	else
	{
		UInt32 category = kAudioSessionCategory_PlayAndRecord;
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error) printf("couldn't set audio category!");

		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);

		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);

		// we also need to listen to see if input availability changes
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);

		error = AudioSessionSetActive(true);
		if (error) printf("AudioSessionSetActive (true) failed");
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self RecordSessionInitialize];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
#ifdef ENABLE_PUSH_NOTIFICATIONS
    // Register for push notifications...
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
#endif
    
    // TestFlight SDK...
#ifdef USE_TESTFLIGHT

#ifdef DEBUG
    /*
        IMPORTANT: This line should not be present in release builds, as
        the function is not supported for AppStore released apps.
     
        However, it is required for correct networking operation of
        TestFlight SDK. With out it, lots of timeouts become an issue.
    */
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    [TestFlight takeOff:OSTR_TESTFLIGHT_KEY];
#endif
    // User interface...
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SelectionViewController* vw = nil;
    if (IS_IPAD)
        vw = [[SelectionViewController alloc] initWithNibName:@"SelectionViewController_ipad" bundle:nil];
    else if (IS_IPHONE_4)
        vw = [[SelectionViewController alloc] initWithNibName:@"SelectionViewController_480h" bundle:nil];
    else
        vw = [[SelectionViewController alloc] initWithNibName:@"SelectionViewController" bundle:nil];
    
    UINavigationController* navVw = [[UINavigationController alloc] initWithRootViewController:vw];
    navVw.navigationBar.barStyle = UIBarStyleBlack;
    navVw.navigationBarHidden = YES;
    [self.window setRootViewController:navVw];
    [self.window makeKeyAndVisible];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    // Lets see version...
    TRACE(@"App Version: \"%@\"", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
    
#ifdef ENABLE_PUSH_NOTIFICATIONS
    // Notifications...
    
    /*
     FIXME!!! PROCESS RECEIVED NOTIFICATIONS
     */
#endif
    
    // Done...
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    TRACE(@"applicationWillResignActive called.");
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{    
    TRACE(@"applicationDidEnterBackground called.");
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{    
    TRACE(@"applicationWillEnterForeground called.");
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    TRACE(@"applicationDidBecomeActive called.");
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
#ifdef ENABLE_PUSH_NOTIFICATIONS
    // Clear numbering on application badge...
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    TRACE(@"applicationWillTerminate called.");
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#ifdef ENABLE_PUSH_NOTIFICATIONS

-(void)application:(UIApplication*)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{    
    NSString* token = [NSString stringWithFormat:@"%@", deviceToken];
    NSString* device = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueIdentifier]];
    
    token = [[token stringByTrimmingCharactersInSet:
              [NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
             stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString* url = [NSString stringWithFormat:@"%@?deviceid=%@&token=%@", OSTR_URL_APNS_REGISTER, [device stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [token stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSString* result = [Utils stringFromURL:url timeout:30];
    if (result)
    {
        TRACE(@"Successfully sent APNS device token.");
    }
    else
    {
        TRACE(@"Failed to send APNS device token.");
    }
}

-(void)application:(UIApplication*)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    TRACE(@"Failed to register device token.");
}

-(void)application:(UIApplication*)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    TRACE(@"didReceiveRemoteNotification was called.");
    
    /*
        Multiple alert notifications?
     */
    
    NSDictionary* aps = [userInfo objectForKey:@"aps"];
    if (aps)
    {
        NSString* alert = [aps objectForKey:@"alert"];
        if (alert)
        {
            UIAlertView* pAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:alert delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [pAlert show];
        }
    }
}

#endif

-(NSData*)GetDataFromDic:(NSDictionary*)dic
{
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver encodeObject:dic forKey:@"dic"];
    [archiver finishEncoding];
    [data appendBytes:"\x0D\x0A" length:2];
    return data;
}

-(NSDictionary*)GetDicFromData:(NSData*)data
{
    NSData* coreData = [NSData dataWithBytes:data.bytes length:data.length - 2];
    NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:coreData] autorelease];
    NSDictionary *myDictionary = [unarchiver decodeObjectForKey:@"dic"];
    [unarchiver finishDecoding];
    return myDictionary;
}
@end
