//
//  SubMoviePlayerViewController.m
//  MplayerDemo
//
//  Created by David on 13-8-15.
//  Copyright (c) 2013年 David. All rights reserved.
//

#import "SubMoviePlayerViewController.h"

@interface SubMoviePlayerViewController ()

@end

@implementation SubMoviePlayerViewController

- (void)dealloc
{
    //监听视频文件预加载完成时
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    //监听视频文件播放结束后
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.hiddenBgTimer invalidate];
    if (self.hiddenBgTimer) {
        self.hiddenBgTimer = nil;
    }
    
    [_MPMoviePlayer release];
    [_controlBar release];
    [_chooseView release];
    [_topBar release];
    [_startTimeLabel release];
    [_sliderBar release];
    [_endTimeLabel release];
    [_VolueButton release];
    [_volumeBar release];
    [_listHD release];
    [_showTimeView release];
    [_timeShowLabel release];
    [_hdUrl release];
    [_sdUrl release];
    [_tvUrl release];
    [_movieTitle release];
    [_bgButton release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    self.gestureStatus = -1;
    //    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化播放器
    MPMoviePlayerController *playController = [[MPMoviePlayerController alloc]init];
    self.MPMoviePlayer = playController;
    [playController release];
    self.MPMoviePlayer.controlStyle = MPMovieControlStyleNone;
    
    //设置播放器的frame
    [self.MPMoviePlayer.view setFrame:CGRectMake(0, 0, IS_IPHONE5?(480+88):480, 320)];
    //设置播放背景颜色
    [self.MPMoviePlayer.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.MPMoviePlayer.view];
    [self.MPMoviePlayer prepareToPlay];
    
    //***************************添加背景按钮**************************
    UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bgButton = bgButton;
    [bgButton setFrame:CGRectMake(self.MPMoviePlayer.view.frame.origin.x, self.MPMoviePlayer.view.frame.origin.y, self.MPMoviePlayer.view.frame.size.width, self.MPMoviePlayer.view.frame.size.height)];
    [bgButton setAlpha:0.2f];
    [bgButton addTarget:self action:@selector(bgButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.MPMoviePlayer.view addSubview:bgButton];
    
    //***************************重写控制条****************************
    UIView *controlBar = [[UIView alloc]initWithFrame:CGRectMake(self.MPMoviePlayer.view.frame.origin.x, self.MPMoviePlayer.view.frame.size.height-50, IS_IPHONE5?480+88:480, 50)];
    self.controlBar = controlBar;
    [controlBar release];
    [self.controlBar setBackgroundColor:[UIColor blackColor]];
    [self.controlBar setAlpha:0.7f];
    [self.MPMoviePlayer.view addSubview:self.controlBar];
    
    
    //开始/暂停播放按钮
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setFrame:CGRectMake(((IS_IPHONE5?(480+88):480)-40)/2, 10  , 40, 30)];
    [playButton setImage:[UIImage imageNamed:@"details_stop.png"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"details_stop_select.png"] forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBar addSubview:playButton];
    
    //快进
    UIButton *playUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playUpButton setFrame:CGRectMake(((IS_IPHONE5?(480+88):480)-40)/2+60, 10, 40, 30)];
    [playUpButton setImage:[UIImage imageNamed:@"details_down.png"] forState:UIControlStateNormal];
    [playUpButton setImage:[UIImage imageNamed:@"details_down_select.png"] forState:UIControlStateSelected];
    [playUpButton addTarget:self action:@selector(playUpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBar addSubview:playUpButton];
    
    //后退
    UIButton *playDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playDownButton setFrame:CGRectMake(((IS_IPHONE5?(480+88):480)-40)/2-60, 10, 40, 30)];
    [playDownButton setImage:[UIImage imageNamed:@"details_up.png"] forState:UIControlStateNormal];
    [playDownButton setImage:[UIImage imageNamed:@"details_up_select.png"] forState:UIControlStateSelected];
    [playDownButton addTarget:self action:@selector(playDownButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBar addSubview:playDownButton];
    
    //音量控制
    self.VolueButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.VolueButton setFrame:CGRectMake(playUpButton.frame.origin.x+65, playUpButton.frame.origin.y+15, 20,16)];
    [self.VolueButton setImage:[UIImage imageNamed:@"details_sound.png"] forState:UIControlStateNormal];
    [self.VolueButton addTarget:self action:@selector(VolueButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBar addSubview:self.VolueButton];
    
    
    //进度条
    //开始时间
    UILabel *startTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(IS_IPHONE5?(392+88):392 ,5, 40, 15)];
    self.startTimeLabel = startTimeLabel;
    [startTimeLabel release];
    [self.startTimeLabel setText:[NSString stringWithFormat:@"0"]];
    [self.startTimeLabel setTextColor:[UIColor whiteColor]];
    [self.startTimeLabel setBackgroundColor:[UIColor blackColor]];
    [self.startTimeLabel setAlpha:0.6f];
    [self.startTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.startTimeLabel setFont:[UIFont systemFontOfSize:10]];
    [self.controlBar addSubview:self.startTimeLabel];
    //进度条
    UISlider *sliderBar = [[UISlider alloc]initWithFrame:CGRectMake(0,-12, IS_IPHONE5?(480+88):480, 1)];
    self.sliderBar = sliderBar;
    [sliderBar release];
    [self.sliderBar setMinimumValue:0];
    [self.sliderBar setMaximumValue:self.MPMoviePlayer.duration];
    
    [self.sliderBar setMinimumTrackImage:[UIImage imageNamed:@"details_progress_select"] forState:UIControlStateNormal];
    [self.sliderBar setMaximumTrackImage:[UIImage imageNamed:@"details_progress"] forState:UIControlStateNormal];
    [self.sliderBar setThumbImage:[UIImage imageNamed:@"details_Progress of the point"] forState:UIControlStateNormal];
    [self.sliderBar setThumbImage:[UIImage imageNamed:@"details_Progress of the point"] forState:UIControlStateHighlighted];
    
    [self.sliderBar addTarget:self action:@selector(sliderBarTouchUpClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderBar addTarget:self action:@selector(sliderBarTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.controlBar addSubview:self.sliderBar];
    
    
    
    //时间分隔
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(IS_IPHONE5?(432+88):432, 5, 3, 15)];
    [line setText:@"/"];
    [line setTextColor:[UIColor whiteColor]];
    [line setBackgroundColor:[UIColor blackColor]];
    [line setAlpha:0.6f];
    [line setFont:[UIFont systemFontOfSize:10]];
    [self.controlBar addSubview:line];
    [line release];
    //结束时间(总时间)
    UILabel *endTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(IS_IPHONE5?(435+88):435, 5, 45, 15)];;
    self.endTimeLabel = endTimeLabel;
    [endTimeLabel release];
    [self.endTimeLabel setText:@"0"];
    [self.endTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.endTimeLabel setTextColor:[UIColor whiteColor]];
    [self.endTimeLabel setFont:[UIFont systemFontOfSize:10]];
    [self.endTimeLabel setBackgroundColor:[UIColor blackColor]];
    [self.endTimeLabel setAlpha:0.6f];
    [self.controlBar addSubview:self.endTimeLabel];
    
    
    //监听视频文件预加载完成时
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieStart) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    //监听视频文件播放结束后
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieEnd) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    
    //*************************右侧状态条****************
    UIView *chooseView = [[UIView alloc]initWithFrame:CGRectMake((IS_IPHONE5?(480+88):480)-40, 50, 40, 150)];
    self.chooseView = chooseView;
    [chooseView release];
    [self.chooseView setBackgroundColor:[UIColor whiteColor]];
    [self.chooseView setAlpha:0.6f];
    //    [self.MPMoviePlayer.view addSubview:self.chooseView];
    
    //清晰度.高清切换按钮   默认为普清
    UIButton *HDbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [HDbutton setFrame:CGRectMake(40, 15, 45, 30)];
    [HDbutton setTag:146];
    [HDbutton setImage:[UIImage imageNamed:@"details_ordinary.png"] forState:UIControlStateNormal];
    [HDbutton addTarget:self action:@selector(HDbuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBar addSubview:HDbutton];
    
    //airPlay
    MPVolumeView *volumeViewButton = [[MPVolumeView alloc]initWithFrame:CGRectMake(120, 15, 45, 45)];
    [volumeViewButton setShowsVolumeSlider:NO];
    [volumeViewButton sizeToFit];
    //    volumeViewButton.showsRouteButton = NO;
    //    volumeViewButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [self.controlBar addSubview:volumeViewButton];
    [volumeViewButton release];
    
    //音量控制条
    UISlider *volumeBar = [[UISlider alloc]initWithFrame:CGRectMake(playUpButton.frame.origin.x+90, playUpButton.frame.origin.y+10, 100, 4)];
    self.volumeBar = volumeBar;
    [volumeBar release];
    [self.volumeBar setMinimumValue:0.0];
    [self.volumeBar setMaximumValue:1.0];
    [self.volumeBar setMinimumTrackImage:[UIImage imageNamed:@"details_progress_select"] forState:UIControlStateNormal];
    [self.volumeBar setMaximumTrackImage:[UIImage imageNamed:@"details_progress"] forState:UIControlStateNormal];
    [self.volumeBar setThumbImage:[UIImage imageNamed:@"details_Progress of the point"] forState:UIControlStateNormal];
    [self.volumeBar setThumbImage:[UIImage imageNamed:@"details_Progress of the point"] forState:UIControlStateHighlighted];
    
    [self.volumeBar addTarget:self action:@selector(VolumeSliderBarValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.controlBar addSubview:self.volumeBar];
    
    //物理按键监听
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(volumeChanged:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
    
    //***************************topBar****************
    UIView *topBar = [[UIView alloc]initWithFrame:CGRectMake(0, 20, IS_IPHONE5?(480+88):480, 30)];
    self.topBar = topBar;
    [topBar release];
    [self.topBar setBackgroundColor:[UIColor blackColor]];
    [self.topBar setAlpha:0.5f];
    [self.MPMoviePlayer.view addSubview:self.topBar];
    
    //视频标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (IS_IPHONE5?(480+88):480), 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    //self.movieTitle为视频标题
    [titleLabel setText:self.movieTitle];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [self.topBar addSubview:titleLabel];
    [titleLabel release];
    
    //后退按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"details_button_back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"details_button_back_select.png"] forState:UIControlStateSelected];
    [backButton setFrame:CGRectMake( 3, 2, 30, 25)];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:backButton];
    
    //*****************************************进度条、音量控制条的手势添加***********************************
#pragma mark 手势
    //滑动手势
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveAction:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self.MPMoviePlayer.view addGestureRecognizer:panRecognizer];
    [panRecognizer release];
    
    ////左右进度条手势
    
}

