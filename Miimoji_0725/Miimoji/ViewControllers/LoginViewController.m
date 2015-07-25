//
//  LoginViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "RootViewController.h"
//#import <Parse/Parse.h>

@interface LoginViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate> {
    UITapGestureRecognizer *tap;
    UITextField* activeField;
}

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignin;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UIButton *btnFBSigin;
@end

@implementation LoginViewController
@synthesize txtEmail, txtPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeButtonRound:self.btnSignin WithCornerRadius:5 BorderWidth:0 AndBorderColor:[UIColor clearColor]];
    [self makeButtonRound:self.btnSignup WithCornerRadius:5 BorderWidth:2 AndBorderColor:[UIColor whiteColor]];
    [self makeButtonRound:self.btnFBSigin WithCornerRadius:5 BorderWidth:0 AndBorderColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated { /*
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser != nil && currentUser.username != nil && currentUser.email != nil) {
        [self gotoMainScreen];
    } else {
        // show the signup or login screen
    } */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"SignupSegue"]) {
        SignUpViewController* destViewController = segue.destinationViewController;
        destViewController.loginViewController = self;
    }
}

#pragma mark - Methods relative to buttons

- (void)makeButtonRound:(UIButton*)button WithCornerRadius:(CGFloat)cornderRadius BorderWidth:(CGFloat)borderWidth AndBorderColor:(UIColor*)borderColor {
    button.layer.cornerRadius = cornderRadius;
    button.layer.borderWidth = borderWidth;
    button.layer.borderColor = borderColor.CGColor;
    // (note - may prefer to use the tintColor of the control)
}

- (IBAction)onBtnLogin:(id)sender {
/*
    // Check whether textFields are empty
    if ([txtEmail.text isEqualToString:@""] ||
        [txtPassword.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Please type in the fields"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    // Log in
    NSString* name = [NSString stringWithFormat:@"%@_name", self.txtEmail.text];
    
    [PFUser logInWithUsernameInBackground:name password:self.txtPassword.text
        block:^(PFUser *user, NSError *error) {
            if (user) {
                // Do stuff after successful login.
                PFUser *currentUser = [PFUser currentUser];
                if (currentUser != nil && currentUser.username != nil && currentUser.email != nil) {
                    [self gotoMainScreen];
                } else {
                    // show the signup or login screen
                    [[[UIAlertView alloc] initWithTitle:@""
                                                message:@"Success Login, but No User"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            } else {
                // The login failed. Check error to see why.
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:[NSString stringWithFormat:@"Failed Login %@", [error userInfo][@"error"]]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }]; */
}

- (IBAction)onBtnForget:(id)sender {
}

- (void)gotoMainScreen {
    // Login Successfully
    RootViewController* rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"rootController"];
    [APPDELEGATE setRootViewController:rootViewController];
    [self presentViewController:rootViewController animated:YES completion:nil];
    
    // Clear Login Infos
    txtEmail.text = @"";
    txtPassword.text = @"";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUInteger index = textField.tag;
    
    if (index == 1) { // Last textField
        [textField resignFirstResponder];
    }else{
        UITextField *nextTextField = (UITextField*)[self.view viewWithTag:index+1];
        [nextTextField becomeFirstResponder];
        
    }
    return NO;
}

@end
