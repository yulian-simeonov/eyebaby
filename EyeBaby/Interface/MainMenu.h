//
//  MainMenu.h
//  EyeBaby
//

#import "PageBase.h"
#import "OrantekCameraSearch.h"

@interface MainMenu : PageBase
{
    OrantekCameraSearch*    m_pCameraSearch;
    NSTimer*                m_searchTimer;
    NSTimer*                m_updateTableTimer;
}

- (void)applicationDidEnterBackground:(id)obj;
- (void)applicationWillEnterForeground:(id)obj;
- (void)refreshTable;

@end
