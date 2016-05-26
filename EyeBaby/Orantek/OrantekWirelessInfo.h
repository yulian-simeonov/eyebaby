//
//  OrantekWirelessInfo.h
//  EyeBaby
//

#import <Foundation/Foundation.h>
#include "Orantek.h"

@interface OrantekWirelessInfo : NSObject

@property (nonatomic) int Index;
@property (copy, nonatomic) NSString* SSID;
@property (nonatomic) int Mode;
@property (nonatomic) int Security;
@property (nonatomic) int Encryption;
@property (nonatomic) int Channel;
@property (nonatomic) int Signal;

-(BOOL)isValid;
-(BOOL)compareSSID:(NSString*)ssid;

#ifdef DEBUG
-(void)dump;
#endif

@end
