/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import <Foundation/Foundation.h>

#import "_CLImageEditorViewController.h"
#import "CLImageToolSettings.h"
#import "MiimojiViewController.h"

static const CGFloat kCLImageToolAnimationDuration = 0.3;
static const CGFloat kCLImageToolFadeoutDuration   = 0.2;


@interface CLImageToolBase : NSObject <CLImageToolProtocol>

@property (nonatomic, weak) MiimojiViewController *editor;
@property (nonatomic, weak) CLImageToolInfo *toolInfo;

- (id)initWithImageEditor:(MiimojiViewController*)editor withToolInfo:(CLImageToolInfo*)info;

- (void)setup;
- (void)cleanup;
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
