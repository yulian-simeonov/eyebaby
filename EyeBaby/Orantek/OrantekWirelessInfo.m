//
//  OrantekWirelessInfo.m
//  EyeBaby
//

#import "OrantekWirelessInfo.h"

@implementation OrantekWirelessInfo

@synthesize Index = _Index;
@synthesize SSID = _SSID;
@synthesize Mode = _Mode;
@synthesize Security = _Security;
@synthesize Encryption = _Encryption;
@synthesize Channel = _Channel;
@synthesize Signal = _Signal;

-(BOOL)isValid
{
    if (!Orantek_IsValidSecurity(_Security)) return NO;
    if (!Orantek_IsValidEncryption(_Encryption)) return NO;
    return YES;
}

-(BOOL)compareSSID:(NSString*)ssid
{
    if ([ssid compare:_SSID] == NSOrderedSame)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#ifdef DEBUG
-(void)dump
{
    TRACE(@".Index: %d", _Index);
    TRACE(@".SSID: \"%@\"", _SSID);
    TRACE(@".Mode: \"%s\"", Orantek_CodeNameForIdentifier(OrantekWifiModes, _Mode));
    TRACE(@".Security: \"%s\"", Orantek_CodeNameForIdentifier(OrantekWifiSecurity, _Security));
    TRACE(@".Encryption: \"%s\"", Orantek_CodeNameForIdentifier(OrantekWifiEncryption, _Encryption));
    TRACE(@".Channel: %d", _Channel);
    TRACE(@".Signal: %d", _Signal);
}
#endif

@end

