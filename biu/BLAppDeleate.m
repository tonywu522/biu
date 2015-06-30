//
//  AppDelegate.m
//  biu
//
//  Created by Tony Wu on 5/5/15.
//  Copyright (c) 2015 BiuLove. All rights reserved.
//

#import "BLAppDeleate.h"
#import "BLWelcomeViewController.h"
#import "BLMatchViewController.h"
#import "BLProfileViewController.h"

@interface BLAppDeleate ()

@property (assign, nonatomic) NSInteger badgeCount;

@end

@implementation BLAppDeleate

@synthesize passwordItem, blurMenu, welNavController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
     self.passwordItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
    
    // Get current user
    self.currentUser = [[User alloc] initWithFromUserDefault];
    
    // Add Navigation
    BLWelcomeViewController *welcomeViewController = [[BLWelcomeViewController alloc] initWithNibName:nil bundle:nil];
    self.welNavController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    self.welNavController.navigationBarHidden = YES;
    self.window.rootViewController = self.welNavController;
    
    // Create filling information navigation controller
    BLProfileViewController *profileViewController = [[BLProfileViewController alloc] initWithNibName:nil bundle:nil];
    profileViewController.profileViewType = BLProfileViewTypeCreate;
    self.fillingInfoNavController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    self.fillingInfoNavController.navigationBarHidden = YES;
    
    // Create master navigation controller
    BLMatchViewController *matchViewController = [[BLMatchViewController alloc] initWithNibName:nil bundle:nil];
    BLMenuViewController *menuViewController = [[BLMenuViewController alloc] init];
    UINavigationController *masterNavViewController = [[UINavigationController alloc] initWithRootViewController:matchViewController];
    masterNavViewController.navigationBarHidden = YES;
    
    // Create BL Menu view controller
    self.blurMenu = [[BLBlurMenu alloc] initWithRootViewController:masterNavViewController
                                                menuViewController:menuViewController];
    
    // Let the device know we want to receive push notifications
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    self.badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark Push Notification Delegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.deviceToken = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Got device token as %@", self.deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
}

@end
