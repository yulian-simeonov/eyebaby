//
//  alutils.h
//

#ifndef __ALUTILS__
#define __ALUTILS__

#include <stdio.h>
#include <stdlib.h>

#include <OpenAL/al.h>
#include <OpenAL/alc.h>

#ifdef __cplusplus
extern "C" {
#endif

    const char* AL_GetErrorName(ALenum);

    int AL_Debug(const char*);
    
    int AL_ConvertFloatSamples(uint8_t*, int);
    int AL_ConvertDoubleSamples(uint8_t*, int);
    
#ifdef __cplusplus
} // extern "C"
#endif
        
#endif
