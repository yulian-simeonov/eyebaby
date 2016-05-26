//
//  VideoStream.h
//

#ifndef EyeBaby_VideoStream_h
#define EyeBaby_VideoStream_h

#ifndef __cplusplus
#error Requires C++
#endif

// FFMPEG...
#include "ffmpeg_utils.h"

// C/C++
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "VideoImage.h"
#include "VideoRender.h"

//
// VideoStreamDelegate
// ===================
//
class VideoStreamDelegate
{
public:
    virtual void   DispatchAudio(AVCodecContext*, uint8_t*, int) = 0;
};

//==============================================================================

//
// VideoStream
// ===========
//
class VideoStream
{
private:
    pthread_mutex_t      m_MutexVideoBuffers;
    
    AVFormatContext*     m_pFormatCtx;
    AVCodecContext*      m_pVideoCodecCtx;
    AVCodecContext*      m_pAudioCodecCtx;
    AVCodec*             m_pVideoCodec;
    AVCodec*             m_pAudioCodec;
    
    int                  m_nVideoStream;
    int                  m_nAudioStream;
    
    double               m_nVideoTimebase;
    double               m_nAudioTimebase;
    
    AVFrame*             m_pFrameVideoBG;
    AVFrame*             m_pFrameAudio;
    
    VideoImage           m_Image;
    
    double               m_nPlaybackTime;
    clock_t              m_nLastTimeSample;
    
    bool                 m_bNewFrame;

    bool                 m_bTerminate;
    
    bool                 InitVideo(void);
    bool                 InitAudio(void);

    static int           InterruptCallback(void*);
    
public:
    VideoStream();
    ~VideoStream();
    
    bool GetNextFrame(VideoRenderer*);
    
    int  Open(const char*, const char*, const char*);
    void Close(void);
    
    bool Pump(VideoStreamDelegate&);

    void Terminate(void);
    
    void Dump(FILE*) const;
};

#endif // EyeBaby_VideoStream_h
