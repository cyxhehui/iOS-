//
//  DBManager.m
//  BGTransferDemo
//
//  Created by 小丸子 on 22/7/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "DBManager.h"


#define CREATE_TABLE @"create table if not exists downloadItems ( \
fileTitle text primary key,              \
taskId integer ,                         \
downloadSource text,                                 \
resumeData  text,                            \
status   integer,                         \
progress real)"

static sqlite3 * database = nil;
static const NSString * DBNAME = @"TestFiledownloader.db"; //数据库名
static const NSString * DOWNLOADITEMS = @"DOWNLOADITEMS"; //表名
static const NSInteger DEFAULT_DOWNLOADTASK_EXPIREDTIME = 7 * 24 * 3600;


@interface DBManager()

@property (nonatomic, strong) NSString * databasePath;

@property (nonatomic, strong) NSString * dbFileName;

@property (nonatomic, strong) NSMutableArray * columnNamesArray;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;

@property (nonatomic, strong) NSString * dbFullFilePath;

@property (nonatomic, strong) NSMutableArray *resultsArray;   // 用来存储查询结果

-(NSArray *)loadDataFromDB:(NSString *)query;

-(BOOL)executeQuery:(NSString *)query;

@end

@implementation DBManager

-(instancetype)initDatabaseWithPath:(nullable NSString *)dbPath{
    
    self = [super init];
    if (self) {
        if (dbPath == nil) {
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            self.databasePath = [NSString stringWithFormat:@"%@/%@", paths[0], DBNAME];
        }
        else{
            self.databasePath = [NSString stringWithFormat:@"%@/%@", dbPath, DBNAME];
        }
        
    }
    
    return self;
}

-(void)dealloc{
    
    sqlite3_close(database);
}

