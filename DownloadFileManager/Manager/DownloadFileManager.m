//
//  FileDownloadManager.m
//  DownLoadManager
//
//  Created by Kevin on 16/1/20.
//  Copyright © 2016年 11 111. All rights reserved.
//

#import "DownloadFileManager.h"

#define TmpPlistExtention @"plist"
#define DownloadFilePlist @"FinishedDownloadFiles.plist"

@interface DownloadFileManager() {
//    ASINetworkQueue *_queue;
    
}

@property NSMutableArray *downloadFilesArray;
@property NSMutableArray *downloadRequestsArray;
@property NSMutableArray *downloadFinishedFileArray;

@end



@implementation DownloadFileManager
static DownloadFileManager *_fileDownloadManagerInstance;


#pragma mark 类方法
/**
 *  单例模式
 *
 *  @return
 */
+(id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fileDownloadManagerInstance = [[super allocWithZone:NULL] init];
    });
    
    return _fileDownloadManagerInstance;
}

/**
 *  重写allocWithZone，当使用alloc时会调用allocWithZone申请内存空间
 *
 *  @param zone
 *
 *  @return
 */
+(id)allocWithZone:(struct _NSZone *)zone{
    return [DownloadFileManager sharedInstance];
}

/**
 *  重写copyWithZone，当使用copyWithZone返回
 *
 *  @param zone
 *
 *  @return
 */
