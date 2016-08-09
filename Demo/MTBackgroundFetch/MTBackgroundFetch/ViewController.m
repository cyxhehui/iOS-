//
//  ViewController.m
//  MTBackgroundFetch
//
//  Created by Jorge Costa on 10/14/13.
//  Copyright (c) 2013 MobileTuts. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLSessionDelegate>
@property (nonatomic, strong) NSTimer *myTimer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     self.possibleTableData = [NSArray arrayWithObjects:@"Spicy garlic Lime Chicken",@"Apple Crisp II",@"Eggplant Parmesan II",@"Pumpkin Ginger Cupcakes",@"Easy Lasagna", @"Puttanesca", @"Alfredo Sauce", nil];
    
    self.navigationItem.title = @"Delicious Dishes";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(insertNewObject:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
}

- (void)insertNewObject:(id)sender
{
    self.numberOfnewPosts = [self getRandomNumberBetween:0 to:3];
    NSLog(@"%d new fetched objects",self.numberOfnewPosts);
    
    for(int i = 0; i < self.numberOfnewPosts; i++){
        int addPost = [self getRandomNumberBetween:0 to:(int)([self.possibleTableData count]-1)];
        [self insertObject:[self.possibleTableData objectAtIndex:addPost]];
    }
    [self.refreshControl endRefreshing];
    
}

- (void)insertObject:(id)newObject
{
    [self.objects insertObject:newObject atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
}


-(NSMutableArray *)objects
{
    if (_objects == nil) {
        _objects = [[NSMutableArray alloc] init];
    }
    return _objects;
}

#pragma mark - Table view delegate/data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.objects[indexPath.row];
    
    if(indexPath.row < self.numberOfnewPosts){
        cell.backgroundColor = [UIColor yellowColor];
    }
    else
        cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)insertNewObjectForFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Update the tableview.");
    
    /*self.numberOfnewPosts = [self getRandomNumberBetween:0 to:4];
    NSLog(@"%d new fetched objects",self.numberOfnewPosts);

    if (self.possibleTableData == nil) {
        self.possibleTableData = [NSArray arrayWithObjects:@"Spicy garlic Lime Chicken",@"Apple Crisp II",@"Eggplant Parmesan II",@"Pumpkin Ginger Cupcakes",@"Easy Lasagna", @"Puttanesca", @"Alfredo Sauce", nil];
    }
    for(int i = 0; i < self.numberOfnewPosts; i++){
        int addPost = [self getRandomNumberBetween:0 to:(int)([self.possibleTableData count]-1)];
        [self insertObject:[self.possibleTableData objectAtIndex:addPost]];
    }

    if (self.numberOfnewPosts == 0) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
    else{
        completionHandler(UIBackgroundFetchResultNewData);
    }*/
//    self.myTimer =[NSTimer scheduledTimerWithTimeInterval:1.0f
//                                                   target:self
//                                                 selector:@selector(timerMethod:)
//                                                 userInfo:nil
//                                                  repeats:YES];

    [self dataTaskResumeWithCompletionHandler:completionHandler];
   // completionHandler(UIBackgroundFetchResultNoData);
}

-(void)dataTaskResumeWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSURL * url = [NSURL URLWithString:@"http://xmind-dl.oss-cn-qingdao.aliyuncs.com/xmind-7-update1-macosx.dmg"];
    
    NSURLSessionDataTask * dataTask = [[self defaultURLSession] dataTaskWithURL:url
                                                              completionHandler:^(NSData *data, NSURLResponse * response, NSError * error)
                                       {
                                           
                                           if (error == nil) {
                                               NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                               
                                               NSLog(@"Data = %@", text);
                                               [self insertObject:@"haha"];
                                               //[self dataTaskResumeWithCompletionHandler:completionHandler];
                                               completionHandler(UIBackgroundFetchResultNewData);
                                               [self insertObject:@"last"];
                                               
                                           }
                                           
                                           
                                           
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

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
