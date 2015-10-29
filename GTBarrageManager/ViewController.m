//
//  ViewController.m
//  ResponseDemo
//
//  Created by 高添 on 15/10/29.
//  Copyright © 2015年 高添. All rights reserved.
//

#import "ViewController.h"
#import "GTBarrageManager-Swift.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
}


- (IBAction)sendBtn_Click:(UIButton *)sender {
    NSDictionary *dict = @{@"message" : @"阿斯顿发送到发送到vf"};

    [[BarrageManager shareInstance] showBarrage:dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
