//
//  EditAccountViewController.m
//  Miimoji
//
//  Created by Master of IT on 7/2/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "EditAccountViewController.h"
//#import <Parse/Parse.h>

@interface EditAccountViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPasswordConfirm;
@property (weak, nonatomic) IBOutlet UINavigationBar *navibar;
@end

@implementation EditAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navibar setBackgroundImage:[UIImage new]
                       forBarMetrics:UIBarMetricsDefault];
    self.navibar.shadowImage = [UIImage new];
    self.navibar.translucent = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Methods
- (IBAction)onBtnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBtnSave:(id)sender {
    // Check whether textFields are empty
    if ([self.txtFirstName.text isEqualToString:@""] ||
        [self.txtLastName.text isEqualToString:@""] ||
        [self.txtEmail.text isEqualToString:@""] ||
        [self.txtPassword.text isEqualToString:@""] ||
        [self.txtPasswordConfirm.text isEqualToString:@""]) {
        
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Please type in the fields"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    // Confirm password
    if (![self.txtPassword.text isEqualToString:self.txtPasswordConfirm.text]) {
        
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Please check the passwords"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
/*
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
            if (currentUser) {
                // Signup Successfully
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:[NSString stringWithFormat:@"Success Signup %@ %@", currentUser.username, currentUser.email]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                
                // Go to main screen
                [self.navigationController popToRootViewControllerAnimated:NO];
                [self.loginViewController gotoMainScreen];
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
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
*/
}

@end
