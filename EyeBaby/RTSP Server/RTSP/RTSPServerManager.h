//
//  RTSPServer.h
//  EyeBaby
//
//  Created by     on 11/20/13.
//
//

#import <Foundation/Foundation.h>
#import "ifaddrs.h"
#import "arpa/inet.h"
#include "MyMediaSource.h"
#include "BasicUsageEnvironment.hh"
#include "MyVideoSubsession.h"
#include "MyAudioSubsession.h"

@interface RTSPServerManager : NSObject
{
    NSString* m_serverURL;
    TaskScheduler* m_pScheduler;
    UsageEnvironment* m_pEnvironment;
    RTSPServer* m_pRTSPServer;
    ServerMediaSession* m_serverMediaSession;
    MyMediaSource* m_pMediaSource;
    char        m_bStop;
@public
    bool        m_bRunning;
}
-(bool)Run;
-(void)End;
-(void)AddVideo:(AVPacket*)packet;
-(void)AddAudio:(AVPacket*)packet;
-(NSString*)GetServerUrl;
@end