//
//  MiimojiViewController.h
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YCameraViewControllerDelegate;

@interface MiimojiViewController : UIViewController {    
}

@property (weak, nonatomic) NSString* glossary;
@property (strong, nonatomic) UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *menuView;
@property (weak, nonatomic) IBOutlet UIView *toolView;

- (void)resetZoomScaleWithAnimated:(BOOL)animated;
- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)enableButtonsForNeedToApply;

@end

@protocol YCameraViewControllerDelegate
- (void)didFinishPickingImage:(UIImage *)image;
- (void)yCameraControllerDidCancel;

@end
