//
//  UIButtonWithImageAspectFit.m
//  Miimoji
//
//  Created by Master of IT on 7/10/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "UIButtonWithImageAspectFit.h"

@implementation UIButtonWithImageAspectFit

- (void)awakeFromNib {
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
