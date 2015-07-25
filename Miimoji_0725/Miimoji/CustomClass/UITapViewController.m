//
//  UIView+Tap.m
//  NavSample
//
//  Created by Master of IT on 7/6/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "UITapViewController.h"

@interface UITapViewController () <UIGestureRecognizerDelegate> {
    
    UITapGestureRecognizer *tap;
    UITextField* activeField;
}

@end

@implementation UITapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tap.delegate = self;
    tap.enabled = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Tap Methods
- (void)tapView:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.view endEditing:YES];
        activeField = nil;
        tap.enabled = NO;
        
        //V Necessary
        CGPoint point = [tapRecognizer locationInView:tapRecognizer.view];
        if (!CGRectContainsPoint(activeField.frame, point))
        {
            [self.view endEditing:YES];
            tap.enabled = NO;
        }
    }
    
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)note
{
    id _obj = [note.userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGRect _keyboardBound = CGRectNull;
    [_obj getValue:&_keyboardBound];
    
    CGRect mainBound = [[UIScreen mainScreen] bounds];
    CGRect activeFrame = activeField.frame;
    CGFloat activeBottomY = activeFrame.origin.y + activeFrame.size.height;
    
    if (activeBottomY > mainBound.size.height - _keyboardBound.size.height) {
        CGFloat offsetYByKeyboard = _keyboardBound.size.height - self.tabBarController.tabBar.frame.size.height;
        if (offsetYByKeyboard > 0) {
            
            [UIView animateWithDuration:0.1 animations:^{
                for (UIView* view in self.view.subviews) {
                    view.transform = CGAffineTransformMakeTranslation(0, -offsetYByKeyboard);
                }
                //                self.scrollView.transform = CGAffineTransformMakeTranslation(0, -offsetYByKeyboard);
            }];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    id _obj = [note.userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGRect _keyboardBound = CGRectNull;
    [_obj getValue:&_keyboardBound];
    
    CGFloat offsetYByKeyboard = _keyboardBound.size.height - self.tabBarController.tabBar.frame.size.height;
    
    if ( offsetYByKeyboard > 0 ) {
        
        [UIView animateWithDuration:0.1 animations:^{
            //            self.scrollView.transform = CGAffineTransformIdentity;
            for (UIView* view in self.view.subviews) {
                view.transform = CGAffineTransformIdentity;
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    tap.enabled = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
