//
//  SecondViewController.h
//  APIDoctor
//
//  Created by kevin on 15/6/30.
//  Copyright (c) 2015年 Kevin chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *interfaceTableView;
}

@property(nonatomic,strong)UITableView *interfaceTableView;

@end

