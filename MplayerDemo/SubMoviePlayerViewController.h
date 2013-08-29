//
//  SubMoviePlayerViewController.h
//  MplayerDemo
//
//  Created by David on 13-8-15.
//  Copyright (c) 2013年 David. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface SubMoviePlayerViewController : MPMoviePlayerViewController<UIAlertViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, retain) MPMoviePlayerController *MPMoviePlayer;

//下边栏控制条
@property (nonatomic, retain) UIView *controlBar;
//右边栏
@property (nonatomic, retain) UIView *chooseView;
//上边栏
@property (nonatomic, retain) UIView *topBar;

//定时器
@property (nonatomic, retain) NSTimer *timer;

//进度条开始时间Label
@property (nonatomic, retain) UILabel *startTimeLabel;
//进度条slider
@property (nonatomic, retain) UISlider *sliderBar;
//结束播放时间Label
@property (nonatomic, retain) UILabel *endTimeLabel;

//音量图标
@property (nonatomic, retain) UIButton *VolueButton;
//音量控制条
@property (nonatomic, retain) UISlider *volumeBar;

//listHD
@property (nonatomic, retain) UIView *listHD;
//记录进度条手势快进秒数
@property (nonatomic, assign) double second;

//快进的时候显示时间提示
@property (nonatomic, retain) UIView *showTimeView;

//timeShowLabel
@property (nonatomic, retain) UILabel *timeShowLabel;

//手势状态
@property (nonatomic, assign) int gestureStatus;
//记录起始点
@property (assign, nonatomic) float lastX;
@property (assign, nonatomic) float lastY;

@property (retain, nonatomic) NSString *hdUrl;
@property (retain, nonatomic) NSString *sdUrl;
@property (retain, nonatomic) NSString *tvUrl;

@property (retain, nonatomic) NSString *movieTitle;

@property (retain, nonatomic) UIButton *bgButton;

//定时器
@property (nonatomic, retain) NSTimer *hiddenBgTimer;



@end
