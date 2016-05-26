//
//  OrantekCameraProperties.m
//  EyeBaby
//

#import "OrantekCameraProperties.h"
#import "Utils.h"
#import "Registry.h"
#import "Config.h"

#define CMD_SEARCH_SSID         @"wirelessSearchSsid"

#define TIMEOUT_DEFAULT         5.0
#define TIMEOUT_WIFI_SEARCH     30.0

@implementation OrantekCameraProperties

// Core details...
@synthesize macAddress = m_macAddress;
@synthesize cameraModel = m_cameraModel;
@synthesize location = m_location;
@synthesize name = m_name;
@synthesize ipAddress = m_ipAddress;
@synthesize port = m_port;

// Extra details...
@synthesize contact = m_contact;

@synthesize videoFlipVertical = m_videoFlipVertical;
@synthesize videoFlipHorizontal = m_videoFlipHorizontal;
@synthesize videoMoonlightMode = m_videoMoonlightMode;
@synthesize videoRotateImage = m_videoRotateImage;
@synthesize videoLightFrequency = m_videoLightFrequency;

@synthesize audioEnabled = m_audioEnabled;
@synthesize audioVolume = m_audioVolume;
@synthesize audioBitRate = m_audioBitRate;

@synthesize nightIfraredLED = m_nightIfraredLED;
@synthesize nightBlackWhite = m_nightBlackWhite;

@synthesize wifiEnabled = m_wifiEnabled;

@synthesize wifiSSID = m_wifiSSID;
@synthesize wifiMode = m_wifiMode;
@synthesize wifiSecurity = m_wifiSecurity;
@synthesize wifiEncryption = m_wifiEncryption;
@synthesize wifiAuthType = m_wifiAuthType;
@synthesize wifiKeyType = m_wifiKeyType;
@synthesize wifiWEPIDX = m_wifiWEPIDX;
@synthesize wifiWEPKEY = m_wifiWEPKEY;
@synthesize wifiWPAKEY = m_wifiWPAKEY;

@synthesize powerLED = m_powerLED;

@synthesize firmwareVersion = m_firmwareVersion;

//------------------------------------------------------------------------------
#pragma mark - Object lifetime

