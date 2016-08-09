//
//  AppDelegate.m
//  HHBackgroundTask
//
//  Created by 小丸子 on 18/7/2016.
//  Copyright © 2016 hehui. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <NSURLSessionTaskDelegate, NSURLSessionDelegate>
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"did finish launch");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test1" message:@"系统alertview" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self. backgroundTaskIdentifier =[application beginBackgroundTaskWithExpirationHandler:^( void) {
        [self endBackgroundTask];
    }];
    
    [self dataTaskResume];
    // 模拟一个Long-Running Task
//    self.myTimer =[NSTimer scheduledTimerWithTimeInterval:0.001f
//                                                   target:self
//                                                 selector:@selector(timerMethod:)
//                                                 userInfo:nil
//                                                  repeats:YES];
//    
    NSLog(@"进入后台");
}

-(void)dataTaskResume
{
    NSURL * url = [NSURL URLWithString:@"http://xmind-dl.oss-cn-qingdao.aliyuncs.com/xmind-7-update1-macosx.dmg"];
    
   // NSURLSessionDataTask * dataTask = [[self defaultURLSession] dataTaskWithURL:url];
    NSURLSessionDataTask * dataTask = [[self defaultURLSession] dataTaskWithURL:url
                                                          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
                                                              [self endBackgroundTask];
    }];
    [dataTask resume];
    
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

-(void)endBackgroundTask{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            //[strongSelf.myTimer invalidate];// 停止定时器
            
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

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"进入前台");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"进入active状态");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"应用将终止");
}

#pragma urlsession delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if(error == nil){
        
        [self dataTaskResume];
    }
}
@end
