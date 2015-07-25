//
//  ShareViewController.h
//  Miimoji
//
//  Created by Master of IT on 7/14/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMiimojiViewController.h"

@interface ShareViewController : UIViewController

@property (assign, nonatomic) NSInteger selectedMiimoji;
@property (weak, nonatomic) MyMiimojiViewController* parentViewController;

@end