- (void)viewDidAppear:(BOOL)animated{
    if (!self.MPMoviePlayer.contentURL) {
        //替换播放器url地址即可
        self.MPMoviePlayer.contentURL = [NSURL URLWithString:self.sdUrl];
    }
    [self.MPMoviePlayer play];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    NSLog(@"点击");
    CGPoint translatedPoint = [gestureRecognizer locationInView:self.MPMoviePlayer.view];
    NSLog(@"%f,%f",translatedPoint.x,translatedPoint.y);
    self.lastX = 0;
    self.lastY = 0;
    self.gestureStatus = -1;
    return YES;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}


//移动手势
-(void)moveAction:(UIPanGestureRecognizer*)gestureRecognizer {
    CGPoint translatedPoint = [gestureRecognizer translationInView:self.MPMoviePlayer.view];
    NSLog(@"%f,%f",translatedPoint.x,translatedPoint.y);
    
    NSLog(@"拖动");
    if (self.gestureStatus == -1) {//刚刚触发拖动
        if (translatedPoint.x*translatedPoint.x>translatedPoint.y*translatedPoint.y) {
            //触发进度
            self.gestureStatus = 1;
            self.second = self.MPMoviePlayer.currentPlaybackTime;
        } else {
            //触发音量
            self.gestureStatus = 0;
        }
    } else if (self.gestureStatus == 0){//音量
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        if (self.lastY>translatedPoint.y&&musicPlayer.volume<0.99) {
            musicPlayer.volume = musicPlayer.volume+0.02;
        }
        if (self.lastY<translatedPoint.y&&musicPlayer.volume>0.01) {
            musicPlayer.volume = musicPlayer.volume-0.02;
        }
        self.lastY = translatedPoint.y;
    } else if (self.gestureStatus == 1){//进度
        [self.MPMoviePlayer pause];
        
        if (self.showTimeView == nil) {
            UIView *showTimeView = [[UIView alloc]initWithFrame:CGRectMake(IS_IPHONE5?((480+88)-200)/2:(480-80)/2, 100, 200, 100)];
            self.showTimeView = showTimeView;
            [showTimeView release];
        }
        [self.showTimeView setAlpha:0.7f];
        [self.showTimeView setBackgroundColor:[UIColor blackColor]];
        [self.showTimeView.layer setCornerRadius:8];
        [self.MPMoviePlayer.view addSubview:self.showTimeView];
        [self.showTimeView setHidden:NO];
        
        if (self.lastX<translatedPoint.x && self.second < self.MPMoviePlayer.duration) {
            self.second =self.second + self.MPMoviePlayer.duration*0.005;
        }
        if (self.lastX>translatedPoint.x && self.second >0) {
            self.second = self.second - self.MPMoviePlayer.duration*0.005;
        }
        
        self.lastX = translatedPoint.x;
        
        if (self.timeShowLabel == nil) {
            UILabel *timeShowLabel = [[UILabel alloc]initWithFrame:self.showTimeView.bounds];
            self.timeShowLabel = timeShowLabel;
            [timeShowLabel release];
            [self.showTimeView addSubview:self.timeShowLabel];
            [self.timeShowLabel setFont:[UIFont boldSystemFontOfSize:18]];
            [self.timeShowLabel setTextAlignment:NSTextAlignmentCenter];
            [self.timeShowLabel setBackgroundColor:[UIColor clearColor]];
            [self.timeShowLabel setTextColor:[UIColor whiteColor]];
        }
        [self.timeShowLabel setText:[NSString stringWithFormat:@"%@ / %@",[self secondTimeChange:[NSString stringWithFormat:@"%f",self.second]] ,self.endTimeLabel.text]];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"手指离开");
        if (self.gestureStatus == 1) {
            self.sliderBar.value = self.second;
            self.MPMoviePlayer.currentPlaybackTime = self.sliderBar.value;
            [self.MPMoviePlayer play];
        }
        [self.showTimeView setHidden:YES];
    }
}

