#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "RTSPPlayer.h"
#include "RTSPServerConfig.h"

typedef enum _AUDIO_STATE {
    AUDIO_STATE_READY           = 0,
    AUDIO_STATE_STOP            = 1,
    AUDIO_STATE_PLAYING         = 2,
    AUDIO_STATE_PAUSE           = 3,
    AUDIO_STATE_SEEKING         = 4
} AUDIO_STATE;

#define AudioQueueCount 10
@interface AudioStreamer : NSObject
{
    NSString *playingFilePath_;
    AudioStreamBasicDescription audioStreamBasicDesc_;
    AudioQueueRef audioQueue_;
    BOOL started_, finished_;
    NSTimeInterval durationTime_, startedTime_;
    NSTimer *seekTimer_;
    NSLock *decodeLock_;
    AVCodecContext *_audioCodecContext;
    AVPacket m_lastPacket;
    
@public
    RTSPPlayer *_streamer;
    int         m_curQueueIdx;
    int                 m_curBufIdx;
    int                 m_playingBufferSize;
    NSInteger state_;
}

- (void)_startAudio;
- (void)_stopAudio;
- (BOOL)createAudioQueue;
- (void)removeAudioQueue;
- (void)audioQueueIsRunningCallback;
- (void)ReadyBuffer:(AVPacket*)packet;
- (id)initWithStreamer:(RTSPPlayer*)streamer;

- (OSStatus)startQueue;
-(void)ResetQueue;
@end
