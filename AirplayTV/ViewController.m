//
//  ViewController.m
//  AirplayTV
//
//  Created by chedao on 15/8/24.
//  Copyright (c) 2015年 chedao. All rights reserved.
//

#import "ViewController.h"
#import "VideoView.h"
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController (){

    VideoView *videoV ;
    int k;

}

//将视频镜像到支持airplay的设备上的view按钮
@property(nonatomic,strong)MPVolumeView *airplayView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = @"airplayDome";
    videoV = [[VideoView alloc] init];
    videoV.frame = CGRectMake(0, 70, self.view.frame.size.width, 300);
    
    [self.view addSubview:videoV];
    
    videoV.title = @"视频";
    videoV.urlPath = [[NSBundle mainBundle]pathForResource:@"localMedia" ofType:@"mp4"];
    
    _airplayView = [[MPVolumeView alloc] initWithFrame:CGRectMake(videoV.frame.size.width - 60, 5, 30, 30)];
    _airplayView.showsVolumeSlider = NO;
    [self.airplayView setRouteButtonImage:[UIImage imageNamed:@"airPlay"] forState:UIControlStateNormal];
    self.airplayView.hidden = YES;
    [videoV addSubview:_airplayView];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(activeInfo) name:MPVolumeViewWirelessRouteActiveDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(availableInfo) name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification object:nil];
    
    //开始播放视频按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width , 50);
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

-(void)startClick{

    [videoV play];

}



-(void)activeInfo{

    if (self.airplayView.isWirelessRouteActive) {
        NSLog(@"已经连上电视");
        
    }else{
    
        NSLog(@"断开连接");
    }
    
    [videoV play];

}
-(void)availableInfo{
    if (self.airplayView.areWirelessRoutesAvailable) {
        NSLog(@"可以搜到设备");
        self.airplayView.hidden = NO;
        
    }else{
        self.airplayView.hidden = YES;
        NSLog(@"没有搜索到设备");
    
    }
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
