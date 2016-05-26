//
//  GLView.h
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@protocol GLViewDelegate <NSObject>
@optional
-(void)onInitialize:(id)view;
-(void)onShutdown:(id)view;
-(void)onReshape:(id)view;
-(void)onDisplay:(id)view;
@end

@interface GLView : UIView
{
@private
    EAGLContext* context;
    GLuint viewRenderBuffer;
    GLuint viewFrameBuffer;
}

@property (nonatomic, assign) id delegate;

-(void)initView;
-(void)shutdownView;
-(void)drawView;
-(void)makeCurrent;

@end