-(id)copyWithZone:(struct _NSZone *)zone{
    return [DownloadFileManager sharedInstance];
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

#pragma mark 添加要下载的文件

/**
 *  添加要下载的文件，参数是DownloadFileModel类型的数组
 *
 *  @param fileUrls 下载文件的URL地址，参数是DownloadFileModel类型的数组
 */
-(void)addDownloadFiles:(NSArray *)fileUrls{
    if (_downloadFilesArray == nil) {
        _downloadFilesArray = [[NSMutableArray alloc] init];
    }
    
    if ([fileUrls isKindOfClass:[NSArray class]] && fileUrls.count > 0) {
        for (int i = 0; i < fileUrls.count; i++) {
            DownloadFileModel *dict = [fileUrls objectAtIndex:i];
            [self addDownloadFile:dict];
        }
    }
    
}

/**
 *  添加要下载的文件
 *
 *  @param fileUrl 下载文件的URL地址，参数是DownloadFileModel类型
 */
-(void)addDownloadFile:(DownloadFileModel *)fileModel{
    if (_downloadFilesArray == nil) {
        _downloadFilesArray = [[NSMutableArray alloc] init];
    }
    if (fileModel) {
        BOOL isExist = NO;
        //查找下是不是已经重复了
        for (int j = 0; j<_downloadFilesArray.count; j++) {
            DownloadFileModel *fileInArr = [_downloadFilesArray objectAtIndex:j];
            if ([fileInArr.fileURL isEqualToString:fileModel.fileURL]) {
                isExist = YES;
                break;
            }
        }
        //如果不存在就加入文件列表
        if (!isExist) {
            DownloadFileModel *file= [[DownloadFileModel alloc] init];
            file.fileURL = fileModel.fileURL;
            file.fileID = fileModel.fileID;
            file.fileName = fileModel.fileName;
            file.isDownloading = NO;
            file.willDownloading = YES;
            file.isFinished = NO;
            file.isCancel = NO;
            file.fileReceivedSize = @"0";
            
            [_downloadFilesArray addObject:file];
        }
    }
    
}

/**
 *  根据该url判断是否有下载过，如果有下载过，则返回该文件
 *
 *  @param fileUrl 文件url
 *  @return 返回以DownloadFileModel类型的数组
 */
-(DownloadFileModel *)isHaveDownloaded:(NSString *)fileUrl{
    DownloadFileModel *fileModel = nil;
    NSArray *finishedFilesArray = [self getFinishedFiles];
    if (finishedFilesArray!= nil && finishedFilesArray.count > 0) {
        for (int i = 0; i < finishedFilesArray.count; i++) {
            DownloadFileModel *file = [finishedFilesArray objectAtIndex:i];
            if ([file.fileURL isEqualToString:fileUrl]) {
                fileModel = file;
                break;
            }
        }
    }
    
    return fileModel;
}


#pragma mark 开始，停止，继续下载事件

/**
 *  开始下载
 */
-(void)startDownload{
    NSString *homePath = NSHomeDirectory();
    NSString *downloadPath = [DownloadFileManager getDownloadDestinationPath];
    NSString *downloadTmpPath = [DownloadFileManager getDownloadTempPath];
    _relationshipFinishDownloadPath = [downloadPath substringFromIndex:[homePath length]];
    _relationshipDownloadTmpPath = [downloadTmpPath substringFromIndex:[homePath length]];
    
    _maxConcurrentOperationCount = _maxConcurrentOperationCount<1 ? 1 : _maxConcurrentOperationCount;
    if (_downloadRequestsArray == nil) {
        _downloadRequestsArray = [NSMutableArray array];
    }
    if (_downloadFinishedFileArray == nil) {
        _downloadFinishedFileArray = [NSMutableArray array];
    }
    NSMutableArray *haveDownloadList = [NSMutableArray array];
//    NSString *cache = [DownloadFileManager getDownloadTempPath];
    //循环文件列表去下载
    for (int i = 0; i < _downloadFilesArray.count; i++) {
        DownloadFileModel *file = [_downloadFilesArray objectAtIndex:i];
        BOOL isDownloading = NO;
        //从列表中查找是否之前已经创建过该文件的下载http request
        for (int i = 0; i < _downloadRequestsArray.count; i++) {
            ASIHTTPRequest *requestInArr = [_downloadRequestsArray objectAtIndex:i];
            DownloadFileModel *requestingFile = [requestInArr.userInfo objectForKey:@"File"];
            //如果该文件已在http request中
            if ([file.fileURL isEqualToString:requestingFile.fileURL] && [requestInArr isExecuting]) {
                isDownloading = YES;
                break;
            }
        }
        //判断本地是否有下载了该文件
        DownloadFileModel *hasDownedFile = [self isHaveDownloaded:file.fileURL];
        if (hasDownedFile != nil) {
            [haveDownloadList addObject:hasDownedFile];
        }
        //如果该文件还没开始下载，那就建立http下载
        if ((!isDownloading) && hasDownedFile == nil) {
            NSString *fileName = [downloadTmpPath stringByAppendingPathComponent:file.fileName];
            file.tempPath = fileName;
            if (!([_downloadFinishedPath isKindOfClass:[NSString class]] && _downloadFinishedPath.length > 0)){
                _downloadFinishedPath = [DownloadFileManager getDownloadDestinationPath];
            }
//            file.relationshipFinishDownloadPath = _relationshipFinishDownloadPath;
//            file.relationshipDownloadTmpPath = _relationshipDownloadTmpPath;
            file.targetPath = [_downloadFinishedPath stringByAppendingPathComponent:file.fileName];
            //建立http request下载
            [self httpDownload:file];
        }
    }
    //判断下是否有已经下载好的文件，如果有下载好的文件，直接调用下载完成事件
    if (_finishedDownloadFileBlock != nil) {
        for (int i = 0; i < haveDownloadList.count; i++) {
            DownloadFileModel *itm = [haveDownloadList objectAtIndex:i];
            _finishedDownloadFileBlock(itm);
        }
    }
    
}

/**
 *  停止下载
 *
 *  @param fileUrls 要停止下载的url数组，参数是DownloadFileModel类型的数组
 *  @param isDeleteTmpFile 是否删除临时文件
 */
-(void)stopDownload:(NSArray *)fileUrls isDeleteTmpFile:(BOOL)isDeleteTmpFile{
    
    NSMutableArray *removeRequest = [NSMutableArray array];
    for (int i = 0; i < _downloadRequestsArray.count; i++) {
        ASIHTTPRequest *request = [_downloadRequestsArray objectAtIndex:i];
        
        DownloadFileModel *requestingFile = [request.userInfo objectForKey:@"File"];
        for (int j = 0; j<fileUrls.count; j++) {
            DownloadFileModel *url = [fileUrls objectAtIndex:j];
            //查找要停止的url和正在http request列表里的url是否一样，
            if ([url.fileURL isEqualToString:requestingFile.fileURL]) {
                //判断当前request是否正在请求数据，如果是的话就取消
                if ([request isExecuting]) {
                    [request cancel];//取消请求下载
                    [removeRequest addObject:request];
                    //删除掉临时文件
                    if (isDeleteTmpFile) {
                        [self deletePlistFile:requestingFile];
                        [self deleteTempFile:requestingFile];
                        [_downloadFilesArray removeObject:requestingFile];
                    }
                }
            }
        }
    }
    //删除掉取消的http request，释放资源
    if (removeRequest.count > 0) {
        [_downloadRequestsArray removeObjectsInArray:removeRequest];
    }
}

/**
 *  继续下载
 *
 *  @param fileUrls 要继续下载的url数组，参数是DownloadFileModel类型的数组
 */
-(void)resumeDownload:(NSArray *)fileUrls{
    //循环恢复要下载的文件
    for (int i = 0; i < fileUrls.count; i++) {
        DownloadFileModel *needDownloadFile = [fileUrls objectAtIndex:i];
        [self addDownloadFile:needDownloadFile];
    }
    [self startDownload];
    
}

/**
 *  建立http请求下载
 *
 *  @param fileUrl  要下载的url地址
 *  @param file    DownloadFileModel类型的文件信息
 */
-(void)httpDownload:(DownloadFileModel *)file{
    NSURL *url = [NSURL URLWithString:file.fileURL];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDelegate:self];
    //设置临时目录
    [request setTemporaryFileDownloadPath:file.tempPath];
    //设置下载目录
    [request setDownloadDestinationPath:file.targetPath];
    [request setUserInfo:[NSDictionary dictionaryWithObject:file forKey:@"File"]];
    //设置重试次数
    [request setNumberOfTimesToRetryOnTimeout:3];
    //设置timeout时间
    [request setTimeOutSeconds:120];
    [request setAllowResumeForFileDownloads:YES];//支持断点续传
    [request setDownloadProgressDelegate:self];
    
    [_downloadRequestsArray addObject:request];
    
    //开始异步下载
    [request startAsynchronous];
    [self saveDownloadTmpInfo:file];
}

