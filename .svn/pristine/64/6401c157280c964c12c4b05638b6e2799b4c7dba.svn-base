//
//  VideoStream.cpp
//
#include <algorithm>

#include "VideoStream.h"

#include "Config.h"

#ifndef NDEBUG
#define AVTRACE(x)  { printf("AVTRACE: "); printf x ; printf("\n"); }
#else
#define AVTRACE(x)  /* Nothing */
#endif

#define AVTRACE_SHOW_TIMES  0

//==============================================================================
/*
                                VideoStream
*/

//
// Constructor
// ===========
//
VideoStream::VideoStream()
{
    pthread_mutex_init(&m_MutexVideoBuffers, NULL);
    
    m_pFormatCtx = NULL;
    m_pVideoCodecCtx = NULL;
    m_pAudioCodecCtx = NULL;
    m_pVideoCodec = NULL;
    m_pAudioCodec = NULL;
    
    m_nVideoStream = -1;
    m_nAudioStream = -1;
    
    m_nVideoTimebase = 0;
    m_nAudioTimebase = 0;
    
    m_pFrameVideoBG = NULL;
    
    m_pFrameAudio = NULL;
    
    m_bNewFrame = false;

    m_bTerminate = false;
}

//
// Destructor
// ==========
//
VideoStream::~VideoStream()
{
    Close();
    
    pthread_mutex_destroy(&m_MutexVideoBuffers);
}

//
// GetNextFrame()
// ==============
//
bool VideoStream::GetNextFrame(VideoRenderer* pRenderer)
{
    bool bResult = false;
    
    // Check parameters...
    if (!pRenderer) return false;
    
    // Lock the mutex...
    pthread_mutex_lock(&m_MutexVideoBuffers);
    
    // Check if there is a new frame...
    if (m_bNewFrame)
    {
        pRenderer->SetImageYUV420P(m_Image);
        m_bNewFrame = false;
            
        bResult = true;        
    }
    
    // Unlock...
    pthread_mutex_unlock(&m_MutexVideoBuffers);
    
    // Done...
    return bResult;
}

//
// InitVideo()
// ===========
//
bool VideoStream::InitVideo(void)
{
    // Check if there is a video stream...
    if (m_nVideoStream < 0)
    {
        return false;
    }
    
    // Get video codec context...
    m_pVideoCodecCtx = m_pFormatCtx->streams[m_nVideoStream]->codec;
    if (m_pVideoCodecCtx == NULL)
    {
        m_nVideoStream = -1;
        return false;
    }
    
    // Get video codec...
    m_pVideoCodec = avcodec_find_decoder(m_pVideoCodecCtx->codec_id);
    if (m_pVideoCodec == NULL)
    {
        m_pVideoCodecCtx = NULL;
        m_nVideoStream = -1;
        return false;      
    }
    
    // Open the video codec...
    if (avcodec_open2(m_pVideoCodecCtx, m_pVideoCodec, NULL) < 0)
    {
        m_pVideoCodec = NULL; 
        m_pVideoCodecCtx = NULL;
        m_nVideoStream = -1;
        return false;      
    }
        
    // Allocate video frame buffers...
    m_pFrameVideoBG = avcodec_alloc_frame();
    
    // Done...
    return true;
}

//
// InitAudio()
// ===========
//
bool VideoStream::InitAudio(void)
{    
    // Check if stream is available...
    if (m_nAudioStream < 0)
    {
        return false;
    }
    
    // Get audio codec...
    m_pAudioCodecCtx = m_pFormatCtx->streams[m_nAudioStream]->codec;
    if (m_pAudioCodecCtx == NULL)
    {
        m_nAudioStream = -1;
        return false;
    }
    
    // Get audio codec...
    m_pAudioCodec = avcodec_find_decoder(m_pAudioCodecCtx->codec_id);
    if (m_pAudioCodec == NULL)
    {
        m_pAudioCodecCtx = NULL;
        m_nAudioStream = -1;
        return false;
    }
    
    // Open the codec...
    if (avcodec_open2(m_pAudioCodecCtx, m_pAudioCodec, NULL) < 0)
    {
        m_pAudioCodec = NULL;
        m_pAudioCodecCtx = NULL;
        m_nAudioStream = -1;
        return false;
    }
    
    // Allocate frame buffer...    
    m_pFrameAudio = avcodec_alloc_frame();
    
    // Done...
    return true;
}

//
// InterruptCallback()
// ===================
//
int VideoStream::InterruptCallback(void* p)
{
    if (p == NULL) return 0;
    if (reinterpret_cast<VideoStream*>(p)->m_bTerminate)
    {
        return 1;
    }
    
    return 0;
}

