//
//  OpenFileManager.m
//  GbssApps-IOS
//
//  Created by Kevin on 16/1/25.
//
//

#import "OpenFileManager.h"

@implementation OpenFileManager

-(id)init{
    self = [super init];
    if (self) {
        [self initManager];
    }
    return self;
}

-(id)initWithParentViewController:(UIViewController *)pParentViewController{
    self = [super init];
    if (self) {
        [self initManager];
        _parentViewController = pParentViewController;
    }
    return self;
}

-(void)initManager{
//    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fileUrl]];
//    [_documentInteractionController setDelegate:self];
    _downloadFileManager = [DownloadFileManager sharedInstance];
    [self setDownloadBlock];
}

/**
 *  打开文件
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
-(void)openFile:(BOOL)isOther isNotExist:(BOOL)isNotExist downloadUrl:(NSString *)downloadUrl localFile:(NSString *)localFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExistLocalFile = NO;
    _fileUrl = downloadUrl;
    _fileName = [DownloadFileManager createNewId];
    //如果参数中有传来localfile值，判断下本地是否存在该文件，存在就打开，不存在就用downloadUrl下载
    if (localFile!= nil && [localFile isKindOfClass:[NSString class]] && localFile.length > 0) {
        if ([fileManager fileExistsAtPath:localFile]) {
            //根据用户传来的localFile存在，则打开
            isExistLocalFile = YES;
            [self openLocalFile:localFile];
        }
    }
    //用户传来的localFile不存在，用downloadUrl打开下载
    if (!isExistLocalFile) {
        if (downloadUrl != nil && [downloadUrl isKindOfClass:[NSString class]] && downloadUrl.length > 0) {
            DownloadFileModel *fileModel = [_downloadFileManager isHaveDownloaded:downloadUrl];
            if (fileModel != nil) {
                //如果有下载过文件，则打开本地文件
                [self openLocalFile:fileModel.targetPath];
            }else{
                //没有下载过此文件
                if (isNotExist) {
                    //需要下载此文件
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您还没下载此文件，需要下载吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", @"在线打开", nil];
                    [alert show];
                }else{
                    //在线看文件
//                    [self openWebFile:downloadUrl];
                }
            }
        }else{
            NSLog(@"downloadUrl is null");
        }
    }
    
}

/**
 *  打开本地文件
 *
 *  @param fileUrl 本地文件路径
 */
-(void)openLocalFile:(NSString *)fileUrl{
    //预览
//    if (_parentViewController != nil) {
//        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fileUrl]];
//        documentController.delegate = self;
//        [documentController presentOpenInMenuFromRect:CGRectZero inView:_parentViewController.view animated:YES];
//    }
//    return;
    
    //使用系统自带其它app打开文件
    NSURL *URL = [NSURL fileURLWithPath:fileUrl];
    if (URL) {
        CGRect frame = CGRectMake(100, 100, 100, 100);
        // Initialize Document Interaction Controller
        _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        // Configure Document Interaction Controller
        [_documentInteractionController setDelegate:self];
        // Present Open In Menu
        [_documentInteractionController presentOpenInMenuFromRect:frame inView:_parentViewController.view animated:YES];
    }
    
}

/**
 *  使用UIWebView或者safari浏览器打开在线文档，此处使用safari
 *
 *  @param fileUrl 在线文档的地址url
 */
-(void)openWebFile:(NSString *)fileUrl{
    NSURL *resourceToOpen = [NSURL URLWithString:fileUrl];
    BOOL canOpenResource = [[UIApplication sharedApplication] canOpenURL:resourceToOpen];
    if (canOpenResource) {
        [[UIApplication sharedApplication] openURL:resourceToOpen];
    }
}

-(void)setDownloadBlock{
    __weak __typeof(self) weakSelf = self;
    
    [_downloadFileManager setDidReceiveBytesBlock:^(DownloadFileModel *file) {
//        NSLog(@"已下载字节：%@",file.fileReceivedSize);
        [weakSelf runDidReceiveBytesBlock:file];
    }];
    [_downloadFileManager setStartDownloadFileBlock:^(DownloadFileModel *file) {
//        NSLog(@"开始下载：%@",file.fileName);
        [weakSelf runStartDownloadFileBlock:file];
    }];
    [_downloadFileManager setDownloadFileFailBlock:^(DownloadFileModel *file, BOOL isCancel, NSError *error) {
//        if (isCancel) {
//            NSLog(@"取消暂停下载");
//        }else{
//            NSLog(@"下载失败，可能是网络问题：%@",error);
//        }
        [weakSelf runDownloadFileFailBlock:file isCancel:isCancel error:error];
    }];
    [_downloadFileManager setFinishedDownloadFileBlock:^(DownloadFileModel *file) {
//        NSLog(@"下载完成：%@",file.fileName);
        [weakSelf runFinishedDownloadFileBlock:file];
        
    }];
    [_downloadFileManager setDownloadReceiveResponseHeaderBlock:^(DownloadFileModel *file, NSDictionary *responseHeader) {
//        NSLog(@"接收到文件：%@, 文件信息：%@",file.fileName, responseHeader);
        [weakSelf runDownloadReceiveResponseHeaderBlock:file responseHeader:responseHeader];
    }];
}

