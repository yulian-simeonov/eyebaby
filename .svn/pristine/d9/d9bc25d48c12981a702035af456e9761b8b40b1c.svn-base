#import "AudioStreamer.h"
#import "RTSPPlayer.h"

void audioQueueOutputCallback(void *inClientData, AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer);
void audioQueueIsRunningCallback(void *inClientData, AudioQueueRef inAQ,
                                 AudioQueuePropertyID inID);

void audioQueueOutputCallback(void *inClientData, AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer)
{
    AudioStreamer *audioController = (AudioStreamer*)inClientData;
    uint64_t pts;
    memcpy(&pts, inBuffer->mUserData, sizeof(uint64_t));
    [audioController->_streamer TryRenderVideo:pts];
    AudioQueueFreeBuffer(inAQ, inBuffer);
    audioController->m_curBufIdx--;
}

void audioQueueIsRunningCallback(void *inClientData, AudioQueueRef inAQ,
                                 AudioQueuePropertyID inID) {
    
    AudioStreamer *audioController = (AudioStreamer*)inClientData;
    [audioController audioQueueIsRunningCallback];
}

@interface AudioStreamer ()
@property (nonatomic, assign) RTSPPlayer *streamer;
@property (nonatomic, assign) AVCodecContext *audioCodecContext;
@end

@implementation AudioStreamer

@synthesize streamer = _streamer;
@synthesize audioCodecContext = _audioCodecContext;

- (id)initWithStreamer:(RTSPPlayer*)streamer {
    if (self = [super init]) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        _streamer = streamer;
        _audioCodecContext = _streamer._audioCodecContext;
    }
    
    return  self;
}

- (void)dealloc
{
    [self removeAudioQueue];
    [super dealloc];
}

- (void)_startAudio
{
    NSLog(@"ready to start audio");
    if (started_) {
        AudioQueueStart(audioQueue_, NULL);
    } else {
        [self createAudioQueue] ;
        [self startQueue];
    }
    
    state_ = AUDIO_STATE_PLAYING;
}

- (void)_stopAudio
{
    if (started_) {
        AudioQueueStop(audioQueue_, YES);
        startedTime_ = 0.0;
        state_ = AUDIO_STATE_STOP;
        finished_ = NO;
    }
}

- (BOOL)createAudioQueue
{
    state_ = AUDIO_STATE_READY;
    finished_ = NO;
    
    audioStreamBasicDesc_.mFormatID = kAudioFormatLinearPCM;
    audioStreamBasicDesc_.mSampleRate = _audioCodecContext->sample_rate;
    audioStreamBasicDesc_.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioStreamBasicDesc_.mFramesPerPacket = 1;
    audioStreamBasicDesc_.mChannelsPerFrame = 1;
    audioStreamBasicDesc_.mBitsPerChannel = 16;
    audioStreamBasicDesc_.mBytesPerPacket = 2;
    audioStreamBasicDesc_.mBytesPerFrame = 2;
    
    OSStatus status = AudioQueueNewOutput(&audioStreamBasicDesc_, audioQueueOutputCallback, (void*)self, NULL, NULL, 0, &audioQueue_);
    if (status != noErr) {
        NSLog(@"Could not create new output.");
        return NO;
    }
    
    status = AudioQueueAddPropertyListener(audioQueue_, kAudioQueueProperty_IsRunning, audioQueueIsRunningCallback, (void*)self);
    if (status != noErr) {
        NSLog(@"Could not add propery listener. (kAudioQueueProperty_IsRunning)");
        return NO;
    }
    m_curBufIdx = 0;
    return YES;
}

- (void)removeAudioQueue
{
    [self _stopAudio];
    started_ = NO;
    
    AudioQueueDispose(audioQueue_, YES);
}

- (void)audioQueueIsRunningCallback
{
    UInt32 isRunning;
    UInt32 size = sizeof(isRunning);
    OSStatus status = AudioQueueGetProperty(audioQueue_, kAudioQueueProperty_IsRunning, &isRunning, &size);
    
    if (status == noErr && !isRunning && state_ == AUDIO_STATE_PLAYING) {
        state_ = AUDIO_STATE_STOP;
        
        if (finished_) {
        }
    }
}

- (void)ReadyBuffer:(AVPacket*)packet
{
    OSStatus status = noErr;
    
    int got_ptr = 0;
    AVFrame* srcFrame = avcodec_alloc_frame();
    int decoded = avcodec_decode_audio4(_audioCodecContext, srcFrame, &got_ptr, packet);
    av_free_packet(packet);
    if (decoded < 0 || got_ptr == 0)
    {
        avcodec_free_frame(&srcFrame);
        return;
    }
    
    SwrContext* convContext = swr_alloc_set_opts( NULL,
                                                 AV_CH_LAYOUT_MONO, AV_SAMPLE_FMT_S16, _audioCodecContext->sample_rate,
                                                 _audioCodecContext->channel_layout, _audioCodecContext->sample_fmt, _audioCodecContext->sample_rate,
                                                 0, NULL);
    swr_init(convContext);
    
    AVFrame* dstFrame = avcodec_alloc_frame();
    dstFrame->nb_samples = srcFrame->nb_samples;
    int buf_size = av_samples_get_buffer_size( NULL, 1, dstFrame->nb_samples, AV_SAMPLE_FMT_S16, 0 );
    uint8_t* out_buf = av_malloc(buf_size);
    avcodec_fill_audio_frame(dstFrame, 1, AV_SAMPLE_FMT_S16, out_buf, buf_size, 0);
    int converted = swr_convert(convContext, (uint8_t**)dstFrame->data, dstFrame->nb_samples, (const uint8_t**)srcFrame->data, srcFrame->nb_samples);
    int out_buf_size = av_samples_get_buffer_size( NULL, 1, converted, AV_SAMPLE_FMT_S16, 0 );
    swr_free(&convContext);
    
    AudioQueueBufferRef buffer;
    if (AudioQueueAllocateBuffer(audioQueue_, _audioCodecContext->sample_rate, &buffer) != noErr)
        return;
    memcpy((uint8_t *)buffer->mAudioData, out_buf, out_buf_size);
    buffer->mAudioDataByteSize = out_buf_size;
    buffer->mUserData = malloc(sizeof(uint64_t));
    memcpy(buffer->mUserData, &packet->pts, sizeof(uint64_t));
    avcodec_free_frame(&srcFrame);
    avcodec_free_frame(&dstFrame);
    av_free(out_buf);
    
    if (buffer->mAudioDataByteSize > 0) {
        status = AudioQueueEnqueueBuffer(audioQueue_, buffer, 0, NULL);
        if (status != noErr) {
            NSLog(@"Could not enqueue buffer.");
        }
        else
            m_curBufIdx++;
    }
}

- (OSStatus)startQueue
{
    OSStatus status = noErr;
    
    if (!started_) {
        status = AudioQueueStart(audioQueue_, NULL);
        if (status == noErr) {
            started_ = YES;
        }
        else {
            NSLog(@"Could not start audio queue.");
        }
    }
    
    return status;
}

-(void)ResetQueue
{
    AudioQueueReset(audioQueue_);
}
@end
