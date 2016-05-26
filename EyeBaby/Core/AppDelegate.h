//
//  AppDelegate.h
//  EyeBaby
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
@public
    const int a;
}
@property (strong, nonatomic) UIWindow *window;
-(NSData*)GetDataFromDic:(NSDictionary*)dic;
-(NSDictionary*)GetDicFromData:(NSData*)data;
void interruptionListener(	void *	inClientData,
						  UInt32	inInterruptionState);
void propListener(	void *                  inClientData,
				  AudioSessionPropertyID	inID,
				  UInt32                  inDataSize,
				  const void *            inData);
@end
