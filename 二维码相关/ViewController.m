//
//  ViewController.m
//  二维码相关
//
//  Created by archerLj on 2016/10/12.
//  Copyright © 2016年 com.bocodo.csr. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    QRScanViewController *vc = [[QRScanViewController alloc] init];
    
    if (vc.isCameraValid && vc.isCameraAllowed) {
        vc.scanDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if (!vc.isCameraAllowed) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的设置-隐私-相机中允许访问相机。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];
            
        }else if (!vc.isCameraValid){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查你的摄像头。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    }
}

- (IBAction)qrThree:(UIButton *)sender {
}

- (void)scanToolController:(QRScanViewController *)scanToolController completed:(NSString *)result{
    [scanToolController.navigationController popViewControllerAnimated:YES];
    NSLog(@"%@",result);
}

@end


