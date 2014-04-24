//
//  XYXViewController.m
//  ASIHttpRequestDemo
//
//  Created by xxcao on 14-4-16.
//  Copyright (c) 2014年 xxcao. All rights reserved.
//

#import "XYXViewController.h"

@interface XYXViewController ()

@end

@implementation XYXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)dealloc {
    [[XYXNetworkManager sharedInstace]unregistNetwork:self];
}

- (IBAction)goAction:(id)sender{
    //request data
    NSDictionary *jsonDictionary = @{@"MethodName": @"GetTaskList",
                                         @"UserId": @"003",
                                         @"RoleId": @"eab8eee5-ef75-42e2-9a13-88d64095b8fa",
                                          @"BizId": @" ",
                                         @"Status": @"0",
                                        @"PageNum": @" ",
                                       @"PageSize": @" "};
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    NSDictionary *dataDic = @{@"reqData": jsonString,
                             @"userName": @" ",
                             @"passWord": @" "};
    [[XYXNetworkManager sharedInstace] Network_API_CommitMyInfomation:dataDic 
                                                                 Delg:self];
}

#pragma -mark ======
#pragma -mark ======Network Delegate=====
#pragma -mark ======
- (void)networkFinished:(NetworkHeader*)header {
    if (header.reqType == REQ_TYPE_GET_INFOMATION) {
        NSLog(@"network request success:%@",header.data);
    }
}

- (void)networkFailed:(NetworkHeader*)header {
    if (header.reqType == REQ_TYPE_GET_INFOMATION) {
        NSLog(@"network request fail:%@",header.data);
    }
}

@end
