//
//  Credentials.h
//  EyeBaby
//

#import <Foundation/Foundation.h>

@interface Credentials : NSObject

@property (copy, nonatomic) NSString* username;
@property (copy, nonatomic) NSString* password;

- (id)init;
- (BOOL)isDefault;

+ (Credentials*)load:(NSString*)ip;
- (void)store:(NSString*)ip;

@end
