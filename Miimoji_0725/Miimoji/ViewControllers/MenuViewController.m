//
//  MenuViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "MainViewController.h"
#import "SecondViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "NavigationController.h"
#import "EditAccountViewController.h"
#import "PrivacyViewController.h"
#import "AboutViewController.h"
//#import <Parse/Parse.h>

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionShare;
@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        
        CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height * 2;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, height)];
        view;
    });
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.collectionShare.backgroundColor = [UIColor clearColor];
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];

    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: // Create Miimoji
                [[APPDELEGATE mainViewController] clickBtnCreateMiimoji];
                break;
            case 1: // My Miimoji
                [[APPDELEGATE mainViewController] clickBtnMyMiimoji];
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
//            case 0: // Sign out
//            {
//                [PFUser logOut];
//                PFUser *currentUser = [PFUser currentUser]; // this will now be nil
//                if (currentUser != nil && currentUser.username == nil && currentUser.email == nil) {
//                    RootViewController* rootViewController = [APPDELEGATE rootViewController];
//                    [rootViewController dismissViewControllerAnimated:YES completion:nil];
//                }
//            }
//                break;
//            case 1: // Edit Account
//                [[APPDELEGATE mainViewController] showViewController:NSStringFromClass([EditAccountViewController class])];
//                break;
            case 0: // Privacy Policy
                [[APPDELEGATE mainViewController] showViewController:NSStringFromClass([PrivacyViewController class])];
                break;
            case 1: // About this version
                [[APPDELEGATE mainViewController] showViewController:NSStringFromClass([AboutViewController class])];
                break;
            case 2: // Rate the app
                [[APPDELEGATE mainViewController] showViewController:@"RateThisApp"];
                break;
            case 3: // Report a problem
                [[APPDELEGATE mainViewController] showViewController:@"ReportAProblem"];
                break;
        }
    } else if (indexPath.section == 3) {
        // Share options
    }
    
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        MainViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainController"];
//        navigationController.viewControllers = @[homeViewController];
//    } else {
//        SecondViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"secondController"];
//        navigationController.viewControllers = @[secondViewController];
//    }
//    
//    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
//{
//    UIView* view = [super tableView:tableView viewForHeaderInSection:sectionIndex];
//    
////    if (view != nil) {
////        view.backgroundColor = [UIColor redColor];
////    }
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;

    CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height * 1.5;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 4) {
        height = 1000;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [super tableView:tableView numberOfRowsInSection:sectionIndex];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor blackColor];
    v.textLabel.textColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger retNum = 0;
    
    if ([collectionView isEqual:self.collectionShare]) {
        retNum = 4;
    }
    
    return retNum;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = nil;
    
    if ([collectionView isEqual:self.collectionShare]) {
        NSArray* shareArray = [NSArray arrayWithObjects:@"share_message.png", @"share_email.png", @"share_twitter.png", @"share_facebook.png", nil];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shareCell" forIndexPath:indexPath];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        imageView.image = [UIImage imageNamed:shareArray[indexPath.row]];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 0;
        imageView.layer.borderColor = [UIColor blackColor].CGColor;
        imageView.layer.borderWidth = 0.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        [cell.contentView addSubview:imageView];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.collectionShare]) {
        switch (indexPath.row) {
            case 0:
                [[APPDELEGATE mainViewController] showViewController:@"ShareAppByMessage"];
                break;
            case 1:
                [[APPDELEGATE mainViewController] showViewController:@"ShareAppByEmail"];
                break;
            case 2:
                [[APPDELEGATE mainViewController] showViewController:@"ShareAppByTwitter"];
                break;
            case 3:
                [[APPDELEGATE mainViewController] showViewController:@"ShareAppByFacebook"];
                break;
            default:
                break;
        }
    }
    
    //    [collectionView reloadItemsAtIndexPaths:indexPaths];
    
    [self.frostedViewController hideMenuViewController];
}

@end
