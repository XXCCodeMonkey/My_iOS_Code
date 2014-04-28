//
//  Common.m
//  iAPHD
//
//  Created by 曹兴星 on 13-6-9.
//  Copyright (c) 2013年 曹兴星. All rights reserved.
//

#import "Common.h"
#import <MessageUI/MFMessageComposeViewController.h>
#include <sys/socket.h> 
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "GetIPAddress.h"

#define HASH_MAX_LENGTH 2*1024	//最大字符串长度(字节)
typedef unsigned int DWORD;		//类型定义
static DWORD cryptTable[0x500];		//哈希表
static bool HASH_TABLE_INITED = false;
static void prepareCryptTable();
DWORD HashString(const char *lpszFileName,DWORD dwCryptIndex);

@implementation Common

/*==============================公用方法===========================*/

#pragma -mark 系统相关
//获取当前软件版本
+ (NSString *)getCurrentAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

//获取当前软件名称
+ (NSString *)getCurrentAppName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return app_Name;
}

//拨打电话
+ (BOOL)makeCall:(NSString *)telno {
    if(!isiPhone){
        Alert(@"您的设备不是iPhone，不好拨打电话");
        return NO;
    }
    if(![Common isMobileNumber:telno]){
        Alert(@"电话号码不合法");
        return NO;
    }
    NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", telno]];
    [[UIApplication sharedApplication] openURL:phoneNumberURL];
    return YES;
}

//给指定的人发指定的短信
+ (void)sendSMS:(NSString *)message recipientList:(NSArray *)recipients del:(id)ctrl{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]){
        //短信内容
        controller.body = message;
        //指定联系人
        controller.recipients = recipients;
        //指定代理类
        controller.messageComposeDelegate = ctrl;
        [ctrl presentModalViewController:controller animated:YES];
    } else {
        Alert(@"该设备不支持发短信");
    }
}

//获取设备的mac地址
+ (NSString *)getMacAddress {
	int                    mib[6];
	size_t                 len;
	char                   *buf;
	unsigned char          *ptr;
	struct if_msghdr       *ifm;
	struct sockaddr_dl     *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}
	
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
		printf("Error: sysctl, take 2");
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
}

//获取ip地址
+ (NSString *)getIPAddress {
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    return [NSString stringWithFormat:@"%s", ip_names[1]];
}

//获取documents路径的文件
+ (NSString *)getOrSetDocumentsDirectrybyFileName:(NSString *)fileNameStr{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentD = [paths objectAtIndex:0];
    NSString *configFile = [documentD stringByAppendingPathComponent:fileNameStr];
    return configFile;
}

//时间相关
#pragma -mark 时间相关
//获取系统当前时间
+ (NSString *)getCurrentTimeFormat:(NSString *)formatStr {
    /* YYYY-MM-dd hh:mm:ss
       YY-MM-dd-hh-mm-ss
     时间格式
     */
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:formatStr];
    NSString *ret = [formatter stringFromDate:[NSDate date]];
    return ret;
}

//根据时间戳转换成时间
+ (NSString *)timeIntervalSince1970:(NSTimeInterval)secs Format:(NSString*)formatStr {
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:secs];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:formatStr];
    NSString *ret = [formatter stringFromDate:date];
    return ret;
}

//正则匹配
#pragma -mark 正则匹配
//电话号码合法性检查
+ (BOOL)isMobileNumber:(NSString *)mobileNum {
    //入参检查
    NSRange range = [mobileNum rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        [mobileNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,181,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     * 增加：14开头的号码
     */
    NSString * MOBILE = @"^1(3[0-9]|4[0-9]|5[0-35-9]|8[0125-9])\\d{8}$";
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:mobileNum])|| ([regextestcm evaluateWithObject:mobileNum])|| ([regextestct evaluateWithObject:mobileNum])|| ([regextestcu evaluateWithObject:mobileNum]) || ([regextestphs evaluateWithObject:mobileNum])) {
        return YES;
    } else {
        return NO;
    }
}

