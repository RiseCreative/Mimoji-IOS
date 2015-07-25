/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import "CLHueEffect.h"

#import "UIView+Frame.h"

@implementation CLHueEffect
{
    UIView *_containerView;
    UISlider *_hueSlider;
    UICollectionView *_collectionColor;
    NSArray *colorArray;
    NSInteger selColorIndex;
    NSInteger selColorTag;
    UIScrollView *_menuScroll;
}

#pragma mark-

+ (NSString*)defaultTitle
{
    return NSLocalizedStringWithDefaultValue(@"CLHueEffect_DefaultTitle", nil, [CLImageEditorTheme bundle], @"Hue", @"");
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

- (id)initWithSuperView:(UIView*)superview imageViewFrame:(CGRect)frame toolInfo:(CLImageToolInfo *)info
{
    self = [super initWithSuperView:superview imageViewFrame:frame toolInfo:info];
    if(self){
        _containerView = [[UIView alloc] initWithFrame:superview.bounds];
        _containerView.clipsToBounds = YES;
        [superview addSubview:_containerView];
        
        [self setUserInterface];
    }
    return self;
}

- (void)cleanup
{
    [_containerView removeFromSuperview];
}

- (UIImage*)applyEffect:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
//    [filter setValue:[NSNumber numberWithFloat:_hueSlider.value] forKey:@"inputAngle"];
    
    // Use CollectionView
    
    CGFloat colorAngle = [((NSDictionary*)colorArray[selColorTag])[@"hue"] floatValue] * M_PI / 180.0;
    [filter setValue:[NSNumber numberWithFloat:colorAngle] forKey:@"inputAngle"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

#pragma mark - Slider

- (UISlider*)sliderWithValue:(CGFloat)value minimumValue:(CGFloat)min maximumValue:(CGFloat)max
{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 0, 260, 30)];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, slider.height)];
    container.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    container.layer.cornerRadius = slider.height/2;
    
    slider.continuous = YES;
    [slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    
    slider.maximumValue = max;
    slider.minimumValue = min;
    slider.value = value;
    
    [container addSubview:slider];
    [_containerView addSubview:container];
    
    return slider;
}

