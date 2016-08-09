//
//  AppDelegate.h
//  Push
//
//  Created by 小丸子 on 8/7/2016.
//  Copyright © 2016 hehui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, copy) void(^backgroundTransferCompletionHandler)();

@end

