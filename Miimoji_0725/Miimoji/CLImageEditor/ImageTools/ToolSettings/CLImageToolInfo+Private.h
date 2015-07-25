/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import "CLImageToolInfo.h"

@protocol CLImageToolProtocol;

@interface CLImageToolInfo (Private)

+ (CLImageToolInfo*)toolInfoForToolClass:(Class<CLImageToolProtocol>)toolClass;
+ (NSArray*)toolsWithToolClass:(Class<CLImageToolProtocol>)toolClass;

@end
