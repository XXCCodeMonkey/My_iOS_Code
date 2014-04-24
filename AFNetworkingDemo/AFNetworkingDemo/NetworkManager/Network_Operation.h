//
//  Network_Operation.h
//  AFNetworkingDemo
//
//  Created by xxcao on 14-4-24.
//  Copyright (c) 2014年 xxcao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@interface Network_Operation : NSObject

#pragma -mark
#pragma -mark GET, POST, DELETE, PUT Request
+ (AFHTTPRequestOperation *)requestOperation_Url:(NSURL *)url
                                      Parameters:(id)parameter
                                          Method:(NSString *)method;

#pragma -mark
#pragma -mark Upload Files Request
+ (AFHTTPRequestOperation *)uploadOperation_Url:(NSURL *)url
                                           Body:(id)parameter
                                       FileName:(NSString *)fName
                                           Data:(id)data;

#pragma -mark
#pragma -mark Download Files Request
+ (AFHTTPRequestOperation *)downloadOperation_Url:(NSURL *)url
                                         FilePath:(NSString *)fPath;

@end
