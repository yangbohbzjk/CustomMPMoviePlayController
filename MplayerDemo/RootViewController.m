//
//  RootViewController.m
//  MplayerDemo
//
//  Created by David on 13-8-15.
//  Copyright (c) 2013年 David. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
            [self.navigationController setNavigationBarHidden:YES];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(0, 0, 80, 50)];
    [button setTitle:@"player" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}

//播放视频
- (void)buttonClicked:(UIButton *)sender
{
    SubMoviePlayerViewController *subMoviePlayerViewController = [[SubMoviePlayerViewController alloc]init];
    [self.navigationController pushViewController:subMoviePlayerViewController animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
