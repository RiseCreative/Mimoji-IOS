//
//  SignUpViewController.h
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITapViewController.h"
#import "LoginViewController.h"

@interface SignUpViewController : UITapViewController

@property (weak, nonatomic) LoginViewController* loginViewController;

@end
