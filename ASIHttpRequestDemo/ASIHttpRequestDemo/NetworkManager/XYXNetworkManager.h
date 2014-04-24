/*!
 @header 这里的信息应该与该源代码文件的名字一致
 @abstract 关于这个源代码文件的一些基本描述
 @author Kevin Wu (作者信息)
 @version 1.00 2012/01/20 Creation (此文档的版本信息)
 */

#import "NetworkManager.h"

/*!
 @enum
 @abstract 关于这个enum的一些基本信息
 */
enum NETWORK_HEADER_REQ_TYPES {
    REQ_TYPE_GET_INFOMATION = 100,
};

@interface XYXNetworkManager : NetworkManager

- (NetworkHeader *)Network_API_CommitMyInfomation:(NSDictionary *)data
                                             Delg:(id<NetworkProtocol>)delg;

@end
