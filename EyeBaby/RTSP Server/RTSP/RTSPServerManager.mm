//
//  RTSPServer.m
//  EyeBaby
//
//  Created by     on 11/20/13.
//
//

#import "RTSPServerManager.h"

@implementation RTSPServerManager

-(id)init
{
    if (self = [super init])
    {
        m_pScheduler = NULL;
        m_pEnvironment = NULL;
        m_pMediaSource = NULL;
        m_bStop = 0;
        m_bRunning = false;
        m_serverURL = nil;
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
    if (m_serverURL)
        [m_serverURL release];
}

-(void)BackgroundRun
{
    m_bRunning = true;
    m_pEnvironment->taskScheduler().doEventLoop(&m_bStop);
    m_bRunning = false;
}

-(bool)Run
{
    if (m_pScheduler != NULL)
        return true;
    
    bool fSuccess = false;
    do {
        m_pScheduler = BasicTaskScheduler::createNew();
        if (!m_pScheduler)
            break;
        
        m_pEnvironment = BasicUsageEnvironment::createNew(*m_pScheduler);
        if (!m_pEnvironment)
            break;
        
        m_pRTSPServer = RTSPServer::createNew(*m_pEnvironment, 0);
        if (!m_pRTSPServer)
            break;
        
        m_pMediaSource = MyMediaSource::createNew(*m_pEnvironment);
        if (!m_pMediaSource)
            break;
        
        m_serverMediaSession = ServerMediaSession::createNew(*m_pEnvironment, "iBaby");
        if (!m_serverMediaSession)
            break;

        m_serverMediaSession->addSubsession(MyVideoSubsession::createNew(*m_pEnvironment, *m_pMediaSource, VIDEO_BITRATE));
        m_serverMediaSession->addSubsession(MyAudioSubsession::createNew(*m_pEnvironment, *m_pMediaSource, AUDIO_BITRATE));
        
        m_pRTSPServer->addServerMediaSession(m_serverMediaSession);
        m_serverURL = [[NSString stringWithUTF8String:m_pRTSPServer->rtspURL(m_serverMediaSession)] retain];
        [self performSelectorInBackground:@selector(BackgroundRun) withObject:nil];
        fSuccess = true;
    } while (false);
    
    if (!fSuccess)
        [self End];
    
    return fSuccess;
}

-(void)End
{
    m_bStop = 1;
    while (true) {
        if(!m_bRunning)
            break;
        sleep(0.01f);
    }
    
    if(m_pRTSPServer)
    {
        m_pRTSPServer->closeAllClientSessionsForServerMediaSession(m_serverMediaSession);
        Medium::close(m_pRTSPServer);
        m_pRTSPServer = NULL;
    }
    
    if (m_pMediaSource)
    {
        Medium::close(m_pMediaSource);
        m_pMediaSource = NULL;
    }
    
    if (m_pEnvironment)
    {
        m_pEnvironment->reclaim();
        m_pEnvironment = NULL;
    }
    
    if (m_pScheduler)
    {
        delete m_pScheduler;
        m_pScheduler = NULL;
    }
}

-(void)AddVideo:(AVPacket*)packet
{
    if (m_pMediaSource && packet)
        m_pMediaSource->AddVideo(packet);
}

-(void)AddAudio:(AVPacket*)packet
{
    if (m_pMediaSource && packet)
        m_pMediaSource->AddAudio(packet);
}

-(NSString*)GetServerUrl
{
    return m_serverURL;
}
@end
