//
//  VideoRender.cpp
//  EyeBaby
//

#include "VideoRender.h"

//==============================================================================

//
// Note: Testing shows that textures dimensions definitely must be a power-of-two.
//
#define TEX_Y_WIDTH     2048
#define TEX_Y_HEIGHT    1024

#define TEX_UV_WIDTH    (TEX_Y_WIDTH / 2)
#define TEX_UV_HEIGHT   (TEX_Y_HEIGHT / 2)

#define TEX_Y_BUFFER_SIZE (TEX_Y_WIDTH * TEX_Y_HEIGHT)
#define TEX_UV_BUFFER_SIZE (TEX_UV_WIDTH * TEX_UV_HEIGHT)

#define TEX_Y_DEFAULT   0
#define TEX_UV_DEFAULT  127

//==============================================================================

struct VERTEX
{
    GLfloat position[2];
    GLfloat tex_coord[2];
};

static struct VERTEX g_Vertices[] =
{
    { {-1, -1}, {0, 0} },
    { {1, -1}, {1, 0} },
    { {1, 1}, {1, 1} },
    { {-1, 1}, {0, 1} }
};

//==============================================================================

//
// Constructor
// ===========
//
VideoRenderer::VideoRenderer()
{
    m_nVertexBuffer = 0;
    
    m_nProgram = 0;
    m_nAttribPosition = 0;
    m_nAttribTexCoord = 0;
    m_nUniformTransform = 0;
    m_nUniformTexScaleY = 0;
    m_nUniformTexScaleUV = 0;
    m_nUniformTexY = 0;
    m_nUniformTexU = 0;
    m_nUniformTexV = 0;
    
    m_nTextures[0] = 0;
    m_nTextures[1] = 0;
    m_nTextures[2] = 0;
    
    m_nFrameWidth = 640;
    m_nFrameHeight = 480;
}

//
// CreateTextureYUV420P()
// ======================
//
GLuint VideoRenderer::CreateTextureYUV420P(GLenum nTexUnit, int nWidth, int nHeight, const GLubyte* pInitialData)
{
    GLuint nTex;
    
    // Create texture...
    glGenTextures(1, &nTex);
    if (nTex)
    {
        glActiveTexture(nTexUnit);
        glBindTexture(GL_TEXTURE_2D, nTex);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, nWidth, nHeight, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, pInitialData);
        
        glEnable(GL_TEXTURE_2D);        
    }

    return nTex;
}

//
// CreateProgram()
// ===============
//
bool VideoRenderer::CreateProgram(const char* pVertexShader, const char* pFragmentShader)
{
    GLuint nVertexShader, nFragmentShader;
    GLint nStatus;
    bool bResult = true;
    
    // Create shader program...
    m_nProgram = glCreateProgram();
    if (!m_nProgram) return false;
    
    // Load vertex shader...
    nVertexShader = GL_CreateShader(GL_VERTEX_SHADER, pVertexShader);
    if (!nVertexShader) return false;
    
    // Load fragment shader...
    nFragmentShader = GL_CreateShader(GL_FRAGMENT_SHADER, pFragmentShader);
    if (!nFragmentShader) return false;

    // Attach shaders to program...
    glAttachShader(m_nProgram, nVertexShader);
    glAttachShader(m_nProgram, nFragmentShader);
    
    // Vertex attributes...
    glBindAttribLocation(m_nProgram, 0, "in_position");
    glBindAttribLocation(m_nProgram, 1, "in_tex_coord");
    
    // Link...
    glLinkProgram(m_nProgram);
    glGetProgramiv(m_nProgram, GL_LINK_STATUS, &nStatus);
    if (!nStatus)
    {
#ifndef NDEBUG
        GL_PrintProgramLog(stdout, m_nProgram);
#endif
        bResult = false;
    }
    
    // Release vertex and fragment shaders...
    if (nVertexShader)
    {
        glDetachShader(m_nProgram, nVertexShader);
        glDeleteShader(nVertexShader);
    }
    if (nFragmentShader)
    {
        glDetachShader(m_nProgram, nFragmentShader);
        glDeleteShader(nFragmentShader);
    }
    
    // Prepare the program...
    m_nAttribPosition = glGetAttribLocation(m_nProgram, "in_position");
    m_nAttribTexCoord = glGetAttribLocation(m_nProgram, "in_tex_coord");
    m_nUniformTransform = glGetUniformLocation(m_nProgram, "in_transform");
    m_nUniformTexScaleY = glGetUniformLocation(m_nProgram, "in_tex_scale_y");
    m_nUniformTexScaleUV = glGetUniformLocation(m_nProgram, "in_tex_scale_uv");
    m_nUniformTexY = glGetUniformLocation(m_nProgram, "texY");
    m_nUniformTexU = glGetUniformLocation(m_nProgram, "texU");
    m_nUniformTexV = glGetUniformLocation(m_nProgram, "texV");
    
    // Done...
    return bResult;
}

