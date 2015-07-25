/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import "CLFontPickerView.h"

#import "UIView+Frame.h"
#import "CLPickerView.h"

const CGFloat kCLFontPickerViewConstantFontSize = 14;

@interface CLFontPickerView()
<CLPickerViewDelegate, CLPickerViewDataSource>
@end

@implementation CLFontPickerView
{
    CLPickerView *_pickerView;
}

+ (NSArray*)allFontList
{
    NSMutableArray *mutableFontList = [NSMutableArray array];
    
    
    // After the app HAS been reviewed on the AppStore ======
        _fontList = [NSArray arrayWithObjects:
                     @"BubbleMan",
                     @"Flavors",
                     @"Balinese Family",
                     @"Needlework Perfect",
                     @"Rubber",
                     @"Vtks Revolt",
                     
                     nil];
    
    
    for (int i = 0; i< [_fontList count]; i++) {
        NSString *familyNameStr = [_fontList objectAtIndex:i];
        [mutableFontList addObject:[UIFont fontWithName:familyNameStr size:kCLFontPickerViewConstantFontSize]];
    }
    
    return [mutableFontList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fontName" ascending:YES]]];
}



+ (NSArray*)defaultSizes
{
    return @[@8, @10, @12, @14, @16, @18, @20, @24, @28, @32, @38, @44, @50];
}


+ (UIFont*)defaultFont
{
    // Default Initial Font
    return [UIFont fontWithName:@"BubbleMan"size:kCLFontPickerViewConstantFontSize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        _pickerView = [[CLPickerView alloc] initWithFrame:self.bounds];
        _pickerView.center = CGPointMake(self.width/2, self.height/2);
        _pickerView.backgroundColor = [UIColor clearColor];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self addSubview:_pickerView];
        
        _fontList = [self.class allFontList];
        NSLog(@"FONTS LIST:  %@",_fontList);
        
        _fontSizes = [self.class defaultSizes];
        self.font = [self.class defaultFont];
        self.foregroundColor = [UIColor colorWithRed:36.0/255.0 green:42.0/255.0 blue:50.0/255.0 alpha:1];
        self.textColor = [UIColor colorWithRed:36.0/255.0 green:42.0/255.0 blue:50.0/255.0 alpha:1];
    }
    return self;
}

- (void)setForegroundColor:(UIColor *)foregroundColor
{
    _pickerView.foregroundColor = foregroundColor;
}

- (UIColor*)foregroundColor
{
    return _pickerView.foregroundColor;
}

- (void)setFontList:(NSArray *)fontList
{
    if(fontList != _fontList){
        _fontList = fontList;
        [_pickerView reloadComponent:0];
    }
}

- (void)setFontSizes:(NSArray *)fontSizes
{
    if(fontSizes != _fontSizes){
        _fontSizes = fontSizes;
        [_pickerView reloadComponent:1];
    }
}

- (void)setFont:(UIFont *)font
{
    UIFont *tmp = [font fontWithSize:kCLFontPickerViewConstantFontSize];
    
    NSInteger fontIndex = [_fontList indexOfObject: tmp];
    //[self.fontList indexOfObject:tmp];
    if(fontIndex==NSNotFound){ fontIndex = 0; }
    
    NSInteger sizeIndex = 0;
    for(sizeIndex=0; sizeIndex < _fontSizes.count; sizeIndex++){
        if(font.pointSize <= [_fontSizes[sizeIndex] floatValue]){
            break;
        }
    }
    
    [_pickerView selectRow:fontIndex inComponent:0 animated:NO];
    [_pickerView selectRow:sizeIndex inComponent:1 animated:NO];
}

- (UIFont*)font
{
    UIFont *font = _fontList[[_pickerView selectedRowInComponent:0]];
    CGFloat size = [_fontSizes[[_pickerView selectedRowInComponent:1]] floatValue];
    return [font fontWithSize:size];
}

- (void)setSizeComponentHidden:(BOOL)sizeComponentHidden
{
    _sizeComponentHidden = sizeComponentHidden;
    
    [_pickerView setNeedsLayout];
}

#pragma mark- UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(CLPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(CLPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return _fontList.count;
        case 1:
            return _fontSizes.count;
    }
    return 0;
}

#pragma mark- UIPickerViewDelegate

- (CGFloat)pickerView:(CLPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.height/3;
}

- (CGFloat)pickerView:(CLPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat ratio = self.sizeComponentHidden ? 1 : 0.8;
    switch (component) {
        case 0:
            return self.width*ratio;
        case 1:
            return self.width*(1-ratio);
    }
    return 0;
}

- (UIView*)pickerView:(CLPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *lbl = nil;
    
    if([view isKindOfClass:[UILabel class]]){
        lbl = (UILabel *)view;
    }
    else{
        CGFloat W = [self pickerView:pickerView widthForComponent:component];
        CGFloat H = [self pickerView:pickerView rowHeightForComponent:component];
        CGFloat dx = 10;
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(dx, 0, W-2*dx, H)];
        lbl.backgroundColor = [UIColor whiteColor];
        lbl.adjustsFontSizeToFitWidth = YES;
        lbl.minimumScaleFactor = 0.5;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.textColor = [UIColor colorWithRed:36.0/255.0 green:42.0/255.0 blue:50.0/255.0 alpha:1];
    }
    
    switch (component) {
        case 0:
            lbl.font = _fontList[row];
            if(self.text.length>0){
                lbl.text = self.text;
            }
            else{
                lbl.text = [NSString stringWithFormat:@"%@", lbl.font.fontName];
            }
            break;
        case 1:
            lbl.font = [UIFont systemFontOfSize:kCLFontPickerViewConstantFontSize];
            lbl.text = [NSString stringWithFormat:@"%@", self.fontSizes[row]];
            break;
            
        default: break;
    }
    
    return lbl;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if([self.delegate respondsToSelector:@selector(fontPickerView:didSelectFont:)]){
        [self.delegate fontPickerView:self didSelectFont:self.font];
    }
}

@end
