//
//  SecondViewController.m
//  APIDoctor
//
//  Created by kevin on 15/6/30.
//  Copyright (c) 2015年 Kevin chen. All rights reserved.
//

#import "AutoCheckViewController.h"
#import "Constant.h"
#import "AFNetworking.h"

#define SUCCESS   @"1"
#define FAILURE     @"0"

@interface AutoCheckViewController (){
    //接口地址数组
    NSMutableArray *urlArray;
    //接口名称数组
    NSMutableArray *interfaceNameArray;
    //接口请求开始时间
    NSMutableArray *startTimeArray;
    //接口耗费时间
    NSMutableArray *allTimeArray;
    //接口请求成功标志
    NSMutableArray *isSuccessArray;
    //当前请求接口index
    NSInteger currentInterfaceIndex;
    
    //plist 缓存数组
    __strong NSMutableArray *plistArray;
    AFHTTPRequestOperationManager* manager;
     NSMutableArray *resultArray;
    
    NSString *session;
    NSString *token;
    NSInteger loop;
    BOOL isRunning;
    __strong NSTimer *_timer;
    NSInteger uploadIndex;
}

@end

@implementation AutoCheckViewController
@synthesize interfaceTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenFrame = [[UIScreen mainScreen]applicationFrame];
    loop = 0;
    uploadIndex = 0;
    isRunning = false;
    manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = TIMEOUT ;
    
    // Do any additional setup after loading the view, typically from a nib.
    interfaceTableView = [[UITableView alloc]initWithFrame:screenFrame style:UITableViewStylePlain];
    interfaceTableView.delegate = self;
    interfaceTableView.dataSource = self;
//    [self.view addSubview:interfaceTableView];
    //初始化
    urlArray = [[NSMutableArray alloc]initWithCapacity:0];
    interfaceNameArray = [[NSMutableArray alloc]initWithCapacity:0];
    startTimeArray = [[NSMutableArray alloc]initWithCapacity:0];
//    [startTimeArray addObject:@"2015-2-2 12:23:23"];
//    [startTimeArray addObject:@"2015-2-2 12:23:23"];
    
    //接口访问成功失败标志数组
    isSuccessArray = [[NSMutableArray alloc]initWithCapacity:0];
    [isSuccessArray addObject:SUCCESS];
    [isSuccessArray addObject:FAILURE];
    
    //接口访问下载数据时间（毫秒）
    allTimeArray =[[NSMutableArray alloc]initWithCapacity:0];
//    [allTimeArray addObject:@"320"];
//    [allTimeArray addObject:@"420"];
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"interface" ofType:@"plist"];
    plistArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
//    NSLog(@"%@", plistArray);//直接打印数据
    
    currentInterfaceIndex = [plistArray count] - 1;
//    [self autoCheckInterface];
    resultArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self loginAccess];
    
}
-(void)autoCheckInterface{

        _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        [_timer fire];
    
    
}
-(void)alwaysRequestAPI{
    if (plistArray &&loop <[plistArray count]-2 && resultArray && session) {
        NSMutableDictionary * resultDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
        NSDictionary *URLDictionary = (NSDictionary*)[plistArray objectAtIndex:loop];
        
        NSString *url = [NSString stringWithFormat:@"%@%@",DOMAIN,[URLDictionary objectForKey:@"url"]];
//        NSString *method = (NSString*)[URLDictionary objectForKey:@"method"];
        NSDictionary *bodyDictionary = (NSDictionary*)[URLDictionary objectForKey:@"body"];
        if (session) {
            [bodyDictionary setValue:session forKey:@"session_id"];
        }
        NSString *urlName = (NSString*)[URLDictionary objectForKey:@"name"];
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        [resultDictionary setObject:url forKey:@"url"];
        [resultDictionary setObject:urlName forKey:@"name"];
        [resultDictionary setObject:strDate forKey:@"start"];
        
        [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            //请求成功
            isRunning = false;
            
            [resultDictionary setObject:[self intervalSinceNow:dat] forKey:@"time"];
            [resultDictionary setObject:@"成功" forKey:@"result"];
            [resultArray addObject:resultDictionary];
            loop ++;
            [self alwaysRequestAPI];
            
        }failure:^(AFHTTPRequestOperation* operation, NSError* error){
            //错误收集
            [resultDictionary setObject:@"失败" forKey:@"result"];
            [resultDictionary setObject:[self intervalSinceNow:dat] forKey:@"time"];
            [resultArray addObject:resultDictionary];
            loop ++;
            [self alwaysRequestAPI];
        }];
        
    }else if (loop == [plistArray count]-2){
        [self.view addSubview:interfaceTableView];
        [interfaceTableView reloadData];
        loop = 0;
        [self uploadResult];
    }
}
-(void)loginAccess{
    if(manager){
//        loop ++;
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
        NSDictionary *postDictionary = @{@"username" : USERNAME , @"password" : PASSWORD};
        
        [manager POST:LOGIN parameters:postDictionary success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSString* flag = [resultDic objectForKey:@"flag"];
            [dictionary setValue:[self intervalSinceNow:dat] forKey:@"time"];
            
            if (flag.intValue == 1) {
                
                token = [resultDic objectForKey:@"login_token"];
                session = [resultDic objectForKey:@"session_id"];
                NSLog(@"%@",resultDic);
//                [self alwaysRequestAPI];
            }
            else {
                
                NSLog(@"登录失败");
                
            }
            [self autoCheckInterface];
        }failure:^(AFHTTPRequestOperation* operation, NSError* error){
            
            NSLog(@"%@",error);
        }
         ];
    }
}
-(void)uploadResult{
    if (uploadIndex >= [resultArray count]) {
        uploadIndex = 0;
        return;
    }
    NSDictionary *postDictionary = (NSDictionary *)[resultArray objectAtIndex:uploadIndex];
    [manager POST:UPLOAD_URL parameters:postDictionary success:^(AFHTTPRequestOperation *operation, id responseObject){
//        NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        uploadIndex ++;
        [self uploadResult];
       
    }failure:^(AFHTTPRequestOperation* operation, NSError* error){
        
        NSLog(@"%@",error);
    }
     ];
    
}

