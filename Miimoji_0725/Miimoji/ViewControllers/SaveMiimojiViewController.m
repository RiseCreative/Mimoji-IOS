//
//  SaveMiimojiViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "AppDelegate.h"
#import "SaveMiimojiViewController.h"
#import "MainViewController.h"
#import "UIImage+Extended.h"

@interface SaveMiimojiViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgMiimoji;
@property (weak, nonatomic) IBOutlet UILabel *txtMiimojiName;
@end

@implementation SaveMiimojiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    UIImage* finalImage = [self cropImage];
    self.imgMiimoji.image = finalImage; //[APPDELEGATE selectedPhoto];
    self.txtMiimojiName.text = self.miimojiName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

#pragma mark - Buttons Methods
- (IBAction)onBtnSaveMiimoji:(id)sender {
    // Resize the image
    UIImage* resizedImage = nil;
    resizedImage = [self.imgMiimoji.image resizedImageToFitInSize:CGSizeMake(70, 70) scaleIfSmaller:NO];
    
    [APPDELEGATE saveImageWithCurrentDateTime:resizedImage andName:self.miimojiName];
    [[APPDELEGATE mainViewController] clickBtnMyMiimoji];
}

#pragma mark - Image Crop Method
- (UIImage *)cropImage
{
    UIImage *maskImage = [APPDELEGATE selectedPhoto];
    UIImage *finalImage = nil;
    CGSize imageSize = maskImage.size;
    CGSize imageViewSize = [APPDELEGATE mainScreenSize];//self.imgMiimoji.bounds;
    imageViewSize.height /= 2;

    // scale ratio
    CGFloat ratio = imageSize.width / imageViewSize.width;

    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Crop Size & Original
    CGFloat h = imageViewSize.height - 50;
    CGFloat w = h * 0.75;
    CGSize sz = CGSizeMake(w, h); // smallerRect.size;
//    CGSize sz = CGSizeMake(150, 200);
    CGPoint pt = CGPointMake((imageViewSize.width - sz.width) / 2,
                             (imageViewSize.height - sz.height) / 2);
    
    NSArray *points = [NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width / 2, pt.y)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y + sz.height / 2)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width / 2, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y + sz.height / 2)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y)],
                       nil];
    if(1)
    {
        CGPoint start = [points[0] CGPointValue];
        CGPoint middleCurve = CGPointZero;
        CGPoint second = CGPointZero;
        CGContextMoveToPoint(context,
                             ratio * (start.x),
                             ratio * (start.y));
        for(int i = 1; i < points.count; i ++)
        {
            if (i % 2 == 0)
            {
                middleCurve = [points[i-1] CGPointValue];
                second = [points[i] CGPointValue];
                CGContextAddQuadCurveToPoint(context,
                                             ratio * (middleCurve.x),
                                             ratio * (middleCurve.y),
                                             ratio * (second.x),
                                             ratio * (second.y));
            }
        }
        if(points.count >= 6)
        {
            second = [points[0] CGPointValue];
            middleCurve = [points[points.count - 1] CGPointValue];
            CGContextAddQuadCurveToPoint(context,
                                         ratio * (middleCurve.x),
                                         ratio * (middleCurve.y),
                                         ratio * (second.x),
                                         ratio * (second.y));
        }
        CGContextClosePath(context);
        CGContextClip(context);
    }
    
    CGContextTranslateCTM(context, 0, imageSize.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), maskImage.CGImage);
    
    // Whole Image, but only cropped area shown
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    // Get Only Cropped Image
    CGRect targetFrame = CGRectMake(ratio * pt.x, ratio * pt.y, ratio * sz.width, ratio * sz.height);
    CGImageRef contextImage = CGImageCreateWithImageInRect([image CGImage], targetFrame);
    if (contextImage != NULL) {
        finalImage = [UIImage imageWithCGImage:contextImage
                                         scale:1.0
                                   orientation:UIImageOrientationUp];
        
        CGImageRelease(contextImage);
    }

    UIGraphicsEndImageContext();
    
    return finalImage;
}

@end