//音量物理按键的监听通知
- (void)volumeChanged:(NSNotification *)notification
{
    float volume =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    self.volumeBar.value = volume;
    // Do stuff with volume
}
#pragma mark 视频开始播放
-(void)movieStart
{
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerClicked) userInfo:nil repeats:YES];
    }
    
    if (!self.hiddenBgTimer) {
        self.hiddenBgTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hiddenControlView) userInfo:nil repeats:NO];
    }
}

#pragma mark 视频播放完成
- (void)movieEnd
{
    //监听视频文件预加载完成时
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    //监听视频文件播放结束后
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.timer invalidate];
    if (self.timer) {
        self.timer = nil;
    }
    [self.MPMoviePlayer stop];
    self.MPMoviePlayer = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//清晰度切换
- (void)HDbuttonClicked:(UIButton *)sender
{
    if (self.listHD == nil) {
        //清晰度列表
        UIView *listHD = [[UIView alloc]initWithFrame:CGRectMake(20, 155, 92, 98)];
        self.listHD = listHD;
        [listHD release];
        [self.listHD setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"details_definition_bg.png"]]];
        
        //高清,标清，普清
        for (int i = 0; i<3; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(1, 1+30*i, 90,30)];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setTag:135+i];
            [button setTitle:[NSString stringWithFormat:@"%@",(i==0)?@"高清":(i==1)?@"标清":@"普清"] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
            if (i == 0&&(self.hdUrl == nil)) {
                button.enabled = NO;
            }
            if (i == 1&&(self.sdUrl == nil)) {
                button.enabled = NO;
            }
            if (i == 2&&(self.tvUrl == nil)) {
                button.enabled = NO;
            }
            [button addTarget:self action:@selector(listHDClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.listHD addSubview:button];
        }
        
        [self.MPMoviePlayer.view addSubview:self.listHD];
    }
    if ([sender isSelected]) {
        //单击后
        [UIView animateWithDuration:0.5f animations:^{
            [self.listHD setAlpha:0.0f];
        }];
        [sender setSelected:NO];
    }else if (![sender isSelected]){
        [UIView animateWithDuration:0.5f animations:^{
            [self.listHD setAlpha:0.7f];
        }];
        [sender setSelected:YES];
    }
}

