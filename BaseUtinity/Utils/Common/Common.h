//
//  Common.h
//  iAPHD
//
//  Created by 曹兴星 on 13-6-9.
//  Copyright (c) 2013年 曹兴星. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IMAGE_SCALE_TYPE_FITMAX  0
#define IMAGE_SCALE_TYPE_FITMIN  1
#define IMAGE_SCALE_TYPE_FILL    2

@interface Common : NSObject
/*==============================公用方法============================================*/


/*==============================系统相关===========================*/
//获取当前软件版本
+ (NSString *)getCurrentAppVersion;
//获取当前软件名称
+ (NSString *)getCurrentAppName;
//拨打电话
+ (BOOL)makeCall:(NSString *)telno;
//发送短信
+ (void)sendSMS:(NSString *)message recipientList:(NSArray *)recipients del:(id)ctrl;
//获取mac地址
+ (NSString *)getMacAddress;
//获取ip地址
+ (NSString *)getIPAddress;
//获取documents目录的文件
+ (NSString *)getOrSetDocumentsDirectrybyFileName:(NSString *)fileNameStr;

/*==============================时间相关===========================*/
//获取系统当前时间
+ (NSString *)getCurrentTimeFormat:(NSString *)formatStr;
//根据时间戳转换成时间
+ (NSString *)timeIntervalSince1970:(NSTimeInterval)secs Format:(NSString*)formatStr;

/*==============================正则匹配===========================*/
//手机号码的合法性
+ (BOOL)isMobileNumber:(NSString *)mobileNum;
//邮箱的合法性
+ (BOOL)isEmail:(NSString *)emailAddress;
//检测是否是纯数字
+ (BOOL)isAllNum:(NSString *)string;
/*==============================加密解密===========================*/

/*==============================字符串处理===========================*/
//检查是否空字符串
+ (BOOL)isEmptyString:(NSString *)sourceStr;
//哈希字符串
+ (NSString*)hashString:(NSString*)str;
//过滤html标签
+ (NSString *)flattenHTML:(NSString *)html;

/*==============================UI相关===========================*/
//去除UITableView多余分割线
+ (void)removeExtraCellLines:(UITableView *)tableView;
//压缩原图片成指定大小
+ (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
                                  SourceImage:(UIImage *)sourceImage
                                     CropType:(NSUInteger)cropType;
//生成圆角图片
+ (UIImage *)createRoundedRectImage:(UIImage*)image size:(CGSize)size;

//生成BarItem
+ (UIBarButtonItem *)createBarItemWithTitle:(NSString *)name target:(id)target Selector:(SEL)sel;

//生成绘制图片
+ (CGImageRef)drawImageSize:(CGSize)size;

@end
