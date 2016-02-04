//
//  ViewController.m
//  DownloadFileManager
//
//  Created by Kevin on 16/2/4.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    OpenFileManager *_openFileManager;
    DownloadFileManager *_downloadFileManager;
}

@end

@implementation ViewController


/**
 *  <#Description#>
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.1.1.dmg
    //http://dldir1.qq.com/qqfile/qq/QQ8.1/17202/QQ8.1.exe
    //http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.6.dmg
    //http://downmini.kugou.com/kugou8025.exe
    //http://downmobile.kugou.com/upload/ios_beta/kugou.ipa
    //http://downmobile.kugou.com/Android/KugouPlayer/7999/KugouPlayer_219_V7.9.12.apk
    //http://downmobile.kugou.com/iPad/1100/kugouHD_1002_V1.1.0.ipa
    
    // init
    _openFileManager = [[OpenFileManager alloc] init];
    _downloadFileManager = [DownloadFileManager sharedInstance];
    [self setDownloadBlock];
    

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  开始下载
 *  单文件下载
 *
 *  @param sender
 */
- (IBAction)startDownload_OnTouch:(id)sender {
    NSString *fileUrl = @"https://itunesconnect.apple.com/docs/UsingApplicationLoader.pdf";
    DownloadFileModel *fileModel = [[DownloadFileModel alloc] init];
    NSString *extension = [fileUrl pathExtension];
    NSString *fileName = [DownloadFileManager createNewId];
    fileModel.fileID = fileName;;
    fileModel.fileURL = fileUrl;
    if (extension != nil && [extension isKindOfClass:[NSString class]] && extension.length > 0) {
        fileModel.fileName = [fileName stringByAppendingPathExtension:extension];
    }else{
        fileModel.fileName = fileName;
    }
    
    //下载
    [_downloadFileManager addDownloadFile:fileModel];
    [_downloadFileManager startDownload];
}

/**
 *  暂停下载
 *
 *  @param sender
 */
- (IBAction)pauseDownload_OnTouch:(id)sender {
    
    
    NSString *fileUrl = @"https://itunesconnect.apple.com/docs/UsingApplicationLoader.pdf";
    DownloadFileModel *fileModel = [[DownloadFileModel alloc] init];
    NSString *extension = [fileUrl pathExtension];
    NSString *fileName = [DownloadFileManager createNewId];
    fileModel.fileID = fileName;;
    fileModel.fileURL = fileUrl;
    if (extension != nil && [extension isKindOfClass:[NSString class]] && extension.length > 0) {
        fileModel.fileName = [fileName stringByAppendingPathExtension:extension];
    }else{
        fileModel.fileName = fileName;
    }
    
    
    NSString *fileUrl2 = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.1.1.dmg";
    DownloadFileModel *fileModel2 = [[DownloadFileModel alloc] init];
    NSString *extension2 = [fileUrl2 pathExtension];
    NSString *fileName2 = [DownloadFileManager createNewId];
    fileModel2.fileID = fileName2;;
    fileModel2.fileURL = fileUrl2;
    if (extension2 != nil && [extension2 isKindOfClass:[NSString class]] && extension2.length > 0) {
        fileModel2.fileName = [fileName2 stringByAppendingPathExtension:extension2];
    }else{
        fileModel2.fileName = fileName2;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:fileModel, fileModel2, nil];
    
    [_downloadFileManager stopDownload:array isDeleteTmpFile:NO];
}

/**
 *  停止下载
 *
 *  @param sender
 */
- (IBAction)stopDownload_OnTouch:(id)sender {
    [self pauseDownload_OnTouch:sender];
}

/**
 *  多文件下载
 *
 *  @param sender
 */
