//
//  AppDelegate.h
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RootViewController.h"
#import "MainViewController.h"

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIImage* selectedPhoto;
@property (weak, nonatomic) RootViewController* rootViewController;
@property (weak, nonatomic) MainViewController* mainViewController;
//@property (weak, nonatomic) UIViewController* branchViewController;
@property (assign, nonatomic) CGSize mainScreenSize;
@property (assign, nonatomic) BOOL bNeedToApply;

@property (strong, nonatomic) UIWindow* window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSString*)saveImageWithCurrentDateTime:(UIImage*)imageToSave andName:(NSString*)miimojiName;
- (NSString*)saveImage:(UIImage*)imageToSave withName:(NSString*)filename;

//- (void)setViewControllers:(UIViewController*)viewController;

@end

