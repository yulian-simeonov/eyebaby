//
//  CameraPageBase.h
//  EyeBaby
//

#import <UIKit/UIKit.h>

#import "PageBase.h"
#import "OrantekCameraProperties.h"

@interface CameraPageBase : PageBase
{
    @protected
    OrantekCameraProperties*    m_pCamera;
}

-(id)initWithCam:(OrantekCameraProperties*)camera;

-(BOOL)shouldPop;

@end
