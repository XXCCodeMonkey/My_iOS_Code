#import "XYXNetworkManager.h"

@implementation XYXNetworkManager

#pragma mark -
#pragma mark === 网络接口的调用 ===
#pragma mark -
- (NetworkHeader *)Network_API_CommitMyInfomation:(NSDictionary *)data Delg:(id<NetworkProtocol>)delg{
    //这个可以把共用的url写成宏
    NSString *apiUrlString = @"http://ss.lbs2010.com:8010/enpiwebservice/Service.asmx/GetInformation";
    NetworkHeader *ret = [self addPostOperation:apiUrlString
                                        ReqType:REQ_TYPE_GET_INFOMATION
                                      PostDatas:data
                                       Delegate:delg];
    ret.reqName = [NSString stringWithFormat:@"commitMyInfo"];
    return ret;
}

#pragma mark -
#pragma mark === 处理返回数据 ===
#pragma mark -
- (BOOL)filter:(NetworkHeader*)header {
    BOOL ret = NO;
    NetworkResponse *response = (NetworkResponse *)header.data;
    NSLog(@"\n==========================\n Request Name:%@  \n Response code:%@ \n Response string:%@ \n==========================\n", header.reqName, response.responseCode, response.responseString);
    
    NSError *error = nil;
    id retObj = [NSJSONSerialization JSONObjectWithData:response.responseData
                                                options:kNilOptions
                                                  error:&error];
    if (!retObj || error != nil) {
        header.data = @"数据解析错误";
    } else if (header.reqType == REQ_TYPE_GET_INFOMATION) {
        if ([retObj isKindOfClass:[NSDictionary class]]) {
            //在这里可以解析jsonString
            header.data = retObj;
            ret = YES;
        } else {
            header.data = @"数据解析错误";
        }
    }
    return ret;
}
//==================================================================================
//==================================================================================
#pragma mark -
#pragma mark === 覆盖父类方法，添加通用参数 ===
#pragma mark -
- (NetworkHeader*)addGetOperation:(NSString *)urlStr ReqType:(NSUInteger)reqType Delegate:(id)delg {
    NSMutableString *ms = [NSMutableString string];
    [ms setString:urlStr];
    NSString *murl = [ms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"QueryUrl:%@", ms);
    return [super addGetOperation:murl
                          ReqType:reqType
                         Delegate:delg];
}

- (NetworkHeader*)addPostOperation:(NSString *)urlStr ReqType:(NSUInteger)reqType PostDatas:(NSDictionary *)postDatas Delegate:(id)delg {
    NSMutableString *ms = [NSMutableString string];
    [ms setString:urlStr];
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    [md setDictionary:postDatas];
    NSString *murl = [ms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Parameter:%@", md);
    return [super addPostOperation:murl
                           ReqType:reqType
                         PostDatas:md
                          Delegate:delg];
}

@end
