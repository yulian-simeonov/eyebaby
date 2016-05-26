//
//  glutils.h
//

#ifndef __GLUTILS__
#define __GLUTILS__

#include <OpenGLES/ES2/gl.h>
#include <stdio.h>

#define BUFFER_OFFSET(i) ((char*)NULL + (i))

#ifdef __cplusplus
extern "C" {
#endif
    
    void GL_PrintShaderLog(FILE*, GLuint);
    void GL_PrintProgramLog(FILE*, GLuint);
    
    GLuint GL_CreateShader(GLenum, const GLchar*);
    const char* GL_GetErrorName(GLenum);
    void GL_PrintError(FILE*);
    void GL_DumpState(FILE*);
    
    void GL_MatrixIdentityf(GLfloat*);
    void GL_MatrixTranslatef(GLfloat*, GLfloat, GLfloat, GLfloat);
    void GL_MatrixScalef(GLfloat*, GLfloat, GLfloat, GLfloat);
    void GL_MatrixOrthof(GLfloat*, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat);
    
#ifdef __cplusplus
} // extern "C"
#endif

#endif // __GLUTILS__