- (IBAction)downloadMutilFile_OnTouch:(id)sender {
    NSString *fileUrl = @"http://dldir1.qq.com/qqfile/qq/QQ8.1/17202/QQ8.1.exe";
    DownloadFileModel *fileModel = [[DownloadFileModel alloc] init];
    NSString *extension = [fileUrl pathExtension];
    NSString *fileName = [DownloadFileManager createNewId];
    fileModel.fileID = fileName;;
    fileModel.fileURL = fileUrl;
    if (extension != nil && [extension isKindOfClass:[NSString class]] && extension.length > 0) {
        fileModel.fileName = [fileName stringByAppendingPathExtension:extension];
    }else{
        fileModel.fileName = fileName;
    }
    
    
    NSString *fileUrl2 = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.1.1.dmg";
    DownloadFileModel *fileModel2 = [[DownloadFileModel alloc] init];
    NSString *extension2 = [fileUrl2 pathExtension];
    NSString *fileName2 = [DownloadFileManager createNewId];
    fileModel2.fileID = fileName2;;
    fileModel2.fileURL = fileUrl2;
    if (extension2 != nil && [extension2 isKindOfClass:[NSString class]] && extension2.length > 0) {
        fileModel2.fileName = [fileName2 stringByAppendingPathExtension:extension2];
    }else{
        fileModel2.fileName = fileName2;
    }
    
    NSString *fileUrl3 = @"http://downmini.kugou.com/kugou8025.exe";
    DownloadFileModel *fileModel3 = [[DownloadFileModel alloc] init];
    NSString *extension3 = [fileUrl3 pathExtension];
    NSString *fileName3 = [DownloadFileManager createNewId];
    fileModel3.fileID = fileName3;;
    fileModel3.fileURL = fileUrl3;
    if (extension3 != nil && [extension3 isKindOfClass:[NSString class]] && extension3.length > 0) {
        fileModel3.fileName = [fileName3 stringByAppendingPathExtension:extension3];
    }else{
        fileModel3.fileName = fileName3;
    }
    
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:fileModel, fileModel2, fileModel3, nil];
    
    //下载
    [_downloadFileManager addDownloadFiles:array];
    [_downloadFileManager startDownload];
    
    
}

/**
 *  恢复下载
 *
 *  @param sender
 */
- (IBAction)resumeDownload_OnTouch:(id)sender {
    
    NSString *fileUrl = @"http://dldir1.qq.com/qqfile/qq/QQ8.1/17202/QQ8.1.exe";
    DownloadFileModel *fileModel = [[DownloadFileModel alloc] init];
    NSString *extension = [fileUrl pathExtension];
    NSString *fileName = [DownloadFileManager createNewId];
    fileModel.fileID = fileName;;
    fileModel.fileURL = fileUrl;
    if (extension != nil && [extension isKindOfClass:[NSString class]] && extension.length > 0) {
        fileModel.fileName = [fileName stringByAppendingPathExtension:extension];
    }else{
        fileModel.fileName = fileName;
    }
    
    
    NSString *fileUrl2 = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.1.1.dmg";
    DownloadFileModel *fileModel2 = [[DownloadFileModel alloc] init];
    NSString *extension2 = [fileUrl2 pathExtension];
    NSString *fileName2 = [DownloadFileManager createNewId];
    fileModel2.fileID = fileName2;;
    fileModel2.fileURL = fileUrl2;
    if (extension2 != nil && [extension2 isKindOfClass:[NSString class]] && extension2.length > 0) {
        fileModel2.fileName = [fileName2 stringByAppendingPathExtension:extension2];
    }else{
        fileModel2.fileName = fileName2;
    }
    
    NSString *fileUrl3 = @"http://downmini.kugou.com/kugou8025.exe";
    DownloadFileModel *fileModel3 = [[DownloadFileModel alloc] init];
    NSString *extension3 = [fileUrl3 pathExtension];
    NSString *fileName3 = [DownloadFileManager createNewId];
    fileModel3.fileID = fileName3;;
    fileModel3.fileURL = fileUrl3;
    if (extension3 != nil && [extension3 isKindOfClass:[NSString class]] && extension3.length > 0) {
        fileModel3.fileName = [fileName3 stringByAppendingPathExtension:extension3];
    }else{
        fileModel3.fileName = fileName3;
    }
    
    
    NSString *fileUrl4 = @"http://downmobile.kugou.com/Android/KugouPlayer/7999/KugouPlayer_219_V7.9.12.apk";
    DownloadFileModel *fileModel4 = [[DownloadFileModel alloc] init];
    NSString *extension4 = [fileUrl4 pathExtension];
    NSString *fileName4 = [DownloadFileManager createNewId];
    fileModel4.fileID = fileName4;;
    fileModel4.fileURL = fileUrl4;
    if (extension4 != nil && [extension4 isKindOfClass:[NSString class]] && extension.length > 0) {
        fileModel4.fileName = [fileName4 stringByAppendingPathExtension:extension];
    }else{
        fileModel4.fileName = fileName4;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:fileModel, fileModel2, fileModel3, fileModel4, nil];
    
    [_downloadFileManager resumeDownload:array];
}

