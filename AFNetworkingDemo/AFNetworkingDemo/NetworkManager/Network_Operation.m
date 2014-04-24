//
//  Network_Operation.m
//  AFNetworkingDemo
//
//  Created by xxcao on 14-4-24.
//  Copyright (c) 2014年 xxcao. All rights reserved.
//

#import "Network_Operation.h"
#import "AFHTTPClient.h"
#import "AFDownloadRequestOperation.h"

static const double time_out_seconds = 30.0;

@implementation Network_Operation

#pragma -mark
#pragma -mark GET, POST, DELETE Request
+ (AFHTTPRequestOperation *)requestOperation_Url:(NSURL *)url
                                      Parameters:(id)parameter
                                          Method:(NSString *)method {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass: [AFHTTPRequestOperation class]];
//    //custom header
//    [httpClient setDefaultHeader:@"key" value:@"value"];
//    [httpClient setAuthorizationHeaderWithUsername:@"username" password:@"password"];
//    [httpClient setAuthorizationHeaderWithToken:@"token"];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:method
                                                            path:url.absoluteString
                                                      parameters:parameter];
    [request setTimeoutInterval:time_out_seconds];
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}


#pragma -mark
#pragma -mark Upload File Request
+ (AFHTTPRequestOperation *)uploadOperation_Url:(NSURL *)url
                                           Body:(id)parameter
                                       FileName:(NSString *)fName
                                           Data:(id)data {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass: [AFHTTPRequestOperation class]];
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:url.absoluteString
                                                                   parameters:parameter
                                                    constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                        [formData appendPartWithFileData:data
                                                                                    name:@"avatar"
                                                                                fileName:fName
                                                                                mimeType:@"image/jpeg"];
                                                    }];
    [request setTimeoutInterval:time_out_seconds];
    return [[AFHTTPRequestOperation alloc] initWithRequest:request];
}

+ (AFHTTPRequestOperation *)downloadOperation_Url:(NSURL *)url
                                         FilePath:(NSString *)fPath {
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:url
                                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                 timeoutInterval:time_out_seconds];
    
    AFDownloadRequestOperation *downloadOp = [[AFDownloadRequestOperation alloc] initWithRequest:downloadRequest
                                                                                      targetPath:fPath
                                                                                    shouldResume:YES];
    return downloadOp;
}
@end
