//
//  AppDelegate.m
//  DemoApp
//
//  Created by jarinosuke on 9/8/13.
//  Copyright (c) 2013 jarinosuke. All rights reserved.
//

#import "AppDelegate.h"
#import "JRNPasteboardMonitor.h"
#import "JRNLocalNotificationCenter.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //this is another library, please read this. https://github.com/jarinosuke/JRNLocalNotificationCenter
    //set notification handler
    [[JRNLocalNotificationCenter defaultCenter] setLocalNotificationHandler:^(NSString *key, NSDictionary *userInfo) {
        [[[UIAlertView alloc] initWithTitle:@"You copied!"
                                    message:userInfo[@"copied_string"]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
    
    
    
    //set expiration handler
    [JRNPasteboardMonitor defaultMonitor].expireHandler = ^{
        [[JRNLocalNotificationCenter defaultCenter] postNotificationOnNowForKey:@"JRNPasteboardMonitor_Expire"
                                                                      alertBody:@"Monitoring was expired, please launch again."
                                                                       userInfo:nil];
    };
    
    
    //set pasteboard handler
    [[JRNPasteboardMonitor defaultMonitor] startMonitoringWithChangeHandler:^(NSString *string) {
        [[JRNLocalNotificationCenter defaultCenter] postNotificationOnNowForKey:@"JRNPasteboardMonitor_Copy"
                                                                      alertBody:[NSString stringWithFormat:@"%@ copied.", string]
                                                                       userInfo:@{@"copied_string": string}];
    }];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //this is another library, please read this. https://github.com/jarinosuke/JRNLocalNotificationCenter
    //notification handling method.
    [[JRNLocalNotificationCenter defaultCenter] didReceiveLocalNotificationUserInfo:notification.userInfo];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
