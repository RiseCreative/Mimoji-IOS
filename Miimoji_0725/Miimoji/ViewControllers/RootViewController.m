//
//  RootViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
//    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
//}

@end