#pragma mark 文件保存，删除等私有方法

/**
 *  当文件还在下载中时，保存文件临时下载的情况，方便用于断点下载
 *
 *  @param file
 */
-(void)saveDownloadTmpInfo:(DownloadFileModel *)file{
    NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:file.fileID,@"fileID", file.fileName, @"fileName", file.fileURL, @"fileURL", file.tempPath,@"tempPath", file.targetPath, @"targetPath", file.fileSize, @"fileSize",file.fileReceivedSize, @"fileReceivedSize", nil];
    NSString *filePlist = [file.tempPath stringByAppendingPathExtension:TmpPlistExtention];
    if (![fileDict writeToFile:filePlist atomically:YES]) {
        NSLog(@"write plist fail: %@",filePlist);
    }
}

/**
 *  当文件下载完成后，保存下载过的历史文件
 *
 *  @param file
 */
-(void)saveDownloadFilePlist:(DownloadFileModel *)file{
    NSMutableArray *finishedList = [NSMutableArray array];
    NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:file.fileID,@"fileID", file.fileName, @"fileName", file.fileURL, @"fileURL", file.tempPath,@"tempPath", file.targetPath, @"targetPath", file.fileSize, @"fileSize",file.fileReceivedSize, @"fileReceivedSize", nil];
    [finishedList addObject:fileDict];
    NSString *filePlist = [DownloadFileManager getDownloadFilePlist];
    //读取出来历史下载过的文件信息
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePlist]) {
        NSMutableArray *finishArr = [[NSMutableArray alloc]initWithContentsOfFile:filePlist];
        for (NSDictionary *dic in finishArr) {
            NSString *target = [dic objectForKey:@"targetPath"];
            //判断文件是否存在
            if([[NSFileManager defaultManager] fileExistsAtPath:target]){
                [finishedList addObject:dic];
            }
        }
    }
    //保存
    if (![finishedList writeToFile:filePlist atomically:YES]) {
        NSLog(@"write plist fail");
    }
    
}

