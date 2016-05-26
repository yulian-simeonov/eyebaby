//
//  VideoStreamDelegate.h
//

#ifndef VideoStreamDelegate_h
#define VideoStreamDelegate_h

#include "alutils.h"
#include "VideoStream.h"

//
// EyeBabyStreamDelegate
// =====================
//
class EyeBabyStreamDelegate : public VideoStreamDelegate
{
private:
    static const int    c_nMaxBuffers = 16;
    
    ALuint              m_nSource;
    ALuint              m_nBuffers[c_nMaxBuffers];
    ALint               m_nBufferCount;
    
public:
    EyeBabyStreamDelegate();
    
    void Initialize(void);
    void Shutdown(void);
    
    virtual void DispatchAudio(AVCodecContext*, uint8_t*, int);
};

#endif
