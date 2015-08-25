//
//  VideoView.h
//  AirplayTV
//
//  Created by chedao on 15/8/24.
//  Copyright (c) 2015年 chedao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface VideoView : UIView{

    UIView *top;
    UIView *bottom;
    UILabel *label; //标题
    
    //播放按钮
    UIButton *playBtn;
    /*! 播放器 */
    AVPlayer *_player;
    //进度条
    UIProgressView *progress;
    int nums;//记录5秒之后隐藏工具菜单
}


//视频的名字
@property(nonatomic,copy)NSString *title;
/*! 视频的播放地址 */
@property(nonatomic,copy)NSString *urlPath;


-(void)play;//开始
-(void)stop;//暂停


@end
