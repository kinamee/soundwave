//
//  AppDelegate.m
//  repeater
//
//  Created by admin on 2015. 12. 19..
//  Copyright © 2015년 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import "KSPath.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //NSLog(@"URL:%@", [url path]);
    //NSLog(@"APP:%@", sourceApplication);
    
    /*-------------------
     도큐먼트 경로로 이동시킨다
     --------------------*/
    NSString* pathTo = [[KSPath shared] documentPath];
    pathTo = [pathTo stringByAppendingString:@"/"];
    pathTo = [pathTo stringByAppendingString:[url lastPathComponent]];
    
    //NSLog(@"COPY TO: %@", pathTo);
    [[KSPath shared] moveFile:[url path] targetPath:pathTo];
    [[KSPath shared] deleteFile:[url path]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // COPY CONFIGURATION FILE INTO DOCUMENTS/_TEMP/
    [[Config shared] copyConfigToDoc];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // SAVE CURRENT CONFIGURATION
    // PLAYING INFO WILL ALSO SAVED
    [[Config shared] writeToFile];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // SAVE CURRENT CONFIGURATION
    // PLAYING INFO WILL ALSO SAVED
    [[Config shared] writeToFile];
}

@end
