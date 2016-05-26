//
//  OrantekCameraProperties.h
//  EyeBaby
//

#import <Foundation/Foundation.h>
#import "OrantekWirelessInfo.h"

#define ORANTEK_CAMERA_MAX_VOLUME   14

// Event notifications...
#define OrantekCommandSucceeded         @"OrantekCommandSucceeded"
#define OrantekCommandFailed            @"OrantekCommandFailed"
#define OrantekWirelessSearchSuccess    @"OrantekWirelessSearchSuccess"
#define OrantekWirelessSearchFail       @"OrantekWirelessSearchFail"

@interface OrantekCameraProperties : NSObject
{
@private
    NSMutableArray* m_pWirelessSearchResults;
    
    NSString*   m_macAddress;
    NSString*   m_cameraModel;
    NSString*   m_location;
    NSString*   m_name;
    NSString*   m_port;
    
    NSString*   m_contact;
    
    BOOL        m_videoFlipHorizontal;
    BOOL        m_videoFlipVertical;
    int         m_videoMoonlightMode;
    BOOL        m_videoRotateImage;
    int         m_videoLightFrequency;
    
    BOOL        m_audioEnabled;
    int         m_audioVolume;
    int         m_audioBitRate;

    int         m_nightIfraredLED;
    int         m_nightBlackWhite;
    
    BOOL        m_wifiEnabled;
    
    NSString*   m_wifiSSID;
    int         m_wifiMode;
    int         m_wifiSecurity;
    int         m_wifiEncryption;
    int         m_wifiAuthType;
    int         m_wifiKeyType;
    int         m_wifiWEPIDX;
    NSString*   m_wifiWEPKEY;
    NSString*   m_wifiWPAKEY;
    
    BOOL        m_powerLED;
    
    NSString*   m_firmwareVersion;
}

// Core details...
@property (copy, nonatomic) NSString* macAddress;
@property (copy, nonatomic) NSString* cameraModel;
@property (copy, nonatomic) NSString* location;
@property (copy, nonatomic) NSString* name;
@property (copy, nonatomic) NSString* ipAddress;
@property (copy, nonatomic) NSString* port;

// Extra details...
@property (copy, nonatomic) NSString* contact;

@property (nonatomic) BOOL videoFlipHorizontal;
@property (nonatomic) BOOL videoFlipVertical;
@property (nonatomic) int videoMoonlightMode;
@property (nonatomic) BOOL videoRotateImage;
@property (nonatomic) int videoLightFrequency;

@property (nonatomic) BOOL audioEnabled;
@property (nonatomic) int audioVolume;
@property (nonatomic) int audioBitRate;

@property (nonatomic) int nightIfraredLED;
@property (nonatomic) int nightBlackWhite;

@property (nonatomic) BOOL wifiEnabled;

@property (copy, nonatomic) NSString* wifiSSID;
@property (nonatomic) int wifiMode;
@property (nonatomic) int wifiSecurity;
@property (nonatomic) int wifiEncryption;
@property (nonatomic) int wifiAuthType;
@property (nonatomic) int wifiKeyType;
@property (nonatomic) int wifiWEPIDX;
@property (copy, nonatomic) NSString* wifiWEPKEY;
@property (copy, nonatomic) NSString* wifiWPAKEY;

@property (nonatomic) BOOL powerLED;

@property (copy, nonatomic) NSString* firmwareVersion;

-(id)init;

-(BOOL)isEqualToCamera:(OrantekCameraProperties*)other;
-(BOOL)updateCoreDetails:(OrantekCameraProperties*)src;
-(BOOL)stillConnected;

-(NSString*)getUniversalID;

-(BOOL)getIdentityParams;
-(BOOL)getVideoParams;
-(BOOL)getPowerLEDParams;
-(BOOL)getFlipVideoParams;
-(BOOL)getAudioParams;
-(BOOL)getNightVisionParams;
-(BOOL)getWirelessEnabled;
-(BOOL)getWirelessParams;
-(BOOL)getFirmwareParams;

-(NSArray*)getWirelessResults;
-(void)searchWireless;

-(void)asyncSetIdentity;
-(void)asyncSetVideoFlip;
-(void)asyncSetVideoParams;
-(void)asyncSetAudioParams;
-(void)asyncSetPowerLED;
-(void)asyncSetNightVision;
-(void)asyncSetWirelessEnabled;
-(void)asyncSetWireless;

-(void)assignWirelessParams:(OrantekWirelessInfo*)params password:(NSString*)password;

-(void)dumpCoreDetails;

@end
