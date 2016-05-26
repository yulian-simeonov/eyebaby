//
//  Utils.m
//  EyeBaby
//

#import "Utils.h"

@implementation Utils

+ (NSString*)stringFromBuffer:(const char*)str length:(int)len
{
    NSString* nsstr;
    char* p;
    
    /*
     This method is necessary because NSString doesn't have a version of
     stringWithUTF8String that takes a length parameter.
     */
    
    p = (char*) malloc(len + 1);
    memcpy(p, str, len);
    p[len] = '\0';
    
    nsstr = [NSString stringWithUTF8String:p];
    
    free(p);
    
    return nsstr;
}

+ (BOOL)boolFromString:(NSString*)str
{
    // "on" and "off"...
    if ([str caseInsensitiveCompare:@"on"] == NSOrderedSame) return YES;
    if ([str caseInsensitiveCompare:@"true"] == NSOrderedSame) return YES;
    
    // Default operation...
    return [str boolValue];
}

+ (NSString*)secureText:(NSString*)str
{
    int i;
    NSMutableString* securedMutableText = [[NSMutableString alloc] init];
    
    for (i = 0; i < [str length]; ++i)
    {
        [securedMutableText appendString:@"*"];// FIXME!!!
    }
    
    return [NSString stringWithString:securedMutableText];
}

+ (void)printStringList:(NSArray*)pData
{
    int i;
    
    for (i = 0; i < [pData count]; ++i)
    {
        TRACE(@"\"%@\"", (NSString*)[pData objectAtIndex:i]);
    }
}

+ (NSString*) stringFromURL:(NSString*)url_str timeout:(NSTimeInterval)timeout
{
    NSURL* url = [NSURL URLWithString:url_str];
    NSURLRequest* pRequest = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    
    NSURLResponse* pResponse = nil;
    NSError* pError = nil;
    
    NSData* pData = [NSURLConnection sendSynchronousRequest:pRequest returningResponse:&pResponse error:&pError];
    if (!pData)
    {
        TRACE(@"%@", pError.localizedDescription);
        return nil;
    }
    
    return [[NSString alloc] initWithData:pData encoding:NSASCIIStringEncoding];
}

@end
