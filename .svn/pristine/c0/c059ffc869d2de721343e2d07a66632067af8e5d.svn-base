//
//  Registry.m
//  EyeBaby
//

#import "Registry.h"

@implementation Registry

+ (NSString*) createKey:(NSString*)name forCamera:(NSString*)camera
{
    /*
        Note that with each new release via TestFlight, the registry database will
        be deleted, so there is no need to monitor versions.
     */
    
    return [NSString stringWithFormat:@"cam/%@/%@", camera, name];
}

+ (NSString*) camera:(NSString*)camera getKeyString:(NSString*)name defaultVal:(NSString*)defaultVal
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];   
    NSString* key = [Registry createKey:name forCamera:camera];    
    NSString* str = [userDefaults stringForKey:key];
    if (str) return str;
    else return defaultVal;
}

+ (int) camera:(NSString *)camera getKeyInt:(NSString *)name defaultVal:(int)defaultVal
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];   
    NSString* key = [Registry createKey:name forCamera:camera];
    
    NSString* str = [userDefaults stringForKey:key];
    if (str) return [str intValue];
    else return defaultVal;
}

+ (void) camera:(NSString*)camera setKeyString:(NSString*)name withValue:(NSString*)value
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [Registry createKey:name forCamera:camera];
    
    [userDefaults setValue:value forKey:key];
}

+ (void) camera:(NSString *)camera setKeyInt:(NSString *)name withValue:(int)value
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [Registry createKey:name forCamera:camera];
    
    [userDefaults setValue:[NSString stringWithFormat:@"%d", value] forKey:key]; 
}

@end