- (void)timerFired:(id)sender{
    NSLog(@"timer fired");
    [self alwaysRequestAPI];
    resultArray = [[NSMutableArray alloc]initWithCapacity:0];
    return;
    
    if (loop >= [plistArray count]) {
        return;
    }
    if (isRunning) {
        return;
    }else
        isRunning = true;
    NSDictionary *URLDictionary = (NSDictionary*)[plistArray objectAtIndex:currentInterfaceIndex];
    

    NSString *url = [NSString stringWithFormat:@"%@%@",DOMAIN,[URLDictionary objectForKey:@"url"]];
    [urlArray addObject:url];
    
    NSString *method = (NSString*)[URLDictionary objectForKey:@"method"];
    NSDictionary *bodyDictionary = (NSDictionary*)[URLDictionary objectForKey:@"body"];
    if (session) {
        [bodyDictionary setValue:session forKey:@"session_id"];
    }
    NSString *urlName = (NSString*)[URLDictionary objectForKey:@"name"];
    [interfaceNameArray addObject:urlName];
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    [startTimeArray addObject:strDate];
    
    if ([method isEqualToString:@"get"]) {
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            //请求成功
            isRunning = false;
            loop ++;
            [allTimeArray addObject:[self intervalSinceNow:dat]];
            NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];

            if ([resultDic objectForKey:@"session_id"]) {
                session = [resultDic objectForKey:@"session_id"];
            }
            if (loop ==[plistArray count]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //Update UI in UI thread here
                    
                    [interfaceTableView reloadData];
                    
                });
                
            }
            
            
        }failure:^(AFHTTPRequestOperation* operation, NSError* error){
            //错误收集
            isRunning = false;
            loop ++;
            [allTimeArray addObject:[self intervalSinceNow:dat]];
           
            if (loop ==[plistArray count]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //Update UI in UI thread here
                    
                    [interfaceTableView reloadData];
                    
                });
            }

        }];
    }else if ([method isEqualToString:@"post"]){
        
        [manager POST:url parameters:bodyDictionary success:^(AFHTTPRequestOperation *operation, id responseObject){
            //请求成功
            isRunning = false;
            loop ++;
            [allTimeArray addObject:[self intervalSinceNow:dat]];
            NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            
            if ([resultDic objectForKey:@"session_id"]) {
                session = [resultDic objectForKey:@"session_id"];
            }
            if (loop ==[plistArray count]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //Update UI in UI thread here
                    
                    [interfaceTableView reloadData];
                    
                });
            }

        }failure:^(AFHTTPRequestOperation* operation, NSError* error){
            //请求失败
            NSLog(@"%@",error);
            isRunning = false;
            loop ++;
            [allTimeArray addObject:[self intervalSinceNow:dat]];
            if (loop ==[plistArray count]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //Update UI in UI thread here
                    
                    [interfaceTableView reloadData];
                    
                });
            }

            
        }
         ];
    }
    currentInterfaceIndex --;
    
    
}
#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [resultArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static  NSString  *CellIdentiferId = @"MomentsViewControllerCellID";
    UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentiferId];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"interfaceResultCell" owner:nil options:nil];
        cell = [nibs lastObject];
        cell.backgroundColor = [UIColor clearColor];
    };
    NSInteger row = [indexPath row];
    if (row%2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }else{
        cell.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1];
    }
    if (resultArray && [resultArray count]>0) {
        NSDictionary *infoDictionary = [resultArray objectAtIndex:row];
        
        //接口URL地址
        UILabel *urlLable = (UILabel*)[cell viewWithTag:101];
        urlLable.text = (NSString*)[infoDictionary objectForKey:@"url"];
//        urlLable.text = [NSString stringWithFormat:@"%@:%@",
//                         @"接口地址",(NSString*)[urlArray objectAtIndex:row]];
        @try{
        //接口名称
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:100];
        nameLabel.text =(NSString*)[infoDictionary objectForKey:@"name"];

        
        //接口开始时间
        UILabel *startTimeLabel = (UILabel*)[cell viewWithTag:102];
        startTimeLabel.text =(NSString*)[infoDictionary objectForKey:@"start"];
        
        //接口耗时
        UILabel *allTimeLabel = (UILabel*)[cell viewWithTag:103];
            
        allTimeLabel.text =(NSString*)[infoDictionary objectForKey:@"time"];

        
        //接口请求结果
        UILabel *resultLabel = (UILabel*)[cell viewWithTag:104];
        resultLabel.text =(NSString*)[infoDictionary objectForKey:@"result"];
        }
        @catch(NSException *e){
            
        };
    
        
    }
    return cell;

}


#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 85.0f;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
@end
