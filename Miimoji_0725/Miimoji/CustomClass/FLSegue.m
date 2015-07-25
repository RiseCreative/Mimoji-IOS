//
//  FLSegue.m
//  CustomSegue
//
//  Created by Lombardo on 01/05/13.
//  Copyright (c) 2013 Lombardo. All rights reserved.
//

#import "FLSegue.h"

@implementation FLSegue

-(void)perform{
    UIViewController *dst = [self destinationViewController];
    UIViewController *src = [self sourceViewController];
    
    [src addChildViewController:dst];
    [src.view addSubview:dst.view];
    [src.view bringSubviewToFront:dst.view];
    
//    CGRect frame;
//    frame.size.height = src.view.frame.size.height;
//    frame.size.width = src.view.frame.size.width;
//    frame.origin.x = src.view.bounds.origin.x;
//    frame.origin.y = src.view.bounds.origin.y;
//    dst.view.frame = frame;
    
    dst.view.alpha = 0;
    dst.view.frame = src.view.bounds;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        dst.view.alpha = 1.0f;
        
        NSLog(@"%@", NSStringFromCGRect(dst.view.frame));
    }];
}

@end
