#import <Foundation/Foundation.h>
#import "avformat.h"
#import "avcodec.h"
#import "avio.h"
#import "swscale.h"
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioToolbox.h>

@class MonitorViewController;
@interface RTSPPlayer : NSObject {
	AVFormatContext *pFormatCtx;
	AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVPacket packet;
	AVPicture picture;
	int videoStream;
    int audioStream;
	struct SwsContext *img_convert_ctx;
	int sourceWidth, sourceHeight;
	int outputWidth, outputHeight;
	UIImage *currentImage;
	double duration;
    double currentTime;
    AVCodecContext *_audioCodecContext;
    int16_t *_audioBuffer;
    AVStream *_audioStream;
    NSUInteger _audioBufferSize;
    BOOL _inBuffer;
    NSMutableArray* m_videoPacketQueue;
    NSLock *videoPacketQueueLock;
    BOOL primed;
@public
    MonitorViewController* m_parent;
}

/* Last decoded picture as UIImage */
@property (nonatomic, readonly) UIImage *currentImage;

/* Size of video frame */
@property (nonatomic, readonly) int sourceWidth, sourceHeight;

/* Output image size. Set to the source size by default. */
@property (nonatomic) int outputWidth, outputHeight;

/* Length of video in seconds */
@property (nonatomic, readonly) double duration;

/* Current time of video in seconds */
@property (nonatomic, readonly) double currentTime;

@property (nonatomic, assign) AVCodecContext *_audioCodecContext;
@property (nonatomic, assign) AVStream *_audioStream;

/* Initialize with movie at moviePath. Output dimensions are set to source dimensions. */
-(id)initWithVideo:(NSString *)moviePath usesTcp:(BOOL)usesTcp parent:(id)prnt;

/* Read the next frame from the video stream. Returns false if no frame read (video over). */
-(BOOL)stepFrame;

/* Seek to closest keyframe near specified time */
-(void)seekTime:(double)seconds;

-(void)closeAudio;
- (AVPacket*)readPacket;
-(void)TryRenderVideo:(uint64_t)pts;
@end
