//
//  VideoRender.h
//  EyeBaby
//

#ifndef EyeBaby_VideoRender_h
#define EyeBaby_VideoRender_h

#ifndef __cplusplus
#error This file requires C++
#endif

#include "glutils.h"
#include "ffmpeg_utils.h"
#include "VideoImage.h"

class VideoRenderer
{
private:
    GLuint                      m_nVertexBuffer;
    GLuint                      m_nProgram;
    
    GLuint                      m_nAttribPosition;
    GLuint                      m_nAttribTexCoord;
    
    GLuint                      m_nUniformTransform;
    GLuint                      m_nUniformTexScaleY;
    GLuint                      m_nUniformTexScaleUV;
    GLuint                      m_nUniformTexY;
    GLuint                      m_nUniformTexU;
    GLuint                      m_nUniformTexV;
    
    GLuint                      m_nTextures[3];
    
    int                         m_nFrameWidth;
    int                         m_nFrameHeight;
    
    GLuint                      CreateTextureYUV420P(GLenum, int, int, const GLubyte*);
    bool                        CreateProgram(const char*, const char*);

public:
    VideoRenderer();
    
    bool Initialize(const char*, const char*);
    void Shutdown(void);
    
    void SetImageYUV420P(VideoImage&);
    
    void Render(GLfloat, GLfloat);
};


#endif