//
// Initialize()
// ============
//
bool VideoRenderer::Initialize(const char* pVertexShader, const char* pFragmentShader)
{
    GLubyte* p;
    
    // Create program...
    if (!CreateProgram(pVertexShader, pFragmentShader)) return false;
    glUseProgram(m_nProgram);
    
    // Bind the texture units...
    glUniform1i(m_nUniformTexY, 0);
    glUniform1i(m_nUniformTexU, 1);
    glUniform1i(m_nUniformTexV, 2);
    
    // Create working buffer...
    p = (GLubyte*) malloc(TEX_Y_BUFFER_SIZE);
    if (!p) return false;
    
    // Y plane...
    memset(p, TEX_Y_DEFAULT, TEX_Y_BUFFER_SIZE);
    m_nTextures[0] = CreateTextureYUV420P(GL_TEXTURE0, TEX_Y_WIDTH, TEX_Y_HEIGHT, p);
    
    // U and V planes...
    memset(p, TEX_UV_DEFAULT, TEX_UV_BUFFER_SIZE);
    m_nTextures[1] = CreateTextureYUV420P(GL_TEXTURE1, TEX_UV_WIDTH, TEX_UV_HEIGHT, p);
    m_nTextures[2] = CreateTextureYUV420P(GL_TEXTURE2, TEX_UV_WIDTH, TEX_UV_HEIGHT, p);
    
    // Delete working buffer...
    free(p);
    
    /*
     
        FIXME!!! INITIAL COLOR VALUES!!!
     
     */
    
    // Create vertex buffer...
    glGenBuffers(1, &m_nVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, m_nVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(struct VERTEX) * 4, g_Vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(m_nAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(struct VERTEX), 0);
    glVertexAttribPointer(m_nAttribTexCoord, 4, GL_FLOAT, GL_FALSE, sizeof(struct VERTEX), BUFFER_OFFSET(sizeof(GLfloat) * 2));
    glEnableVertexAttribArray(m_nAttribPosition);
    glEnableVertexAttribArray(m_nAttribTexCoord);
    
    // Initialize OpenGL default state...
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    // Done...
    return true;
}

//
// Shutdown()
// ==========
//
void VideoRenderer::Shutdown(void)
{
    // Disable texturing...
    glActiveTexture(GL_TEXTURE0);
    glDisable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE1);
    glDisable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE2);
    glDisable(GL_TEXTURE_2D);
    
    // Delete all textures...
    glDeleteTextures(3, m_nTextures);
    m_nTextures[0] = 0;
    m_nTextures[1] = 0;
    m_nTextures[2] = 0;
    
    // Delete the vertex buffer...   
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDeleteBuffers(1, &m_nVertexBuffer);
    m_nVertexBuffer = 0;
   
    // Delete the program object...
    glUseProgram(0);
    glDeleteProgram(m_nProgram);
    m_nProgram = 0;
}

//
// SetImageYUV420P()
// =================
//
void VideoRenderer::SetImageYUV420P(VideoImage& img)
{
    // Save the frame dimensions...
    m_nFrameWidth = img.GetWidth(PIC_PLANE_Y);
    m_nFrameHeight = img.GetHeight(PIC_PLANE_Y);
    
    // Load the Y image...
    glActiveTexture(GL_TEXTURE0);
    glTexSubImage2D(
                    GL_TEXTURE_2D,
                    0, 0, 0,
                    img.GetLineWidth(PIC_PLANE_Y),
                    img.GetHeight(PIC_PLANE_Y),
                    GL_LUMINANCE, GL_UNSIGNED_BYTE,
                    img.GetImage(PIC_PLANE_Y));
    
    // Load the U image...
    glActiveTexture(GL_TEXTURE1);
    glTexSubImage2D(
                    GL_TEXTURE_2D,
                    0, 0, 0,
                    img.GetLineWidth(PIC_PLANE_U),
                    img.GetHeight(PIC_PLANE_U),
                    GL_LUMINANCE, GL_UNSIGNED_BYTE,
                    img.GetImage(PIC_PLANE_U));
    
    
    // Load the V image...
    glActiveTexture(GL_TEXTURE2);
    glTexSubImage2D(
                    GL_TEXTURE_2D,
                    0, 0, 0,
                    img.GetLineWidth(PIC_PLANE_V),
                    img.GetHeight(PIC_PLANE_V),
                    GL_LUMINANCE, GL_UNSIGNED_BYTE,
                    img.GetImage(PIC_PLANE_V));
}

//
// Render()
// ========
//
void VideoRenderer::Render(GLfloat width, GLfloat height)
{
    GLfloat M[16];
    GLfloat x;
        
    // Portrait...
    if (height > width)
    {        
        x = (height * (GLfloat) m_nFrameWidth) / (width * (GLfloat) m_nFrameHeight); 
        
        GL_MatrixOrthof(M, -1.0f, 1.0f, -x, x, -1.0f, 1.0f);
        
        //GL_MatrixOrthof(M, -1.0f, 1.0f, 1.0f - 2.0 * x, 1.0f, -1.0f, 1.0f);
    }
    
    // Landscape...
    else
    {
        x = (width * (GLfloat) m_nFrameHeight) / (height * (GLfloat) m_nFrameWidth);
        
        GL_MatrixOrthof(M, -x, x, -1.0, 1.0f, -1.0f, 1.0f);
    }
    
    // Clear...
    glClear(GL_COLOR_BUFFER_BIT);
        
    // Frame-specific uniforms...
    glUniformMatrix4fv(m_nUniformTransform, 1, GL_FALSE, M);
    glUniform2f(m_nUniformTexScaleY, (GLfloat) m_nFrameWidth / (GLfloat) TEX_Y_WIDTH, (GLfloat) m_nFrameHeight / (GLfloat) TEX_Y_HEIGHT);
    glUniform2f(m_nUniformTexScaleUV, (GLfloat) m_nFrameWidth / (GLfloat) (TEX_UV_WIDTH * 2), (GLfloat) m_nFrameHeight / (GLfloat) (TEX_UV_HEIGHT * 2));
        
    // Draw the quad...
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

//==============================================================================
