//
//  DBManager.h
//  BGTransferDemo
//
//  Created by 小丸子 on 22/7/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FileDownloadInfo.h"

@interface DBManager : NSObject

/**
 *  构造函数
 *
 *  @param dbPath 数据库保存路径
 *
 *  @return HTDBManager实例对象
 */
-(nonnull instancetype)initDatabaseWithPath:(nullable NSString *)dbPath;

/**
 *  创建数据库，创建downloadItems表
 *
 *  @return YES:创建成功  NO:失败
 */
-(BOOL)createDatabase;

/**
 *  更新一条记录，如果该记录不存在，则插入；反之，更新
 *
 *  @param item 要更新的数据
 */
-(void)updateOrInsertDownloadItem:(nonnull FileDownloadInfo *)item;

/**
 *  异步插入一条新的downloadItem
 *
 *  @param item 要插入的downloadItems
 *
 *  @return YES: 插入成功， NO: 插入失败
 */
-(BOOL)insertNewDownloadItem:(nonnull FileDownloadInfo *)item;

/**
 *  异步更新一条downloadItem
 *
 *  @param item 要更新的downloadItem
 *
 *  @return YES: 更新成功， NO: 更新失败
 */
-(BOOL)updateDownloadItem:(nonnull FileDownloadInfo *)item;

/**
 *  异步删除一条downloadItem
 *
 *  @param item 要删除的downloadItem
 *
 *  @return YES: 删除成功， NO: 删除失败
 */
//-(BOOL)deleteDownloadItem:(nonnull FileDownloadInfo *)item;

/**
 *  异步删除所有的downloadItems
 *
 *  @return YES: 删除成功， NO: 删除失败
 */
//-(BOOL)deleteAllDownloadItems;

/**
 *  异步清理过期的downloadItems。默认expire时间为一周：7 * 24 * 3600。
 *
 *  @return YES: 删除成功， NO: 删除失败
 */
//-(BOOL)deleteExpiredDownloadItems;

/**
 *  查询downloadItem
 *
 *  @param downloadId
 *
 *  @return downloadItem
 */
//-(nullable FileDownloadInfo *)downloadItemWithDownloadId:(nonnull NSString *)downloadId;

/**
 *  查询downloadItem的状态
 *
 *  @param downloadId 要查询记录的ID
 *
 *  @return downloadItem的状态值
 */
//-(HTFileTransferState)downloadItemStatus:(nonnull NSString *)downloadId;

/**
 *  查询所有的downloadItems
 *
 *  @return downloadItems集合
 */
-(nullable NSArray<FileDownloadInfo *> *)allDownloadItems;

/**
 *  查询所有suspended、failed的downloadItems
 *
 *  @return downloadItems集合（suspended,failed)
 */
//-(nullable NSArray<FileDownloadInfo *> *)allSuspendedOrFailedDownloadItems;


@end
