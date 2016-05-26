//
//  VideoStreamController.h
//  EyeBaby
//

#import <Foundation/Foundation.h>

#include "VideoStream.h"
#include "VideoStreamDelegate.h"
#include "VideoRender.h"
#include "Orantek.h"

@interface VideoStreamController : NSObject
{
@private    
    BOOL                                    m_bRunning;
    
    NSThread*                               m_pThreadStreamPump;
    
    const struct ORANTEK_STREAM_INFO*       m_pStreamInfo;
    int                                     m_nStreamNumber;
    NSString*                               m_Transport;
    NSString*                               m_Username;
    NSString*                               m_Password;
    NSString*                               m_ipAddress;

    VideoStream                             m_VideoStream;
    EyeBabyStreamDelegate                   m_StreamDelegate;
}

-(id)init;

-(void)setStreamInfo:(const struct ORANTEK_STREAM_INFO*)pStreamInfo;
-(void)setStreamNumber:(int)num;
-(void)setTransportProtocol:(NSString*)protocol;
-(void)setUsername:(NSString*)username password:(NSString*)password;
-(void)setAddress:(NSString*)ip_address;

-(void)start;
-(void)stop;
-(BOOL)isRunning;

-(BOOL)getNextFrame:(VideoRenderer*)renderer;

@end