//清晰度切换列表中button的点击事件
- (void)listHDClicked:(UIButton *)sender
{
    [self.MPMoviePlayer pause];
    
    if (sender.tag == 135) {
        //高清点击效果
        
        [((UIButton *)[self.view viewWithTag:146]) setImage:[UIImage imageNamed:@"details_definition_select.png"] forState:UIControlStateNormal];
        //高清格式的视频url
        [self.MPMoviePlayer setContentURL:[NSURL URLWithString:self.hdUrl]];
    }else if (sender.tag == 136){
        //标清点击效果
        [((UIButton *)[self.view viewWithTag:146]) setImage:[UIImage imageNamed:@"details_hd_select.png"] forState:UIControlStateNormal];
        //标清视频url
        [self.MPMoviePlayer setContentURL:[NSURL URLWithString:self.sdUrl]];
    }else if (sender.tag == 137){
        //普清点击效果
        [((UIButton *)[self.view viewWithTag:146]) setImage:[UIImage imageNamed:@"details_ordinary_select.png"] forState:UIControlStateNormal];
        //普清视频url替换
        [self.MPMoviePlayer setContentURL:[NSURL URLWithString:self.tvUrl]];
    }
    [UIView animateWithDuration:0.5f animations:^{
        [self.listHD setAlpha:0.0f];
    }];
    
    [((UIButton *)[self.view viewWithTag:146])setSelected:NO];
    [self.MPMoviePlayer prepareToPlay];
    [self.MPMoviePlayer play];
}