/**
 *  执行 _didReceiveBytesBlock 方法
 *
 *  @param file
 */
-(void)runDidReceiveBytesBlock:(DownloadFileModel *)file{
    if (_didReceiveBytesBlock != nil) {
        _didReceiveBytesBlock(file);
    }
}

/**
 *  执行 _startDownloadFileBlock
 *
 *  @param file
 */
-(void)runStartDownloadFileBlock:(DownloadFileModel *)file{
    if (_startDownloadFileBlock != nil) {
        _startDownloadFileBlock(file);
    }
}

/**
 *  执行 _downloadReceiveResponseHeaderBlock
 *
 *  @param file           要下载的文件
 *  @param responseHeader 文件头信息
 */
-(void)runDownloadReceiveResponseHeaderBlock:(DownloadFileModel *)file responseHeader:(NSDictionary *)responseHeader{
    if (_downloadReceiveResponseHeaderBlock != nil) {
        _downloadReceiveResponseHeaderBlock(file, responseHeader);
    }
}

/**
 *  执行 _downloadFileFailBlock
 *
 *  @param file 下载失败的文件
 *  @param isCancel 是否取消
 *  @param error    错误信息
 */
-(void)runDownloadFileFailBlock:(DownloadFileModel *)file isCancel:(BOOL)isCancel error:(NSError *)error{
    if (_downloadFileFailBlock != nil) {
        _downloadFileFailBlock(file, isCancel, error);
    }
}

/**
 *  执行 _finishedDownloadFileBlock
 *
 *  @param file
 */
-(void)runFinishedDownloadFileBlock:(DownloadFileModel *)file{
//    if (_finishedDownloadFileBlock != nil) {
//        _finishedDownloadFileBlock(file);
//    }
    [self openLocalFile:file.targetPath];
}

#pragma mark Block通知设定方法

/**
 *  已下载字节数Block 通知
 *
 *  @param file
 */
-(void)setDidReceiveBytesBlock:(DidReceiveBytesBlock)bDidReceiveBytes{
    _didReceiveBytesBlock = nil;
    _didReceiveBytesBlock = bDidReceiveBytes;
}

/**
 *  开始下载 通知
 *
 *  @param file
 */
-(void)setStartDownloadFileBlock:(StartDownloadFileBlock)bStartDownloadFileBlock{
    _startDownloadFileBlock = nil;
    _startDownloadFileBlock = bStartDownloadFileBlock;
}

/**
 *  将要下载时收到回应Header文件信息 通知
 *
 *  @param file
 */
-(void)setDownloadReceiveResponseHeaderBlock:(DownloadReceiveResponseHeaderBlock)bDownloadReceiveResponseHeaderBlock{
    _downloadReceiveResponseHeaderBlock = nil;
    _downloadReceiveResponseHeaderBlock = bDownloadReceiveResponseHeaderBlock;
}

/**
 *  下载文件完成Block 通知
 *
 *  @param file
 */
-(void)setFinishedDownloadFileBlock:(FinishedDownloadFileBlock)bFinishedDownloadFileBlock{
    _finishedDownloadFileBlock = nil;
    _finishedDownloadFileBlock = bFinishedDownloadFileBlock;
}

/**
 *  下载文件失败Block 通知
 *
 *  @param file
 */
-(void)setDownloadFileFailBlock:(DownloadFileFailBlock)bDownloadFileFailBlock{
    _downloadFileFailBlock = nil;
    _downloadFileFailBlock = bDownloadFileFailBlock;
}

-(void)startDownload{
    DownloadFileModel *fileModel = [[DownloadFileModel alloc] init];
    NSString *extension = [_fileUrl pathExtension];
    fileModel.fileID = _fileName;
    fileModel.fileURL = _fileUrl;
    if (extension != nil && [extension isKindOfClass:[NSString class]] && extension.length > 0) {
        fileModel.fileName = [_fileName stringByAppendingPathExtension:extension];
    }else{
        fileModel.fileName = _fileName;
    }
    
    //下载
    [_downloadFileManager addDownloadFile:fileModel];
    [_downloadFileManager startDownload];
}

#pragma mark UIAlertViewDelegate 回调事件

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //取消
        NSLog(@"取消");
        
    }else if (buttonIndex == 1){
        //确定下载
        [self startDownload];
    }else if (buttonIndex == 2){
        //在线打开
        [self openWebFile:_fileUrl];
    }
}

- (void)isAlertView:(UIView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"确定下载");
        [self startDownload];
    }else if (buttonIndex == 1){
        NSLog(@"取消下载");
//        [self openWebFile:_fileUrl];
    }
}


#pragma mark UIDocumentInteractionControllerDelegate 事件回调

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return _parentViewController;
}


#pragma mark 重载系统方法

-(void)dealloc{
    _didReceiveBytesBlock = nil;
    _startDownloadFileBlock = nil;
    _downloadReceiveResponseHeaderBlock = nil;
    _finishedDownloadFileBlock = nil;
    _downloadFileFailBlock = nil;
}


@end
