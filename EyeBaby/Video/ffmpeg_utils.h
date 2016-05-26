//
//  ffmpeg_utils.h
//

#ifndef ffmpeg_utils_h
#define ffmpeg_utils_h

#ifdef __cplusplus
extern "C" {
#endif
    
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>   
    
    const char* FFMPEG_GetErrorName(int);
    AVPacket*   FFMPEG_PacketAlloc(void);
    void        FFMPEG_PacketFree(AVPacket*);
    
#ifdef __cplusplus
} // extern "C"
#endif

// Threads...
#include <pthread.h>

#define YIELD_THREAD    pthread_yield_np()

#endif
