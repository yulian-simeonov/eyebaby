//
//  alutils.cpp
//

#include <pthread.h>
#include <limits.h>
#include <unistd.h>

#include "alutils.h"
#include "Config.h"

#ifndef MAXSHORT
#define MAXSHORT SHRT_MAX
#endif

//
// AL_GetErrorName()
// =================
//
const char* AL_GetErrorName(ALenum nError)
{
    const char* pszText = NULL;

    switch (nError)
    {
        case AL_NO_ERROR: pszText = "AL_NO_ERROR"; break;
        case AL_INVALID_NAME: pszText = "AL_INVALID_NAME"; break;
        case AL_INVALID_ENUM: pszText = "AL_INVALID_ENUM"; break;
        case AL_INVALID_VALUE: pszText = "AL_INVALID_VALUE"; break;
        case AL_INVALID_OPERATION: pszText = "AL_INVALID_OPERATION"; break;
        case AL_OUT_OF_MEMORY: pszText = "AL_OUT_OF_MEMORY"; break;
    }
    
    return pszText;
}

//
// AL_Debug()
// ==========
//
int AL_Debug(const char* pszPrefix)
{
    ALenum nError;
    const char* pszError;
    
    nError = alGetError();
    if (nError != AL_NO_ERROR)
    {
        pszError = AL_GetErrorName(nError);
        if (pszError != NULL)
        {
            printf("%s: %s\n", pszPrefix, pszError);
        }
        else
        {
            printf("%s: %d\n", pszPrefix, static_cast<int>(nError));
        }
        
        return 1;
    } 
    else
    {
        return 0;
    }
}

//
// AL_ConvertFloatSamples()
// ========================
//
int AL_ConvertFloatSamples(uint8_t* pBuffer, int len)
{
    float*   pBufferFloat;
    int16_t* pBufferInt;
    int      i;
    
    // Set up iterators...
    pBufferFloat = reinterpret_cast<float*>(pBuffer);
    pBufferInt = reinterpret_cast<int16_t*>(pBuffer);
    
    // Iterate...
    for (i = 0, len /= sizeof(float); i < len; ++i)
    {
        *pBufferInt++ = static_cast<int16_t>(*pBufferFloat++ * MAXSHORT);
    }
    
    // Done...
    return len * sizeof(int16_t);
}

//
// AL_ConvertDoubleSamples()
// =========================
//
int AL_ConvertDoubleSamples(uint8_t* pBuffer, int len)
{
    double*  pBufferFloat;
    int16_t* pBufferInt;
    int      i;
    
    // Set up iterators...
    pBufferFloat = reinterpret_cast<double*>(pBuffer);
    pBufferInt = reinterpret_cast<int16_t*>(pBuffer);
    
    // Iterate...
    for (i = 0, len /= sizeof(double); i < len; ++i)
    {
        *pBufferInt++ = static_cast<int16_t>(*pBufferFloat++ * MAXSHORT);
    }
    
    // Done...
    return len * sizeof(int16_t);
}

