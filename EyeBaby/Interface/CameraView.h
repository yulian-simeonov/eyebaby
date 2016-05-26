//
//  CameraView.h
//  EyeBaby
//

#import <UIKit/UIKit.h>
#import "GLView.h"
#import "VideoStreamController.h"
#import "OrantekCameraProperties.h"

#include "VideoRender.h"

@interface CameraView : UIViewController <GLViewDelegate>
{
    GLView*                     m_glView;
    CADisplayLink*              m_displayLink;
    NSTimer*                    m_timer;
    VideoStreamController*      m_videoStreamController;
    UIView*                     m_popupConnecting;
        
    int                         m_nWaitCounter;
    BOOL                        m_bRotating;
    BOOL                        m_bIsActive;
    
    VideoRenderer               m_Renderer;
    
    OrantekCameraProperties*    m_pCameraProperties;
}

-(void)setCameraProperties:(OrantekCameraProperties*)camera;
-(void)appEnterBackground;
-(void)appEnterForeground;
-(void)onTimer;
-(void)onDisplayUpdate;

@end
