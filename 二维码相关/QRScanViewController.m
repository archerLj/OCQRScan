//
//  XHScanToolController.m
//  XHScanTool
//
//  Created by TianGeng on 16/6/27.
//  Copyright © 2016年 bykernel. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "QRScanViewController.h"
#import "ScanView.h"
#import <AVFoundation/AVFoundation.h>

#define kVedioFrame self.view.bounds
#define kScanViewSize CGSizeMake(200, 200)

@interface QRScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) ScanView *scanView;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) AVCaptureDeviceInput *activeVideoInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutPut;
@property (nonatomic, strong) AVCaptureSession *captureSeesion;
@end



@implementation QRScanViewController
//*****************************************************************************/
#pragma mark - LifeCycle
//*****************************************************************************/
- (void)viewDidLoad {
    [super viewDidLoad];

    
    NSError *error;
    self.view.backgroundColor = [UIColor whiteColor];
    BOOL isSuccess= [self setUpSession:error];
    if (isSuccess) {
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSeesion];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        //设置layer的frame为大视图的frame
        
        //把拍摄的layer添加到主视图的layer中
        [self.view.layer insertSublayer:self.preview atIndex:0];
        self.preview.frame = kVedioFrame;
        
        [self.captureSeesion startRunning];
        [self.view addSubview:self.scanView];
    }else{
        // UNDO
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGRect cropRect = CGRectMake((self.scanView.frame.size.width - self.scanView.showSize.width) / 2,
                                 (self.scanView.frame.size.height - self.scanView.showSize.height) / 2,
                                 self.scanView.showSize.width,
                                 self.scanView.showSize.height);
    CGSize size = self.scanView.bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = self.scanView.frame.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        self.metadataOutPut.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                        cropRect.origin.x/size.width,
                                                        cropRect.size.height/fixHeight,
                                                        cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = self.scanView.frame.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        self.metadataOutPut.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                        (cropRect.origin.x + fixPadding)/fixWidth,
                                                        cropRect.size.height/size.height,
                                                        cropRect.size.width/fixWidth);
    }
}



//*****************************************************************************/
#pragma mark - private
//*****************************************************************************/
- (BOOL)setUpSession:(NSError *)error{
    
    // 初始化会话
    self.captureSeesion = [[AVCaptureSession alloc] init];
    self.captureSeesion.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 初始化默认输入设备
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 默认的视频捕捉设备
    self.activeVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (error) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to init activeVideoInput"};
        error = [NSError errorWithDomain:@"error" code:0 userInfo:userInfo];
        
        return NO;
    }
    // 初始化输出设备
    if (self.activeVideoInput) {
        if ([self.captureSeesion canAddInput: self.activeVideoInput]) {
            [self.captureSeesion addInput: self.activeVideoInput];
            self.activeVideoInput =  self.activeVideoInput;
        }
    }else{
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to add activeVideoInput"};
        error = [NSError errorWithDomain:@"error" code:0 userInfo:userInfo];
        
        return NO;
    }
    // 初始化输出设备
    self.metadataOutPut = [[AVCaptureMetadataOutput alloc] init];
    if ([self.captureSeesion canAddOutput:self.metadataOutPut]) {
        [self.captureSeesion addOutput:self.metadataOutPut];
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        
        [self.metadataOutPut setMetadataObjectsDelegate:self queue:mainQueue];
        
        NSArray *types = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        self.metadataOutPut.metadataObjectTypes = types;
        
    }else{
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to add metadaa output"};
        error = [NSError errorWithDomain:@"error" code:0 userInfo:userInfo];
        return NO;
        
    }
    return YES;
}


//扫描完成的时候就会调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //终止会话
    [self.captureSeesion stopRunning];
    self.captureSeesion = nil;
    //把扫描的layer从主视图的layer中移除
    [self.preview removeFromSuperlayer];
    
    NSString *val = nil;
    if (metadataObjects.count > 0)
    {
        //取出最后扫描到的对象
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        //获得扫描的结果
        val = obj.stringValue;
        if ([self.scanDelegate respondsToSelector:@selector(scanToolController:completed:)]) {
            [self.scanDelegate scanToolController:self completed:val];
        }
    }
}



//*****************************************************************************/
#pragma mark - setter, getter
//*****************************************************************************/
-(BOOL)isCameraAllowed {
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    }
    
    return YES;
}

-(BOOL)isCameraValid {
    
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (ScanView *)scanView{
    if (!_scanView) {
        _scanView = [[ScanView alloc] init];
        _scanView.frame = kVedioFrame;
        _scanView.showSize = kScanViewSize;
    }
    return _scanView;
}
@end
