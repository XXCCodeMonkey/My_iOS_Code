//
//  NetworkManager.h
//  MiniBlog
//
//  Created by jsb on 11-3-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@class NetworkHeader;

@protocol NetworkProtocol
-(void)networkFinished:(NetworkHeader*)header;
-(void)networkFailed:(NetworkHeader*)header;
@end

//自定义网络数据包头，用于区分不同类型的请求和回复
@interface NetworkHeader : NSObject

@property (nonatomic) NSUInteger reqType;         //请求类型
@property (nonatomic, copy) NSString *reqName;    //请求方法名
@property (nonatomic, strong) id data;            //返回数据
@property (nonatomic, assign) id <NetworkProtocol> netDelegate;
@property (nonatomic, strong) ASIHTTPRequest *request;
@end

//自定义网络数据返回
@interface NetworkResponse : NSObject
@property (nonatomic, strong) NSNumber *responseCode;     //返回code
@property (nonatomic, strong) NSString *responseString;   //返回字符串
@property (nonatomic, strong) id responseData;            //返回数据
@end

//网络管理器
@interface NetworkManager : NSObject

@property (nonatomic, strong) ASINetworkQueue *networkQueue;
@property (nonatomic, strong) NSMutableDictionary *queueMapping;
@property (nonatomic, strong) NSMutableDictionary *registedInstances;
@property (nonatomic, copy) NSString *downloadImageFolder;
@property (nonatomic) BOOL threadLock;

+ (id)sharedInstace;

- (NetworkHeader*)addGetOperation:(NSString*)urlStr ReqType:(NSUInteger)reqType Delegate:(id)delg;

- (NetworkHeader*)addPostOperation:(NSString*)urlStr ReqType:(NSUInteger)reqType PostDatas:(NSDictionary*)postDatas Delegate:(id)delg;

- (BOOL)checkRegist:(id)instanceAddress;
//处理返回值转换
- (BOOL)filter:(NetworkHeader*)header;
//增加网络控制防止崩溃
- (BOOL)registNetwork:(id)instanceAddress;
- (BOOL)unregistNetwork:(id)instanceAddress;
- (void)cancelHeader:(NetworkHeader*)header;
@end




