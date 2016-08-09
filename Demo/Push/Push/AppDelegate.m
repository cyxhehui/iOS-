//
//  AppDelegate.m
//  Push
//
//  Created by 小丸子 on 8/7/2016.
//  Copyright © 2016 hehui. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <NSURLSessionDelegate>
/**
 * 唯一标识后台任务的一个ID
 */
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push" message:@"App launch" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
//  NSDictionary * remoteNotificationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
//    if (remoteNotificationInfo) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push" message:@"Process notification in application:didFinishLaunchingWithOptions" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
//        [alert show];
//    }
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken{
    
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

/**
 *  IOS7以上系统，如果以下两个方法同时实现了，默认调用第二个方法
 */

//此方法只有在应用在前台时才被调用（但是，如果content-avaliable设置为1的话，此方法在后台也会被调用，但是不可取）
-(void)application:(UIApplication *)application
didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
    NSLog(@"receive notification"); //(10ms) (10us，100us no)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
        
        //[self dataTaskResume];
        NSLog(@"%@", userInfo);
    });
}

//API文档建议，尽量使用此回调方法。
//如果app在前台运行时，正常处理notification，完成下载
//如果app在退到后台时，app被唤醒在后台运行，有短暂的时间处理notification
//如果设备进入休息或锁屏时，app会从后台运行进入suspend的状态，此时如果有notification，会短暂地从后台唤醒app,执行过后，如果不解锁设备的话，app会再次进入suspend的状态
//NSURLSessionTask 通过新的线程继续在后台运行（后台线程），直至设备进入休眠，app很快进入suspend的状态
//
-(void)application:(UIApplication *)application
didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    [self dataTaskResumeWithCompletionHandler:completionHandler];
    NSLog(@"%@", userInfo);
    
    //completionHandler(UIBackgroundFetchResultNewData);
}

-(void)dataTaskResumeWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
   // NSURL * url = [NSURL URLWithString:@"http://xmind-dl.oss-cn-qingdao.aliyuncs.com/xmind-7-update1-macosx.dmg"];
    NSURL * url = [NSURL URLWithString:@"https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"];
    NSURLSessionDataTask * dataTask = [[self defaultURLSession] dataTaskWithURL:url
                                                              completionHandler:^(NSData *data, NSURLResponse * response, NSError * error)
                                       {
                                           
                                           if (error == nil) {
                                               NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                               
                                               NSLog(@"Data = %@", text);
                                               completionHandler(UIBackgroundFetchResultNewData);
                                           }
                                           else{
                                               completionHandler(UIBackgroundFetchResultFailed);
                                           }
                                           
                                       }];
    [dataTask resume];
    
}

-(void)downloadTaskResume
{
    NSURL * url = [NSURL URLWithString:@"http://xmind-dl.oss-cn-qingdao.aliyuncs.com/xmind-7-update1-macosx.dmg"];
    
    NSURLSessionDownloadTask * backgroundTask = [[self backgroundURLSession] downloadTaskWithURL:url];
    [backgroundTask resume];
}

- (NSURLSession *)backgroundURLSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"io.objc.backgroundTransferExample";
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return session;
}

- (NSURLSession *)defaultURLSession
{
    static NSURLSession * defaultSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        defaultSession = [NSURLSession sessionWithConfiguration:configuration
                                                                      delegate:self
                                                                 delegateQueue:[NSOperationQueue mainQueue]];
    });
    return defaultSession;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"become inactive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"did enter backgournd");
    
}

-(void)endBackgroundTask{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            [strongSelf.myTimer invalidate];// 停止定时器
            
            // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉系统后台任务已经执行完，系统可以将app挂起
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            // 销毁后台任务标识符
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}

// 模拟的一个 Long-Running Task 方法
- (void) timerMethod:(NSTimer *)paramSender{
    // backgroundTimeRemaining 属性包含了程序留给的我们的时间
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
    }
}
//
-(void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler{
    
    
    NSLog(@"Save completionHandler");
    self.backgroundTransferCompletionHandler = completionHandler;
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

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    NSLog(@"receive data : %ld", (long)totalBytesWritten);
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"finish");
    if (_backgroundTransferCompletionHandler) {
        
        void (^handle)() = _backgroundTransferCompletionHandler;
        handle();
    }
}

@end
