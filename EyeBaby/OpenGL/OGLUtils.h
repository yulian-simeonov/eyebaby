//
//  OGLUtils.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface OGLUtils:NSObject

+ (NSString*) loadShader:(NSString*)name ext:(NSString*)ext;
+ (GLuint) loadTextureFromPNG:(NSString*)name;

@end

