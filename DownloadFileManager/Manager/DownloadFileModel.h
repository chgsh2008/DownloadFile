//
//  FileModel.h
//  KCDownloadManager
//
//  Created by Kevin on 16/1/20.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DownloadFileModel : NSObject

@property(nonatomic,copy)NSString *fileID;
@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,copy)NSString *fileSize;
@property(nonatomic,copy)NSString *fileType;
// 0:@"Video" ;1:@"Audio";2:@"Image";3:@"File"4:Record

@property(nonatomic,copy)NSString *fileReceivedSize;
@property(nonatomic,copy)NSString *fileURL;
@property(nonatomic,copy)NSString *targetPath;//包含绝对目录
@property(nonatomic,copy)NSString *tempPath;//包含绝对目录
//@property(nonatomic,copy)NSString *relationshipFinishDownloadPath;//App下的已下载完成的相对目录，
//@property(nonatomic,copy)NSString *relationshipDownloadTmpPath;//App下的正在下载的相对目录，
@property(nonatomic, assign)BOOL isDownloading;//是否正在下载
@property(nonatomic, assign)BOOL  willDownloading;
@property(nonatomic, assign)BOOL  isFinished;//是否已下载
@property(nonatomic, assign)BOOL  isCancel;//是否已取消
@property(nonatomic, assign)BOOL hasError;
@property(nonatomic,copy)NSError *error;

@end
