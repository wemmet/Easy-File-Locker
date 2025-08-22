#ifndef PrefixHeader_h
#define PrefixHeader_h

#define Localizable_LF_Size_Bytes                                   @"%lld Bytes"
#define Localizable_LF_Size_K                                       @"%lld K"
#define Localizable_LF_Size_M                                       @"%lld.%lld M"
#define Localizable_LF_Size_G                                       @"%lld.%d G"
#define Localizable_LF_All_Size_M                                   @"%lld.%lld M"
#define Localizable_LF_All_Size_G                                   @"%lld.%lld G"

#define Kboundary @"----282861610524488"  //分隔符
#define KnewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

#define TC_STR(x) ([x isKindOfClass:[NSNull class]] ? @"" : (x == nil ? @"" : ([x isEqualToString:@"<null>"] ? @"" : x)))
#define kDirectory [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject]
#define kGSG_CDWebUploaderFolder [kDirectory stringByAppendingPathComponent:@"Documents/GCDWebUploader_Bundle"]

#define kWIDTH [UIScreen mainScreen].bounds.size.width
#define kHEIGHT [UIScreen mainScreen].bounds.size.height
#define SafeAreaTopHeight ((kHEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"] ? 88 : 64)
#define SafeAreaBottomHeight ((kHEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"]  ? 30 : 0)
#define kDWCPType 4
#define kDWFlag 7

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kDocumentsFolder [NSString stringWithFormat:@"%@", [(NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)) lastObject]]

#define kDocumentsDir    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#define kGcpinvalidsnJson_Url @"https://gilisoft.xyz/api2022/copyprotect/gcpinvalidsn/gcpinvalidsn.json"

#endif
