//
//  CameraWireless.h
//  EyeBaby
//

#import "CameraPageBase.h"

@interface CameraWireless : CameraPageBase
{
    BOOL                    m_bSearching;
    
    NSArray*                m_pWirelessResults;
    OrantekWirelessInfo*    m_pWirelessInfo;
    UIAlertView*            m_pAlertView;
}

-(BOOL)initPage;

@end
