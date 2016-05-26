//
//  OGLUtils.m
//

#import "OGLUtils.h"

@implementation OGLUtils

+ (NSString*)loadShader:(NSString*)name ext:(NSString*)ext
{
    NSString* path;
    
    path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    if (path == nil)
    {
        /*
         If this fails, its because the resource is not in
         the list of files to copy to bundle!
         */
        
        TRACE(@"Failed to load shader resource.");
        return nil;
    }
    
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

+ (GLuint)loadTextureFromPNG:(NSString*)name
{
    NSString* path;
    NSData* data;
    UIImage* image;
    CGColorSpaceRef colorSpace;
    CGContextRef context;
    void* pImageData;
    GLuint width, height;
    GLuint tex_id;

    // Locate the resource...
    path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    if (path == nil)
    {
        TRACE(@"Failed to load resource \"%@\"", name);
        return 0;
    }
    
    // Get contents of the file...
    data = [[NSData alloc] initWithContentsOfFile:path];
    if (data == nil)
    {
        TRACE(@"Failed to load file \"%@\"", path);
        return 0;
    }
    
    // Convert to UIImage...
    image = [[UIImage alloc] initWithData:data];
    if (image == nil)
    {
        TRACE(@"Failed to create UIImage from \"%@\"", path);
        return 0;
    }
    
    // Get image metrics...
    width = CGImageGetWidth(image.CGImage);
    height = CGImageGetHeight(image.CGImage);
        //
        // FIXME!!! CHECK WIDTH AND HEIGHT ARE POWER OF TWO BEFORE PROCEEDING!!!
        // FIXME!!! DOES OpenGL ON iOS SUPPORT NON_POWER_OF_TWO SIZES?
        //
    pImageData = malloc(width * height * 4);
    if (pImageData == NULL)
    {
        return 0;
    }
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(pImageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, CGRectMake(0, 0, width, height));
    
    // Flip the image vertically...
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Transfer image to buffer...
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    
    // Create texture object...
    glGenTextures(1, &tex_id);
    
    // Configure it...
    glBindTexture(GL_TEXTURE_2D, tex_id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pImageData);
    
    // Clean up...
    CGContextRelease(context);
    free(pImageData);
    
    // Done...
    return tex_id;
}

@end

