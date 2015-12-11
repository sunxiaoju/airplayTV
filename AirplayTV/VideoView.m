//
//  VideoView.m
//  AirplayTV
//
//  Created by chedao on 15/8/24.
//  Copyright (c) 2015年 chedao. All rights reserved.
//

#import "VideoView.h"
#import "Masonry.h"


@implementation VideoView

-(instancetype)init{

    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        [self makeToolView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [self addGestureRecognizer:tap];
        /////
        
        /////
        ////
        ////
        ///
        
    }
    return self;

}

-(void)setTitle:(NSString *)title{

    if (title) {
        label.text = title;
    }

}

-(void)tapClick{

    if (top.hidden) {
        top.hidden = NO;
        bottom.hidden = NO;
        nums = 0;
        
    }else{
    
        top.hidden = YES;
        bottom.hidden = YES;
    }
    

}
-(void)makeToolView{
    
    top = [UIView new];
    top.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:top];
    [top mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [top addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(top);
        make.centerY.equalTo(top);
        make.height.mas_equalTo(30);
        
    }];
    
    
    
    
    bottom = [UIView new];
    bottom.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:bottom];
    
    [bottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(44);
        
    }];
    
    playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"videoPause"] forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(playBtn) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:playBtn];
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottom).offset(20);
        make.centerY.equalTo(bottom);
        make.width.height.mas_equalTo(30);
    }];
    
    
    
    progress = [UIProgressView new];
    [bottom addSubview:progress];
    
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(playBtn.mas_right).offset(20);
        make.right.equalTo(bottom).offset(-20);
        make.centerY.equalTo(bottom);
    }];
    
    [progress setProgress:0 animated:YES];
    
}
-(void)playBtn{
    if (!_player) {
        return;
    }
    if (playBtn.selected) {
        playBtn.selected = NO;
        [_player pause];
    }else{
        [_player play];
        playBtn.selected = YES;
    }
    nums = 0;
}


+(Class)layerClass{

    return [AVPlayerLayer class];
}
-(void)setUrlPath:(NSString *)urlPath{

    if (urlPath) {
        
        [self loadVideoWithPath:urlPath];
    }

}

-(void)loadVideoWithPath:(NSString*)path{

    NSURL *url;
    
    if ([path hasPrefix:@"http://"] || [path hasPrefix:@"https://"]) {
        //远程的资源地址
        url = [NSURL URLWithString:path];
    }else{
        //本地的资源
        url = [NSURL fileURLWithPath:path];
    }
    
    
    //AVAsset 视频信息的抽象集合类，可以对视频进行预加载，目的是收集视频的信息和参数
    AVAsset *set = [AVAsset assetWithURL:url];
    //loadValuesAsynchronouslyForKeys 根据 tracks 关键字来预加载视频，获取视频的信息
    [set loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        //获取预加载视频资源的状态
        AVKeyValueStatus status = [set statusOfValueForKey:@"tracks" error:nil];
        //成功获取视频的信息(预加载完毕)
        if (status == AVKeyValueStatusLoaded) {
            //AVPlayerItem 带有视频信息的具体项目,里面带有视频的总时长、视频的播放进度和视频类型等信息
            AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:set];
            //初始化视频播放器
            _player = [[AVPlayer alloc] initWithPlayerItem:item];
            //将播放器传给videoView
//            
            AVPlayerLayer *plauerLayer = (AVPlayerLayer*)self.layer;
            [plauerLayer setPlayer:_player];
            //播放视频
//            [_player play];
            playBtn.selected = YES;
            //通过播放器来获取视频的播放进度
            //CMTime 视频对应的时间单位 ,CMTimeMake(1.0,1.0) _player 会将间隔处理成1秒
            //单独开辟一个线程，每隔一秒来获取一次视频的状态
            //block{}中 默认对成员变量保持强引用,Root中对成员变量也是强引用 (强-强引用彼此不能被编译器释放)
            __block VideoView *videoV = self;
            [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0,1.0) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
                if (!videoV->top.hidden) {
                    videoV->nums++;
                }
               
                //通过_player来获取视频当前的播放进度
                //blockVc->_player block中 弱引用_player(强-弱)
                CMTime current = videoV->_player.currentItem.currentTime;
                //获取视频总时间
                CMTime total = videoV->_player.currentItem.duration;
                //CMTimeGetSeconds 将视频的时间单位CMTime转化成秒
                float progressF = CMTimeGetSeconds(current)/CMTimeGetSeconds(total);
                //回到主线程，刷新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressF>=0.0&&progressF<=1.0) {
                        [videoV->progress setProgress:progressF animated:YES];
                        if (videoV->nums >= 20) {
                            videoV->top.hidden = YES;
                            videoV->bottom.hidden = YES;
                            
                        }
                    }
                });
            }];
        }
    }];

    
    
    

}

-(void)play{
    
    [_player play];
}

-(void)stop{

    if (_player) {
         [_player pause];
    }
   
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
