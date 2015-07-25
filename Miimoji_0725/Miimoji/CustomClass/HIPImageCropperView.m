//
//  HIPImageCropperView.m
//  HIPImageCropper
//
//  Created by Taylan Pince on 2013-05-27.
//  Copyright (c) 2013 Hipo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "HIPImageCropperView.h"
#import "UIImage+Extended.h"

@interface HIPImageCropperView ()

@property (nonatomic, readwrite, strong) UIScrollView *scrollView;
@property (nonatomic, readwrite, strong) UIImageView *imageView;
@property (nonatomic, readwrite, strong) UIView *overlayView;

- (void)updateOverlay;

@end


@implementation HIPImageCropperView

- (id)initWithFrame:(CGRect)frame
       cropAreaSize:(CGSize)cropSize {

    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }
    
    [self setBackgroundColor:[UIColor blackColor]];
    [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                               UIViewAutoresizingFlexibleHeight)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:
                       CGRectInset(self.bounds, (frame.size.width - cropSize.width) / 2,
                           (frame.size.height - cropSize.height) / 2)];
    //self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setAlwaysBounceVertical:YES];
    [self.scrollView setAlwaysBounceHorizontal:YES];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView.layer setMasksToBounds:NO];
    [self.scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin |
                                          UIViewAutoresizingFlexibleBottomMargin)];
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:self.imageView];

    //V Remove overlayView, because of the [MiimojiViewController maskImageView]
//    self.overlayView = [[UIView alloc] initWithFrame:self.bounds];
//    [self.overlayView setUserInteractionEnabled:NO];
//    [self.overlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
//    [self.overlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
//                                           UIViewAutoresizingFlexibleHeight)];
//    [self addSubview:self.overlayView];
    
//    [self updateOverlay];
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
//    [self updateOverlay];
}

- (void)setImage:(UIImage *)image {
    CGFloat minZoomScale = 1.0;
    
    if (image.size.width < image.size.height) {
        minZoomScale = (self.scrollView.frame.size.width / image.size.width);
    } else {
        minZoomScale = (self.scrollView.frame.size.height / image.size.height);
    }
    
    // Must exist
    [self.scrollView setZoomScale:1.0];
    [self.imageView setImage:image];
    [self.imageView sizeToFit];
    
    [self.scrollView setContentSize:self.imageView.frame.size];
    [self.scrollView setMinimumZoomScale:minZoomScale];
    [self.scrollView setMaximumZoomScale:10.0];
    
    // Set proper zoomScale and contentOffset
    [self.scrollView setZoomScale:minZoomScale * MAX(self.frame.size.width / self.scrollView.frame.size.width,
                                                     self.frame.size.height / self.scrollView.frame.size.height)];
    [self.scrollView setContentOffset:CGPointMake((self.imageView.frame.size.width - self.scrollView.frame.size.width) / 2,
                                                  (self.imageView.frame.size.height - self.scrollView.frame.size.height) / 2)];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)updateOverlay {
    if (self.overlayView == nil)
        return;
    
    for (UIView *subview in [self.overlayView subviews]) {
        [subview removeFromSuperview];
    }
    
    UIView *borderView = [[UIView alloc] initWithFrame:self.scrollView.frame];
    
    [borderView.layer setBorderColor:[[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor]];
    [borderView.layer setBorderWidth:1.0];
    [borderView setBackgroundColor:[UIColor clearColor]];
    [borderView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin)];
//    [self.overlayView addSubview:borderView];
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    CGSize maskSize = borderView.frame.size;
    CGRect biggerRect = self.overlayView.bounds;
    CGRect smallerRect = CGRectMake((biggerRect.size.width - maskSize.width) / 2.0,
                                    (biggerRect.size.height - maskSize.height) / 2.0,
                                    maskSize.width, maskSize.height);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    // imageViewHeight : [APPDELEGATE mainScreenSize].height / 2
    CGFloat h = [APPDELEGATE mainScreenSize].height / 2 - 50;
    CGFloat w = h * 0.75;
    CGSize sz = CGSizeMake(w, h); // smallerRect.size;
    CGPoint pt = CGPointMake(smallerRect.origin.x + smallerRect.size.width / 2 - sz.width / 2,
                             smallerRect.origin.y + smallerRect.size.height / 2 - sz.height / 2);// smallerRect.origin;
    
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
    
    [maskPath moveToPoint:[points[0] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[2] CGPointValue] controlPoint:[points[1] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[4] CGPointValue] controlPoint:[points[3] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[6] CGPointValue] controlPoint:[points[5] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[0] CGPointValue] controlPoint:[points[7] CGPointValue]];
    
    [maskWithHole setFrame:self.bounds];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setPath:[maskPath CGPath]];
    
    [self.overlayView.layer setMask:maskWithHole];
    
    [borderView setFrame:CGRectInset(smallerRect, -1.0, -1.0)];
}

- (UIImage *)processedImage {
    CGFloat scale = [[UIScreen mainScreen] scale];
    //scale = 1.0f;
    scale = 1.0f;
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, scale);
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:graphicsContext];
    CGImageRef imgRef = CGBitmapContextCreateImage(graphicsContext);
    UIImage* selfImage = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
//    CGContextRelease(graphicsContext);
    UIGraphicsEndImageContext();

    return selfImage; // return Image from self
    
    UIImage *finalImage = nil;
    UIImage *sourceImage = [APPDELEGATE selectedPhoto];
    sourceImage = [sourceImage fixOrientation];
    CGSize size = sourceImage.size;
    
    float xRatio = size.width / self.scrollView.contentSize.width;
    float yRatio = size.height / self.scrollView.contentSize.height;
    
    CGPoint offsetPt = self.scrollView.contentOffset;
    CGSize offsetSize = self.scrollView.frame.size;
    CGRect targetFrame = CGRectMake(offsetPt.x * scale * xRatio,
                                    offsetPt.y * scale * yRatio,
                                    offsetSize.width * scale * xRatio,
                                    offsetSize.height * scale * yRatio);

    CGImageRef contextImage = CGImageCreateWithImageInRect([sourceImage CGImage], targetFrame);
    
    if (contextImage != NULL) {
        finalImage = [UIImage imageWithCGImage:contextImage
                                         scale:scale
                                   orientation:sourceImage.imageOrientation];

        CGImageRelease(contextImage);
    }
    
    return finalImage;
}

@end