//
// Open()
// ======
//
int VideoStream::Open(
                       const char*       uri,
                       const char*       format,
                       const char*       rtsp_transport)
{
    int             i, nResult;
    bool            bVideo, bAudio;
    AVInputFormat*  pInputFormat = NULL;
    AVDictionary*   format_opts = NULL;
    
    // Close an already open stream...
    Close();
    
    // Initialize format options...
    if (rtsp_transport)
    {
        av_dict_set(&format_opts, "rtsp_transport", rtsp_transport, 0);
    }
    
    // Initialize format context...
    m_pFormatCtx = avformat_alloc_context();
    m_pFormatCtx->interrupt_callback.callback = InterruptCallback;
    m_pFormatCtx->interrupt_callback.opaque = reinterpret_cast<void*>(this);
    
    // Disable termination at this point...
    m_bTerminate = false;
    
    // Get the input format...
    if (format)
    {
        pInputFormat = av_find_input_format(format);
    }

    // Open the source...
    nResult = avformat_open_input(&m_pFormatCtx, uri, pInputFormat, &format_opts);
    if (nResult != 0)
    {
        av_dict_free(&format_opts);
        return nResult;
    }
    
    // Retrieve stream information...
    nResult = avformat_find_stream_info(m_pFormatCtx, NULL);
    if (nResult < 0)
    {
        avformat_close_input(&m_pFormatCtx);
        av_dict_free(&format_opts);
        return nResult;
    }
    
    // Find the video and audio streams...
    m_nVideoStream = -1;
    m_nAudioStream = -1;
    for (i = 0; i < static_cast<int>(m_pFormatCtx->nb_streams); ++i)
    {
        // Video codec...
        if (m_pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO)
        {
            m_nVideoStream = i;
            m_nVideoTimebase = av_q2d(m_pFormatCtx->streams[i]->time_base);
        }
        
        // Audio codec...
        else if (m_pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO)
        {
            m_nAudioStream = i;
            m_nAudioTimebase = av_q2d(m_pFormatCtx->streams[i]->time_base);
        }
    }
    
    // Initialize video and audio, and return true if at least one succeeds...
    bVideo = InitVideo();
    bAudio = InitAudio();
    
    // Clean up...
    av_dict_free(&format_opts);
    
    // Initialize time...
    m_nPlaybackTime = 0.0;
    m_nLastTimeSample = clock();
    
    // Done...
    if (bVideo || bAudio) return 0;
    else return AVERROR_STREAM_NOT_FOUND;
}

//
// Close()
// =======
//
void VideoStream::Close(void)
{        
    if (m_pFrameAudio != NULL)
    {
        av_free(m_pFrameAudio);
        m_pFrameAudio = NULL;
    }
    
    pthread_mutex_lock(&m_MutexVideoBuffers);
    {
        if (m_pFrameVideoBG != NULL)
        {
            av_free(m_pFrameVideoBG);
            m_pFrameVideoBG = NULL;
        }
    }
    pthread_mutex_unlock(&m_MutexVideoBuffers);
    
    if (m_pAudioCodecCtx != NULL)
    {
        avcodec_close(m_pAudioCodecCtx);
        m_pAudioCodecCtx = NULL;
    }
    
    if (m_pVideoCodecCtx != NULL)
    {
        avcodec_close(m_pVideoCodecCtx);
        m_pVideoCodecCtx = NULL;
    }
    
    if (m_pFormatCtx != NULL)
    {
        avformat_close_input(&m_pFormatCtx);
    }
    
    m_bNewFrame = false;
}

