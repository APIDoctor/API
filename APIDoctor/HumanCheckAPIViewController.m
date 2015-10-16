//
//  FirstViewController.m
//  APIDoctor
//
//  Created by kevin on 15/6/30.
//  Copyright (c) 2015年 Kevin chen. All rights reserved.
//
#import "HumanCheckAPIViewController.h"
#import "AFNetworking.h"
#import "Constant.h"



@interface HumanCheckAPIViewController ()
{
    NSString *domain;
    NSString *session;
    NSString *token;
    NSMutableDictionary *errorDictionary;
    NSMutableArray *errorArray;
    AFHTTPRequestOperationManager* manager;
    NSInteger loop;
    BOOL isRunning;
}
-(void)allUserInfo:(NSString*)name password:(NSString*)password;
-(void)postAllDataToServer:(NSDictionary*)data;
@end

@implementation HumanCheckAPIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化错误存储字典
    errorDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
    errorArray = [[NSMutableArray alloc]initWithCapacity:0];
    loop = 0;
    //初始化网络连接
    manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = TIMEOUT ;
    isRunning = TRUE;
    return;
}

-(void)errorMessage:(NSMutableDictionary *)dictionary message:(NSString*)message{
    
}

-(void)allUserInfo:(NSString*)name password:(NSString*)password{
    
}
#pragma mark - Tools

//计算时间差值，返回毫秒
- (NSString *)intervalSinceNow: (NSDate *) time
{
    NSTimeInterval late=[time timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval alltime=(now-late)*1000;
    timeString = [NSString stringWithFormat:@"%.0f", alltime];
    return timeString ;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
