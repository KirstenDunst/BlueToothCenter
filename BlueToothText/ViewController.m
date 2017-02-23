//
//  ViewController.m
//  BlueToothText
//
//  Created by CSX on 2017/2/22.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController ()<MCSessionDelegate,MCBrowserViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong,nonatomic) MCSession *session;
@property (strong,nonatomic) MCBrowserViewController *browserController;
@property (strong,nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UITextField *sendText;
@property (weak, nonatomic) IBOutlet UILabel *receiveLabel;

@property (strong, nonatomic) UIImageView *photo;
@end

@implementation ViewController

#pragma mark - 控制器视图事件
- (void)viewDidLoad {
    [super viewDidLoad];
    //创建节点
    MCPeerID *peerID=[[MCPeerID alloc]initWithDisplayName:@"KenshinCui"];
    //创建会话
    _session=[[MCSession alloc]initWithPeer:peerID];
    _session.delegate=self;
    
    
    
    
    _photo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 280, self.view.frame.size.width, self.view.frame.size.height-280)];
    [self.view addSubview:_photo];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"查找设备" style:UIBarButtonItemStylePlain target:self action:@selector(chooseDevice)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"选择照片" style:UIBarButtonItemStylePlain target:self action:@selector(choosePicture)];
}
- (IBAction)send:(UIButton *)sender {
    NSError *error=nil;
   
    [self.session sendData:[self.sendText.text dataUsingEncoding:NSUTF8StringEncoding] toPeers:[self.session connectedPeers] withMode:MCSessionSendDataUnreliable error:&error];
    NSLog(@"开始发送数据...");
    if (error) {
        NSLog(@"发送数据过程中发生错误，错误信息：%@",error.localizedDescription);
    }
}
#pragma mark- UI事件
- (void)chooseDevice{
    _browserController=[[MCBrowserViewController alloc]initWithServiceType:@"cmj-stream" session:self.session];
    _browserController.delegate=self;
    [self presentViewController:_browserController animated:YES completion:nil];
}
- (void)choosePicture{
    _imagePickerController=[[UIImagePickerController alloc]init];
    _imagePickerController.delegate=self;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}


#pragma mark - MCBrowserViewController代理方法
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    NSLog(@"已选择");
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}
-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    NSLog(@"取消浏览.");
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MCSession代理方法
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSLog(@"didChangeState");
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"连接成功.");
            [self.browserController dismissViewControllerAnimated:YES completion:nil];
            break;
        case MCSessionStateConnecting:
            NSLog(@"正在连接...");
            break;
        default:
            NSLog(@"连接失败.");
            break;
    }
}
//接收数据
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog(@"开始接收数据...");
    self.receiveLabel.text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

//    UIImage *image=[UIImage imageWithData:data];
//    [self.photo setImage:image];
    //保存到相册
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}
#pragma mark - UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self.photo setImage:image];
    //发送数据给所有已连接设备
//    NSError *error=nil;
//    NSString *str = @"曹世鑫的测试";
//    [str dataUsingEncoding:NSUTF8StringEncoding]
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}




@end
