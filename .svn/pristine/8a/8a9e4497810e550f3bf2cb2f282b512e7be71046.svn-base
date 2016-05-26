//
//  BackgroundThread.h
//  EyeBaby
//

#import <Foundation/Foundation.h>

#include "VideoStream.h"
#include "VideoStreamDelegate.h"

@interface BackgroundThread : NSObject
{
@private
    NSThread*               m_pThread;
    
    bool                    m_bRunning;
    bool                    m_bSigTerminate;
    
    VideoStream             m_VideoStream;
    EyeBabyStreamDelegate   m_StreamDelegate;
    
    NSString*               m_pURL;
}

-(id)init;
-(void)setURL:(NSString*)url;
-(void)start;
-(void)stop;
-(BOOL)isRunning;

-(void)lock;
-(void)unlock;
-(BOOL)hasImage;

-(void)getWidth:(int*)pWidth andHeight:(int*)pHeight;
-(const void*)getFrameContent;

@end
