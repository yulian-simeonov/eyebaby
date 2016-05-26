//
//  VideoStreamController.mm
//  EyeBaby
//

#import "VideoStreamController.h"
#include "Config.h"

@implementation VideoStreamController

-(id)init
{
    self = [super init];
    if (self)
    {
        m_pStreamInfo = NULL;
        m_nStreamNumber = 0;
        
        m_bRunning = NO;
    }
    
    return self;
}

//------------------------------------------------------------------------------

-(const char*) urlencode:(NSString*)str
{
    return [[str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] cStringUsingEncoding:NSASCIIStringEncoding];
}

//------------------------------------------------------------------------------

-(BOOL)pumpVideoStream
{
    char uri[128];
    char transport[32];
    int nResult;
        
    if (!m_pStreamInfo)
    {
        TRACE(@"No stream details provided.");
        return NO;
    }
    
    // Create URI...
    Orantek_CreateStreamURI(
                            m_pStreamInfo,
                            uri, 128,
                            [self urlencode:m_Username],
                            [self urlencode:m_Password],
                            [self urlencode:m_ipAddress],
                            m_nStreamNumber);
    TRACE(@"URI: %s", uri);
    
    // Transport format...
    strcpy(transport, [m_Transport cStringUsingEncoding:NSASCIIStringEncoding]);
    
    // Open the stream...
    nResult = m_VideoStream.Open(uri, m_pStreamInfo->force_format, transport);
    if (nResult != 0)
    {
        char buffer[128];
        /*
         FIXME!!! NEED MORE INTELLIGENT ERROR HANDLING
         */
        
        TRACE(@"Failed: %d %s", nResult, FFMPEG_GetErrorName(nResult));
        av_strerror(nResult, buffer, 128);
        TRACE(@"%s", buffer);
        return NO;
    }
    
    YIELD_THREAD;
    
#ifndef NDEBUG
    m_VideoStream.Dump(stdout);
#endif
    
    YIELD_THREAD;
    
    // Initialize the stream delegate...
    m_StreamDelegate.Initialize();
    
    YIELD_THREAD;
    
    TF_CHECKPOINT(@"VIDEO_START");
    
    // Pump...
    while (![[NSThread currentThread] isCancelled])
    {
        // Let other threads have a go...
        YIELD_THREAD;
        
        if (!m_VideoStream.Pump(m_StreamDelegate))
        {
            break;
        }
    }

    TF_CHECKPOINT(@"VIDEO_END");
    
    // Clean up...
    m_StreamDelegate.Shutdown();
    m_VideoStream.Close();
    
    // Done...
    return YES;
}

-(void)streamPumpMain
{
    @autoreleasepool {
        
        TRACE(@"Camera view thread started.");
        
        // Video stream pump...
        while (![[NSThread currentThread] isCancelled])
        {
            // Pump the stream...
            [self pumpVideoStream];
        }
        
        // Finish...  
        TRACE(@"Camera view thread terminated.");
        
    }
}

//------------------------------------------------------------------------------

-(void)setStreamInfo:(const struct ORANTEK_STREAM_INFO*)pStreamInfo
{
    @synchronized(self)
    {
        m_pStreamInfo = pStreamInfo;
    }
}

-(void)setStreamNumber:(int)num
{
    @synchronized(self)
    {
        m_nStreamNumber = num;
    }
}

-(void)setTransportProtocol:(NSString*)protocol
{
    @synchronized(self)
    {
        m_Transport = protocol;
    }
}

-(void)setUsername:(NSString*)username password:(NSString*)password
{
    @synchronized(self)
    {
        m_Username = username;
        m_Password = password;
    }
}

-(void)setAddress:(NSString*)ip_address
{
    @synchronized(self)
    { 
        m_ipAddress = ip_address;
    }
}

//------------------------------------------------------------------------------

-(void)start
{
    @synchronized (self)
    {
        if (!m_bRunning)
        {
            // Start up...
            m_bRunning = YES;
        
            // Create and start the worker thread...
            m_pThreadStreamPump = [[NSThread alloc] initWithTarget:self selector:@selector(streamPumpMain) object:nil];
            [m_pThreadStreamPump start];
        }
    }
}

-(void)stop
{
    @synchronized (self)
    {
        if (m_bRunning)
        {
            // No longer running...
            m_bRunning = NO;
            
            // Instruct the video stream to terminate...
            m_VideoStream.Terminate();
            
            // Stop stream pump thread...
            [m_pThreadStreamPump cancel];
            m_pThreadStreamPump = nil;
        }
    }
}

-(BOOL)isRunning
{
    @synchronized (self)
    {
        return m_bRunning;
    }
}

-(BOOL)getNextFrame:(VideoRenderer*)renderer
{
    return m_VideoStream.GetNextFrame(renderer);
}

@end
