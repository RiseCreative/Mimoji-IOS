/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import "CLFramesTool.h"

#import "CLCircleView.h"

static NSString* const kCLFramesToolFramesPathKey = @"framesPath";

@interface _CLFramesView : UIView
+ (void)setActiveFramesView:(_CLFramesView *)view;
- (UIImageView*)imageView;
- (id)initWithImage:(UIImage *)image;
- (void)setScale:(CGFloat)scale;
@end



@implementation CLFramesTool
{
   // UIImage *_originalImage;
  //  UIView *_workingView;
    UIScrollView *_menuScroll;
}

+ (NSArray*)subtools
{
    
    return nil;
}

+ (NSString*)defaultTitle
{
    return NSLocalizedStringWithDefaultValue(@"CLFramesTool_DefaultTitle", nil, [CLImageEditorTheme bundle], @"Frames", @"");
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

/*
+ (CGFloat)defaultDockedNumber
{
    return 8;
}
*/
#pragma mark- STICKER PATH ============

+ (NSString*)defaultFramesPath
{
    return [[[CLImageEditorTheme bundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/frames", NSStringFromClass(self)]];
}

+ (NSDictionary*)optionalInfo
{
    return @{kCLFramesToolFramesPathKey:[self defaultFramesPath]};
}



#pragma mark- INITIALIZATION ==========

- (void)setup {
    
    _originalImage = self.editor.imageView.image;
    
    [self.editor fixZoomScaleWithAnimated:YES];
    
    _menuScroll = [[UIScrollView alloc] initWithFrame:self.editor.menuView.frame];
    _menuScroll.backgroundColor = self.editor.menuView.backgroundColor;
    _menuScroll.showsHorizontalScrollIndicator = YES;
    [self.editor.view addSubview:_menuScroll];
    
    _workingView = [[UIView alloc] initWithFrame:[self.editor.view convertRect:self.editor.imageView.frame fromView:self.editor.imageView.superview]];
    _workingView.clipsToBounds = YES;
    [self.editor.view addSubview:_workingView];
    
    [self setFramesMenu];
    
    _menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height - _menuScroll.top);
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         _menuScroll.transform = CGAffineTransformIdentity;
                     }];
}

- (void)cleanup
{
    [self.editor resetZoomScaleWithAnimated:YES];
    
    [_workingView removeFromSuperview];
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
    animations:^{
    _menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
      }
    completion:^(BOOL finished) {
    
        [_menuScroll removeFromSuperview];
    }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    [_CLFramesView setActiveFramesView:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage:_originalImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}



#pragma mark - SET FRAMES MENU =================

- (void)setFramesMenu {
    CGFloat W = 70;
    CGFloat H = _menuScroll.height;
    CGFloat x = 0;

    
    framesPath = self.toolInfo.optionalInfo[kCLFramesToolFramesPathKey];
    if(framesPath == nil){
        framesPath = [[self class] defaultFramesPath];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
        list = [fileManager contentsOfDirectoryAtPath:framesPath error:&error];
        
    for (NSString *pathStr in list){
        filePath = [NSString stringWithFormat:@"%@/%@", framesPath, pathStr];
        
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
       
        if(image){
            CLToolbarMenuItem *view = [CLImageEditorTheme menuItemWithFrame:CGRectMake(x, 0, W, H) target:self action:@selector(tappedFramesPanel:) toolInfo:nil];
            view.iconImage = [image aspectFit:CGSizeMake(50, 50)];
            view.userInfo = @{@"filePath" : filePath};
          
            
            [_menuScroll addSubview:view];
            x += W;
        }
    }
    
    
    NSLog(@"%@", list);
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
    
    
}


- (void)tappedFramesPanel:(UITapGestureRecognizer*)sender
{
    UIView *view = sender.view;
    
    NSString *filePath = view.userInfo[@"filePath"];
    
    // Shows the frame tapped and its name into LOG
    NSLog(@"filepath= %@", filePath);
    
     if (filePath) {
        _CLFramesView *view = [[_CLFramesView alloc] initWithImage:[UIImage imageWithContentsOfFile:filePath]];
         
       //  CGFloat ratio = MIN( _workingView.width / view.width, _workingView.height / view.height);
         
      //  CGFloat ratio = MIN( (0.5 * _workingView.width) / view.width, (0.5 * _workingView.height) / view.height);
       // [view setScale:ratio];
         
         // Puts the frame in the center of the image
        view.center = CGPointMake(_workingView.width/2, _workingView.height/2);
        
         width = _workingView.width;
         height = _workingView.height;
         
         view.frame = CGRectMake(0,0, width, height);
      //   NSLog(@"workW: %f - workH: %f", width, height);

         
        [_workingView addSubview:view];
        [_CLFramesView setActiveFramesView:view];
    }
    
    
    view.alpha = 0.2;
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
    animations:^{  view.alpha = 1;
    }];
}


- (UIImage*)buildImage:(UIImage*)image
{
    UIGraphicsBeginImageContext(image.size);
    
    [image drawAtPoint:CGPointZero];
    
    CGFloat scale = image.size.width / _workingView.width;
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    [_workingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
}


@end





#pragma mark - FRAMES VIEW IMPLEMENTATION ======================
@implementation _CLFramesView
{
    
    UIImageView *_imageView;
    UIButton *_deleteButton;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

+ (void)setActiveFramesView:(_CLFramesView*)view {
    
    static _CLFramesView *activeView = nil;
    if(view != activeView){
        [activeView setActive:NO];
        activeView = view;
        [activeView setActive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
    }
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithFrame:CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height)];
    
    if(self){
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.center = self.center;
        
        width = _workingView.width;
        height = _workingView.height;
        
        _imageView.frame = CGRectMake(0,0, width, height);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        
        NSLog(@"width: %f - height: %f", width, height);
        NSLog(@"imageW:%f - imageH%f", _imageView.frame.size.width, _imageView.frame.size.height);
        
        [self addSubview:_imageView];
        
        _scale = 2;
        _arg = 0;
        
        [self initGestures];
    }
    return self;
}

- (void)initGestures  {
    
    _imageView.userInteractionEnabled = YES;
    
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_imageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_imageView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)]];

    
    // DOUBLE TAP on a Frame to delete it
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteFrame)];
    doubleTap.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer: doubleTap];
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view= [super hitTest:point withEvent:event];
    if(view==self){
        return nil;
    }
    return view;
}

- (UIImageView*)imageView
{
    return _imageView;
}

-(void)deleteFrame {
    _CLFramesView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[_CLFramesView class]]){
            nextTarget = (_CLFramesView*)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=index-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[_CLFramesView class]]){
                nextTarget = (_CLFramesView*)view;
                break;
            }
        }
    }
    
    [[self class] setActiveFramesView:nextTarget];
    [self removeFromSuperview];
}

- (void)setActive:(BOOL)active
{
    _deleteButton.hidden = !active;
  //  _circleView.hidden = !active;
    _imageView.layer.borderWidth = (active) ? 1/_scale : 0;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    
    self.transform = CGAffineTransformIdentity;
    
    _imageView.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_imageView.width + 32)) / 2;
    rct.origin.y += (rct.size.height - (_imageView.height + 32)) / 2;
    rct.size.width  = _imageView.width + 32;
    rct.size.height = _imageView.height + 32;
    self.frame = rct;
    
    _imageView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _imageView.layer.borderWidth = 1/_scale;
    _imageView.layer.cornerRadius = 3/_scale;
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    [[self class] setActiveFramesView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveFramesView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
}

-(void)viewDidPinch: (UIPinchGestureRecognizer *) sender {
    
    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    sender.scale = 1;
    

}


@end
