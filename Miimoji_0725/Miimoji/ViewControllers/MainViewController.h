//
//  MainViewController.h
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface MainViewController : UIViewController

- (IBAction)showMenu;
- (void)clickBtnCreateMiimoji;
- (void)clickBtnMyMiimoji;
- (void)showViewController:(NSString*)viewClass;

@end