-(BOOL)createDatabase{
    
    BOOL result = YES;
    
    if (sqlite3_open([self.databasePath UTF8String], &database) != SQLITE_OK) {
        
        sqlite3_close(database);
        result = NO;
        //NSAssert(0, @"open database faild!");
        NSLog(@"[HTFileDownloader]: %@", @"create or open DB failed");
    }
    else{
        char * errorMsg;
        if (sqlite3_exec(database, [CREATE_TABLE UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            
            result = NO;
            //NSAssert(0, @"create table failed!");
            NSLog(@"[HTFileDownloader]: create table failed");
        }
    }
    NSLog(@"[HTFileDownloader]: create or open DB successfully");
    return result;
}

-(void)updateOrInsertDownloadItem:(FileDownloadInfo *)item
{
    NSString * selectSql = [NSString stringWithFormat:@"select * from downloadItems where fileTitle = \"%@\"", item.fileTitle];
    
    NSArray * results = [[NSArray alloc]initWithArray:[self loadDataFromDB:selectSql]];
    
    if (results.count == 0) {
        [self insertNewDownloadItem:item];
    }
    else{
        [self updateDownloadItem:item];
    }
    
}

-(BOOL)insertNewDownloadItem:(FileDownloadInfo *)item
{
    NSString * insertSql = [NSString stringWithFormat:@"insert into downloadItems (fileTitle, taskId, downloadSource, resumeData,  status, progress) values (\"%@\", \"%ld\",\"%@\", \"%@\", \"%ld\", \"%f\")", item.fileTitle, item.taskIdentifier, item.downloadSource, item.taskResumeData, (long)item.status, item.downloadProgress];
    
    return [self executeQuery:insertSql];
    
}

-(BOOL)updateDownloadItem:(FileDownloadInfo *)item
{
    NSString * updateSql = [NSString stringWithFormat:@"update downloadItems set taskId = \"%ld\", downloadSource = \"%@\", resumeData = \"%@\",  status = \"%ld\",progress = \"%f\" where fileTitle = \"%@\"", item.taskIdentifier, item.downloadSource, item.taskResumeData, (long)item.status, item.downloadProgress, item.fileTitle];
    
    return [self executeQuery:updateSql];
}

-(NSArray<FileDownloadInfo *>*)allDownloadItems
{
    NSMutableArray * downloadItems = [NSMutableArray array];
    
    NSString * selectSql = [NSString stringWithFormat:@"select * from downloadItems"];
    
    NSArray * results = [[NSArray alloc]initWithArray:[self loadDataFromDB:selectSql]];
    
    for (int i = 0; i < [results count]; ++i) {
        
        FileDownloadInfo * item = [[FileDownloadInfo alloc]init];
        item.fileTitle = [[results objectAtIndex:i]objectAtIndex:[self.columnNamesArray indexOfObject:@"fileTitle"]];
        item.taskIdentifier = [[[results objectAtIndex:i]objectAtIndex:[self.columnNamesArray indexOfObject:@"taskId"]] integerValue];
        item.downloadSource = [[results objectAtIndex:i]objectAtIndex:[self.columnNamesArray indexOfObject:@"downloadSource"]];
        item.taskResumeData = [[results objectAtIndex:i]objectAtIndex:[self.columnNamesArray indexOfObject:@"resumeData"]];
        item.status = [[[results objectAtIndex:i]objectAtIndex:[self.columnNamesArray indexOfObject:@"status"]] integerValue];
        item.downloadProgress = [[[results objectAtIndex:i]objectAtIndex:[self.columnNamesArray indexOfObject:@"progress"]]floatValue];
        
        [downloadItems addObject:item];
    }
    
    return downloadItems;
}

#pragma mark -- interanl methods.

-(NSArray *)loadDataFromDB:(NSString *)query
{
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    return (NSArray *)self.resultsArray;
}

-(BOOL)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable
{
    //sqlite3 * sqlite3Database;
    BOOL isSuccess;
    
    if (self.resultsArray != nil) {
        [self.resultsArray removeAllObjects];
        self.resultsArray = nil;
    }
    
    self.resultsArray = [[NSMutableArray alloc]init];
    
    if (self.columnNamesArray != nil) {
        [self.columnNamesArray removeAllObjects];
        self.columnNamesArray = nil;
    }
    
    self.columnNamesArray = [[NSMutableArray alloc] init];
    
    sqlite3_stmt * compiledStatement; // query object
    BOOL prepareStatementResult = sqlite3_prepare_v2(database, query, -1, &compiledStatement, NULL);
    if (prepareStatementResult == SQLITE_OK) {
        
        //if not executable
        if (!queryExecutable) {
            
            NSMutableArray * arrDataRow;
            
            // Loop through the results and add them to the results array row by row.
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Initialize the mutable array that will contain the data of a fetched row.
                arrDataRow = [[NSMutableArray alloc] init];
                
                // Get the total number of columns.
                int totalColumns = sqlite3_column_count(compiledStatement);
                
                // Go through all columns and fetch each column data.
                for (int i=0; i<totalColumns; i++){
                    // Convert the column data to text (characters).
                    char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                    
                    // If there are contents in the currenct column (field) then add them to the current row array.
                    if (dbDataAsChars != NULL) {
                        // Convert the characters to string.
                        [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                    }
                    
                    // Keep the current column name.
                    if (self.columnNamesArray.count != totalColumns) {
                        dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                        [self.columnNamesArray addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                    }
                }
                
                // Store each fetched data row in the results array, but first check if there is actually data.
                if (arrDataRow.count > 0) {
                    [self.resultsArray addObject:arrDataRow];
                }
            }
            isSuccess = YES;
        }
        else{
            // excutable query
            
            NSUInteger excuteQueryResults = sqlite3_step(compiledStatement);
            if (excuteQueryResults == SQLITE_DONE) {
                self.affectedRows = sqlite3_changes(database);
                
                self.lastInsertedRowID = sqlite3_last_insert_rowid(database);
                isSuccess = YES;
            }
            else {
                // If could not execute the query show the error message on the debugger.
                isSuccess = NO;
                NSLog(@"[HTFileDownloader]: %s", sqlite3_errmsg(database));
            }
        }
    }
    else{
        isSuccess = NO;
        NSLog(@"[HTFileDownloader]: %s", sqlite3_errmsg(database));
    }
    // Release the compiled statement from memory.
    sqlite3_finalize(compiledStatement);
    
    return isSuccess;
}

-(BOOL)executeQuery:(NSString *)query
{
    return [self runQuery:[query UTF8String] isQueryExecutable:YES];
}


@end
