/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import <UIKit/UIKit.h>

#import "UIView+CLImageToolInfo.h"

@interface CLToolbarMenuItem : UIView
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) UIImage *iconImage;
@property (nonatomic, assign) BOOL selected;

 - (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action toolInfo:(CLImageToolInfo*)toolInfo;

@end