/**
 *  删除文件临时信息文件，也就是要删除TmpPlistExtention宏定义的后缀文件
 *
 *  @param file
 */
-(void)deletePlistFile:(DownloadFileModel *)file{
    if (file) {
        NSString *plistTmpFile = [file.tempPath stringByAppendingPathExtension:TmpPlistExtention];
        [self deleteFile:plistTmpFile];
    }
}

/**
 *  删除临时文件
 *
 *  @param file
 */
-(void)deleteTempFile:(DownloadFileModel *)file{
    if (file) {
        [self deleteFile:file.tempPath];
    }
}

/**
 *  删除文件
 *
 *  @param filePath 文件路径
 */
-(void)deleteFile:(NSString *)filePath{
    NSFileManager *fileNamager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if ([fileNamager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        NSError *error = nil;
        //删除文件
        [fileNamager removeItemAtPath:filePath error:&error];
        if (!error) {
            NSLog(@"%@",[error description]);
        }
    }
}

/**
 *  获取所有的下载的临时文件的信息
 *
 *  @return 返回以DownloadFileModel类型的数组
 */
-(NSArray *)getTempFilesInfo{
    NSMutableArray *fileArray = [NSMutableArray array];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *filelist=[fileManager contentsOfDirectoryAtPath:[DownloadFileManager getDownloadTempPath] error:&error];
    if(!error)
        NSLog(@"%@",[error description]);
    for(NSString *file in filelist)
    {
        NSString *filetype = [file  pathExtension];
        if([filetype isEqualToString:@"plist"])
            [fileArray addObject:[self getTempfile:[[DownloadFileManager getDownloadTempPath] stringByAppendingPathComponent:file]]];
    }
    
    return fileArray;
}

-(DownloadFileModel *)getTempfile:(NSString *)path{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    DownloadFileModel *file = [[DownloadFileModel alloc]init];
    file.fileName = [dic objectForKey:@"fileName"];
    file.fileURL = [dic objectForKey:@"fileUrl"];
    file.fileSize = [dic objectForKey:@"fileSize"];
    file.fileReceivedSize= [dic objectForKey:@"fileRecieveSize"];
    file.tempPath = [[DownloadFileManager getDownloadTempPath] stringByAppendingPathComponent:file.fileName];
    file.targetPath = [[DownloadFileManager getDownloadDestinationPath] stringByAppendingPathComponent:file.fileName];
    file.isDownloading=NO;
    file.isDownloading = NO;
    file.willDownloading = NO;
    // file.isFirstReceived = YES;
    file.hasError = NO;
    
    NSData *fileData=[[NSFileManager defaultManager ] contentsAtPath:file.tempPath];
    NSInteger receivedDataLength=[fileData length];
    file.fileReceivedSize=[NSString stringWithFormat:@"%ld",(long)receivedDataLength];
    return file;
    
}

/**
 *  获取所有已经下载完成的文件，
 *  返回以DownloadFileModel类型的数组
 *
 *  @return 返回以DownloadFileModel类型的数组
 */
-(NSArray *)getFinishedFiles{
    NSMutableArray *finishedList = [NSMutableArray array];
    NSMutableArray *existFinishedList = [NSMutableArray array];
    NSString *filePlist = [DownloadFileManager getDownloadFilePlist];
    NSString *downloadPath = [DownloadFileManager getDownloadDestinationPath];
    //读取出来历史下载过的文件信息
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePlist]) {
        NSMutableArray *finishArr = [[NSMutableArray alloc]initWithContentsOfFile:filePlist];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSDictionary *dic in finishArr) {
            NSString *fileName = [dic objectForKey:@"fileName"];
            fileName = [downloadPath stringByAppendingPathComponent:fileName];
            //判断文件是否存在
            if([fileManager fileExistsAtPath:fileName]){
                [dic setValue:fileName forKey:@"targetPath"];
                [existFinishedList addObject:dic];
                DownloadFileModel *file = [[DownloadFileModel alloc] init];
                file.fileID = [dic objectForKey:@"fileID"];
                file.fileName = [dic objectForKey:@"fileName"];
                file.fileReceivedSize = [dic objectForKey:@"fileReceivedSize"];
                file.fileSize = [dic objectForKey:@"fileSize"];
                file.fileURL = [dic objectForKey:@"fileURL"];
                file.targetPath = fileName;//[dic objectForKey:@"targetPath"];
                
                [finishedList addObject:file];
            }
            
        }
        //保存
        if (![existFinishedList writeToFile:filePlist atomically:YES]) {
            NSLog(@"write plist fail");
        }
    }
    
    return finishedList;
    
}

