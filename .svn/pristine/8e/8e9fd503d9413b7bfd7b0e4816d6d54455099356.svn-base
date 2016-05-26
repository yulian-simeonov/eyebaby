//
//  OrantekCameraSearch.h
//  EyeBaby
//

#import <Foundation/Foundation.h>
#import "OrantekCameraProperties.h"

@interface OrantekCameraSearch : NSObject
{
    BOOL                m_bChanged;
    NSMutableArray*     m_pCameras;
    NSThread*           m_pBackgroundThread;
}

-(void)startListening;
-(void)stopListeningAndWait:(BOOL)wait;
-(BOOL)sendSearchRequest;

-(void)addCamera:(OrantekCameraProperties*)camera;
-(int)count;
-(OrantekCameraProperties*)get:(int)index;
-(void)clear;
-(BOOL)hasChanged;

-(id)init;
-(void)dealloc;

@end
