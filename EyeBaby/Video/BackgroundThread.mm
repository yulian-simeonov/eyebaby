//
//  BackgroundThread.m
//  EyeBaby
//

#import "BackgroundThread.h"
#include "Config.h"

@implementation BackgroundThread

-(id)init
{
    self = [super init];
    if (self)
    {
        m_bRunning = false;
        m_bSigTerminate = false;
        
        return self;
    }
    else
    {
        return nil;
    }
}

-(BOOL)pumpVideoStream
{
    if (m_pURL == nil)
    {
        NSLog(@"No URL provided.");
        return NO;
    }
    
    // Open the stream...
    if (!m_VideoStream.Open([m_pURL cStringUsingEncoding:NSASCIIStringEncoding], PIX_FMT_RGB24, 0, 0))
    {
        NSLog(@"Failed to open video stream.");
        return NO;
    }
    
#ifndef NDEBUG
    m_VideoStream.Dump(stdout);
#endif
    
    // Initialize...
    m_StreamDelegate.Initialize();
    
    // Pump...
    while (!m_bSigTerminate)
    {
        if (!m_VideoStream.Pump(m_StreamDelegate))
        {
            break;
        }
    }
    
    NSLog(@"Video stream stopped.");
    
    // Clean up...
    m_StreamDelegate.Shutdown();
    m_VideoStream.Close();
    
    // Done...
    return YES;
}

-(void)mainFunc
{
    NSLog(@"Thread started.");
        
    // Video stream pump...
    while (!m_bSigTerminate)
    {
        [self pumpVideoStream];
    }
    
    // Finish...
    NSLog(@"Thread terminated.");
}

-(void)setURL:(NSString*)url;
{
    m_pURL = [NSString stringWithString:url];
}

-(void)start
{
    if (!m_bRunning)
    {
        // Start up...
        m_bRunning = true;
        m_bSigTerminate = false;
        
        // Create and start thread...
        m_pThread = [[NSThread alloc] initWithTarget:self selector:@selector(mainFunc) object:nil];
        [m_pThread start];
    }
}

-(void)stop
{
    if (m_bRunning)
    {
        // Signal thread to terminate...
        m_bSigTerminate = true;
        m_VideoStream.Terminate();
    
#if 0
        // Wait for the thread to finish...
        while (![m_pThread isFinished]);
#endif
        
        // Clean up...
        m_pThread = nil;
        m_bRunning = false;
    }
}

-(BOOL)isRunning
{
    if (m_bRunning) return YES;
    else return NO;
}

-(void)lock
{
    m_VideoStream.Lock();
}

-(void)unlock
{
    m_VideoStream.Unlock();
}

-(BOOL)hasImage
{
    if (m_bRunning && m_VideoStream.HasNewFrame()) return YES;
    else return NO;
}

-(void)getWidth:(int*)pWidth andHeight:(int*)pHeight
{
    *pWidth = m_VideoStream.GetImageWidth();
    *pHeight = m_VideoStream.GetImageHeight();
}

-(const void*)getFrameContent
{
    if (m_bRunning)
    {
        return m_VideoStream.GetFrameContent();
    }
    else
    {
        return NULL;
    }
}

@end