/**
 *  获取临时下载文件的目录
 *
 *  @return
 */
+(NSString *)getDownloadTempPath{
//    NSString *homeDir = NSHomeDirectory();
//    NSURL *cashe = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *tmpDir =  NSTemporaryDirectory();
    tmpDir = [tmpDir stringByAppendingPathComponent:@"DownloadTemp"];
//    cashe = [cashe URLByAppendingPathComponent:@"DownloadTemp" isDirectory:YES];
//    NSString *path = [cashe path];
    NSString *path = tmpDir;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
            
        }
    }
    
    return path;
}

/**
 *  获取下载文件的目录
 *
 *  @return
 */
+(NSString *)getDownloadDestinationPath{
//    NSURL *cashe = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//    cashe = [cashe URLByAppendingPathComponent:@"DownloadDestination" isDirectory:YES];
//    NSString *path = [cashe path];
    NSString *tmpDir =  NSTemporaryDirectory();
    tmpDir = [tmpDir stringByAppendingPathComponent:@"Download"];
    //    cashe = [cashe URLByAppendingPathComponent:@"Download" isDirectory:YES];
    //    NSString *path = [cashe path];
    NSString *path = tmpDir;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
            
        }
    }
    
    return path;
}

/**
 *  获取下载了文件的plist记录文件
 *
 *  @return 返回
 */
+(NSString *)getDownloadFilePlist{
    NSString *downloadPath = [DownloadFileManager getDownloadDestinationPath];
    NSString *downloadFilePlist = [downloadPath stringByAppendingPathComponent:DownloadFilePlist];
    
    return downloadFilePlist;
}

/**
 *  随机产生一个序列号,带时间格式确保唯一
 *
 *  @return
 */
+(NSString *)createNewId{
    NSInteger stringLen = 32;
    NSString *identifierForAdvertising = [[NSString alloc] init];
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    for (int i = 0; i < stringLen; i++) {
        int number = arc4random() % stringLen;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            identifierForAdvertising = [identifierForAdvertising stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % (stringLen - 10)) + 97;
            char character = figure;
            NSString *tempString = [[NSString stringWithFormat:@"%c", character] uppercaseString];
            identifierForAdvertising = [identifierForAdvertising stringByAppendingString:tempString];
        }
    }
    date = [date stringByAppendingString:identifierForAdvertising];
    
    return date;
}

#pragma mark ASIHttpRequest响应事件

/**
 *  http request开始下载文件时
 *
 *  @param request
 */
- (void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"ASIHttpRequest requestStarted: %@",request.responseString);
    if (_startDownloadFileBlock != nil) {
        DownloadFileModel *file = [request.userInfo objectForKey:@"File"];
        _startDownloadFileBlock(file);
    }
}

