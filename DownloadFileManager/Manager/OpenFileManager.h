//
//  OpenFileManager.h
//  GbssApps-IOS
//
//  Created by Kevin on 16/1/25.
//
//

#import <Foundation/Foundation.h>
#import "DownloadFileManager.h"

@interface OpenFileManager : NSObject<UIAlertViewDelegate, UIDocumentInteractionControllerDelegate,UIDocumentInteractionControllerDelegate>{
    NSString *_fileUrl;
    NSString *_fileName;
    DownloadFileManager *_downloadFileManager;
    UIDocumentInteractionController *_documentInteractionController;
    
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

-(id)initWithParentViewController:(UIViewController *)pParentViewController;

@property(nonatomic, strong)UIViewController *parentViewController;

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



/**
 *  打开文件，
 *   使用场景：
 *   1.需要打开的本地文件，请传入本地文档的路径。目前暂时只支持第三那方打开的方式。
 *   2.需要打开远程文件，则会先搜索本地是否有缓存，根据isNotExist这个参数，当缓存不存在的时候，是否进行下载。
 *   3.远程文件会默认存到tmp目录。
 *   4.版本支持 2.7 and later。
 *
 *  @param isOther     是否必须使用第三方打开, 目前暂时只支持第三那方打开的方式。
 *  @param isNotExist  文件不存在是否提示用户是否下载
 *  @param downloadUrl 该文件的下载地址,
 *  @param localFile   本地的文档路径
 */
-(void)openFile:(BOOL)isOther isNotExist:(BOOL)isNotExist downloadUrl:(NSString *)downloadUrl localFile:(NSString *)localFile;



@end
