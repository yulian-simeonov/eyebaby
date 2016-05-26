//
//  VideoStreamDelegate.cpp
//  EyeBaby
//

#include "VideoStreamDelegate.h"
#include "Config.h"

//
// Constructor
// ===========
//
EyeBabyStreamDelegate::EyeBabyStreamDelegate()
{
    m_nSource = 0;
    m_nBufferCount = 0;
}

//
// Initialize()
// ============
//
void EyeBabyStreamDelegate::Initialize(void)
{
    alGenSources(1, &m_nSource);
}

//
// Shutdown()
// ==========
//
void EyeBabyStreamDelegate::Shutdown(void)
{
    // Stop the source...
    alSourceStop(m_nSource);
    
    // Detatch buffers...
    alSourcei(m_nSource, AL_BUFFER, 0);

    // Delete buffers...
    alDeleteBuffers(m_nBufferCount, m_nBuffers);
    m_nBufferCount = 0;

    // Delete the source...
    alDeleteSources(1, &m_nSource);
    m_nSource = 0;
}

//
// DispatchAudio()
// ===============
//
void EyeBabyStreamDelegate::DispatchAudio(
                                          AVCodecContext*   pAudioCodecCtx,
                                          uint8_t*          pBuffer,
                                          int               nLen)
{
    ALuint  nBuffer;
    ALint   nValue;
    ALenum  nFormat;
    bool    bSkip = false;
    
    // Check object state..
    if (!m_nSource) return;
            
    // Check length...
    if (nLen <= 0)
    {
        return;
    }
    
    // Check number of channels...   
    if (pAudioCodecCtx->channels < 1 || pAudioCodecCtx->channels > 2)
    {
        return;
    }
    
    // If there are too many buffers, skip...
    alGetSourcei(m_nSource, AL_BUFFERS_QUEUED, &nValue);
    if (nValue >= c_nMaxBuffers)
    {
        bSkip = true;
    }

    // Check format...
    switch (pAudioCodecCtx->sample_fmt)
    {
        case AV_SAMPLE_FMT_U8:
            if (pAudioCodecCtx->channels > 1)
            {
                nFormat = AL_FORMAT_STEREO8;
            }
            else
            {
                nFormat = AL_FORMAT_MONO8;
            }
            break;
            
        case AV_SAMPLE_FMT_S16:
            if (pAudioCodecCtx->channels > 1)
            {
                nFormat = AL_FORMAT_STEREO16;
            }
            else
            {
                nFormat = AL_FORMAT_MONO16;
            }
            break;
            
        case AV_SAMPLE_FMT_S32:
            // FIXME!!! CONVERT TO 16-BIT
            return;         
            
        case AV_SAMPLE_FMT_FLT:
            nLen = AL_ConvertFloatSamples(pBuffer, nLen);
            if (pAudioCodecCtx->channels > 1)
            {
                nFormat = AL_FORMAT_STEREO16;
            }
            else
            {
                nFormat = AL_FORMAT_MONO16;
            }
            break;
            
        case AV_SAMPLE_FMT_DBL:
            nLen = AL_ConvertDoubleSamples(pBuffer, nLen);
            if (pAudioCodecCtx->channels > 1)
            {
                nFormat = AL_FORMAT_STEREO16;
            }
            else
            {
                nFormat = AL_FORMAT_MONO16;
            }
            break;
            
        default:
            return;
    }

    // Get a used buffer if available...
    alGetSourcei(m_nSource, AL_BUFFERS_PROCESSED, &nValue);
    if (nValue > 0)
    {
        // Get an available buffer...
        alSourceUnqueueBuffers(m_nSource, 1, &nBuffer);
    }
    
    // Else create a new one...
    else
    {
        // Skipping...
        if (bSkip)
        {
            return;
        }
        
        // Generate a new buffer...
        alGenBuffers(1, &nBuffer);
        m_nBuffers[m_nBufferCount++] = nBuffer;
    }
    
    // Check status...
    if (nBuffer == 0)
    {
        return;
    }
    
    // Buffer the data...
    alBufferData(
                 nBuffer,
                 nFormat,
                 reinterpret_cast<const ALvoid*>(pBuffer),
                 static_cast<ALsizei>(nLen),
                 static_cast<ALsizei>(pAudioCodecCtx->sample_rate));
    
    // Enqueue the buffer...
    alSourceQueueBuffers(m_nSource, 1, &nBuffer);
        
    // Play (if not already)...
    alGetSourcei(m_nSource, AL_SOURCE_STATE, &nValue);
    if (nValue != AL_PLAYING)
    {
        alSourcePlay(m_nSource);
    }
}