//邮箱合法性
+ (BOOL)isEmail:(NSString *)emailAddress {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

//是否纯数字
+ (BOOL)isAllNum:(NSString *)string {
    if([Common isEmptyString:string]){
        return NO;
    }
    unichar c;
    for (int i = 0; i < string.length; i++) {
        c = [string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}


//加密解密
#pragma -mark 加密解密


//字符串处理
#pragma -mark 字符串处理
//过滤HTML标签
+ (NSString *)flattenHTML:(NSString *)html {
	if (!html) {
		return nil;
	}
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    NSString *ret = [NSString stringWithString:html];
    
    while (![theScanner isAtEnd]) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        ret = [ret stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text]
                                             withString:@" "];
        //过滤&nbsp;
        ret = [ret stringByReplacingOccurrencesOfString:@"&nbsp;"
                                             withString:@" "];
    }
    return ret;
}

//字符串为空检查
+ (BOOL)isEmptyString:(NSString *)sourceStr {
    if ([sourceStr isEqual:@"null"]) {
        return YES;
    }
    if ([sourceStr isEqual:@""]) {
        return YES;
    }
    if (sourceStr == nil) {
        return YES;
    }
    if (sourceStr == NULL) {
        return YES;
    }
    if ((NSNull *)sourceStr == [NSNull null]) {
        return YES;
    }
    if (sourceStr.length == 0) {
        return YES;
    }
    return NO;
}

//哈希字符串
+ (NSString*)hashString:(NSString*)str {
    if (!str) {
        return nil;
    }
	char buffer[HASH_MAX_LENGTH];
	memset(buffer, 0, sizeof(char) * HASH_MAX_LENGTH);
	const char *buffer2 = [str UTF8String];
	DWORD hashCode = HashString(buffer2, 1);
	return [NSString stringWithFormat:@"%u", hashCode];
}

//生成哈希表
static void prepareCryptTable() {
	DWORD dwHih, dwLow,seed = 0x00100001,index1 = 0,index2 = 0, i;
	for(index1 = 0; index1 < 0x100; index1++) {
		for(index2 = index1, i = 0; i < 5; i++, index2 += 0x100) {
			seed = (seed * 125 + 3) % 0x2AAAAB;
			dwHih= (seed & 0xFFFF) << 0x10;
			seed = (seed * 125 + 3) % 0x2AAAAB;
			dwLow= (seed & 0xFFFF);
			cryptTable[index2] = (dwHih| dwLow);
		}
	}
}

//生成HASH值
DWORD HashString(const char *lpszFileName, DWORD dwCryptIndex) {
	if (!HASH_TABLE_INITED) {
		prepareCryptTable();
		HASH_TABLE_INITED = true;
	}
	unsigned char *key = (unsigned char *)lpszFileName;
	DWORD seed1 = 0x7FED7FED, seed2 = 0xEEEEEEEE;
	int ch;
	while(*key != 0){
		ch = *key++;
		seed1 = cryptTable[(dwCryptIndex<< 8) + ch] ^ (seed1 + seed2);
		seed2 = ch + seed1 + seed2 + (seed2 << 5) + 3;
	}
	return seed1;
}

//UI相关
#pragma -mark UI相关
//去除UITableView多余分割线
+ (void)removeExtraCellLines:(UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = ClearColor;
    [tableView setTableFooterView:view];
}

//压缩成指定大小的图片
+ (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize SourceImage:(UIImage*)sourceImage CropType:(NSUInteger)cropType {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO && cropType != IMAGE_SCALE_TYPE_FILL)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
		if (cropType == IMAGE_SCALE_TYPE_FITMAX)
		{
			if (widthFactor > heightFactor)
				scaleFactor = widthFactor; // scale to fit height
			else
				scaleFactor = heightFactor; // scale to fit width
		}
        else if (cropType == IMAGE_SCALE_TYPE_FITMIN)
		{
			if (widthFactor < heightFactor)
				scaleFactor = widthFactor; // scale to fit height
			else
				scaleFactor = heightFactor; // scale to fit width
		}
		
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight)); // this will crop
    
    CGRect thumbnailRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight) {
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

//生成圆角图片
+ (UIImage *) createRoundedRectImage:(UIImage*)image size:(CGSize)size {
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGBitmapByteOrderDefault);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, 10, 10);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultImg = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return resultImg;
}

//生成BarItem
+ (UIBarButtonItem *)createBarItemWithTitle:(NSString *)name target:(id)target Selector:(SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 55, 31);
    [btn addTarget:target
            action:sel
  forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:Image(@"btn_navi_normal.png")
                   forState:UIControlStateNormal];
    [btn setTitle:name
         forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor]
              forState:UIControlStateNormal];
    [btn.titleLabel setFont:Font(16.0)];
    [btn sizeToFit];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return barItem;
}

//生成自己绘制的图片
#define HIRESDEVICE (((int)rintf([[[UIScreen mainScreen] currentMode] size].width/[[UIScreen mainScreen] bounds].size.width ) > 1))

+ (CGImageRef)drawImageSize:(CGSize)size {
    CGFloat imageScale = (CGFloat)1.0;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if (HIRESDEVICE) {
        imageScale = (CGFloat)2.0;
    }
    // Create a bitmap graphics context of the given size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width * imageScale, height * imageScale, 8, 0, colorSpace, kCGBitmapByteOrderDefault);
    
    // Draw ...
    CGContextSetRGBFillColor(context, 160.0, 198.0, 231.0, 1.0);
    
    // Get your image
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRef resImage = cgImage;
    CGImageRelease(cgImage);
    return resImage;
}

@end
