//
//  ShareViewController.m
//  Miimoji
//
//  Created by Master of IT on 7/14/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "AppDelegate.h"
#import "ShareViewController.h"
#import <MessageUI/MessageUI.h>

@interface ShareViewController () <UIAlertViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    NSMutableArray *miimojiArray;
    UITapGestureRecognizer *tap;
}

@property (weak, nonatomic) IBOutlet UIView *buttonView;
@end

@implementation ShareViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.buttonView.layer.cornerRadius = 5.0f;
    self.buttonView.backgroundColor = [UIColor whiteColor];

    // Gesture
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    // Load miimojis from CoreData
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequestOverlay = [[NSFetchRequest alloc] initWithEntityName:@"Miimoji"];
    miimojiArray = [[managedObjectContext executeFetchRequest:fetchRequestOverlay error:nil] mutableCopy];
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

#pragma mark - Tap Methods
- (void)tapView:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self disappearView:YES];
    }
}

#pragma mark - Button Methods

- (void)disappearView:(BOOL)animation {
    CGFloat time = 0;
    if (animation) {
        time = 0.3f;
    }
    
    [UIView animateWithDuration:time animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (IBAction)onBtnCancel:(id)sender {
    [self disappearView:YES];
}

- (IBAction)onBtnText:(id)sender {
    [self sendByMessage];
}

- (IBAction)onBtnCopy:(id)sender {
    [self copyMiimoji];
}

- (IBAction)onBtnEmail:(id)sender {
    [self sendByEmail];
}

- (IBAction)onBtnDelete:(id)sender {
    [self deleteMiimoji];
}

#pragma mark - Miimoji Operation
- (void)sendByMessage {
    NSManagedObject* curObj = miimojiArray[_selectedMiimoji];
    UIImage* img = [UIImage imageWithContentsOfFile:[curObj valueForKey:@"path"]];
    NSString* body = @"Miimoji sent from your friend";
    
    MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
    viewController.messageComposeDelegate = self;
    viewController.body = body;
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    [viewController addAttachmentData:data typeIdentifier:@"photo.jpg" filename:@"photo.jpg"];
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)sendByEmail {
    NSManagedObject* curObj = miimojiArray[_selectedMiimoji];
    UIImage* img = [UIImage imageWithContentsOfFile:[curObj valueForKey:@"path"]];
    NSString* subject = @"Your friend has sent you a miimoji";
    
    MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
    viewController.mailComposeDelegate = self;
    [viewController setSubject:subject];
    //    [viewController setMessageBody:title isHTML:NO];
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    [viewController addAttachmentData:data mimeType:@"image/jpeg" fileName:@"photo.jpg"];
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)copyMiimoji {
    UIImage* img = [UIImage imageWithContentsOfFile:[miimojiArray[_selectedMiimoji] valueForKey:@"path"]];
    //    NSData* data = UIImagePNGRepresentation(img);
    //    NSData* data = [NSData dataWithContentsOfFile:[self.gallery[curSelIndex] valueForKey:@"path"]];
    
    [UIPasteboard generalPasteboard].image = img;
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Copy Miimoji"
                                                        message:@"Your miimoji copied in clipboard"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.tag = 1;
    [alertView show];
    
}

- (void)deleteMiimoji {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete Miimoji"
                                                        message:@"Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
    alertView.tag = 2;
    [alertView show];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
            break;
        case 2:
            if (buttonIndex == 0) {
                
            } else if (buttonIndex == 1) {
                NSManagedObjectContext *context = [self managedObjectContext];
                [context deleteObject:miimojiArray[_selectedMiimoji]];
                
                NSError *error = nil;
                if (![context save:&error]) {
                    NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                    return;
                }
                
                // Remove device from table view
                [miimojiArray removeObjectAtIndex:_selectedMiimoji];
                
                [self.parentViewController refreshView];
            }
            break;
        default:
            break;
    }
    
    [self disappearView:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^(void){
        [self disappearView:YES];
    }];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^(void){
        [self disappearView:YES];
    }];
}

@end
