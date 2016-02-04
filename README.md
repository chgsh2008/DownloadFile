# DownloadFile
文笔不好，莫见怪，嘻嘻

利用ASIHttpRequest实现的文件异步下载，可以断点下载，可以在下载过程中加入新的文件下载。
代码比较简单，这里有两个功能：一是文件下载，二是打开文件，用法都很简单。


一、文件下载

文件如果已经有下载，则忽略。如果没有下载则开始下载。可以断点下载，如果文件上次有下载一半，则继续断点下载。可以多文件下载，也可以单文件下载。

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




二、打开文件

如果文件没有下载，可以下载后并使用iOS本地app打开此文件。如果文件没有下载，也可以选择在线打开文件，在线打开文件是打开iOS的safari浏览器在线打开文件。

用法很简单：

    OpenFileManager *openFileManager = [[OpenFileManager alloc] initWithParentViewController:self];
    [_openFileManager openFile:YES isNotExist:YES downloadUrl:@"https://itunesconnect.apple.com/docs/UsingApplicationLoader.pdf" localFile:nil];
    [_openFileManager setDidReceiveBytesBlock:^(DownloadFileModel *file) {
        NSLog(@"已经下载字节数：%@",file.fileReceivedSize);
    }];
    [_openFileManager setFinishedDownloadFileBlock:^(DownloadFileModel *file) {
        NSLog(@"已经下载完文件: %@", file.fileName);
    }];


如果有什么问题，欢迎提出来更正。

