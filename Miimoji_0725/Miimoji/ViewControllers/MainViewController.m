//
//  MainViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "CreateMiimojiViewController.h"
#import "MyMiimojiViewController.h"
#import "EditAccountViewController.h"
#import "PrivacyViewController.h"
#import "AboutViewController.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface MainViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnMyMiimoji;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateMiimoji;
@end

@implementation MainViewController

- (void)awakeFromNib {
    [self.btnCreateMiimoji.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.btnMyMiimoji.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)viewDidLoad {
    [APPDELEGATE setMainViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.btnCreateMiimoji.contentMode = UIViewContentModeScaleAspectFit;
    self.btnMyMiimoji.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    [APPDELEGATE setMainScreenSize:mainRect.size];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ToNewMiimoji"])
    {
    } else if ([[segue identifier] isEqualToString:@"ToMyMiimoji"]) {
    }
    
    //    [APPDELEGATE setBranchViewController:segue.destinationViewController];
}

- (IBAction)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - Create events for buttons
- (void)clickBtnCreateMiimoji {

    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // Click "Create Miimoji" Button
    [self.btnCreateMiimoji sendActionsForControlEvents: UIControlEventTouchUpInside];
}

- (void)clickBtnMyMiimoji {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // Click "My Miimoji" Button
    [self.btnMyMiimoji sendActionsForControlEvents: UIControlEventTouchUpInside];
}

#pragma mark - Present view controller
- (void)showViewController:(NSString*)viewClass {
    
    if ([viewClass isEqualToString:NSStringFromClass([EditAccountViewController class])]) {
        EditAccountViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editAccountController"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else if ([viewClass isEqualToString:NSStringFromClass([PrivacyViewController class])]) {
        PrivacyViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"privacyController"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else if ([viewClass isEqualToString:NSStringFromClass([AboutViewController class])]) {
        AboutViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutController"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else if ([viewClass isEqualToString:@"ReportAProblem"]) {
        [self reportProblem];
    }
    else if ([viewClass isEqualToString:@"ShareAppByMessage"]) {
        [self shareAppByMessage];
    }
    else if ([viewClass isEqualToString:@"ShareAppByEmail"]) {
        [self shareAppByEmail];
    }
    else if ([viewClass isEqualToString:@"ShareAppByTwitter"]) {
        [self shareAppByTwitter];
    }
    else if ([viewClass isEqualToString:@"ShareAppByFacebook"]) {
        [self shareAppByFacebook];
    }
    else if ([viewClass isEqualToString:@"RateThisApp"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/jobsy/id687059035"]];
    }
}

- (void)reportProblem {
    NSString* subject = @"Reported problem";
    
    MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
    viewController.mailComposeDelegate = self;
    [viewController setSubject:subject];
    [viewController setToRecipients:[NSArray arrayWithObjects:@"WinStar_102@hotmail.com", @"WinStar102@yahoo.com", nil]];
    [viewController setMessageBody:@"There is a problem." isHTML:NO];
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)shareAppByMessage {
    NSString* body = @"http://google.com";
    
    MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
    viewController.messageComposeDelegate = self;
    viewController.body = body;
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)shareAppByEmail {
    NSString* subject = @"App Sharing";
    
    MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
    viewController.mailComposeDelegate = self;
    [viewController setSubject:subject];
    [viewController setMessageBody:@"http://google.com" isHTML:YES];
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)shareAppByTwitter {
    //=============  Using SLComposeViewController  ==============//
    SLComposeViewController *twitterSheet = [SLComposeViewController
                                             composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    [twitterSheet setInitialText:@"Share App"];
    [twitterSheet addURL:[NSURL URLWithString:@"http://baidu.com"]];
    
    [self presentViewController:twitterSheet animated:YES completion:nil];
    
    //============  Using UIActivityViewController  ===============//
    /*
     // Sharing photo using UIActivityViewController
     NSString* text = @"example text";
     NSURL* url = [NSURL URLWithString:@"http://www.google.com"];
     UIImage* img = [UIImage imageWithContentsOfFile:[self.gallery[curSelIndex] valueForKey:@"path"]];
     NSArray* activityItems = @[text, url, img];
     
     UIActivityViewController* activityController = [[UIActivityViewController alloc]
     initWithActivityItems:activityItems
     applicationActivities:nil];
     [self presentViewController:activityController animated:YES completion:nil];
     */
}

- (void)shareAppByFacebook {
    //=============  Using SLComposeViewController  ==============//
    SLComposeViewController *faceSheet = [SLComposeViewController
                                          composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [faceSheet setInitialText:@"Share App"];
    [faceSheet addURL:[NSURL URLWithString:@"http://baidu.com"]];
    
    [self presentViewController:faceSheet animated:YES completion:nil];
    
    
    //=============    Using Facebook SDK    ===============//
    /*
     // If the Facebook app is installed and we can present the share dialog
     if([FBDialogs canPresentShareDialogWithPhotos]) {
     NSLog(@"canPresent");
     // Retrieve a picture from the device's photo library
     //
     //         NOTE: SDK Image size limits are 480x480px minimum resolution to 12MB maximum file size.
     //         In this app we're not making sure that our image is within those limits but you should.
     //         Error code for images that go below or above the size limits is 102.
     
     UIImage* img = [UIImage imageWithContentsOfFile:[self.gallery[curSelIndex] valueForKey:@"path"]];
     
     FBPhotoParams *params = [[FBPhotoParams alloc] init];
     params.photos = @[img];
     
     [FBDialogs presentShareDialogWithPhotoParams:params
     clientState:nil
     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
     if (error) {
     NSLog(@"Error: %@", error.description);
     } else {
     NSLog(@"Success!");
     }
     }];
     }
     */
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^(void){}];
}

@end