- (void)hiddenControlView{
    [UIView animateWithDuration:0.6f animations:^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.controlBar setFrame:CGRectMake(self.MPMoviePlayer.view.frame.origin.x, self.MPMoviePlayer.view.bounds.size.height, IS_IPHONE5?(480+88):480, 0)];
            [self.chooseView setFrame:CGRectMake((IS_IPHONE5?(480+88):480)+40, 50, 40, 150)];
            [self.topBar setFrame:CGRectMake(0, -30, (IS_IPHONE5?(480+88):480), 30)];
        }];
        [self.controlBar setAlpha:0.0f];
        [self.chooseView setAlpha:0.0f];
        [self.topBar setAlpha:0.0f];
    }];
    [self.bgButton setSelected:NO];
    
    [self.hiddenBgTimer invalidate];
    if (self.hiddenBgTimer) {
        self.hiddenBgTimer = nil;
    }
}

//背景按钮事件
- (void)bgButton:(UIButton *)sender
{
    if ([sender isSelected]) {
        [self hiddenControlView];
    }else if (![sender isSelected]){
        [UIView animateWithDuration:0.3f animations:^{
            [UIView animateWithDuration:0.3 animations:^{
                [self.controlBar setFrame:CGRectMake(self.MPMoviePlayer.view.frame.origin.x, self.MPMoviePlayer.view.bounds.size.height-50, IS_IPHONE5?(480+88):480, 50)];
                [self.chooseView setFrame:CGRectMake((IS_IPHONE5?(480+88):480)-40, 50, 40, 150)];
                [self.topBar setFrame:CGRectMake(0, 20, (IS_IPHONE5?(480+88):480), 30)];
            }];
            [self.controlBar setAlpha:0.6f];
            [self.chooseView setAlpha:0.6f];
            [self.topBar setAlpha:0.5f];
        }];
        [sender setSelected:YES];
        
        [self.hiddenBgTimer invalidate];
        if (self.hiddenBgTimer) {
            self.hiddenBgTimer = nil;
        }
        
        self.hiddenBgTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hiddenControlView) userInfo:nil repeats:NO];
    }
}

//播放/暂停按钮
- (void)playButtonClicked:(UIButton *)sender
{
    if ([sender isSelected]) {
        [self.MPMoviePlayer play];
        [sender setSelected:NO];
        [sender setImage:[UIImage imageNamed:@"details_stop_select.png"] forState:UIControlStateSelected];
        [sender setImage:[UIImage imageNamed:@"details_stop.png"] forState:UIControlStateNormal];
    }else {
        [self.MPMoviePlayer pause];
        [sender setSelected:YES];
        [sender setImage:[UIImage imageNamed:@"details_start.png"] forState:UIControlStateSelected];
        [sender setImage:[UIImage imageNamed:@"details_start_select.png"] forState:UIControlStateNormal];
    }
}

