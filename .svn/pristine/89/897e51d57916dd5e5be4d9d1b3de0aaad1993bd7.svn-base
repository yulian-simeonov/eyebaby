//
//  Credentials.m
//  EyeBaby
//

#import "Credentials.h"
#import "Config.h"

@implementation Credentials

@synthesize username = _username;
@synthesize password = _password;

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        _username = OSTR_DEFAULT_USERNAME;
        _password = OSTR_DEFAULT_PASSWORD;
    }
    
    return self;
}

- (BOOL)isDefault
{
    if ([_username isEqualToString:OSTR_DEFAULT_USERNAME] && [_password isEqualToString:OSTR_DEFAULT_PASSWORD])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (Credentials*)load:(NSString*)ip
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    Credentials* cred = [[Credentials alloc] init];    
    
    // Get properties from user storage...
    NSDictionary* dict = [userDefaults dictionaryForKey:ip];
    if (dict != nil)
    {
        cred.username = (NSString*) [dict objectForKey:@"username"];
        cred.password = (NSString*) [dict objectForKey:@"password"];        
    }

    // Done...
    return cred;
}

- (void)store:(NSString*)ip
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"username", _username, @"password", _password, nil] forKey:ip];
}

@end
