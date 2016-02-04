//
//  ViewController.h
//  DownloadFileManager
//
//  Created by Kevin on 16/2/4.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadFileManager.h"
#import "DownloadFileModel.h"
#import "OpenFileManager.h"


@interface ViewController : UIViewController
- (IBAction)startDownload_OnTouch:(id)sender;
- (IBAction)pauseDownload_OnTouch:(id)sender;
- (IBAction)stopDownload_OnTouch:(id)sender;
- (IBAction)openFile_OnTouch:(id)sender;
- (IBAction)downloadMutilFile_OnTouch:(id)sender;
- (IBAction)resumeDownload_OnTouch:(id)sender;
- (IBAction)addFileToDownload_OnTouch:(id)sender;


@end

