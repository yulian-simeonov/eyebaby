//
//  BackgroundView.m
//  EyeBaby
//

#import "BackgroundView.h"

@implementation BackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}




#define COLOR_RGB(r,g,b)  [UIColor colorWithRed:((CGFloat)r / 255.0) green:((CGFloat)g / 255.0) blue:((CGFloat)b / 255.0) alpha:1.0]



- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    // GRADIENT...
    
    /*
     COLOR_RGB(0xC0, 0xC0, 0xFF);
     COLOR_RGB(0xB0, 0xC0, 0xFF);
     
    */
    
    UIColor* currentColor = COLOR_RGB(0xB0, 0xC0, 0xFF);
    UIColor* otherColor = COLOR_RGB(0xFF, 0xFF, 0xFF);
    CGFloat locations[] = {0.0, 1.0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSArray* colors = [NSArray arrayWithObjects: (id) currentColor.CGColor, (id) otherColor.CGColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    // Clouds...
    CGRect rectEllipse = CGRectMake(CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGRect rectEllipse2 = CGRectMake(CGRectGetMaxX(rect) / 3, CGRectGetMaxY(rect) - CGRectGetHeight(rect) / 4, CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2);
    UIColor* colorFill = [UIColor colorWithWhite:1.0 alpha:0.25];
    
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, rectEllipse);
    CGContextAddEllipseInRect(context, rectEllipse2);
    CGContextClip(context);
    CGContextSetFillColorWithColor(context, colorFill.CGColor);
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
}

@end
