//
//  VideoImage.h
//  EyeBaby
//

#ifndef EyeBaby_VideoImage_h
#define EyeBaby_VideoImage_h

#include "ffmpeg_utils.h"

enum
{
    PIC_PLANE_Y,
    PIC_PLANE_U,
    PIC_PLANE_V,
    
    PIC_PLANE_COUNT
};

//
// VideoImage
// ==========
//
class VideoImage
{
private:
    void*   m_Buffers[PIC_PLANE_COUNT];
    size_t  m_BufferSizes[PIC_PLANE_COUNT];
    int     m_LineWidths[PIC_PLANE_COUNT];
    int     m_Width[PIC_PLANE_COUNT];
    int     m_Height[PIC_PLANE_COUNT];
    
public:
    VideoImage();
    ~VideoImage();
    
    void PutImage(int, void*, int, int, int);
        
    inline const void* GetImage(int n) const {return m_Buffers[n];}
    inline int GetWidth(int n) const {return m_Width[n];}
    inline int GetHeight(int n) const {return m_Height[n];}
    inline size_t GetLineWidth(int n) const {return m_LineWidths[n];}
                                                      
};

#endif
