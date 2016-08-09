//
//  AppDelegate.m
//  MTBackgroundFetch
//
//  Created by Jorge Costa on 10/14/13.
//  Copyright (c) 2013 MobileTuts. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:180];
    return YES;
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

//系统会在执行fetch的时候调用这个方法，然后开发者需要做的是在这个方法里完成获取的工作，然后刷新UI，并通知系统获取结束，以便系统尽快回到休眠状态。
//限制：系统不会给很长时间 来做fetch,一般会小于一分钟，而且fetch在绝大多数情况下和别的应用共用网络连接，这些时间对于fetch一些简单数据来说是足够了。但是对于文件传输工作的话，不合适了~~
//在获取完成后，必须通知系统获取完成，此时系统将对现在的UI状态截图并更新App Switcher中的应用截屏，
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
    
    id topViewController = navigationController.topViewController;
    if ([topViewController isKindOfClass:[ViewController class]]) {
        [(ViewController*)topViewController insertNewObjectForFetchWithCompletionHandler:completionHandler];
    } else {
        NSLog(@"Not the right class %@.", [topViewController class]);
        completionHandler(UIBackgroundFetchResultFailed);
    }
}



@end