-(id)init
{
    self = [super init];
    
    if (self)
    {
        m_pWirelessSearchResults = nil;
        
        // Core details...
        m_macAddress = @"";
        m_cameraModel = @"";
        m_location = @"";
        m_name = @"";
        m_ipAddress = @"";
        m_port = @"";
        
        // Extra details...
        m_contact = @"";
        
        m_videoFlipVertical = NO;
        m_videoFlipHorizontal = NO;
        m_videoMoonlightMode = 0;
        m_videoRotateImage = NO;
        m_videoLightFrequency = 0;
        
        m_audioEnabled = NO;
        m_audioVolume = 0;
        m_audioBitRate = 0;
        
        m_nightIfraredLED = 0;
        m_nightBlackWhite = 0;
        
        m_wifiEnabled = NO;
        
        m_wifiSSID = @"";
        m_wifiMode = 0;
        m_wifiSecurity = 0;
        m_wifiEncryption = 0;
        m_wifiAuthType = 0;
        m_wifiKeyType = 0;
        m_wifiWEPIDX = 0;
        m_wifiWEPKEY = @"";
        m_wifiWPAKEY = @"";
        
        m_powerLED = NO;
        
        m_firmwareVersion = @"";
    }
    
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Object testing

//
// Returns true if both objects refer to the same camera.
//
-(BOOL)isEqualToCamera:(OrantekCameraProperties*)other
{    
    @synchronized(self)
    {
        return [m_macAddress isEqualToString:other.macAddress];
    }
}

//
// Updates the core details with values taken from another
// OrantekCameraProperties object.
//
// Returns YES if anything was changed.
//
-(BOOL)updateCoreDetails:(OrantekCameraProperties*)src
{
    BOOL bChanged = NO;
    
    @synchronized(self)
    {        
        // Camera model...
        if (![m_cameraModel isEqualToString:src.cameraModel])
        {
            m_cameraModel = [src.cameraModel copy];
            bChanged = YES;
        }
        
        // Location...
        if (![m_location isEqualToString:src.location])
        {
            m_location = [src.location copy];
            bChanged = YES;
        }
        
        // Name...
        if (![m_name isEqualToString:src.name])
        {
            m_name = [src.name copy];
            bChanged = YES;
        }
        
        // Port...
        if (![m_port isEqualToString:src.port])
        {
            m_port = [src.port copy];
            bChanged = YES;
        }
        
        // IP address...
        if (![m_ipAddress isEqualToString:src.ipAddress])
        {
            m_ipAddress = [src.ipAddress copy];
            bChanged = YES;
        }
    }

    return bChanged;
}

-(BOOL)stillConnected
{
    /*
     FIXME!!
     Direct contact via HTTP of main interface, and if get back 2xx or 3xx response
     of any kind, then we are good.
     */
    return YES;
}

//------------------------------------------------------------------------------
#pragma mark - Get camera properties

-(NSString*)getUniversalID
{
    return m_macAddress; 
}

//------------------------------------------------------------------------------
#pragma mark - Camera Search

-(BOOL)getComponentsFrom:(NSString*)str asName:(NSString**)name andValue:(NSString**)value
{
    NSArray* tokens = [str componentsSeparatedByString:@"="];
    if (tokens == nil) return NO;
    if ([tokens count] != 2) return NO;
    
    *name = [tokens objectAtIndex:0];
    *value = [tokens objectAtIndex:1];
    
    return YES;
}

-(NSArray*)doCameraCommand:(NSString*)cmd timeout:(NSTimeInterval)timeout
{    
    // Load credentials...
    NSString* cam_id = [self getUniversalID];
    NSString* username = [Registry camera:cam_id getKeyString:OSTR_REGKEY_USERNAME defaultVal:OSTR_REGKEY_USERNAME_DEFAULT];
    NSString* password = [Registry camera:cam_id getKeyString:OSTR_REGKEY_PASSWORD defaultVal:OSTR_REGKEY_PASSWORD_DEFAULT];
    
    // Full string...
    NSString* cmdURL = [NSString stringWithFormat:@"http://%@:%@@%@/form/%@", [username stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [password stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], m_ipAddress, cmd];
    
    TRACE(@"Command: %@", cmdURL);

    // Do command...
    NSString* text = [Utils stringFromURL:cmdURL timeout:timeout];
    if (!text)
    {
        return nil;
    }
    
    // Divide into array of lines...
    NSArray* lines = [text componentsSeparatedByString:@"\n"];
    if ([lines count] < 1)
    {
        return nil;
    }
    
    // Check for success...
    if ([[lines objectAtIndex:0] caseInsensitiveCompare:@"000 Success"] != NSOrderedSame)
    {
        int i;
        
        for (i = 0; i < [lines count]; ++i)
        {
            TRACE(@"\"%@\"", [lines objectAtIndex:i]);
        }

        return nil;
    }
    
    // Done...
    return lines;
}

-(void)sendEventSuccess
{
    [self sendMainThreadEvent:OrantekCommandSucceeded withObject:self];
}

-(void)sendEventFailure
{
    [self sendMainThreadEvent:OrantekCommandFailed withObject:self];
}

//------------------------------------------------------------------------------
#pragma mark - Property getters...

-(BOOL)getIdentityParams
{
    NSString* name;
    NSString* value;
    int i;

    // Identity...
    NSArray* lines = [self doCameraCommand:@"getIdentity" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    for (i = 1; i < [lines count]; ++i)
    {
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue;
        
        if ([name isEqualToString:@"NAME"])
        {
            m_name = value;
        }
        
        if ([name isEqualToString:@"LOCATION"])
        {
            m_location = value;
        }
        
        if ([name isEqualToString:@"CONTACT"])
        {
            m_contact = value;
        }
    }
    
    // Done...
    return YES;
}

-(BOOL)getVideoParams
{
    NSString* name;
    NSString* value;
    int i;
    
    // Video parameters...
    NSArray* lines = [self doCameraCommand:@"getVideo" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    for (i = 1; i < [lines count]; ++i)   
    {
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue;
        
        if ([name isEqualToString:@"MOONLIGHT"])
        {
            m_videoMoonlightMode = [value intValue];
        }
        
        else if ([name isEqualToString:@"LIGHTFREQ"])
        {
            m_videoLightFrequency = [value intValue];
        }
        
        else if ([name isEqualToString:@"ROTATE"])
        {
            m_videoRotateImage = [Utils boolFromString:value];
        }
    }
    
    // Done...
    return YES;
}

-(BOOL)getPowerLEDParams
{
    NSString* name;
    NSString* value;
    int i;  
    
    // Power LED light...
    NSArray* lines = [self doCameraCommand:@"getLed" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    for (i = 1; i < [lines count]; ++i)   
    {
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue;
        
        if ([name isEqualToString:@"ENABLE"])
        {
            m_powerLED = [Utils boolFromString:value];
        }
    } 
    
    // Done...
    return YES;
}

-(BOOL)getFlipVideoParams
{
    NSString* name;
    NSString* value;
    int i;   
    
    // Flip video...
    NSArray* lines = [self doCameraCommand:@"getVideoFlip" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    for (i = 1; i < [lines count]; ++i)   
    {
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue;
        
        if ([name isEqualToString:@"FLIPH"])
        {
            m_videoFlipHorizontal = [Utils boolFromString:value];
        }
        
        else if ([name isEqualToString:@"FLIPV"])
        {
            m_videoFlipVertical = [Utils boolFromString:value];
        }
    }

    // Done...
    return YES;
}

-(BOOL)getAudioParams
{
    NSString* name;
    NSString* value;
    int i;
    
    // Audio...
    NSArray* lines = [self doCameraCommand:@"getAudio" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    for (i = 1; i < [lines count]; ++i)   
    {        
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue; 
        
        if ([name isEqualToString:@"ENABLE"])
        {
            m_audioEnabled = [Utils boolFromString:value];
        }
        
        else if ([name isEqualToString:@"VOLUME"])
        {
            m_audioVolume = [value intValue];
        }
        
        else if ([name isEqualToString:@"BITRATE"])
        {
            m_audioBitRate = [value intValue];
        }
    }    

    // Done...
    return YES;
}

-(BOOL)getNightVisionParams
{
    NSString* name;
    NSString* value;
    int i;

    NSArray* lines = [self doCameraCommand:@"getNightVision" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    for (i = 1; i < [lines count]; ++i)   
    {        
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue; 
        
        if ([name isEqualToString:@"LEDCTRL"])
        {
            m_nightIfraredLED = [value intValue];
        }
        
        else if ([name isEqualToString:@"BWCTRL"])
        {
            m_nightBlackWhite = [value intValue];
        }
    }

    // Done...
    return YES;
}

-(BOOL)getWirelessEnabled
{
    NSString* name;
    NSString* value;
    int i;
    
    // Wireless...
    NSArray* lines = [self doCameraCommand:@"getWirelessEnable" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    for (i = 1; i < [lines count]; ++i)   
    {        
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue; 
        
        if ([name isEqualToString:@"ENABLE"])
        {
            m_wifiEnabled = ([value intValue] != 0 ? YES : NO);
        }
    }
    
    // Done...
    return YES;
}

-(BOOL)getWirelessParams
{
    NSString* name;
    NSString* value;
    int i;

    // Wireless...
    NSArray* lines = [self doCameraCommand:@"getWireless" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    for (i = 1; i < [lines count]; ++i)   
    {        
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue; 
        
        if ([name isEqualToString:@"SSID"])
        {
            m_wifiSSID = value;
        }
        
        else if ([name isEqualToString:@"MODE"])
        {
            m_wifiMode = Orantek_IdentifierForCodeName(OrantekWifiModes, [value cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        
        else if ([name isEqualToString:@"SECURITY"])
        {
            m_wifiSecurity = Orantek_IdentifierForCodeName(OrantekWifiSecurity, [value cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        
        else if ([name isEqualToString:@"ENCRYPTION"])
        {
            m_wifiEncryption = Orantek_IdentifierForCodeName(OrantekWifiEncryption, [value cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        
        else if ([name isEqualToString:@"AUTHTYPE"])
        {
            m_wifiAuthType = Orantek_IdentifierForCodeName(OrantekWifiAuthType, [value cStringUsingEncoding:NSUTF8StringEncoding]);
        } 
        
        else if ([name isEqualToString:@"KEYTYPE"])
        {
            m_wifiKeyType = Orantek_IdentifierForCodeName(OrantekWifiKeyType, [value cStringUsingEncoding:NSUTF8StringEncoding]);
        } 
        
        else if ([name isEqualToString:@"WEPIDX"])
        {
            m_wifiWEPIDX = [value intValue];
        } 
        
        else if ([name isEqualToString:@"WEPKEY"])
        {
            m_wifiWEPKEY = value;
        }
        
        else if ([name isEqualToString:@"WPAKEY"])
        {
            m_wifiWPAKEY = value;
        }
    }
    
    // Done...
    return YES;
}

-(BOOL)getFirmwareParams
{
    NSString* name;
    NSString* value;
    int i;
    
    int nMajor = 0, nMinor = 0;
    NSString* build;
    
    NSArray* lines = [self doCameraCommand:@"getFwVer" timeout:TIMEOUT_DEFAULT];
    if (!lines) return NO;
    
    for (i = 1; i < [lines count]; ++i)   
    {        
        if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue; 
        
        if ([name isEqualToString:@"MAJOR"])
        {
            nMajor = [value intValue];
        }
        
        else if ([name isEqualToString:@"MINOR"])
        {
            nMinor = [value intValue];
        }
        
        else if ([name isEqualToString:@"BUILD"])
        {
            build = value;
        }
    }
    
    // Compose firmware version string...
    m_firmwareVersion = [NSString stringWithFormat:@"%d.%dB%@", nMajor, nMinor, build];
    
    // Done...
    return YES;
}

//------------------------------------------------------------------------------
#pragma mark - Wireless search...

-(void)setWirelessResults:(NSMutableArray*)results
{
    @synchronized(self)
    {
        m_pWirelessSearchResults = results;
    }
}

-(NSArray*)getWirelessResults
{
    NSArray* p;
    
    @synchronized(self)
    {
        p = m_pWirelessSearchResults;
    }
    
    return p;
}

-(void)sendMainThreadEvent:(NSString*)eventName withObject:(id)object
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:object];    
    });
}

-(void)searchWireless
{
    TRACE(@"searchWireless called.");
    
    // Delete existing result set...
    @synchronized(self)
    {
        m_pWirelessSearchResults = nil;
    }
    
    // Initiate asynchronous search...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
    
        // Initiate a search...
        NSArray* lines = [self doCameraCommand:CMD_SEARCH_SSID timeout:TIMEOUT_WIFI_SEARCH];
        if (lines)
        {         
            NSString* name;
            NSString* value;
            int i;
            NSMutableArray* results = [[NSMutableArray alloc] init];
            OrantekWirelessInfo* pInfo = nil;            
            
            // Process each line...
            for (i = 1; i < [lines count]; ++i)
            {
                if (![self getComponentsFrom:[lines objectAtIndex:i] asName:&name andValue:&value]) continue;
                
                // New object...
                if ([name isEqualToString:@"INDEX"])
                {
                    // If there is already an object, and it is valid, add it...
                    if (pInfo && [pInfo isValid])
                    {
                        [results addObject: pInfo];
                    }
                    
                    // Allocate new object...
                    pInfo = [[OrantekWirelessInfo alloc] init];
                    
                    // Set index...
                    pInfo.Index = [value intValue];
                }
                
                else if (pInfo && [name isEqualToString:@"SSID"])
                {
                    pInfo.SSID = value;
                }

                else if (pInfo && [name isEqualToString:@"MODE"])
                {
                    pInfo.Mode = Orantek_IdentifierForCodeName(OrantekWifiModes, [value cStringUsingEncoding:NSUTF8StringEncoding]);
                }
                
                else if (pInfo && [name isEqualToString:@"SECURITY"])
                {
                    pInfo.Security = Orantek_IdentifierForCodeName(OrantekWifiSecurity, [value cStringUsingEncoding:NSUTF8StringEncoding]);
                }

                else if (pInfo && [name isEqualToString:@"ENCRYPTION"])
                {
                    pInfo.Encryption = Orantek_IdentifierForCodeName(OrantekWifiEncryption, [value cStringUsingEncoding:NSUTF8StringEncoding]);
                }

                else if ([name isEqualToString:@"CHANNEL"])
                {
                    pInfo.Channel = [value intValue];
                }

                else if (pInfo && [name isEqualToString:@"SIGNAL"])
                {
                    pInfo.Signal = [value intValue];
                }
            }
            
            // Add the remaining object...
            if (pInfo && [pInfo isValid])
            {
                [results addObject: pInfo];
            }
            
            // Store the results...
            [self setWirelessResults:results];
            
            // Signal GUI thread that new results have arrived...
            [self sendMainThreadEvent:OrantekWirelessSearchSuccess withObject:self];
        }
        else
        {
            // Signal GUI thread that there was a failure...
            [self sendMainThreadEvent:OrantekWirelessSearchFail withObject:self];
        }
                
    });
}


//------------------------------------------------------------------------------
#pragma mark - Asynchrononous updates

-(void)asyncSetIdentity
{
    // Build command string...
    NSString* cmd = [NSString stringWithFormat:@"setIdentity?NAME=%@&CONTACT=%@&LOCATION=%@", [m_name stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [m_contact stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [m_location stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    // Asynchronous dispatch...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        if ([self doCameraCommand:cmd timeout:TIMEOUT_DEFAULT])
        {
            TRACE(@"Successfully updated camera identity.");
            [self sendEventSuccess];
        }
        else
        {
            TRACE(@"Failed to update camera identity.");
            [self sendEventFailure];
        }
    });
}

-(void)asyncSetVideoFlip
{
    // Build command string...
    NSString* cmd = [NSString stringWithFormat:@"setVideoFlip?FLIPH=%d&FLIPV=%d", (int) m_videoFlipHorizontal, (int) m_videoFlipVertical];
    
    // Asynchronous dispatch...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        if ([self doCameraCommand:cmd timeout:TIMEOUT_DEFAULT] )
        {
            TRACE(@"Successfully updated camera video flip.");
            [self sendEventSuccess];
        }
        else
        {
            TRACE(@"Failed to update camera video flip.");
            [self sendEventFailure];
        }
    }); 
}

-(void)asyncSetVideoParams
{
    // Build command string...
    NSString* cmd = [NSString stringWithFormat:@"setVideo?MOONLIGHT=%d&LIGHTFREQ=%d&ROTATE=%d", (int) m_videoMoonlightMode, (int) m_videoLightFrequency, (int) m_videoRotateImage];
    
    // Asynchronous dispatch...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        if ([self doCameraCommand:cmd timeout:TIMEOUT_DEFAULT])
        {
            TRACE(@"Successfully updated camera video params.");
            [self sendEventSuccess];
        }
        else
        {
            TRACE(@"Failed to update camera video params.");
            [self sendEventFailure];
        }
    });
}

-(void)asyncSetAudioParams
{
    // Build command string...
    NSString* cmd = [NSString stringWithFormat:@"setAudio?ENABLE=%d&VOLUME=%d&BITRATE=%d", (int) m_audioEnabled, (int) m_audioVolume, (int) m_audioBitRate];
    
    // Asynchronous dispatch...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        if ([self doCameraCommand:cmd timeout:TIMEOUT_DEFAULT])
        {
            TRACE(@"Successfully updated camera audio params.");
            [self sendEventSuccess];
        }
        else
        {
            TRACE(@"Failed to update camera audio params.");
            [self sendEventFailure];
        }
    });
}

-(void)asyncSetPowerLED
{
    // Build command string...
    NSString* cmd = [NSString stringWithFormat:@"setLed?ENABLE=%d", (int) m_powerLED];
    
    // Asynchronous dispatch...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        if ([self doCameraCommand:cmd timeout:TIMEOUT_DEFAULT])
        {
            TRACE(@"Successfully updated camera power LED.");
            [self sendEventSuccess];
        }
        else
        {
            TRACE(@"Failed to update camera power LED.");
            [self sendEventFailure];
        }
    });
}

-(void)asyncSetNightVision
{
    // Build command string...
    NSString* cmd = [NSString stringWithFormat:@"setNightVision?LEDCTRL=%d&BWCTRL=%d", (int) m_nightIfraredLED, (int) m_nightBlackWhite];
    
    // Asynchronous dispatch...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        if ([self doCameraCommand:cmd timeout:TIMEOUT_DEFAULT])
        {
            TRACE(@"Successfully updated camera night vision params.");
            [self sendEventSuccess];
        }
        else
        {
            TRACE(@"Failed to update camera night vision params.");
            [self sendEventFailure];
        }
    });    
}

-(NSString*)wifiHelper:(const struct ORANTEK_SYMBOL_TABLE*)pTable identifier:(int)identifier
{
    const char* p;
    
    p = Orantek_CodeNameForIdentifier(pTable, identifier);
    if (p)
    {
        NSString* pString = [NSString stringWithFormat:@"%s", p];
        return [pString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    }
    else
    {
        return @"";
    }
}

-(void)asyncSetWirelessEnabled
{
    // Build command string...
    NSString* cmd = [NSString stringWithFormat:@"setWirelessEnable?ENABLE=%d", m_wifiEnabled ? 1 : 0];
    
    // Asynchronous dispatch...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        if ([self doCameraCommand:cmd timeout:TIMEOUT_DEFAULT])
        {
            TRACE(@"Successfully updated wifi enable.");
            [self sendEventSuccess];
        }
        else
        {
            TRACE(@"Failed to update wifi enable.");
            [self sendEventFailure];
        }
    });
}

-(void)asyncSetWireless
{
    // Build command string...
    NSString* cmd = [NSString stringWithFormat:@"setWireless?SSID=%@&MODE=%@&SECURITY=%@&ENCRYPTION=%@&AUTHTYPE=%@&KEYTYPE=%@&WEPIDX=%d&WEPKEY=%@&WPAKEY=%@", [m_wifiSSID stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [self wifiHelper:OrantekWifiModes identifier:m_wifiMode], [self wifiHelper:OrantekWifiSecurity identifier:m_wifiSecurity], [self wifiHelper:OrantekWifiEncryption identifier:m_wifiEncryption], [self wifiHelper:OrantekWifiAuthType identifier:m_wifiAuthType], [self wifiHelper:OrantekWifiKeyType identifier:m_wifiKeyType], m_wifiWEPIDX, [m_wifiWEPKEY stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [m_wifiWPAKEY stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    // Asynchronous dispatch...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        if ([self doCameraCommand:cmd timeout:TIMEOUT_DEFAULT])
        {
            TRACE(@"Successfully updated camera wireless params.");
            [self sendEventSuccess];
        }
        else
        {
            TRACE(@"Failed to update camera wireless params.");
            [self sendEventFailure];
        }
    });
}

-(void)assignWirelessParams:(OrantekWirelessInfo*)params password:(NSString*)password
{
    @synchronized(self)
    {
        m_wifiSSID = params.SSID;
        m_wifiMode = params.Mode;
        m_wifiSecurity = params.Security;
        m_wifiEncryption = params.Encryption;
        m_wifiAuthType = OT_WIFI_AUTHTYPE_AUTO;
        m_wifiKeyType = OT_WIFI_KEYTYPE_HEX;
        m_wifiWEPIDX = 1;
        m_wifiWEPKEY = @"";
        m_wifiWPAKEY = password; 
    }
}

-(void)dumpCoreDetails
{
    @synchronized(self)
    {
        TRACE(@"%@", m_macAddress);
        TRACE(@"%@", m_cameraModel);
        TRACE(@"%@", m_location);
        TRACE(@"%@", m_name);
        TRACE(@"%@", m_port);
    }
}


@end