//
// Pump()
// ======
//
bool VideoStream::Pump(VideoStreamDelegate& delegate)
{
    AVPacket packet;
    AVPacket pkt_temp;
    int      nLength;
    int      nFrameFinished;
    clock_t  nTime;
    
    // Update time...
    nTime = clock();
    m_nPlaybackTime += ((double) (nTime - m_nLastTimeSample)) / (double) CLOCKS_PER_SEC;
    m_nLastTimeSample = nTime;
    
    // Read next frame...
    if (av_read_frame(m_pFormatCtx, &packet) < 0)
    {
        AVTRACE(("Error reading frame."));
        return false;
    }
    
    // Is this a packet from the video stream?
    if (packet.stream_index == m_nVideoStream)
    {                        
        // Initialize temporary packet...
        pkt_temp = packet;
        
        // Until packet is completely processed...
        while (pkt_temp.size > 0)
        {
            // Prepare...
            nFrameFinished = 0;
            
            // Decode the packet...
            nLength = avcodec_decode_video2(
                                            m_pVideoCodecCtx,
                                            m_pFrameVideoBG,
                                            &nFrameFinished,
                                            &pkt_temp);
            
            // Allow background threads to work...
            YIELD_THREAD;
            
            // Check...
            if (nLength < 0)
            {                
                pkt_temp.size = 0;
                break;
            }
            
            // Advance...
            pkt_temp.size -= nLength;
            pkt_temp.data += nLength;

            // Did we get the video frame?
            if (nFrameFinished)
            {
#if AVTRACE_SHOW_TIMES
                AVTRACE(("VF: %f %f", (double) m_pFrameVideoBG->pkt_pts * m_nVideoTimebase, m_nPlaybackTime));
#endif

                // Grab the presentation time...
                m_pFrameVideoBG->pts = pkt_temp.pts;
                
                // Allow background threads to work...
                YIELD_THREAD;

                // Lock mutex...
                pthread_mutex_lock(&m_MutexVideoBuffers);
                    
                // No new frame...
                if (!m_bNewFrame)
                {

                    // Copy the image into another buffer...
                    m_Image.PutImage(
                                     PIC_PLANE_Y,
                                     m_pFrameVideoBG->data[0],
                                     m_pFrameVideoBG->linesize[0],
                                     m_pVideoCodecCtx->width,
                                     m_pVideoCodecCtx->height);
                    m_Image.PutImage(
                                     PIC_PLANE_U,
                                     m_pFrameVideoBG->data[1],
                                     m_pFrameVideoBG->linesize[1],
                                     m_pVideoCodecCtx->width / 2,
                                     m_pVideoCodecCtx->height / 2);
                    m_Image.PutImage(
                                     PIC_PLANE_V,
                                     m_pFrameVideoBG->data[2],
                                     m_pFrameVideoBG->linesize[2],
                                     m_pVideoCodecCtx->width / 2,
                                     m_pVideoCodecCtx->height / 2);

                    // Set new frame...
                    m_bNewFrame = true;
                }
                    
                // Unlock mutex...
                pthread_mutex_unlock(&m_MutexVideoBuffers);

                // Allow background threads to work...
                YIELD_THREAD;
            }
        }
    }
    
    // Is this a packet from the audio stream?
    else if (packet.stream_index == m_nAudioStream && m_pFrameAudio != NULL)
    {        
        // Initialize temporary packet...
        pkt_temp = packet;
        
        // Until packet is completely processed...
        while (pkt_temp.size > 0)
        {
            // Decode the packet...
            nLength = avcodec_decode_audio4(m_pAudioCodecCtx, m_pFrameAudio, &nFrameFinished, &pkt_temp);
            
            // Allow background threads to work...
            YIELD_THREAD;

            // Check result...
            if (nLength < 0)
            {
                pkt_temp.size = 0;
                break;
            }
        
            // Advance...
            pkt_temp.size -= nLength;
            pkt_temp.data += nLength;

            // Got a frame?
            if (nFrameFinished)
            {                    
#if AVTRACE_SHOW_TIMES
                AVTRACE(("AF: %f %f", (double) m_pFrameAudio->pkt_pts * m_nAudioTimebase, m_nPlaybackTime));
#endif
                
                // Allow background threads to work...
                YIELD_THREAD;

                // Get the size of the data...
                int nDataSize = av_samples_get_buffer_size(NULL, m_pAudioCodecCtx->channels, m_pFrameAudio->nb_samples, m_pAudioCodecCtx->sample_fmt, 1);
                
                // Displatch the samples...
                delegate.DispatchAudio(m_pAudioCodecCtx, m_pFrameAudio->data[0], nDataSize);
                
                // Allow background threads to work...
                YIELD_THREAD;
            }
        }
    }
    
    // Free the packet that was allocated by av_read_frame...
    av_free_packet(&packet);
    
    // Done...
    return true;
}

//
// Terminate
// =========
//
void VideoStream::Terminate(void)
{
    m_bTerminate = true;
}

//
// Dump()
// ======
//
void VideoStream::Dump(FILE* pOut) const
{
    // Video codec...
    if (m_pVideoCodecCtx != NULL)
    {
        fprintf(pOut, "Video:\n");
        fprintf(pOut, " Width: %d\n", m_pVideoCodecCtx->width);
        fprintf(pOut, " Height: %d\n", m_pVideoCodecCtx->height);
        fprintf(pOut, "\n");
    }
    
    // Audio codec...
    if (m_pAudioCodecCtx != NULL)
    {
        fprintf(pOut, "Audio:\n");
        fprintf(pOut, " Channels: %d\n", static_cast<int>(m_pAudioCodecCtx->channels));
        fprintf(pOut, " Sample Frequency (Hz): %d\n", static_cast<int>(m_pAudioCodecCtx->sample_rate));
        fprintf(pOut, " Sample format: %d (%s)\n", static_cast<int>(m_pAudioCodecCtx->sample_fmt), av_get_sample_fmt_name(m_pAudioCodecCtx->sample_fmt));
        fprintf(pOut, " Bytes per sample: %d\n", static_cast<int>(av_get_bytes_per_sample(m_pAudioCodecCtx->sample_fmt)));
        fprintf(pOut, " Frame size: %d\n", static_cast<int>(m_pAudioCodecCtx->frame_size));
        fprintf(pOut, "\n");
    }
}

//==============================================================================

/* End of File */
