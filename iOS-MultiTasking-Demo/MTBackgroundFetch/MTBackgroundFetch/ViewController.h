//
//  ViewController.h
//  MTBackgroundFetch
//
//  Created by Jorge Costa on 10/14/13.
//  Copyright (c) 2013 MobileTuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController


@property (nonatomic) NSMutableArray *objects;
@property (nonatomic) NSArray *possibleTableData;
@property (nonatomic) int numberOfnewPosts;
@property (nonatomic) UIRefreshControl *refreshControl;

- (void)insertNewObjectForFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
