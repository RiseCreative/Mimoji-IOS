/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import <UIKit/UIKit.h>
#import "CLTextTool.h"

@protocol CLTextSettingViewDelegate;

@interface CLTextSettingView : UIView

@property (nonatomic, weak) id<CLTextSettingViewDelegate> delegate;
@property (nonatomic, strong) NSString *selectedText;
@property (nonatomic, strong) UIColor *selectedFillColor;
@property (nonatomic, strong) UIColor *selectedBorderColor;
@property (nonatomic, assign) CGFloat selectedBorderWidth;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic, weak) CLTextTool *parentView;

- (void)setTextColor:(UIColor*)textColor;
- (void)setFontPickerForegroundColor:(UIColor*)foregroundColor;

- (void)showSettingMenuWithIndex:(NSInteger)index animated:(BOOL)animated;

@end



@protocol CLTextSettingViewDelegate <NSObject>
@optional
- (void)textSettingView:(CLTextSettingView*)settingView didChangeText:(NSString*)text;
- (void)textSettingView:(CLTextSettingView*)settingView didChangeFillColor:(UIColor*)fillColor;
- (void)textSettingView:(CLTextSettingView*)settingView didChangeBorderColor:(UIColor*)borderColor;
- (void)textSettingView:(CLTextSettingView*)settingView didChangeBorderWidth:(CGFloat)borderWidth;
- (void)textSettingView:(CLTextSettingView*)settingView didChangeFont:(UIFont*)font;

@end