/**
 *  将要下载一个文件时接收到文件的头信息，
 *  保存头文件的信息
 *
 *  @param request
 *  @param responseHeaders
 */
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
//    NSLog(@"ASIHttpRequest didReceiveResponseHeaders: %@",responseHeaders);
    DownloadFileModel *file = [request.userInfo objectForKey:@"File"];
    //获取文件长度
    NSString *lenth = [responseHeaders objectForKey:@"Content-Length"];
    //这个信息头，首次收到的为总大小，那么后来续传时收到的大小为肯定小于或等于首次的值，则忽略
    if ([file.fileSize longLongValue]> [lenth longLongValue])
    {
        return;
    }
    file.fileSize = [NSString stringWithFormat:@"%lld",  [lenth longLongValue]];
    [self saveDownloadTmpInfo:file];
    
    //通知接收文件的头信息
    if (_downloadReceiveResponseHeaderBlock != nil) {
        _downloadReceiveResponseHeaderBlock(file, responseHeaders);
    }
}

/**
 *  ASIHttpRequest下载完成时
 *
 *  @param request
 */
- (void)requestFinished:(ASIHTTPRequest *)request{
    //删除下载完成的临时信息文件
    DownloadFileModel *file = [request.userInfo objectForKey:@"File"];
    file.isFinished = YES;
    file.isDownloading = NO;
    file.willDownloading = NO;
    [self deletePlistFile:file];
    
    //保存下载历史记录
    [self saveDownloadFilePlist:file];
    
    //从列表中移除
    [_downloadFilesArray removeObject:file];
    //移除掉http request
    [_downloadRequestsArray removeObject:request];
    
    //通知下载完成
    if (_finishedDownloadFileBlock != nil) {
        _finishedDownloadFileBlock(file);
    }
}

/**
 *  ASIHttpRequest下载失败时
 *
 *  @param request
 */
- (void)requestFailed:(ASIHTTPRequest *)request{
//    NSLog(@"ASIHttpRequest requestFailed: %@",request.error);
    DownloadFileModel *file = [request.userInfo objectForKey:@"File"];
    if ([request isCancelled]) {
        NSLog(@"ASIHttpRequest cancelled");
        //通知下载失败，可能是网络原因
        if (_downloadFileFailBlock != nil) {
            _downloadFileFailBlock(file,YES,request.error);
        }
    }else{
        NSLog(@"ASIHttpRequest requestFailed: %@",request.error);
        NSString *errorDomain = [request.error.userInfo objectForKey:@"NSUnderlyingError"];
        if ([errorDomain rangeOfString:@"kCFErrorDomainCFNetwork"].location != NSNotFound) {
            NSLog(@"ASIHttpRequest requestFailed 网络问题.");
        }
        //通知下载失败，可能是网络原因
        if (_downloadFileFailBlock != nil) {
            _downloadFileFailBlock(file,NO,request.error);
        }
    }
    
}

/**
 *  接收到数据时
 *  When a delegate implements this method, it is expected to process all incoming data itself
 *  This means that responseData / responseString / downloadDestinationPath etc are ignored
 *  You can have the request call a different method by setting didReceiveDataSelector
 *
 *  @param request
 *  @param data
 */
//- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
//    NSLog(@"ASIHttpRequest didReceiveData");
//}


#pragma mark ASIHttpRequest setDownloadProgressDelegate响应事件

/**
 *  Called when the request receives some data - bytes is the length of that data
 *
 *  @param request
 *  @param bytes
 */
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
    //找到下载中的文件，及时更新已下载大小数量
    DownloadFileModel *file=[request.userInfo objectForKey:@"File"];
    file.fileReceivedSize=[NSString stringWithFormat:@"%lld",[file.fileReceivedSize longLongValue]+bytes];
    [self saveDownloadTmpInfo:file];
    
    //通知Block已经下载字节数
    if (_didReceiveBytesBlock != nil) {
        _didReceiveBytesBlock(file);
    }
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
