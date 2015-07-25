/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import "UIDevice+SystemVersion.h"

@implementation UIDevice (SystemVersion)

+ (CGFloat)iosVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

@end
