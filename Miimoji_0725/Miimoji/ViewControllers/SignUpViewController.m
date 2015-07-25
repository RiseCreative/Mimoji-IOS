//
//  SignUpViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "SignUpViewController.h"
//#import <Parse/Parse.h>

@interface SignUpViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPasswordConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@end

@implementation SignUpViewController
@synthesize txtFirstName, txtLastName, txtEmail, txtPassword, txtPasswordConfirm;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self makeButtonRound:self.btnSignup WithCornerRadius:5 BorderWidth:0 AndBorderColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Make navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Methods for buttons
- (void)makeButtonRound:(UIButton*)button WithCornerRadius:(CGFloat)cornderRadius BorderWidth:(CGFloat)borderWidth AndBorderColor:(UIColor*)borderColor {
    button.layer.cornerRadius = cornderRadius;
    button.layer.borderWidth = borderWidth;
    button.layer.borderColor = borderColor.CGColor;
    // (note - may prefer to use the tintColor of the control)
}

- (IBAction)onBtnSignUp:(id)sender {
/*
    // Check whether textFields are empty
    if ([txtFirstName.text isEqualToString:@""] ||
        [txtLastName.text isEqualToString:@""] ||
        [txtEmail.text isEqualToString:@""] ||
        [txtPassword.text isEqualToString:@""] ||
        [txtPasswordConfirm.text isEqualToString:@""]) {
        
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Please type in the fields"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }

    // Confirm password
    if (![txtPassword.text isEqualToString:txtPasswordConfirm.text]) {
        
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Please check the passwords"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    // Sign up
    PFUser *user = [PFUser user];
    user.username = [NSString stringWithFormat:@"%@_name", self.txtEmail.text];
    user.email = self.txtEmail.text;
    user.password = self.txtPassword.text;
    
    user[@"firstName"] = self.txtFirstName.text;
    user[@"lastName"] = self.txtLastName.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFUser *currentUser = [PFUser currentUser];
            if (currentUser != nil && currentUser.username != nil & currentUser.password != nil) {
                // Signup Successfully
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@""
                                           message:[NSString stringWithFormat:@"Success Signup %@ %@", currentUser.username, currentUser.email]
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
                alertView.tag = 1;
                [alertView show];
            } else {
                // show the signup or login screen
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"Success Signup, but No User"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        } else {
            // Failed Signup
            NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:errorString
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }]; */
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            // Go to main screen
//            [self.loginViewController gotoMainScreen];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUInteger index = textField.tag;
    
    if (index == 4) { // Last textField
        [textField resignFirstResponder];
    }else{
        UITextField *nextTextField = (UITextField*)[self.view viewWithTag:index+1];
        [nextTextField becomeFirstResponder];
        
    }
    return NO;
}

@end
