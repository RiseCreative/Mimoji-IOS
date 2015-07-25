//
//  MyMiimojiViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "AppDelegate.h"
#import "MyMiimojiViewController.h"
#import "ShareViewController.h"
#import "FLSegue.h"
#import <MessageUI/MessageUI.h>

@interface MyMiimojiViewController () <UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    NSMutableArray *miimojiArray;
    NSInteger selectedMiimoji;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionMiimoji;
@end

@implementation MyMiimojiViewController

- (void)refreshView {
    // Load miimojis from CoreData
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequestOverlay = [[NSFetchRequest alloc] initWithEntityName:@"Miimoji"];
    miimojiArray = [[managedObjectContext executeFetchRequest:fetchRequestOverlay error:nil] mutableCopy];

    [self.collectionMiimoji reloadData];
}

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

    self.collectionMiimoji.backgroundColor = [UIColor clearColor];
    
    // Load miimojis from CoreData
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequestOverlay = [[NSFetchRequest alloc] initWithEntityName:@"Miimoji"];
    miimojiArray = [[managedObjectContext executeFetchRequest:fetchRequestOverlay error:nil] mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShareMiimojiSegue"]) {
        ShareViewController* destViewController = (ShareViewController*)segue.destinationViewController;
        destViewController.selectedMiimoji = selectedMiimoji;
        destViewController.parentViewController = self;
    }
}

#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger retNum = 0;
    
    if ([collectionView isEqual:self.collectionMiimoji]) {
        retNum = miimojiArray.count;
    }
    
    return retNum;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = nil;
    
    if ([collectionView isEqual:self.collectionMiimoji]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"miimojiCell" forIndexPath:indexPath];
        
        CGSize cellSize = cell.frame.size;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
        imageView.image = [UIImage imageWithContentsOfFile:[miimojiArray[indexPath.row] valueForKeyPath:@"path"]];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 5;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        [cell.contentView addSubview:imageView];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedMiimoji = indexPath.row;

    //V !! Present viewcontroller by custom segue
    ShareViewController* toViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    FLSegue *segue = [[FLSegue alloc] initWithIdentifier:@"ShareMiimojiSegue" source:self destination:toViewController];
    UICollectionViewCell* curCell = [collectionView cellForItemAtIndexPath:indexPath];
    [self prepareForSegue:segue sender:curCell];
    [segue perform];
    
    return;
    
    if ([collectionView isEqual:self.collectionMiimoji]) {
        selectedMiimoji = indexPath.row;
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Select One"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Send by Message", @"Send by Email", @"Copy", @"Delete", nil];
        actionSheet.tag = 100;
//        for (NSString *title in designations) {
//            [actionSheet addButtonWithTitle: title];
//        }
//        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
        
        [actionSheet showInView:self.view];
    }
    
//    [collectionView reloadItemsAtIndexPaths:indexPaths];
}

#pragma mark - UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0: // Message
                [self sendByMessage];
                break;
            case 1: // Email
                [self sendByEmail];
                break;
            case 2: // Copy
                [self copyMiimoji];
                break;
            case 3: // Delete
                [self deleteMiimoji];
                break;
            default:
                break;
        }
    }
}

- (void)sendByMessage {
    NSManagedObject* curObj = miimojiArray[selectedMiimoji];
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
    NSManagedObject* curObj = miimojiArray[selectedMiimoji];
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
    UIImage* img = [UIImage imageWithContentsOfFile:[miimojiArray[selectedMiimoji] valueForKey:@"path"]];
    
    [UIPasteboard generalPasteboard].image = img;
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete Miimoji"
                                                        message:@"Your miimoji copied in clipboard"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

}

- (void)deleteMiimoji {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete Miimoji"
                                                        message:@"Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
    alertView.tag = 1;
    [alertView show];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
            if (buttonIndex == 0) {
                
            } else if (buttonIndex == 1) {
                NSManagedObjectContext *context = [self managedObjectContext];
                [context deleteObject:miimojiArray[selectedMiimoji]];
                
                NSError *error = nil;
                if (![context save:&error]) {
                    NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                    return;
                }
                
                // Remove device from table view
                [miimojiArray removeObjectAtIndex:selectedMiimoji];
                
                [self.collectionMiimoji reloadData];
            }
            break;
            
        default:
            break;
    }
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
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
