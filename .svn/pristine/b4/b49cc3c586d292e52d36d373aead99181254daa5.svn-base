//
//  VideoImage.cpp
//  EyeBaby
//

#include "VideoImage.h"

//
// Constructor
// ===========
//
VideoImage::VideoImage()
{
    int i;
    
    for (i = 0; i < PIC_PLANE_COUNT; ++i)
    {
        m_Buffers[i] = NULL;
        m_BufferSizes[i] = 0;
        m_LineWidths[i] = 0;
        m_Width[i] = 0;
        m_Height[i] = 0;
    }
}

//
// Destructor
// ==========
//
VideoImage::~VideoImage()
{
    int i;
    
    for (i = 0; i < PIC_PLANE_COUNT; ++i)
    {
        if (m_Buffers[i] != NULL)
        {
            free(m_Buffers[i]);
            m_Buffers[i] = NULL;
        }

        m_BufferSizes[i] = 0;
    } 
}

//
// PutImage()
// ==========
//
void VideoImage::PutImage(int nIndex, void* pData, int nLineWidth, int nWidth, int nHeight)
{
    size_t nSize = nLineWidth * nHeight;

    // Allocate space for the image...
    if (nSize != m_BufferSizes[nIndex])
    {        
        m_Buffers[nIndex] = realloc(m_Buffers[nIndex], nSize);
        m_BufferSizes[nIndex] = nSize;
    }
    
    // Copy the image...
    memcpy(m_Buffers[nIndex], pData, nSize);
    m_LineWidths[nIndex] = nLineWidth;
    m_Width[nIndex] = nWidth;
    m_Height[nIndex] = nHeight;
}