/**
 *  在下载其它文件过程中，随时可以加入新文件继续下载
 *
 *  @param sender
 */
- (IBAction)addFileToDownload_OnTouch:(id)sender {
    NSString *fileUrl = @"http://downmobile.kugou.com/upload/ios_beta/kugou.ipa";
    DownloadFileModel *fileModel = [[DownloadFileModel alloc] init];
    NSString *extension = [fileUrl pathExtension];
    NSString *fileName = [DownloadFileManager createNewId];
    fileModel.fileID = fileName;;
    fileModel.fileURL = fileUrl;
    if (extension != nil && [extension isKindOfClass:[NSString class]] && extension.length > 0) {
        fileModel.fileName = [fileName stringByAppendingPathExtension:extension];
    }else{
        fileModel.fileName = fileName;
    }
    
    
    NSString *fileUrl2 = @"http://downmobile.kugou.com/iPad/1100/kugouHD_1002_V1.1.0.ipa";
    DownloadFileModel *fileModel2 = [[DownloadFileModel alloc] init];
    NSString *extension2 = [fileUrl2 pathExtension];
    NSString *fileName2 = [DownloadFileManager createNewId];
    fileModel2.fileID = fileName2;;
    fileModel2.fileURL = fileUrl2;
    if (extension2 != nil && [extension2 isKindOfClass:[NSString class]] && extension2.length > 0) {
        fileModel2.fileName = [fileName2 stringByAppendingPathExtension:extension2];
    }else{
        fileModel2.fileName = fileName2;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:fileModel, fileModel2, nil];
    
    //下载
    [_downloadFileManager addDownloadFiles:array];
    [_downloadFileManager startDownload];
    
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
 *  打开文件
 *  请用真机调试
 *
 *  @param sender
 */
- (IBAction)openFile_OnTouch:(id)sender {
    _openFileManager = [[OpenFileManager alloc] initWithParentViewController:self];
    [_openFileManager openFile:YES isNotExist:YES downloadUrl:@"https://itunesconnect.apple.com/docs/UsingApplicationLoader.pdf" localFile:nil];
    [_openFileManager setDidReceiveBytesBlock:^(DownloadFileModel *file) {
        NSLog(@"已经下载字节数：%@",file.fileReceivedSize);
    }];
    [_openFileManager setFinishedDownloadFileBlock:^(DownloadFileModel *file) {
        NSLog(@"已经下载完文件: %@", file.fileName);
    }];
}



/**
 *  执行 _didReceiveBytesBlock 方法
 *
 *  @param file
 */
-(void)runDidReceiveBytesBlock:(DownloadFileModel *)file{
    NSLog(@"接收到文件：%@, 已下载 %@  字节.",file.fileName,file.fileReceivedSize);
}

/**
 *  执行 _startDownloadFileBlock
 *
 *  @param file
 */
-(void)runStartDownloadFileBlock:(DownloadFileModel *)file{
    NSLog(@"开始下载文件: %@",file.fileName);
}

/**
 *  执行 _downloadReceiveResponseHeaderBlock
 *
 *  @param file           要下载的文件
 *  @param responseHeader 文件头信息
 */
-(void)runDownloadReceiveResponseHeaderBlock:(DownloadFileModel *)file responseHeader:(NSDictionary *)responseHeader{
    NSLog(@"开始下载之前，先接收到文件:%@的头文件信息，比如文件的大小等等: %@",file.fileName, responseHeader);
}

/**
 *  执行 _downloadFileFailBlock
 *
 *  @param file 下载失败的文件
 *  @param isCancel 是否取消
 *  @param error    错误信息
 */
-(void)runDownloadFileFailBlock:(DownloadFileModel *)file isCancel:(BOOL)isCancel error:(NSError *)error{
    if (isCancel) {
        NSLog(@"取消下载文件: %@",file.fileName);
    }else{
        NSLog(@"下载文件出错，可能是网络断开，文件：%@, 错误信息：%@",file.fileName,error);
    }
}

/**
 *  执行 _finishedDownloadFileBlock
 *
 *  @param file
 */
-(void)runFinishedDownloadFileBlock:(DownloadFileModel *)file{
    NSLog(@"文件下载完成：%@",file.fileName);
}



@end
