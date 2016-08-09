//
//  FileDownloadInfo.h
//  BGTransferDemo
//
//  Created by Gabriel Theodoropoulos on 25/3/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HTFileTransferState)
{
    HTFileTransferStateNone = 0,
    HTFileTransferStateReady,   //
    HTFileTransferStateTransfering, //任务进行中
    HTFileTransferStatePaused,      //任务中止
    HTFileTransferStateCancelled,   //任务被取消
    HTFileTransferStateDone,        //任务成功结束
    HTFileTransferStateFailed       //任务失败
};

@interface FileDownloadInfo : NSObject

@property (nonatomic, strong) NSString *fileTitle;

@property (nonatomic, strong) NSString *downloadSource;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSData *taskResumeData;

@property (nonatomic) double downloadProgress;

@property (nonatomic) HTFileTransferState status;

@property (nonatomic) unsigned long taskIdentifier;

@property (nonatomic) BOOL isDownloading;

@property (nonatomic) BOOL downloadComplete;


-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source;

@end
