//
//  QRTwoViewController.h
//  二维码相关
//
//  Created by archerLj on 2016/10/12.
//  Copyright © 2016年 com.bocodo.csr. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QRScanViewController;

@protocol QRScanViewControllerDelegate <NSObject>
/**
 *  扫描成功的回掉函数
 *
 *  @param scanToolController 控制器
 *  @param result             扫描的内容
 */
- (void)scanToolController:(QRScanViewController *)scanToolController completed:(NSString *)result;

@end


@interface QRScanViewController : UIViewController
@property (nonatomic, weak) id <QRScanViewControllerDelegate> scanDelegate;

/**
 *  判断相机摄像头可用状态
 */
-(BOOL)isCameraAllowed;
/**
 * 判断权限
 */
-(BOOL)isCameraValid;
@end
