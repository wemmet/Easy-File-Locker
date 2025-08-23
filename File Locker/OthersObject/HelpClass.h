//
//  HelpClass.h
//  File Locker
//
//  Created by MAC_RD on 2025/2/5.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
NS_ASSUME_NONNULL_BEGIN

@interface HelpClass : NSObject

typedef void(^Completion)(NSArray *filePaths);
typedef void(^Failure)(void);

@property (strong, nonatomic) NSMutableArray * disklist;
+ (instancetype)shared;
+ (float)min:(float)num1 num2:(float)num2;
+ (float)max:(float)num1 num2:(float)num2;
+ (Reachability *)reachability;
+ (NSString *)getAppRootFolder;
+ (NSString *)getDeviceName;
+ (id)downloadMacheJSON:(NSString *)url;
+ (NSString *)convertToJsonData:(NSDictionary *) dict;

+ (void)uploadjsonFile:(NSString *)fileName jsonContent:(NSString *)jsonContent;

- (void)canOpenGcpFile:(NSString *)code d:(DWORD *)d
              fileGuid:(NSString *)fileGuid
            gemPasword:(NSString *)gemPasword
               gemPath:(NSString *)gemPath
                  hobj:(HNdfObject)hobj
              supperVC:(UIViewController *)supperVC;
- (void)canOpenGemFile:(DWORD *)d
              fileGuid:(NSString *)fileGuid
               gemPath:(NSString *)gemPath
              supperVC:(UIViewController *)supperVC;
+ (void)openpdfWithPath:(NSString *)path width:(float)width pageIndex:(NSInteger)pageIndex completed:(void(^)(int rotation,int count,UIImage *image))completed;
- (void)readPdfForIndex:(int)m pdfIumObj:(IPDFium _Nullable )pdfIumObj ptSize:(TPointsSizeF *)ptSize ret:(int *)ret width:(float)width completed:(void(^)(int rotation,int count,UIImage *image))completed;
+ (void)openPdf:(HNdfObject)gem_hobj temppath:(NSString *)temppath width:(float)width pdfImageIndex:(NSInteger)pdfImageIndex completed:(void(^)(int rotation,int count,UIImage *image))completed;
- (UIViewController *)DecodeLicenceCode:(HNdfObject)hobj
                  machine:(NSString *)machine
                  licence:(NSString *)szLicence
                     path:(NSString *)gemPath
             passwordText:(NSString *)passwordText
                questions:(NSMutableArray *)questionParams
                     guid:(NSString *)guid
                 supperVC:(UIViewController *)supperVC;
- (void)openGemForPath:(NSString *)gemPath supperVC:(UIViewController *)supperVC;

+ (NSString *)stringForAllFileSize:(UInt64)fileSize;
+ (float)folderSizeAtPath:(NSString*)folderPath;
#pragma mark 读取文件大小
+ (long long) fileSizeAtPath:(NSString*) filePath;

+ (UIImage *)noThumbImage:(int)nFileType;
+ (void)unArchive: (NSString *)filePath andPassword:(NSString*)password destinationPath:(NSString *)destPath completionBlock:(Completion) completionBlock failureBlock:(Failure) failureBlock;
+ (void)openSite_Zip:(NSString * _Nonnull)zipPath outputPath:(NSString *)outputPath temppath:(NSString *)temppath vc:(UIViewController *)vc isInGem:(BOOL)isInGem;
//MARK: 读取SITE文件导出到临时目录
+ (void )getFileData:(NSString *)filePath gem_hobj:(HNdfObject)gem_hobj output:(NSString *)outputPath;
+ (NSString *)getFileMD5Code:(NSString *)path;
+ (NSString *)utf8ToString:(const char *)utf8Content;
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;
+ (NSString *)timeFormatted:(int)totalSeconds;

+ (UIImage *)getWaterMarkImage: (UIImage *)originalImage andTitle: (NSString *)title andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor isThumb:(BOOL)isThumb;

+ (UIColor *)colorWithColors:(NSArray *)colors bounds:(CGRect)bounds;

+ (UIImage *)getThumbImageWithPath:(NSString *)path;

//获取字符串的文字域的高
+ (float)heightForString:(NSString *)value andWidth:(float)width fontSize:(float)fontSize;

+ (NSString *)GetMD5WithContent:(NSString *)content;
+ (BOOL)OpenZip:(NSString*)zipPath  unzipto:(NSString*)_unzipto;
+ (NSString *)getDocumentsDir;
+ (NSString *)getWebUploaderFolder;
+ (UIImage *)disablePreImage;
@end

NS_ASSUME_NONNULL_END
