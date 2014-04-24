//
//  NetworkManager.m
//  MiniBlog
//
//  Created by jsb on 11-3-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "NetworkManager.h"
#import "ASIFormDataRequest.h"

#define TIME_OUT_SECOND_GET 20
#define TIME_OUT_SECOND_POST 30

@implementation NetworkHeader
@end

@implementation NetworkResponse
@end


@implementation NetworkManager

+ (id)sharedInstace {
    static NetworkManager *sharedInstacne = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstacne = [[self alloc] init];
    });
    return sharedInstacne;
}

- (id)init {
	if (self = [super init])  {
		_networkQueue = [[ASINetworkQueue alloc] init];
		[_networkQueue setDelegate:self];
        [_networkQueue setShouldCancelAllRequestsOnFailure:NO];
        [_networkQueue setMaxConcurrentOperationCount:10];//一次最多10个请求
		_queueMapping = [NSMutableDictionary dictionaryWithCapacity:10];
        _registedInstances = [NSMutableDictionary dictionaryWithCapacity:10];
        _threadLock = NO;
	}
	return self;
}


- (BOOL)registNetwork:(id)instanceAddress {
    if (!instanceAddress) {
        return NO;
    }
    NSString *key = [NSString stringWithFormat:@"%p", instanceAddress];
    NSString *value = [NSString stringWithFormat:@"%p", instanceAddress];
    @synchronized(self.registedInstances) {
        self.registedInstances[key] = value;
    }
    return YES;
}

- (BOOL)unregistNetwork:(id)instanceAddress {
    if (!instanceAddress) {
        return NO;
    }
    NSString *key = [NSString stringWithFormat:@"%p", instanceAddress];
    @synchronized(self.registedInstances) {
        [self.registedInstances removeObjectForKey:key];
    }
    @synchronized(self.queueMapping) {
        [self.queueMapping enumerateKeysAndObjectsUsingBlock:^(NSString *objKey, id objValue, BOOL *stop) {
            NetworkHeader *header = (NetworkHeader *)objValue;
            NSString *k = [NSString stringWithFormat:@"%p", header.netDelegate];
            if ([key isEqualToString:k]) {
                NSLog(@"unregist %@", k);
                [header.request clearDelegatesAndCancel];
                header.request = nil;
            }
        }];
    }
    return YES;
}

- (BOOL)checkRegist:(id)instanceAddress {
    if (!instanceAddress) {
        return NO;
    }
    NSString *key = [NSString stringWithFormat:@"%p", instanceAddress];
    NSObject *obj = nil;
    @synchronized(self.registedInstances) {
        obj = self.registedInstances[key];
    }
    if (obj)  {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark === HTTP:GET POST DELETE ===
#pragma mark -
- (NetworkHeader*)addGetOperation:(NSString*)urlStr ReqType:(NSUInteger)reqType Delegate:(id)delg {
    if (![self registNetwork:delg])
    {
        //        return nil;
    }
    NSLog(@"murl:{%@}", urlStr);
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
	[request setDelegate:self];
	request.timeOutSeconds = TIME_OUT_SECOND_GET;
    
    NetworkHeader *header = [[NetworkHeader alloc] init];
	header.netDelegate = delg;
	header.request = request;
	header.reqType = reqType;
	
	[self.networkQueue addOperation:request];
	NSString *key = [NSString stringWithFormat:@"%p", request];
    self.queueMapping[key] = header;
	[self.networkQueue go];
    
    return header;
}

- (NetworkHeader*)addPostOperation:(NSString*)urlStr ReqType:(NSUInteger)reqType PostDatas:(NSDictionary*)postDatas Delegate:(id)delg {
    if (![self registNetwork:delg])
    {
        //        return nil;
    }
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
	[request setDelegate:self];
    request.timeOutSeconds = TIME_OUT_SECOND_POST;
    [postDatas enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSData class]]) {
            [request addData:obj
                withFileName:@"pic.jpg"
              andContentType:@"file"
                      forKey:key];
        } else {
            [request addPostValue:[postDatas objectForKey:key]
                           forKey:key];
        }
    }];
    
    NetworkHeader *header = [[NetworkHeader alloc] init];
	header.netDelegate = delg;
	header.request = request;
	header.reqType = reqType;
	
	[self.networkQueue addOperation:request];
	NSString *key = [NSString stringWithFormat:@"%p", request];
    self.queueMapping[key] = header;
	[self.networkQueue go];
	return header;
}

#pragma mark -
#pragma mark === 请求成功 ===
#pragma mark -
- (void)requestFinished:(ASIHTTPRequest *)request  {
    @synchronized(self.queueMapping) {
        NSString *key = [NSString stringWithFormat:@"%p", request];
        NetworkHeader *header = (NetworkHeader *)self.queueMapping[key];
        if (header) {
            NetworkResponse *response = [[NetworkResponse alloc] init];
            response.responseCode = @([request responseStatusCode]);
            response.responseString = [request responseString];
            response.responseData = [request responseData];
            header.data = response;
            if ([self filter:header]) {
                //线程锁
                if ([self checkRegist:header.netDelegate]) 
                {
                    [header.netDelegate networkFinished:header];
                }
            } else {
                //线程锁
                if ([self checkRegist:header.netDelegate]) 
                {
                    [header.netDelegate networkFailed:header];
                }
            }
            [self.queueMapping removeObjectForKey:key];
        }
    }
	
}

#pragma mark -
#pragma mark === 请求失败 ===
#pragma mark -
- (void)requestFailed:(ASIHTTPRequest *)request {
    @synchronized(self.queueMapping) {
        NSString *key = [NSString stringWithFormat:@"%p", request];
        NetworkHeader *header = self.queueMapping[key];
        if (header)  {
            header.data = @"网络连接失败，请检查网络设置！";
            //线程锁
            if ([self checkRegist:header.netDelegate]) {
                [header.netDelegate networkFailed:header];
            }
            
            [self.queueMapping removeObjectForKey:key];
        }
        NSError *error = [request error];
        NSLog(@"%@", [error localizedDescription]);
    }
}

#pragma mark -
#pragma mark === 过滤方法子类继承 ===
#pragma mark -
//处理返回值转换 子类继承
- (BOOL)filter:(NetworkHeader*)header {
	return NO;
}

#pragma mark -
#pragma mark === 请求取消 ===
#pragma mark -
- (void)cancelHeader:(NetworkHeader*)header {
    if (!header) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%p", header.request];
    header.netDelegate = nil;
    [header.request clearDelegatesAndCancel];
    [self.queueMapping removeObjectForKey:key];
}
@end