//快进按钮事件
- (void)playUpButtonClicked:(UIButton *)sender
{
    
    self.MPMoviePlayer.currentPlaybackTime+=5;
    self.sliderBar.value = self.MPMoviePlayer.currentPlaybackTime;
}

//快退按钮事件
- (void)playDownButtonClicked:(UIButton *)sender
{
    self.MPMoviePlayer.currentPlaybackTime -=5;
    self.sliderBar.value = self.MPMoviePlayer.currentPlaybackTime;
}

//定时器事件
- (void)timerClicked
{
//    DLog(@"屏幕的高度:%f",self.MPMoviePlayer.view.bounds.size.height);
    //设置开始时间
    [self.startTimeLabel setText:[self secondTimeChange:[NSString stringWithFormat:@"%f",self.MPMoviePlayer.currentPlaybackTime]]];
    [self.sliderBar setMaximumValue:self.MPMoviePlayer.duration];
    [self.sliderBar setValue:self.MPMoviePlayer.currentPlaybackTime];
    [self.endTimeLabel setText:[self secondTimeChange:[NSString stringWithFormat:@"%f",self.MPMoviePlayer.duration]]];
}

//backButton后退按钮
- (void)backButtonClicked:(UIButton *)sender
{
    //监听视频文件预加载完成时
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    //监听视频文件播放结束后
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.timer invalidate];
    if (self.timer) {
        self.timer = nil;
    }
    [self.MPMoviePlayer stop];
    self.MPMoviePlayer = nil;
    
    //隐藏控制条的
    [self.hiddenBgTimer invalidate];
    if (self.hiddenBgTimer) {
        self.hiddenBgTimer = nil;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

////alertView delegate mothed
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0) {
//        //重新播放
//        [self.MPMoviePlayer play];
//        self.sliderBar.value = 0;
//        [self timerWithStart];//开启定时器
//    }else if (buttonIndex == 1){
//        [self backButtonClicked:nil];
//    }
//}

//slider value change
- (void)sliderBarTouchUpClicked:(UISlider *)sender
{
    self.MPMoviePlayer.currentPlaybackTime= sender.value;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerClicked) userInfo:nil repeats:YES];
    }
}

//slider touch down method
- (void)sliderBarTouchDown:(UISlider *)sender
{
    [self.timer invalidate];
    if (self.timer) {
        self.timer = nil;
    }
}

//进度条秒数格式转换
- (NSString *)secondTimeChange:(NSString *)second
{
    int s = (int)[second doubleValue];
    int m = 0 ;
    int h = 0;
    if (s>=3600) {
        h = s/3600;
    }
    if ((s-h*3600)>=60) {
        m = (s-h*3600)/60;
    }
    s = s%60;
    
    NSString *string = [NSString stringWithFormat:@"%02d:%02d:%02d",h,m,s];
    return string;
}

//音量调节事件
- (void)VolueButtonClicked:(UIButton *)sender
{
    if ([sender isSelected]) {
        //选中的时候
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        musicPlayer.volume = 0;
        self.volumeBar.value=0;
        [sender setImage:[UIImage imageNamed:@"details_mute"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"details_mute_select"] forState:UIControlStateSelected];
        [sender setSelected:NO];
    }else{
        [sender setImage:[UIImage imageNamed:@"details_sound"] forState:UIControlStateSelected];
        [sender setImage:[UIImage imageNamed:@"details_sound_select"] forState:UIControlStateNormal];
        [sender setSelected:YES];
    }
}

//音量条改变
- (void)VolumeSliderBarValueChanged:(UISlider *)sender
{
    
    //    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    //    mpc.volume = self.volumeBar.value/100;
    
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = [self.volumeBar value];
    
    if (musicPlayer.volume == 0.0) {
        [self.VolueButton setImage:[UIImage imageNamed:@"details_mute"] forState:UIControlStateNormal];
    }else{
        [self.VolueButton setImage:[UIImage imageNamed:@"details_sound"] forState:UIControlStateNormal];
    }
    //    NSLog(@"%f,----%f",volumeBar.value,self.volumeBar.value);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
