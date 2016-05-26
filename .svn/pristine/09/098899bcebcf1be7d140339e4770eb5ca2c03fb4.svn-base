//
//  glutils.cpp
//

#include <stdio.h>
#include <stdlib.h>
#include "glutils.h"

#define GL_TRACE(x)     {printf x ; printf("\n");}

//------------------------------------------------------------------------------

//
// GL_PrintShaderLog()
// ===================
//
void GL_PrintShaderLog(FILE* pOut, GLuint nShader)
{
    GLint nLogLength;
    GLchar* pLog;
    
    glGetShaderiv(nShader, GL_INFO_LOG_LENGTH, &nLogLength);
    if (nLogLength > 0)
    {
        pLog = (GLchar*) malloc(nLogLength);
        glGetShaderInfoLog(nShader, nLogLength, &nLogLength, pLog);
        fprintf(pOut, "%s\n", pLog);
        free(pLog);
    }
}

//
// GL_PrintProgramLog()
// ====================
//
void GL_PrintProgramLog(FILE* pOut, GLuint nProgram)
{
    GLint nLogLength;
    GLchar* pLog;
    
    glGetProgramiv(nProgram, GL_INFO_LOG_LENGTH, &nLogLength);
    if (nLogLength > 0)
    {
        pLog = (GLchar*) malloc(nLogLength);
        glGetProgramInfoLog(nProgram, nLogLength, &nLogLength, pLog);
        fprintf(pOut, "%s\n", pLog);
        free(pLog);
    }
}

//
// GL_CreateShader()
// =================
//
GLuint GL_CreateShader(GLenum type, const GLchar* pSource)
{
    GLuint nShader;
    GLint status;
    
    // Check parameters...
    if (pSource == NULL)
    {
        GL_TRACE(("%s: %s", "GL_CreateShader", "Empty string."));
        return 0;
    }
    
    // Create shader object...
    nShader = glCreateShader(type);
    if (nShader == 0)
    {
        GL_TRACE(("%s: %s", "GL_CreateShader", "Failed to create shader."));
        return 0;
    }

    // Compile shader...
    glShaderSource(nShader, 1, &pSource, NULL);
    glCompileShader(nShader);
    glGetShaderiv(nShader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
#ifndef NDEBUG
        GL_PrintShaderLog(stdout, nShader);
#endif
        glDeleteShader(nShader);
        return 0;
    }

    // Done...
    return nShader;
}

//
// GL_GetErrorName()
// =================
//
const char* GL_GetErrorName(GLenum nError)
{
    const char* pszText = NULL;
    
    switch (nError)
    {
        case GL_NO_ERROR: pszText = "GL_NO_ERROR"; break;
        case GL_INVALID_ENUM: pszText = "GL_INVALID_ENUM"; break;
        case GL_INVALID_FRAMEBUFFER_OPERATION: pszText = "GL_INVALID_FRAMEBUFFER_OPERATION"; break;
        case GL_INVALID_OPERATION: pszText = "GL_INVALID_OPERATION"; break;
        case GL_INVALID_VALUE: pszText = "GL_INVALID_VALUE"; break;
        case GL_OUT_OF_MEMORY: pszText = "GL_OUT_OF_MEMORY"; break;
    }
    
    return pszText;
}

//
// GL_PrintError()
// ===============
//
void GL_PrintError(FILE* pOut)
{
    const char* msg;
    
    msg = GL_GetErrorName(glGetError());
    if (msg != NULL)
    {
        fprintf(pOut, "%s\n", msg);
    }
}

//
// GL_DumpState()
// ==============
//
void GL_DumpState(FILE* pOut)
{
    const char* pString;
    GLint vec[4];
    
    pString = (const char*) glGetString(GL_VERSION);
    fprintf(pOut, "Version: %s\n", pString);
    pString = (const char*) glGetString(GL_RENDERER);
    fprintf(pOut, "Renderer: %s\n", pString);
    pString = (const char*) glGetString(GL_VENDOR);
    fprintf(pOut, "Vendor: %s\n", pString);
    pString = (const char*) glGetString(GL_SHADING_LANGUAGE_VERSION);
    fprintf(pOut, "Vendor: %s\n", pString);
    pString = (const char*) glGetString(GL_EXTENSIONS);
    fprintf(pOut, "Extensions: %s\n", pString);
    
    glGetIntegerv(GL_VIEWPORT, vec);
    fprintf(
            pOut,
            "Viewport: %i %i %i %i\n",
            (int) vec[0],
            (int) vec[1],
            (int) vec[2],
            (int) vec[3]);
    
}

//------------------------------------------------------------------------------

//
// GL_MatrixIdentityf()
// ====================
//
void GL_MatrixIdentityf(GLfloat* M)
{
    M[0] = 1.0f;
    M[1] = 0.0f;
    M[2] = 0.0f;
    M[3] = 0.0f;
    
    M[4] = 0.0f;
    M[5] = 1.0f;
    M[6] = 0.0f;
    M[7] = 0.0f;

    M[8] = 0.0f;
    M[9] = 0.0f;
    M[10] = 1.0f;
    M[11] = 0.0f;

    M[12] = 0.0f;
    M[13] = 0.0f;
    M[14] = 0.0f;
    M[15] = 1.0f;
}

//
// GL_MatrixTranslatef()
// =====================
//
void GL_MatrixTranslatef(GLfloat* M, GLfloat tx, GLfloat ty, GLfloat tz)
{
    M[12] += M[ 0] * tx + M[ 4] * ty + M[ 8] * tz;
    M[13] += M[ 1] * tx + M[ 5] * ty + M[ 9] * tz;
    M[14] += M[ 2] * tx + M[ 6] * ty + M[10] * tz;
    M[15] += M[ 3] * tx + M[ 7] * ty + M[11] * tz;
}

//
// GL_MatrixScalef()
// =================
//
void GL_MatrixScalef(GLfloat* M, GLfloat sx, GLfloat sy, GLfloat sz)
{
    M[ 0] *= sx;
    M[ 1] *= sx;
    M[ 2] *= sx;
    M[ 3] *= sx;
    
    M[ 4] *= sy;
    M[ 5] *= sy;
    M[ 6] *= sy;
    M[ 7] *= sy;
    
    M[ 8] *= sz;
    M[ 9] *= sz;
    M[10] *= sz;
    M[11] *= sz;
}

//
// GL_MatrixOrthof()
// =================
//
void GL_MatrixOrthof(GLfloat* M, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat znear, GLfloat zfar)
{
    M[ 0] = 2.0f / (right - left);
    M[ 1] = 0.0f;
    M[ 2] = 0.0f;
    M[ 3] = 0.0f;
    
    M[ 4] = 0.0f;
    M[ 5] = 2.0f / (bottom - top);
    M[ 6] = 0.0f;
    M[ 7] = 0.0f;

    M[ 8] = 0.0f;
    M[ 9] = 0.0f;
    M[10] = -2.0f / (zfar - znear);
    M[11] = 0.0f;
    
    M[12] = -((right + left) / (right - left));    
    M[13] = -((top + bottom) / (top - bottom));
    M[14] = -((zfar + znear) / (zfar - znear));
    M[15] = 1.0f;
}

//------------------------------------------------------------------------------
