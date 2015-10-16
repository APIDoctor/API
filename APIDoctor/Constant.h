//
//  Constant.h
//  APIDoctor
//
//  Created by kevin on 15/7/1.
//  Copyright (c) 2015年 Kevin chen. All rights reserved.
//

#ifndef APIDoctor_Constant_h
#define APIDoctor_Constant_h

#define USERNAME  @"username"
#define PASSWORD  @"888888"
#define TIMEOUT  60
#define DOMAIN @"http://api.XXX.com"
#define UPLOAD_URL @"http://upload.xxx.com"

//接口定义
#define SESSIONID [NSString stringWithFormat:@"%@/%@",DOMAIN, @"/Member/AnonymityGetSession"]
//手机登录
#define LOGIN [NSString stringWithFormat:@"%@/%@", DOMAIN,@"/Member/Login"]

#endif