- (void)setUserInterface
{
//    _hueSlider = [self sliderWithValue:0 minimumValue:-M_PI maximumValue:M_PI];
//    _hueSlider.superview.center = CGPointMake(_containerView.width/2, _containerView.height-30);
//    
//    [_hueSlider setThumbImage:[CLImageEditorTheme imageNamed:[NSString stringWithFormat:@"%@/hue.png", [self class]]] forState:UIControlStateNormal];
//    [_hueSlider setThumbImage:[CLImageEditorTheme imageNamed:[NSString stringWithFormat:@"%@/hue.png", [self class]]] forState:UIControlStateHighlighted];
//    
//    [_hueSlider setMinimumTrackTintColor:[UIColor purpleColor]];
    
    // Create CollectionView
#define UIColorFromRGB(r, g, b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
    
    colorArray = [NSArray arrayWithObjects:
                  @{@"hue":@(0), @"color":UIColorFromRGB(0, 255, 255)},
                  @{@"hue":@(-180), @"color":UIColorFromRGB(255, 0, 0)},
                  @{@"hue":@(-160), @"color":UIColorFromRGB(255, 85, 0)},
                  @{@"hue":@(-144), @"color":UIColorFromRGB(255, 152, 0)},
                  @{@"hue":@(-121), @"color":UIColorFromRGB(255, 250, 0)},
                  @{@"hue":@(-100), @"color":UIColorFromRGB(169, 255, 0)},
                  @{@"hue":@(-80), @"color":UIColorFromRGB(85, 255, 0)},
                  @{@"hue":@(-60), @"color":UIColorFromRGB(0, 255, 0)},
                  @{@"hue":@(20), @"color":UIColorFromRGB(0, 169, 255)},
                  @{@"hue":@(60), @"color":UIColorFromRGB(0, 0, 255)},
                  @{@"hue":@(97), @"color":UIColorFromRGB(156, 0, 255)},
                  @{@"hue":@(121), @"color":UIColorFromRGB(255, 0, 250)},
                  @{@"hue":@(143), @"color":UIColorFromRGB(255, 0, 156)},
                  @{@"hue":@(160), @"color":UIColorFromRGB(255, 0, 85)},
                  nil];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(50, 50)];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumInteritemSpacing = 0.0f;
    
    CGRect frame = _containerView.bounds;
    frame.origin.y = frame.origin.y + frame.size.height / 2 - 30;
    frame.size.height = 60;
    _collectionColor=[[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [_collectionColor setCollectionViewLayout:layout];
    [_collectionColor registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellColor"];
    [_collectionColor setBackgroundColor:[UIColor whiteColor]];
    [_collectionColor setShowsHorizontalScrollIndicator:NO];
    [_collectionColor setShowsVerticalScrollIndicator:NO];
    [_collectionColor setDataSource:self];
    [_collectionColor setDelegate:self];
    
//    [_containerView addSubview:_collectionColor];

    
    // Add Color ScrollView
    frame = _containerView.bounds;
    _menuScroll = [[UIScrollView alloc] initWithFrame:frame];
    _menuScroll.backgroundColor = [UIColor clearColor];
    _menuScroll.showsHorizontalScrollIndicator = YES;
    _menuScroll.tag = 100;
    [_containerView addSubview:_menuScroll];

    CGFloat W = 50;
    CGFloat H = _menuScroll.height;
    CGFloat itemW = 30, itemH = 30;
    
    NSInteger tag = 0;
    for(NSDictionary* colorObj in colorArray){

        CGRect colorViewFrame = CGRectMake(W * tag + (W - itemW) / 2, (H - itemH) / 2, itemW, itemH);
        UIImageView *colorView = [[UIImageView alloc] initWithFrame:colorViewFrame];
        colorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        colorView.layer.masksToBounds = YES;
        colorView.layer.cornerRadius = 15;
        colorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        colorView.layer.borderWidth = 1.0f;
        colorView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        colorView.layer.shouldRasterize = YES;
        colorView.clipsToBounds = YES;
        colorView.tag = 100 + tag;
        colorView.backgroundColor = colorObj[@"color"];
        [_menuScroll addSubview:colorView];
        
        UIButton* borderView = [UIButton buttonWithType:UIButtonTypeCustom];
        borderView.frame = CGRectInset(colorViewFrame, -4, -4);
        borderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        borderView.layer.masksToBounds = YES;
        borderView.layer.cornerRadius = 17;
        borderView.layer.borderColor = [UIColor blackColor].CGColor;
        borderView.layer.borderWidth = 0;
        borderView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        borderView.layer.shouldRasterize = YES;
        borderView.clipsToBounds = YES;
//        borderView.backgroundColor = colorArray[indexPath.row];
        borderView.tag = tag++;
        [borderView addTarget:self action:@selector(onBtnHueEffect:) forControlEvents:UIControlEventTouchUpInside];
        [_menuScroll addSubview:borderView];
    }
    _menuScroll.contentSize = CGSizeMake(MAX(tag * W, _menuScroll.frame.size.width+1), 0);
    
    // Select first item
    selColorTag = 0;
    UIButton* borderView = (UIButton*)[_menuScroll viewWithTag:selColorTag];
    borderView.layer.borderWidth = 1.0f;
}

- (void)onBtnHueEffect:(id)sender {
    NSInteger tag = ((UIButton*)sender).tag;
    if (selColorTag == tag) return;
    
    UIButton* borderView = (UIButton*)[_menuScroll viewWithTag:selColorTag];
    borderView.layer.borderWidth = 0;

    selColorTag = tag;
    borderView = (UIButton*)[_menuScroll viewWithTag:selColorTag];
    borderView.layer.borderWidth = 1.0f;

    [self.delegate effectParameterDidChange:self];
}

- (void)sliderDidChange:(UISlider*)sender
{
    [self.delegate effectParameterDidChange:self];
}

#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger retNum = 0;
    
    if ([collectionView isEqual:_collectionColor]) {
        retNum = colorArray.count;
    }
    
    return retNum;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if ([collectionView isEqual:_collectionColor]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellColor" forIndexPath:indexPath];
        
        CGFloat itemW = 30, itemH = 30;
        CGRect itemFrame = CGRectMake((cell.bounds.size.width - itemW) / 2, (cell.bounds.size.height - itemH) / 2, itemW, itemH);
        UIImageView *cellImageView = [[UIImageView alloc] initWithFrame:itemFrame];
        cellImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        cellImageView.layer.masksToBounds = YES;
        cellImageView.layer.cornerRadius = 15;
//        cellImageView.layer.borderColor = [UIColor blackColor].CGColor;
        cellImageView.layer.borderWidth = 1.0f;
        cellImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        cellImageView.layer.shouldRasterize = YES;
        cellImageView.clipsToBounds = YES;
        
        NSDictionary *value = (NSDictionary*)colorArray[indexPath.row];
        cellImageView.backgroundColor = value[@"color"];
        cellImageView.tag = 1;
        [cell.contentView addSubview:cellImageView];
        
        itemFrame = CGRectInset(itemFrame, -4, -4);
        UIImageView *cellBorderView = [[UIImageView alloc] initWithFrame:itemFrame];
        cellBorderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        cellBorderView.layer.masksToBounds = YES;
        cellBorderView.layer.cornerRadius = 17;
        cellBorderView.layer.borderColor = [UIColor blackColor].CGColor;
        cellBorderView.layer.borderWidth = 1.0f;
        cellBorderView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        cellBorderView.layer.shouldRasterize = YES;
        cellBorderView.clipsToBounds = YES;
        //        cellBorderView.backgroundColor = colorArray[indexPath.row];
        cellBorderView.tag = 2;
        [cell.contentView addSubview:cellBorderView];
        
        cellBorderView.hidden = YES;
//        if (selColorIndex == indexPath.row) {
//            NSLog(@"V== %@", @(selColorIndex));
//            cellBorderView.hidden = NO;
//        }
    }
    
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(50, 50);
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_collectionColor]) {
        
        selColorIndex = indexPath.row;
        UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIImageView* borderView = (UIImageView*)[cell viewWithTag:2];
        borderView.hidden = NO;

        [self.delegate effectParameterDidChange:self];
    }
    
    //    [collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_collectionColor]) {
        
        UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIImageView* borderView = (UIImageView*)[cell viewWithTag:2];
        borderView.hidden = YES;
    }
}

@end
