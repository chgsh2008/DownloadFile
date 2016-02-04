//
//  FileDownloadManager.h
//  DownLoadManager
//
//  Created by Kevin on 16/1/20.
//  Copyright © 2016年 11 111. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "DownloadFileModel.h"
#import "ASIHTTPRequest.h"

/**
 *  下载文件失败Block 通知
 *
 *  @param file
 */
typedef void(^DownloadFileFailBlock) (DownloadFileModel *file, BOOL isCancel, NSError *error);


/**
 *  下载文件完成Block 通知
 *
 *  @param file
 */
typedef void(^FinishedDownloadFileBlock) (DownloadFileModel *file);

/**
 *  下载队列里能下载的已经下载完 Block 通知
 *
 *  @param request
 */
typedef void(^DownloadQueueFinishedBlock) (ASINetworkQueue *queue);

/**
 *  将要下载时收到回应Header文件信息 通知
 *
 *  @param file
 */
typedef void(^DownloadReceiveResponseHeaderBlock) (DownloadFileModel *file, NSDictionary *responseHeader);

/**
 *  开始下载 通知
 *
 *  @param file
 */
typedef void(^StartDownloadFileBlock) (DownloadFileModel *file);

/**
 *  已下载字节数Block 通知
 *
 *  @param file
 */
typedef void(^DidReceiveBytesBlock) (DownloadFileModel *file);



@interface DownloadFileManager : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>
{
    /**
     *  下载完成的相对目录(在APP下的根目录为相对目录)
     */
    NSString *_relationshipFinishDownloadPath;
    /**
     *  下载中的相对目录(在APP下的根目录为相对目录)
     */
    NSString *_relationshipDownloadTmpPath;
    
    /**
     *  已下载字节数Block 通知
     *
     *  @param file
     */
    DidReceiveBytesBlock _didReceiveBytesBlock;
    
    /**
     *  开始下载 通知
     *
     *  @param file
     */
    StartDownloadFileBlock _startDownloadFileBlock;
    
    /**
     *  将要下载时收到回应Header文件信息 通知
     *
     *  @param file
     */
    DownloadReceiveResponseHeaderBlock _downloadReceiveResponseHeaderBlock;
    
    /**
     *  下载文件完成Block 通知
     *
     *  @param file
     */
    FinishedDownloadFileBlock _finishedDownloadFileBlock;
    
    /**
     *  下载文件失败Block 通知
     *
     *  @param file
     */
    DownloadFileFailBlock _downloadFileFailBlock;
}

#pragma mark 属性

/**
 *  设置下载队列属性，设置为1只允许一个一个下载，默认是并行下载不分前后
 *  目前还没实现这个
 */
@property(nonatomic, assign)NSInteger maxConcurrentOperationCount;

/**
 *  下载完成时文件所放目录
 */
@property(nonatomic, copy)NSString *downloadFinishedPath;


#pragma mark Block通知

/**
 *  已下载字节数Block 通知
 *
 *  @param file
 */
- (void)setDidReceiveBytesBlock:(DidReceiveBytesBlock)bDidReceiveBytes;

/**
 *  开始下载 通知
 *
 *  @param file
 */
-(void)setStartDownloadFileBlock:(StartDownloadFileBlock)bStartDownloadFileBlock;

/**
 *  将要下载时收到回应Header文件信息 通知
 *
 *  @param file
 */
-(void)setDownloadReceiveResponseHeaderBlock:(DownloadReceiveResponseHeaderBlock)bDownloadReceiveResponseHeaderBlock;

/**
 *  下载文件完成Block 通知
 *
 *  @param file
 */
-(void)setFinishedDownloadFileBlock:(FinishedDownloadFileBlock)bFinishedDownloadFileBlock;

/**
 *  下载文件失败Block 通知
 *
 *  @param file
 */
-(void)setDownloadFileFailBlock:(DownloadFileFailBlock)bDownloadFileFailBlock;

#pragma mark 方法

/**
 *  单例模式
 *
 *  @return
 */
+(id)sharedInstance;

/**
 *  添加要下载的文件数组，参数是DownloadFileModel类型的数组
 *
 *  @param fileUrls 下载文件的URL地址，参数是DownloadFileModel类型的数组
 */
-(void)addDownloadFiles:(NSArray *)fileUrls;

/**
 *  添加要下载的文件
 *
 *  @param fileUrl 下载文件的URL地址，参数是DownloadFileModel类型
 */
-(void)addDownloadFile:(DownloadFileModel *)file;

/**
 *  开始下载
 */
-(void)startDownload;

/**
 *  停止(暂停、取消)下载
 *
 *  @param fileUrls 要停止下载的url数组，参数是DownloadFileModel类型的数组
 *  @param isDeleteTmpFile 是否删除临时文件
 */
-(void)stopDownload:(NSArray *)fileUrls isDeleteTmpFile:(BOOL)isDeleteTmpFile;

/**
 *  继续下载
 *
 *  @param fileUrls 要继续下载的url数组，参数是DownloadFileModel类型的数组
 */
-(void)resumeDownload:(NSArray *)fileUrls;


/**
 *  根据该url判断是否有下载过，如果有下载过，则返回该文件
 *
 *  @param fileUrl 文件url
 *  @return 返回以DownloadFileModel类型的数组
 */
-(DownloadFileModel *)isHaveDownloaded:(NSString *)fileUrl;


/**
 *  获取所有的下载的临时文件的信息
 *
 *  @return 返回以DownloadFileModel类型的数组
 */
-(NSArray *)getTempFilesInfo;

/**
 *  获取所有已经下载完成的文件，
 *  返回以DownloadFileModel类型的数组
 *
 *  @return 返回以DownloadFileModel类型的数组
 */
-(NSArray *)getFinishedFiles;

/**
 *  获取临时下载文件的目录
 *
 *  @return
 */
+ (NSString *)getDownloadTempPath;

/**
 *  获取下载文件的目录
 *
 *  @return
 */
+ (NSString *)getDownloadDestinationPath;

/**
 *  随机产生一个序列号,带时间格式确保唯一
 *
 *  @return
 */
+(NSString *)createNewId;


@end
