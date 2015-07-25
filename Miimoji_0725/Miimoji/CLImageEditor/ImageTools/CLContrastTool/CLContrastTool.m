/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import "AppDelegate.h"
#import "CLContrastTool.h"

@implementation CLContrastTool

{
    UIImage *_originalImage;
    UIImage *_thumnailImage;
    
    UISlider *_contrastSlider;
    UIButton *_btnPlus;
    UIButton *_btnMinus;
    UIActivityIndicatorView *_indicatorView;
}

+ (NSString*)defaultTitle
{
   
    return NSLocalizedStringWithDefaultValue(@"CLContrastTool_DefaultTitle", nil, [CLImageEditorTheme bundle], @"Contrast", @"");
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

- (void)setup
{
    _originalImage = self.editor.imageView.image;
    _thumnailImage = [_originalImage resize:self.editor.imageView.frame.size];
    
    [self.editor fixZoomScaleWithAnimated:YES];
    
    [self setupSlider];
}

- (void)cleanup
{
    [_indicatorView removeFromSuperview];
//    [_contrastSlider.superview removeFromSuperview];
    [_contrastSlider removeFromSuperview];
    [_btnPlus removeFromSuperview];
    [_btnMinus removeFromSuperview];
    
    [self.editor resetZoomScaleWithAnimated:YES];
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _indicatorView = [CLImageEditorTheme indicatorView];
        _indicatorView.center = self.editor.toolView.center;
        [self.editor.toolView addSubview:_indicatorView];
        [_indicatorView startAnimating];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self filteredImage:_originalImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}

#pragma mark-

- (UISlider*)sliderWithValue:(CGFloat)value minimumValue:(CGFloat)min maximumValue:(CGFloat)max action:(SEL)action
{
    CGFloat sliderWidth = self.editor.toolView.width - 100;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 0, sliderWidth, 35)];
    
//    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sliderWidth + 20, slider.height)];
//    container.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
//    container.layer.cornerRadius = slider.height /2;
    
    slider.continuous = YES;
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    
    slider.maximumValue = max;
    slider.minimumValue = min;
    slider.value = value;
    
//    [container addSubview:slider];
    [self.editor.toolView addSubview:slider];
    
//    slider.superview.center = CGPointMake(self.editor.toolView.width/2, self.editor.toolView.height / 2);
    slider.center = CGPointMake(self.editor.toolView.width/2, self.editor.toolView.height / 2);

    // Add Plus & Minus buttons
    CGRect rect = slider.frame;
    _btnPlus = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPlus.frame = CGRectMake(rect.origin.x - 30, rect.origin.y, 30, 35);
    [_btnPlus setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _btnPlus.titleLabel.font = [UIFont systemFontOfSize:30.0];
    [_btnPlus setTitle:@"+" forState:UIControlStateNormal];
    [_btnPlus addTarget:self action:@selector(onBtnPlus:) forControlEvents:UIControlEventTouchUpInside];
    [self.editor.toolView addSubview:_btnPlus];

    _btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMinus.frame = CGRectMake(rect.origin.x + rect.size.width, rect.origin.y, 30, 35);
    [_btnMinus setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _btnMinus.titleLabel.font = [UIFont systemFontOfSize:30.0];
    [_btnMinus setTitle:@"-" forState:UIControlStateNormal];
    [_btnMinus addTarget:self action:@selector(onBtnMinus:) forControlEvents:UIControlEventTouchUpInside];
    [self.editor.toolView addSubview:_btnMinus];
    
    return slider;
}

- (void)onBtnPlus:(id)sender {
    _contrastSlider.value = _contrastSlider.value - 0.1;
    [self sliderDidChange:_contrastSlider];
}

- (void)onBtnMinus:(id)sender {
    _contrastSlider.value = _contrastSlider.value + 0.1;
    [self sliderDidChange:_contrastSlider];
}

- (void)setupSlider
{
    _contrastSlider = [self sliderWithValue:1 minimumValue:0.5 maximumValue:1.5 action:@selector(sliderDidChange:)];
//    _contrastSlider.superview.center = CGPointMake(self.editor.toolView.width/2, self.editor.menuView.top);

    [_contrastSlider setThumbImage:[CLImageEditorTheme imageNamed:@"slide_handle.png"] forState:UIControlStateNormal];
//    [_contrastSlider setThumbImage:[CLImageEditorTheme imageNamed:[NSString stringWithFormat:@"%@/contrast.png", [self class]]] forState:UIControlStateHighlighted];
    [_contrastSlider setMinimumTrackTintColor:[UIColor grayColor]];
    [_contrastSlider setMaximumTrackTintColor:[UIColor darkGrayColor]];
}

- (void)sliderDidChange:(UISlider*)sender
{
    static BOOL inProgress = NO;
    
    if(inProgress){ return; }
    inProgress = YES;
    
    //V
    [APPDELEGATE setBNeedToApply:YES];
    [self.editor enableButtonsForNeedToApply];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self filteredImage:_thumnailImage];
        [self.editor.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        inProgress = NO;
    });
}

- (UIImage*)filteredImage:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];

    
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat contrast   = _contrastSlider.value*_contrastSlider.value;
    [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputPower"];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}


@end
