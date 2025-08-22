//
//  HelpClass.m
//  File Locker
//
//  Created by MAC_RD on 2025/2/5.
//
#import "NdfCommon.h"
#import "NdfRead.h"
#import "KanPlayer.h"
#import "FileEDcrypt.h"
#import "libpdfium.h"

#import "HelpClass.h"
#import "PrefixHeader.h"
#import "Reachability.h"
#import "UIWindow+Extension.h"
#import "AlertView.h"
#import "DownTool.h"
#import "InPasswordViewController.h"
#import "File_Locker-Swift.h"
#import "SVProgressHUD.h"
#import "PrefixHeader.h"

#import "SARUnArchiveANY.h"
#import <dispatch/dispatch.h>
#import <Photos/Photos.h>
#include "MD5.h"
//#import "SSZipArchive.h"
//#import <ZipArchive/ZipArchive.h>

#define IMAGE_MAX_SIZE_WIDTH 1080
#define IMAGE_MAX_SIZE_HEIGHT 1080
#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

#define SIZE_LINE        1024
#define SIZE_FILENAME    256

#define BMP_SIZE   320*480*3
#define BMP_HEADER_LENGTH 54

#define min(x, y)        (x <= y) ? x : y
typedef short WORD;
typedef uint32_t DWORD;
typedef int32_t LONG;

#pragma pack(1)
typedef struct tagBITMAPFILEHEADER {
        WORD    bfType;
        DWORD   bfSize;
        WORD    bfReserved1;
        WORD    bfReserved2;
        DWORD   bfOffBits;
} BITMAPFILEHEADER, *PBITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER{
        DWORD      biSize;
        LONG       biWidth;
        LONG       biHeight;
        WORD       biPlanes;
        WORD       biBitCount;
        DWORD      biCompression;
        DWORD      biSizeImage;
        LONG       biXPelsPerMeter;
        LONG       biYPelsPerMeter;
        DWORD      biClrUsed;
        DWORD      biClrImportant;
} BITMAPINFOHEADER, *PBITMAPINFOHEADER;
#pragma pack()

BOOL SaveBmp (uint8_t* pData, int width, int height,int bpp,char *filename)
{
    //char buf[5] = {0};

    BITMAPFILEHEADER bmpheader = {0};
    BITMAPINFOHEADER bmpinfo = {0};
    FILE *fp;
    size_t nWrited = 0;
    size_t nWriting = 0;

    //int size1 = sizeof(BITMAPFILEHEADER);
    //int size2 = sizeof(BITMAPINFOHEADER);

    if((fp=fopen(filename,"wb+")) == NULL )
        return FALSE;

    bmpheader.bfType = 0x4d42;
    bmpheader.bfReserved1 = 0;
    bmpheader.bfReserved2 = 0;
    bmpheader.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
    bmpheader.bfSize = bmpheader.bfOffBits + width*height*bpp/8;

    bmpinfo.biSize = sizeof(BITMAPINFOHEADER);
    bmpinfo.biWidth = width;
    bmpinfo.biHeight = height;
    bmpinfo.biPlanes = 1;
    bmpinfo.biBitCount = bpp;
    bmpinfo.biCompression = 0;//BI_RGB;
    bmpinfo.biSizeImage = width*height*4;//(width*bpp+31)/32*4*height;
    bmpinfo.biXPelsPerMeter = 100;
    bmpinfo.biYPelsPerMeter = 100;
    bmpinfo.biClrUsed = 0;
    bmpinfo.biClrImportant = 0;
    nWrited = fwrite (&bmpheader, sizeof(bmpheader), 1, fp);
    if (nWrited < 1)
    {
        fclose(fp);
        return FALSE;
    }

    nWrited = fwrite (&bmpinfo, sizeof(bmpinfo), 1, fp);
    if (nWrited < 1)
    {
        fclose(fp);
        return FALSE;
    }
    nWriting = width*height*bpp/8;
    nWrited = fwrite (pData, nWriting, 1, fp);
    if (nWrited < 1)
    {
        fclose(fp);
        return FALSE;
    }
    fclose(fp);
    
    return TRUE;
}
@interface HelpClass()<NSURLSessionDelegate>{
    VIDEO_PLAYER_CONFIG _playCfg;
    DRM_USB_COPY_CONFIG _gcpPlayCfg;
    DRM_USER_CONTROL_PARAM _user_Play_Param;
    NSString *_gcpPlayCfg_szMache;
    BOOL _gcpPlayCfg_disablePlay;
    
    
}
@property(nonatomic,assign)HNdfObject hobj;
@property(nonatomic,assign)HNdfFile hFile;
@property(nonatomic,assign)IPDFium pdfIumObj;
@property(nonatomic,assign)UInt8 *pdfBuff;
@property(nonatomic,assign)TPointsSizeF ptSize;

@property(nonatomic,assign)int pdfRet;
@property(nonatomic,assign)int pdfCount;
@property(nonatomic,assign)int pdfImageIndex;
@property(nonatomic,strong)NSURLSession *session;
@end
@implementation HelpClass
+ (instancetype)shared
{
    static HelpClass *singleOjbect = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleOjbect = [[self alloc] init];
    });
    return singleOjbect;
}

+ (float)min:(float)num1 num2:(float)num2{
    return MIN(num1, num2);
}
+ (float)max:(float)num1 num2:(float)num2{
    return MAX(num1, num2);
}

+ (Reachability *)reachability{
    Reachability *lexiu = [Reachability reachabilityForInternetConnection];
    return lexiu;
}

+ (void)openPdf:(HNdfObject)gem_hobj temppath:(NSString *)temppath width:(float)width pdfImageIndex:(NSInteger)pdfImageIndex completed:(void(^)(int rotation,int count,UIImage *image))completed{
    [[HelpClass shared] openPdf:gem_hobj temppath:temppath width:width pdfImageIndex:pdfImageIndex completed:completed];
}
- (void)openPdf:(HNdfObject)gem_hobj temppath:(NSString *)temppath width:(float)width pdfImageIndex:(NSInteger)pdfImageIndex completed:(void(^)(int rotation,int count,UIImage *image))completed {
    
    width = MIN(width, 3000);
    NSLog(@"line:%d",__LINE__);
    if(!gem_hobj){
        NSLog(@" func :%s line:%d error:%d",__func__,__LINE__,NDF_GetLastError());
        if(completed){
            completed(0,[HelpClass shared].pdfCount,nil);
        }
        return;
    }
    [HelpClass shared].hFile = NDF_OpenFile(gem_hobj, [temppath UTF8String]);
    if(![HelpClass shared].hFile && temppath != nil){
        NSLog(@" func :%s line:%d error",__func__,__LINE__);
        NDF_Close(gem_hobj);
        if(completed){
            completed(0,[HelpClass shared].pdfCount,nil);
        }
        return;
    }
    int64_t nSize = 0;
    if([HelpClass shared].pdfBuff){
        //NDF_Free_Buff(_pdfBuff);
    }
    [HelpClass shared].pdfBuff = 0;
    DWORD ret = NDF_ReadFile(gem_hobj, [HelpClass shared].hFile, nil, &nSize);
    [HelpClass shared].pdfBuff = malloc(nSize);
    if (![HelpClass shared].pdfBuff)
    {
        NSLog(@"malloc pdfBuff failed");
        NDF_CloseFile(gem_hobj,[HelpClass shared].hFile);
        NDF_Free_Buff([HelpClass shared].pdfBuff);
        NDF_Close(gem_hobj);
        if(completed){
            completed(0,[HelpClass shared].pdfCount,nil);
        }
        return;
    }
    
    DWORD dwBlockSize = NDF_GetFileEncryptBlockSize(gem_hobj, [HelpClass shared].hFile);
    
    if (0 == dwBlockSize)
    {
        ret = NDF_ReadFile(gem_hobj, [HelpClass shared].hFile, [HelpClass shared].pdfBuff, &nSize);
        if(ret != 0){
            NSLog(@"NDF_ReadFile error:%d",ret);
            NDF_Free_Buff([HelpClass shared].pdfBuff);
            NDF_CloseFile(gem_hobj,[HelpClass shared].hFile);
            //NDF_Close(gem_hobj);
            if(completed){
                completed(0,[HelpClass shared].pdfCount,nil);
            }
            return;
        }
    }
    else
    {
        int64_t nReadedSize = 0;
        int64_t nReadSize = (int64_t)dwBlockSize;
        while (nReadedSize <= nSize)
        {
            if (nSize - nReadedSize < dwBlockSize)
                nReadSize = (int)(nSize - nReadedSize);
            
            ret = NDF_ReadFile(gem_hobj, [HelpClass shared].hFile, [HelpClass shared].pdfBuff + nReadedSize, &nReadSize);
            if(ret != 0)
            {
                NSLog(@"NDF_ReadFile error:%d",ret);
                NDF_Free_Buff([HelpClass shared].pdfBuff);
                if(completed){
                    completed(0,[HelpClass shared].pdfCount,nil);
                }
                return;
            }

            nReadedSize += nReadSize;
            if (nReadSize < dwBlockSize)
                break;
        }
    }
    
    if([HelpClass shared].pdfIumObj){
        PDF_Free([HelpClass shared].pdfIumObj);
        [HelpClass shared].pdfIumObj = nil;
    }
    PDF_Create(PDFIUM_VERSION,&_pdfIumObj);
    //加载pdf(内存模式)
    int nPDFLoadStatus = PDF_LoadFromMemory([HelpClass shared].pdfIumObj,[HelpClass shared].pdfBuff,nSize,nil);
    if (nPDFLoadStatus != 0)
    {
        NDF_Free_Buff([HelpClass shared].pdfBuff);
        NDF_CloseFile(gem_hobj,[HelpClass shared].hFile);
        NDF_Close(gem_hobj);
        if(completed){
            completed(0,[HelpClass shared].pdfCount,nil);
        }
        return;
    }
    
    [HelpClass shared].pdfRet = 0;
    //获取页面个数
    [HelpClass shared].pdfCount = PDF_GetPageCount([HelpClass shared].pdfIumObj);
    TPointsSizeF ptSize = {0};
    [HelpClass shared].ptSize = ptSize;
    
    [[HelpClass shared] readPdfForIndex:pdfImageIndex pdfIumObj:[HelpClass shared].pdfIumObj ptSize:&_ptSize ret:&_pdfRet width:width completed:completed];
    
}

- (void)readPdfForIndex:(int)m pdfIumObj:(IPDFium _Nullable )pdfIumObj ptSize:(TPointsSizeF *)ptSize ret:(int *)ret width:(float)width completed:(void(^)(int rotation,int count,UIImage *image))completed {
    
    IPDFPage pdfPageItem = nil;
    
    //页面的画布数据大小
    PDF_GetPageSize(pdfIumObj,m,ptSize);
    
    //获取页面的信息
    PDF_GetPage(pdfIumObj,m,&pdfPageItem);
    if(!pdfPageItem){
        NSLog(@"获取分页数据出错");
        if(completed){
            completed(0,_pdfCount,nil);
        }
        return ;
    }
    TRect pageRect={0};
    TRect viewPort={0};
    IPDFBitmap pdfPageBitmap = nil;
    if(ptSize->cx == 0 && ptSize->cy ==0){
        ptSize->cx = ptSize->cx * MIN(MAX(1, 1), 3);
        ptSize->cy = ptSize->cy * MIN(MAX(1, 1), 3);
        
    }else{
        float value = ptSize->cy/ptSize->cx;
        ptSize->cx = width;// * MIN(MAX(_gemShowImageView.scaleValue, 1), 3);
        ptSize->cy =  value * width;// * MIN(MAX(_gemShowImageView.scaleValue, 1), 3);
        
    }
    
    
    viewPort.Left = 0;
    viewPort.Top = 0;
    viewPort.Right = ptSize->cx;
    viewPort.Bottom = ptSize->cy;
    
    pageRect.Left = 0;
    pageRect.Top = 0;
    pageRect.Right = viewPort.Right - 0;
    pageRect.Bottom = viewPort.Bottom;
    
    //获取页面位图数据
    *ret = PDFPage_GetBitmap(pdfPageItem,&pageRect,&viewPort,0,0,&pdfPageBitmap);
    int rotation = PDFPage_GetRotation(pdfPageItem);
    
    TPDFBitmapInfo bitmapinfo = {0};
    *ret = PDFBitmap_GetInfo(pdfPageBitmap,&bitmapinfo);
    _pdfCount = PDF_GetPageCount(pdfIumObj);
    UIImage *image = nil;
    if (bitmapinfo.Width > 0 && bitmapinfo.Height >0 && bitmapinfo.Buffer > 0)
    {
        //保存数据进行查看
        NSString *str = [kDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Paid_pdf%d.bmp",m]];
        SaveBmp(bitmapinfo.Buffer,bitmapinfo.Width,bitmapinfo.Height,32, [str UTF8String]);

        NSLog(@"line:%d",__LINE__);
        NSData *dat = [NSData dataWithContentsOfFile:str];
        image = [[UIImage alloc] initWithData:dat];

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImageView *sourceView = [UIImageView new];
        sourceView.contentMode = UIViewContentModeScaleAspectFit;
        sourceView.userInteractionEnabled = YES;
        sourceView.layer.masksToBounds = YES;
        sourceView.image = image;
        sourceView.transform = CGAffineTransformMakeScale(1.0,-1.0);
        sourceView.frame = view.bounds;
        [view addSubview:sourceView];
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 1.0);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:str error:&error];

        dat = nil;
        NSLog(@"line:%d",__LINE__);
    }
    PDFBitmap_Free(pdfPageBitmap);
    PDFPage_Free(pdfPageItem);
    if(completed){
        completed(rotation,_pdfCount,image);
    }
}
+ (void)openpdfWithPath:(NSString *)path width:(float)width pageIndex:(NSInteger)pageIndex completed:(void(^)(int rotation,int count,UIImage *image))completed{
    [[HelpClass shared] openpdfWithPath:path width:width pageIndex:pageIndex completed:completed];
}
- (void)openpdfWithPath:(NSString *)path width:(float)width pageIndex:(NSInteger)pageIndex completed:(void(^)(int rotation,int count,UIImage *image))completed {
    IPDFium pdfIumObj = nil;
    PDF_Create(PDFIUM_VERSION,&pdfIumObj);
    
    width = MIN(width, 3000);
    
    NSString *strPath =path;
    uint8_t *pPDFMemBuff = NULL;
    int nPDFMemSize = 0;
    
    //从文件中加载数据到内存
    //如果是gem文件，需要把选中的文件全部解密到一块内存中
    char* szPath = [strPath UTF8String];
    int fHanle = open(szPath, O_RDONLY, 0666);
    if (fHanle > 0)
    {
        pPDFMemBuff = malloc(10000000);
        if (pPDFMemBuff)
        {
            nPDFMemSize = read(fHanle, pPDFMemBuff, 10000000);
        }
        close(fHanle);
    }
    
    
    //加载pdf(内存模式)
    int nPDFLoadStatus = 0;
    nPDFLoadStatus =PDF_LoadFromFile(pdfIumObj, szPath, nil);
    if (nPDFLoadStatus != 0)
    {
        return;
    }
    
    //获取页面个数
    TPointsSizeF ptSize = {0};
    int _pdfRet = 0;
    [self readPdfForIndex:pageIndex pdfIumObj:pdfIumObj ptSize:&ptSize ret:&_pdfRet width:width completed:completed];
}

- (void)canOpenGcpFile:(NSString *)code 
                     d:(DWORD *)d
              fileGuid:(NSString *)fileGuid 
            gemPasword:(NSString *)gemPasword
               gemPath:(NSString *)gemPath
                  hobj:(HNdfObject)hobj
              supperVC:(UIViewController *)supperVC
{
    if(_gcpPlayCfg.nBindType){
        Reachability *lexiu = [Reachability reachabilityForInternetConnection];
        if([lexiu currentReachabilityStatus] == ReachabilityStatus_NotReachable){
            [UIWindow showTips:NSLocalizedString(@"checkNetwork", nil)];
            return;
        }
        //
        char szMD5Code[NDF_MAX_PATH] = {0};
        *d = GetMD5Code((char *)[gemPath UTF8String], szMD5Code);
        
        NSString *pathMd5Code = [NSString stringWithUTF8String:szMD5Code];
        NSString *url = [NSString stringWithFormat:  @"https://gilisoft.xyz/api2022/copyprotect/gcpfingerprint/%@.json",pathMd5Code];
        NSDictionary* result = [HelpClass downloadMacheJSON:url];
        if(!result){
            NSString *message = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"bingAlertMessage",nil),[HelpClass getDeviceName],NSLocalizedString(@"bingAlertMessage1",nil)];
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"strInfoHit", nil) message:message preferredStyle: UIAlertControllerStyleAlert];
            __block typeof(self) bself = self;
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                bself->_gcpPlayCfg_szMache = code;
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:code,@"pc_fingerprint", nil];
                NSString *jsonContent = [HelpClass convertToJsonData:dic];
                NSString *fileName = [NSString stringWithFormat:@"%@.json",pathMd5Code];
                
                NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:fileName];
                if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
                    [[NSFileManager defaultManager] createFileAtPath:path contents:[jsonContent dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
                }
                bself->_gcpPlayCfg_disablePlay = NO;
                [HelpClass uploadjsonFile:fileName jsonContent:jsonContent];
                
                [self DecodeLicenceCode:hobj machine:code licence:nil path:gemPath passwordText:gemPasword questions:nil guid:fileGuid supperVC:(UIViewController *)supperVC];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
        }else{
            if(![result[@"pc_fingerprint"] isEqualToString:code]){
                _gcpPlayCfg_disablePlay = YES;
                [UIWindow showTips:NSLocalizedString(@"RegisterMessage", nil)];
                return;
            }
            [self DecodeLicenceCode:hobj machine:code licence:nil path:gemPath passwordText:gemPasword questions:nil guid:fileGuid supperVC:(UIViewController *)supperVC];
        }
    }
    else{
        [self DecodeLicenceCode:hobj machine:code licence:nil path:gemPath passwordText:gemPasword questions:nil guid:fileGuid supperVC:supperVC];
    }
}

- (void)canOpenGemFile:(DWORD *)d fileGuid:(NSString *)fileGuid gemPath:(NSString *)gemPath supperVC:(UIViewController *)supperVC
{
    char szMachineCode[LEN_NDF_DES] = {0};
    
    __block NSString *passwordText = @"";
    DWORD dwIsExitPW = 0;
    HNdfObject hobj = NULL;
    
    ANTICOPYQA *pContextList = nil;
    NSMutableArray *questionParams = [NSMutableArray new];
    
    if(_playCfg.nAntiCopyNum > 0)
    {
        pContextList = malloc(_playCfg.nAntiCopyNum*sizeof(ANTICOPYQA));
        if (pContextList)
        {
            memset(pContextList,0,_playCfg.nAntiCopyNum*sizeof(ANTICOPYQA));
            
            *d = NDF_GetAntiCopyQAContext([gemPath UTF8String], pContextList);
            if(*d !=0){
                NSLog(@" func :%s line:%d error:%d",__func__,__LINE__,*d);
                return;
            }
            
            for(int i = 0;i<_playCfg.nAntiCopyNum;i++) {
                NSMutableDictionary *params = [NSMutableDictionary new];
                params[@"nTime"] = [NSNumber numberWithInt:pContextList[i].nTime];
                params[@"szAnswer"] = [NSString stringWithUTF8String:pContextList[i].szAnswer];
                params[@"szQueation"] = [NSString stringWithUTF8String:pContextList[i].szQueation];
                params[@"showed"] = [NSNumber numberWithBool:NO];
                [questionParams addObject:params];
            }
            free(pContextList);
        }
    }
    
    
    *d = GetMachineCode(_playCfg.dwCPFileType, _playCfg.dwMachineCodeStatus, szMachineCode);
    if(*d !=0){
        NSLog(@" func :%s line:%d error:%d",__func__,__LINE__,*d);
        return;
    }

    NSMutableDictionary *info = nil;
    NSString *resultPath = nil;
    
    if(_playCfg.dwMachineCodeStatus == 8)
    {
        for (int i = 0; i<_disklist.count; i++)
        {
            if(![_disklist[i][@"isUSB"] boolValue])
            {
                resultPath = [[HelpClass getAppRootFolder] stringByAppendingPathComponent:@"GemReader.jpg"];
            }
            else
            {
                resultPath = [_disklist[i][@"path"] stringByAppendingPathComponent:@"GemReader.jpg"];
            }
            
            if( [[NSFileManager defaultManager] fileExistsAtPath:resultPath])
            {
                info = [HelpClass readInfo:resultPath section:[NSString stringWithUTF8String:szMachineCode]];
                if([info[@"BindDevID"] isEqualToString:_disklist[i][@"UUID"]])
                {
                    break;
                }
            }
        }
    }
        
    NSString *code = [NSString stringWithCString:szMachineCode encoding:NSUTF8StringEncoding];
    NSString * szLicence = @"";
    
    if(_playCfg.dwCPFileType == CP_TYPE_NO_PW)
    {
        hobj = NDF_Open([gemPath UTF8String], nil, 0);
    }
    else if(_playCfg.dwCPFileType < CP_TYPE_NO_PW)
    {
        dwIsExitPW = NDF_IsExistPassword([gemPath UTF8String]);
        if(1 == dwIsExitPW)
        {
            [SVProgressHUD dismiss];
            [[AlertView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH, kHEIGHT) view:[[UIApplication sharedApplication] keyWindow] isOnlyPassword:YES completed:^(NSString * _Nonnull userName, NSString * _Nonnull passwordValue)
             {
                passwordText = passwordValue;
                int passwordLength = 0;
                if(passwordText.length == 0){
                    [SVProgressHUD dismiss];
                    return;
                }
                
                uint8_t password[LEN_USER_PASSWORD + 1] = {0};
                memcpy(password, [passwordText UTF8String],[passwordText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
                NSLog(@"%s",password);
                passwordLength = (int)strlen((const char *)password);
                
                HNdfObject hobj = NDF_Open([gemPath UTF8String], password, passwordLength);
                if(!hobj)
                {
                    [SVProgressHUD dismiss];
                    DWORD dwErrorCode = NDF_GetLastError();
                    if(dwErrorCode > 0)
                        dwErrorCode = dwErrorCode & 0xFFFF;
                    if(dwErrorCode == 0x0018){
                        [UIWindow showTips:NSLocalizedString(@"strProtect", nil)];
                    }
                    else{
                        [UIWindow showTips:NSLocalizedString(@"PasswordError", nil)];
                    }
                    return;
                }
                [self DecodeLicenceCode:hobj machine:code licence:szLicence path:gemPath passwordText:passwordText questions:questionParams guid:fileGuid supperVC:supperVC];
            }];
        }
        else
        {
            hobj = NDF_Open([gemPath UTF8String], nil, 0);
        }
    }
    else
    {
        //        if([[NSUserDefaults standardUserDefaults] objectForKey:[TC_STR(fileGuid) stringByAppendingString:@"_ReMenber"]]){
        //            szLicence = [[NSUserDefaults standardUserDefaults] objectForKey:[TC_STR(fileGuid) stringByAppendingString:@"_Licence"]];
        //        }
        
        if(szLicence.length>0){
            [self DecodeLicenceCode:hobj machine:code licence:szLicence path:gemPath passwordText:passwordText questions:questionParams guid:fileGuid supperVC:supperVC];
        }else{
            [SVProgressHUD dismiss];
            InPasswordViewController *inPassword = [[InPasswordViewController alloc] init];
            inPassword.machineCodeText = code;
            inPassword.fileGuid = fileGuid;
            inPassword.filePath = gemPath;
            inPassword.isHostAppRun = YES;
            inPassword.StartPlayBlock = ^(NSString * _Nonnull licence, NSString * _Nonnull machineCode, NSString * _Nonnull guid, NSString * _Nonnull filepath) {
                UIViewController *vc = [self DecodeLicenceCode:hobj machine:machineCode licence:licence path:filepath passwordText:passwordText questions:questionParams guid:fileGuid supperVC:nil];
                if(vc){
                    [inPassword leftAction];
                    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [supperVC presentViewController:vc animated:true completion:nil];
                }
                return NO;
            };
            inPassword.modalPresentationStyle = UIModalPresentationOverFullScreen;
            UIViewController *vc = [HelpClass getCurrentVC];
            [vc presentViewController:inPassword animated:true completion:nil];
            if([vc isKindOfClass:[UINavigationController class]]){
                [((UINavigationController *)vc) pushViewController:inPassword animated:NO];
            }else{
                [vc presentViewController:inPassword animated:NO completion:nil];
            }
        }
        return;
    }
    
    [self DecodeLicenceCode:hobj machine:code licence:nil path:gemPath passwordText:passwordText questions:questionParams guid:fileGuid supperVC:supperVC];
    return;
}

- (void)openGemForPath:(NSString *)gemPath
              supperVC:(UIViewController *)supperVC{
    int fNDF = -1;
    int access = 0;
    char* szKanFile = (utf8*)[gemPath UTF8String];
    access = O_RDONLY;
    #ifdef O_BINARY
    access |= O_BINARY;
    #endif
    fNDF = open(szKanFile,access, 0666);
      
    if(fNDF != -1){
        close(fNDF);
    }
    else{
        NSLog(@"打开文件失败：%d",errno);
        NSLog(@"open:(%s)failed! errorcode:%d",szKanFile,errno);
        return;
    }
    
    
    NSString *extension = [gemPath.pathExtension lowercaseString];
    if([extension isEqualToString:@"pdf"]){
        [self openpdfWithPath:gemPath width:kWIDTH *[UIScreen mainScreen].scale pageIndex:0 completed:^(int rotation, int count, UIImage *image) {
            [SVProgressHUD dismiss];
            ImagePrewViewController *imageVC = [[ImagePrewViewController alloc]init];
            imageVC._sourceImage = image;
            imageVC._gem_hobj = nil;
            imageVC._tempPath = nil;
//            imageVC._selectIndex = 0;
//            imageVC._isPDF = YES;
//            imageVC._pdfCount = count;
//            imageVC._isHostAppRun = YES;
            if (supperVC != nil) {
                [supperVC presentViewController:imageVC animated:true completion:nil];
            }
            else{
                [((UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController) pushViewController:imageVC animated:NO];
            }
        }];
        return;
    }
    
    if([extension isEqualToString:@"mov"] ||
       [extension isEqualToString:@"mp4"] ||
       [extension isEqualToString:@"mp3"] ||
       [extension isEqualToString:@"wav"] ||
       [extension isEqualToString:@"aac"] ||
       [extension isEqualToString:@"m4a"]){
        [SVProgressHUD dismiss];
        VideoPlayerViewController *playerVC = [[VideoPlayerViewController alloc] init];
        [playerVC setIsGemFile:NO];
        [playerVC setIsVideo:([extension isEqualToString:@"mov"] || [extension isEqualToString:@"mp4"])];
        [playerVC setIsHostAppRun: YES];
        playerVC._playerPath = gemPath;
        if (supperVC != nil) {
            [supperVC presentViewController:playerVC animated:true completion:nil];
        }
        else{
            [((UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController) pushViewController:playerVC animated:NO];
        }
        return;
    }
    
    if([extension isEqualToString:@"png"] ||
       [extension isEqualToString:@"jpg"] ||
       [extension isEqualToString:@"jpeg"] ||
       [extension isEqualToString:@"tiff"]){
        [SVProgressHUD dismiss];
        ImagePrewViewController *image = [[ImagePrewViewController alloc] init];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:gemPath]];
//        image.isHostAppRun = YES;
        image._sourceImage = [UIImage imageWithData:data];
        if (supperVC != nil) {
            [supperVC presentViewController:image animated:true completion:nil];
        }
        else{
            [((UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController) pushViewController:image animated:NO];
        }
        return;
    }
    
    __block DWORD d = 0;
    VIDEO_PLAYER_CONFIG playCfg = {0};
    _playCfg = playCfg;
    d = NDF_GetPlayerConfig([gemPath UTF8String], &_playCfg);
    if(d !=0){
        NSLog(@"error:NDF_GetPlayerConfig errorCode:%d",d);//44957701
        return;
    }
    int sGuid = 0;
    d = NDF_GetGuid((char *)[gemPath UTF8String],NULL, &sGuid);
    if(d !=0){
        NSLog(@"error:NDF_GetGuid errorCode:%d",d);
        return;
    }
    NSString *fileGuid = @"";
    if(sGuid > 0){
        char *guidCode = malloc(sGuid + 1);
        memset(guidCode,0,sGuid + 1);
        d = NDF_GetGuid((char *)[gemPath UTF8String],guidCode, &sGuid);
        if(d !=0){
            return;
        }
        fileGuid = [NSString stringWithCString:guidCode encoding:NSUTF8StringEncoding];
    }
    
    char szMD5Code[NDF_MAX_PATH] = {0};
    d = GetMD5Code((char *)[gemPath UTF8String], szMD5Code);
    NSString *pathMd5Code = [NSString stringWithUTF8String:szMD5Code];
    
    if([extension isEqualToString:@"gcp"] || _playCfg.dwCPFileType == 4){
        
        __block typeof(self) bself = self;
        __block NSString *passwordText = @"";
        __block NSString *userNameText = @"";
        
        DRM_USB_COPY_CONFIG gcpCfg = {0};
        d = NDF_GetPlayerUsbCopyConfig([gemPath UTF8String], &gcpCfg);
        _gcpPlayCfg = gcpCfg;
        
        char szMachineCode[LEN_NDF_DES] = {0};
        d = GetMachineCode(kDWCPType, kDWFlag, szMachineCode);
        NSString *code = [NSString stringWithCString:szMachineCode encoding:NSUTF8StringEncoding];
        
        NSString *szSN = [NSString stringWithUTF8String:_gcpPlayCfg.szSN];
        NSString *szBlackListGetUrl = [NSString stringWithUTF8String:_gcpPlayCfg.szBlackListGetUrl];
        if(_gcpPlayCfg.nRegister == 0){
            if(szSN.length > 0 && szBlackListGetUrl.length > 0){
                [SVProgressHUD dismiss];
                [UIWindow showTips:NSLocalizedString(@"nRegisterMessage", nil)];
            }
        }else{
            if(szSN.length > 0 && szBlackListGetUrl.length > 0){
               NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:szBlackListGetUrl] encoding:NSUTF8StringEncoding error:nil];
                if(result){
                    if(![result containsString:szSN]){
                        _gcpPlayCfg_disablePlay = YES;
                        [SVProgressHUD dismiss];
                        [UIWindow showTips:NSLocalizedString(@"RegisterMessage", nil)];
                        return;
                    }
                }
            }
        }
        DWORD hasPw = NDF_IsExistPassword([gemPath UTF8String]);
        if(hasPw == 1){
            [SVProgressHUD dismiss];
            [[AlertView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH, kHEIGHT) view:[UIApplication sharedApplication].keyWindow isOnlyPassword:NO completed:^(NSString * _Nonnull userNameValue, NSString * _Nonnull passwordValue) {
                userNameText = userNameValue;
                passwordText = passwordValue;
                int passwordLength = 0;
                if(userNameText.length == 0 || passwordText.length == 0){
                    [UIWindow showTips:NSLocalizedString(@"strLogInPW", nil)];
                    return;
                }
                [SVProgressHUD showWithStatus:NSLocalizedString(@"请稍后...", nil)];
                BOOL isLoginOk = NO;
                BOOL isAdmin = NO;
                if([[NSString stringWithUTF8String:bself->_gcpPlayCfg.pUserParam[0].szUserName] isEqualToString:userNameText] && [[NSString stringWithUTF8String:bself->_gcpPlayCfg.pUserParam[0].szUserPW] isEqualToString:passwordText]){
                    isAdmin = YES;
                }
                for(int i = 0;i<3;i++){
                    NSString *userName = [NSString stringWithUTF8String:bself->_gcpPlayCfg.pUserParam[i].szUserName];
                    NSString *password = [NSString stringWithUTF8String:bself->_gcpPlayCfg.pUserParam[i].szUserPW];
                    if([userName isEqualToString:userNameText] && [password isEqualToString:passwordText]){
                        isLoginOk = YES;
                        bself->_user_Play_Param = bself->_gcpPlayCfg.pUserParam[i];
                        break;
                    }
                }
                NSString *gemPasword = [NSString stringWithUTF8String:bself->_gcpPlayCfg.szGemPw];
                if(isLoginOk){
                    uint8_t password[LEN_USER_PASSWORD + 1] = {0};
                    memcpy(password, [gemPasword UTF8String],[gemPasword lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
                    NSLog(@"%s",password);
                    passwordLength = (int)strlen((const char *)password);
                    
                    NDF_UsbCopyLoginAdmin(isAdmin ? 1 : 0);
                    HNdfObject hobj = NDF_Open([gemPath UTF8String], password, passwordLength);
                    if(!hobj){
                        [SVProgressHUD dismiss];
                        DWORD dwErrorCode = NDF_GetLastError();
                        if(dwErrorCode > 0)
                            dwErrorCode = dwErrorCode & 0xFFFF;
                        if(dwErrorCode == 0x0018)
                        {
                            [UIWindow showTips:NSLocalizedString(@"strProtect", nil)];
                        }
                        else
                        {
                            [UIWindow showTips:NSLocalizedString(@"DisablePlayMessage", nil)];
                        }
                        return;
                    }
                    if(bself->_user_Play_Param.nDisableVirMachine){
                        if(IsVirMache()){
                            [SVProgressHUD dismiss];
                            NSLog(@" func :%s line:%d error:当前文件不允许虚拟机运行",__func__,__LINE__);
                            [UIWindow showTips:NSLocalizedString(@"DisableRunVir", nil)];
                            return;
                        }
                    }

                    if(szSN.length > 0){
                        Reachability *lexiu = [Reachability reachabilityForInternetConnection];
                        if([lexiu currentReachabilityStatus] == ReachabilityStatus_NotReachable){
                            [UIWindow showTips:NSLocalizedString(@"CheckTheCurrentNetwork", nil)];
                            return;
                        }
                        NSString *url = kGcpinvalidsnJson_Url;
                        NSString *jsonpath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"GcpinvalidsnJson.json"];
                        NSString *resultpath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Result_GcpinvalidsnJson.json"];
                        
                        [[NSFileManager defaultManager] removeItemAtPath:jsonpath error:nil];
                        [[NSFileManager defaultManager] removeItemAtPath:resultpath error:nil];
                        DownTool *tool = [[DownTool alloc] initWithURLPath:url savePath:jsonpath];
                        
                        tool.Finish = ^(NSString *cachePath) {
                            FileDecrypt([cachePath UTF8String],[resultpath UTF8String]);
                            
                            NSString *json_string = [NSString stringWithContentsOfFile:resultpath encoding:NSUTF8StringEncoding error:nil];
                            
                            if(json_string){
                                NSData *jsonData = [json_string dataUsingEncoding:NSUTF8StringEncoding];
                                NSError *error;
                                NSDictionary * json_dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                                NSArray *list = json_dict[@"invalidsn"];
                                if([list containsObject:szSN]){
                                    _gcpPlayCfg_disablePlay = YES;
                                    [SVProgressHUD dismiss];
                                    [UIWindow showTips:NSLocalizedString(@"DisableFileMessage", nil)];
                                    
                                }else{
                                    [bself canOpenGcpFile:code d:&d fileGuid:fileGuid gemPasword:gemPasword gemPath:gemPath hobj:hobj supperVC:supperVC];
                                }
                            }
                            else{
                                [bself canOpenGcpFile:code d:&d fileGuid:fileGuid gemPasword:gemPasword gemPath:gemPath hobj:hobj supperVC:supperVC];
                            }
                            [SVProgressHUD dismiss];
                        };
                        [tool start];
                    }
                    return;
                }else{
                    [SVProgressHUD dismiss];
                    [UIWindow showTips:NSLocalizedString(@"UserNameOrPasswordError", nil)];
                    return;
                }
            }];
        }else{
            HNdfObject hobj = NDF_Open([gemPath UTF8String], nil, 0);
            [self DecodeLicenceCode:hobj machine:code licence:nil path:gemPath passwordText:nil questions:nil guid:fileGuid supperVC:supperVC];
        }
        return;
    }
    else if([extension isEqualToString:@"gfx"]){
        
        DWORD hasPw = NDF_IsExistPassword([gemPath UTF8String]);
        if(hasPw == 1){
            __block typeof(self) bself = self;
            __block NSString *passwordText = @"";
            [SVProgressHUD dismiss];
            [[AlertView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH, kHEIGHT) view:[UIApplication sharedApplication].keyWindow isOnlyPassword:YES completed:^(NSString * _Nonnull userNameValue, NSString * _Nonnull passwordValue) {
                passwordText = passwordValue;
                int passwordLength = 0;
                if(passwordText.length == 0){
                    [SVProgressHUD dismiss];
                    return;
                }
                [SVProgressHUD showWithStatus:NSLocalizedString(@"请稍后...", nil)];
                uint8_t password[LEN_USER_PASSWORD + 1] = {0};
                memcpy(password, [passwordText UTF8String],[passwordText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
                NSLog(@"%s",password);
                passwordLength = (int)strlen((const char *)password);
                HNdfObject hobj = NDF_Open([gemPath UTF8String], password, passwordLength);
                if(!hobj){
                    [SVProgressHUD dismiss];
                    DWORD dwErrorCode = NDF_GetLastError();
                    if(dwErrorCode > 0)
                        dwErrorCode = dwErrorCode & 0xFFFF;
                    if(dwErrorCode == 0x0018)
                    {
                        [UIWindow showTips:NSLocalizedString(@"strProtect", nil)];
                    }
                    else
                    {
                        [UIWindow showTips:NSLocalizedString(@"PasswordError", nil)];
                    }
                    return;
                }
                char szMachineCode[LEN_NDF_DES] = {0};
                d = GetMachineCode(bself->_playCfg.dwCPFileType, bself->_playCfg.dwMachineCodeStatus, szMachineCode);
                NSString *code = [NSString stringWithCString:szMachineCode encoding:NSUTF8StringEncoding];

                [self DecodeLicenceCode:hobj machine:code licence:nil path:gemPath passwordText:passwordText questions:nil guid:fileGuid supperVC:supperVC];
                [SVProgressHUD dismiss];
            }];
        }
        else{
            HNdfObject hobj = NDF_Open([gemPath UTF8String], nil, 0);
            char szMachineCode[LEN_NDF_DES] = {0};
            d = GetMachineCode(_playCfg.dwCPFileType, _playCfg.dwMachineCodeStatus, szMachineCode);
            NSString *code = [NSString stringWithCString:szMachineCode encoding:NSUTF8StringEncoding];
            [self DecodeLicenceCode:hobj machine:code licence:nil path:gemPath passwordText:nil questions:nil guid:fileGuid supperVC:supperVC];
            
        }
        
        return;
    }
    else if([extension isEqualToString:@"gem"]){

        NSString *szSN = [NSString stringWithUTF8String:_playCfg.szSN];
        if(szSN.length > 0){
            Reachability *lexiu = [Reachability reachabilityForInternetConnection];
            if([lexiu currentReachabilityStatus] == ReachabilityStatus_NotReachable){
                [SVProgressHUD dismiss];
                [UIWindow showTips:NSLocalizedString(@"checkNetwork", nil)];
                return;
            }
            NSString *url = kGcpinvalidsnJson_Url;
            NSString *jsonpath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"GcpinvalidsnJson.json"];
            NSString *resultpath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Result_GcpinvalidsnJson.json"];
            
            [[NSFileManager defaultManager] removeItemAtPath:jsonpath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:resultpath error:nil];
            DownTool *tool = [[DownTool alloc] initWithURLPath:url savePath:jsonpath];
            __block typeof(self) bself = self;
            tool.Finish = ^(NSString *cachePath) {
                FileDecrypt([cachePath UTF8String],[resultpath UTF8String]);
                
                NSString *json_string = [NSString stringWithContentsOfFile:resultpath encoding:NSUTF8StringEncoding error:nil];
                
                if(json_string){
                    NSData *jsonData = [json_string dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error;
                    NSDictionary * json_dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                    NSArray *list = json_dict[@"invalidsn"];
                    if([list containsObject:szSN]){
                        _gcpPlayCfg_disablePlay = YES;
                        [SVProgressHUD dismiss];
                        [UIWindow showTips:NSLocalizedString(@"DisableFileMessage", nil)];
                    }else{
                        [bself canOpenGemFile:&d fileGuid:fileGuid gemPath:gemPath supperVC:supperVC];
                    }
                }
                else{
                    [bself canOpenGemFile:&d fileGuid:fileGuid gemPath:gemPath supperVC:supperVC];
                }
                
            };
            [tool start];
        }
        else{
            [self canOpenGemFile:&d fileGuid:fileGuid gemPath:gemPath supperVC:supperVC];
        }
        return;
    }
    
    [UIWindow showTips:[NSString stringWithFormat:NSLocalizedString(@"strUnSupportFile", nil)]];
    
}

- (UIViewController *)DecodeLicenceCode:(HNdfObject)hobj
                  machine:(NSString *)machine
                  licence:(NSString *)szLicence
                     path:(NSString *)gemPath
             passwordText:(NSString *)passwordText
                questions:(NSMutableArray *)questionParams
                     guid:(NSString *)guid
                 supperVC:(UIViewController *)supperVC
{
    DWORD d = 0;
    char machineCode[LEN_NDF_DES]   = {0};
    char szPw[LEN_USER_PASSWORD]    = {0};
    int nCheckTimeUseNetTime = 0;
    char szWaterMark[LEN_NDF_DES]   = {0};
    int nMaxNum = 0;
    char szTimeout[LEN_NDF_DES]     = {0};
    int nMaxTime = 0;
   
    NSString *waterText = nil;
    UIFont *waterFont = nil;
    UIColor *waterColor = nil;
    UIImage *waterImage = nil;
    int passwordLength = 0;
    
    if([[[gemPath pathExtension]lowercaseString] isEqualToString:@"gem"])
    {
        NSString *szLicenceCheck = [szLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(szLicenceCheck && szLicenceCheck.length>0)
        {
            NSString *szLicenceCheck = [szLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *szBlackListGetUrl = [NSString stringWithUTF8String:_playCfg.szBlackListGetUrl];
            
            if(szBlackListGetUrl && szBlackListGetUrl.length > 0)
            {
    
                {
                    Reachability *lexiu = [Reachability reachabilityForInternetConnection];
                    if([lexiu currentReachabilityStatus] == ReachabilityStatus_NotReachable){
                        [SVProgressHUD dismiss];
                        [UIWindow showTips:NSLocalizedString(@"checkNetwork", nil)];
                        return nil;
                    }
                }
                
                NSArray *resultlist = [HelpClass downloadMacheJSON:szBlackListGetUrl];
                 if(resultlist && [resultlist containsObject:szLicenceCheck]){
                     _gcpPlayCfg_disablePlay = YES;
                     [SVProgressHUD dismiss];
                     [UIWindow showTips:NSLocalizedString(@"DisablePlayMessage", nil)];
                     return nil;
                 }
            }
            
            d = DecodeLicenceCode2((char *)[szLicenceCheck UTF8String], machineCode, szPw, szWaterMark, szTimeout, &nMaxNum, &nMaxTime,&nCheckTimeUseNetTime);
            if(d>0)
            {
                NSLog(@" func :%s line:%d error:%d",__func__,__LINE__,d);
                [SVProgressHUD dismiss];
                [UIWindow showTips:NSLocalizedString(@"strErrorPlayPW", nil)];
                return nil;
            }
            
            if(![machine isEqualToString:[NSString stringWithUTF8String:machineCode]])
            {
                [SVProgressHUD dismiss];
                [UIWindow showTips:NSLocalizedString(@"strMachineCodeErrorPlayPW", nil)];
                return nil;
            }
            
            passwordText = [NSString stringWithUTF8String:szPw];
            if(passwordText.length == 0)
            {
                [SVProgressHUD dismiss];
                [UIWindow showTips:NSLocalizedString(@"strPlayPasswordErrorPW", nil)];
                return nil;
            }
            
            uint8_t password[LEN_USER_PASSWORD];
            memcpy(password, [passwordText UTF8String],[passwordText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
            NSLog(@"%s",password);
            
            passwordLength = (int)strlen((const char *)password);
            hobj = NDF_Open([gemPath UTF8String], password, passwordLength);
            if(!hobj){
                [SVProgressHUD dismiss];
                [UIWindow showTips:NSLocalizedString(@"strOpenFileError", nil)];
                return nil;
            }
            
            if(strlen(szWaterMark)>0){
                waterText = [NSString stringWithUTF8String:szWaterMark];
            }
            
            if(waterText.length>0){
                int colorValue = _playCfg.nWatermarkClr;
                waterFont = [UIFont systemFontOfSize:_playCfg.nWatermarkFontSize * 2];
                waterColor = [HelpClass colorWithHex:colorValue];
                waterImage = [HelpClass imageWithText:waterText fontSize:_playCfg.nWatermarkFontSize * 2 color:waterColor];
                //double cx = [_playCfg.nWatermarkLeft integerValue]/(double)_rdPlayer.view.bounds.size.width;
                //double cy = [playCfg.nWatermarkTop integerValue]/(double)_rdPlayer.view.bounds.size.height;
                //[_rdPlayer AddImageWatermarkWithData:imageData cx:cx cy:cy];
                
            }
        }else{
            waterText = [NSString stringWithUTF8String:_playCfg.noPwCellCfg.szWatermark];
            if(waterText && waterText.length>0)
            {
                int colorValue = _playCfg.nWatermarkClr;
                waterColor = [HelpClass colorWithHex:colorValue];
                waterFont = [UIFont systemFontOfSize:_playCfg.nWatermarkFontSize * 2];
                waterImage = [HelpClass imageWithText:waterText fontSize:_playCfg.nWatermarkFontSize * 2 color:waterColor];
            }
            
            if(passwordText && passwordText.length > 0)
            {
                uint8_t password[LEN_USER_PASSWORD];
                memcpy(password, [passwordText UTF8String],[passwordText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
                passwordLength = (int)strlen((const char *)password);
            }
        }
    }
    else if([[[gemPath pathExtension]lowercaseString] isEqualToString:@"gcp"])
    {
        {
            BOOL dateEnable = [HelpClass returnDateIsEnableForString:[NSString stringWithUTF8String:_user_Play_Param.szPlayTimeOut]];
            if(!dateEnable){
                [SVProgressHUD dismiss];
                [UIWindow showTips:NSLocalizedString(@"strErrorPlayDate", nil)];
                return nil;
            }
        }
        
        if(!hobj)
        {
            if(passwordText.length > 0)
            {
                uint8_t password[LEN_USER_PASSWORD];
                memcpy(password, [passwordText UTF8String],[passwordText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
                passwordLength = (int)strlen((const char *)password);
                hobj = NDF_Open([gemPath UTF8String], password, passwordLength);
            }else{
                hobj = NDF_Open([gemPath UTF8String], NULL, 0);
            }
        }else{
            uint8_t password[LEN_USER_PASSWORD];
            memcpy(password, [passwordText UTF8String],[passwordText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
            passwordLength = (int)strlen((const char *)password);
        }
        
        if(!hobj){
            [SVProgressHUD dismiss];
            return nil;
        }
        
        waterFont = [UIFont systemFontOfSize:_user_Play_Param.nWatermarkFontSize];
        NSString *waterText = [NSString stringWithUTF8String:_user_Play_Param.szWatermark];
        
        if(strlen(szWaterMark)>0){
            waterText = [NSString stringWithUTF8String:szWaterMark];
        }
        
        if(waterText && waterText.length>0)
        {
            int colorValue = _user_Play_Param.nWatermarkClr;
            waterColor = [HelpClass colorWithHex:colorValue];
            waterFont = [UIFont systemFontOfSize:_user_Play_Param.nWatermarkFontSize * 2];
            waterImage = [HelpClass imageWithText:waterText fontSize:_user_Play_Param.nWatermarkFontSize color:waterColor];
        }
    }else if([[[gemPath pathExtension]lowercaseString] isEqualToString:@"gfx"]){
        if(passwordText.length > 0){
            uint8_t password[LEN_USER_PASSWORD];
            memcpy(password, [passwordText UTF8String],[passwordText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
            passwordLength = (int)strlen((const char *)password);
            hobj = NDF_Open([gemPath UTF8String], password, passwordLength);
        }else{
            hobj = NDF_Open([gemPath UTF8String], NULL, 0);
        }
    }
    
    
    NSString *str = [NSString stringWithFormat:@"%@\\*.*",@"\\public"];
    NSMutableArray *gem_Files = [NSMutableArray new];
    NDF_FIND_DATA pFindFileData={0};
    HNdfDirectory directory =  NDF_FindFirstFile(hobj, (char *)[str UTF8String], &pFindFileData);
    
    if (directory == NULL)
    {
        NSLog(@" func :%s line:%d error:%d",__func__,__LINE__,d);
        [SVProgressHUD dismiss];
        return nil;
    }
    
    do {
        GemFileInfo *gemInfo = [[GemFileInfo alloc] init];
        gemInfo.gemGUID = guid;
        gemInfo.password = passwordText;
        gemInfo.pwLenth  = @(passwordLength);
        gemInfo.nFileSize = @(pFindFileData.nFileSize);
        gemInfo.nFileType = @(pFindFileData.nFileType);
        gemInfo.nFileDataOffset = @(pFindFileData.nFileDataOffset);
        gemInfo.nThumbSize = @(pFindFileData.nThumbSize);
        gemInfo.nIndexOffset = @(pFindFileData.nIndexOffset);
        gemInfo.dwFileAttributes = @(pFindFileData.dwFileAttributes);
        gemInfo.cFileName = [NSString stringWithUTF8String:pFindFileData.cFileName];
        gemInfo.questionParams = questionParams;
        gemInfo.waterText = waterText;
        gemInfo.waterFont = waterFont;
        gemInfo.waterColor = waterColor;
        gemInfo.waterImage = waterImage;
        
        if([[[gemPath pathExtension]lowercaseString] isEqualToString:@"gem"]){
            [gemInfo setplayCfgWithCfg:_playCfg];
        }else if([[[gemPath pathExtension]lowercaseString] isEqualToString:@"gcp"]){
            [gemInfo setgcpCfgWithCfg:_gcpPlayCfg];
            [gemInfo setuserParamWithParam:_user_Play_Param];
            gemInfo.playPageCount = @(_user_Play_Param.nPlayPageCount);
        }else if([[[gemPath pathExtension]lowercaseString] isEqualToString:@"gfx"]){
            [gemInfo setplayCfgWithCfg:_playCfg];
        }
        
        gemInfo.waterImage = waterImage;
        gemInfo.nMaxPlayTime = @(nMaxTime);
        gemInfo.nMaxNum = @(nMaxNum);
        gemInfo.nCheckTimeUseNetTime = @(nCheckTimeUseNetTime);
        gemInfo.szTimeout = [NSString stringWithUTF8String:szTimeout];
        
        if([str length] > [str rangeOfString:@"*.*"].location){
            NSString *temPath = [[str substringToIndex:[str rangeOfString:@"*.*"].location] stringByAppendingString:gemInfo.cFileName];
            gemInfo.tempPath = temPath;
        }
        [gem_Files addObject:gemInfo];
    } while (NDF_FindNextFile(hobj, directory, &pFindFileData));
    
    NSLog(@"gem_Files:%@",gem_Files);
    
    [SVProgressHUD dismiss];
    GemFileDetailViewController *fileVC = [[GemFileDetailViewController alloc] init];
    fileVC._path = gemPath;
    fileVC._temppath = @"\\public";
    fileVC.isGem = @(true);
    fileVC.isHostAppRun = @(true);
    fileVC.gemFiles = gem_Files;
    fileVC.gem_hobj = hobj;
    if (supperVC != nil) {
        fileVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [supperVC presentViewController:fileVC animated:true completion:nil];
        return nil;
    }
    else{
        return fileVC;
    }
    
}
+ (id)downloadMacheJSON:(NSString *)url
{
    NSString *json_string;
    NSString *dataURL = [NSString stringWithFormat:@"%@", url];
    NSLog(@"%@",dataURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:dataURL]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    if(!json_string){
        return nil;
    }
    NSData *jsonData = [json_string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
     id json_dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];

    return json_dict;
}

+ (NSString *)getDeviceName{
    //手机别名： 用户定义的名称
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", userPhoneName);
    //设备名称
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    NSLog(@"设备名称: %@",deviceName );
    return userPhoneName;
}

+ (NSString *)convertToJsonData:(NSDictionary *) dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                        options:NSJSONWritingSortedKeys
                                        error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (void)uploadjsonFile:(NSString *)fileName jsonContent:(NSString *)jsonContent
{
    NSString *uploadstring = @"https://gilisoft.xyz/api2022/copyprotect/uploadren.php?file_fingerprint=gcpfingerprint";
    //(1)确定上传路径
    NSURL *url = [NSURL URLWithString:uploadstring];
    
    //(2)创建"可变"请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    
    //(3)修改请求方法为POST
    request.HTTPMethod = @"POST";
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",Kboundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionUploadTask *uploadTask = [[[HelpClass alloc] init].session uploadTaskWithRequest:request fromData:[self bodyData:fileName jsonContent:jsonContent] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"=======:%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
    //(7)执行task发送请求上传文件
    [uploadTask resume];

}
// 上传文件的请求体
+ (NSData *)bodyData:(NSString *)fileName jsonContent:(NSString *)jsonContent
{
    NSMutableData *data = [NSMutableData data];
    
    //01 拼接文件参数
    /*
    --分隔符
    Content-Disposition: form-data; name="file"; filename="Snip20161126_210.png"
    Content-Type: image/png
    空行
    文件数据
     */
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    //name:file 服务器规定
    //filename:该文件上传到服务器之后的名称
    //username|pwd
    [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"data\"; filename=\"%@\"",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    //要上传文件的二进制数据类型  MIMEType 组成:大类型/小类型
    [data appendData:[@"Content-Type: text/json" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    [data appendData:KnewLine];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:jsonData];
    [data appendData:KnewLine];
    
    //02 拼接非文件参数
    /*
     --分隔符
     Content-Disposition: form-data; name="username"
     空行
     abcdf
     */
    [data appendData:[[NSString stringWithFormat:@"--%@",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    //name:username
    [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"data\"; filename=\"%@\"",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:KnewLine];
    [data appendData:KnewLine];
    [data appendData:jsonData];
    [data appendData:KnewLine];
    
    //03 结尾标识
    /*
     --分隔符--
     */
     [data appendData:[[NSString stringWithFormat:@"--%@--",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
}



+ (NSString *)getAppRootFolder{
    return [kDocumentsDir stringByAppendingPathComponent:@"GemReader.jpg"];
}
+ (NSMutableDictionary *)readInfo:(NSString *)path section:(NSString *)sec {
 
//    const char *file = [path UTF8String];
//
//    char *sect;
//    char *key;
//    char value[256];
//
//    printf("load file %s\n\n", file);
//    iniFileLoad(file);
//
//    sect = [sec UTF8String];
//    NSMutableArray *keys = [@[@"Licence",@"BindDevID",@"SavePw"] mutableCopy];
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    for (NSString *itemkey in keys) {
//        key = [itemkey UTF8String];
//        iniGetString(sect, key, value, sizeof(value), "notfound!");
//        printf("[%s] %s = %s\n", sect, key, value);
//        [dic setObject:[NSString stringWithUTF8String:value] forKey:[NSString stringWithUTF8String:key]];
//
//
//
//    }
//    iniFileFree();
    return nil;//dic;
}



/**文字变图片
 */
+ (UIImage *)imageWithText:(NSString *)text fontSize:(CGFloat)fontSize color:(UIColor *)color{
    //画布大小
    UIFont  *font = [UIFont systemFontOfSize:fontSize];//设置
    NSDictionary *attributes = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
    CGSize size = [text boundingRectWithSize:CGSizeMake(kWIDTH, kHEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [text drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ ( UIColor *)colorWithHex:( u_int32_t )hex {
    int blue = (hex & 0xFF0000 ) >> 16 ;
    int green = (hex & 0x00FF00 ) >> 8 ;
    int red = hex & 0x0000FF ;
   
    return [ UIColor colorWithRed :red / 255.0 green :green / 255.0 blue :blue / 255.0 alpha : 1.0 ];
}

+ (BOOL)returnDateIsEnableForString:(NSString *)string{
    
    if(!string){
        return YES;
    }
    if([string isEqualToString: @""]){
        return YES;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//
    NSDate *startDate = [dateFormatter dateFromString:string];
    
    NSDate* endDate = [NSDate date];
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    if(time<0){
        return YES;
    }else return NO;
}
// 懒加载
- (NSURLSession *)session {
    if (_session == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:0];
    }
    return _session;
}

+ (NSString *)stringForAllFileSize:(UInt64)fileSize
{
    if (fileSize<1024) {//Bytes/Byte
        if (fileSize>1) {
            return [NSString stringWithFormat:Localizable_LF_Size_Bytes,
                    fileSize];
        }else {//==1 Byte
            return [NSString stringWithFormat:Localizable_LF_Size_Bytes,
                    fileSize];
        }
    }
    if ((1024*1024)>(fileSize)&&(fileSize)>1024) {//K
        return [NSString stringWithFormat:Localizable_LF_Size_K,
                fileSize/1024];
    }
    
    if ((1024*1024*1024)>fileSize&&fileSize>(1024*1024)) {//M
        return [NSString stringWithFormat:Localizable_LF_All_Size_M,
                fileSize/(1024*1024),
                fileSize%(1024*1024)/(1024*1024)];
    }
    if (fileSize>(1024*1024*1024)) {//G
        return [NSString stringWithFormat:Localizable_LF_All_Size_G,
                fileSize/(1024*1024*1024),
                fileSize%(1024*1024*1024)/(1024*1024*1024)];
    }
    return nil;
}

+ (float)folderSizeAtPath:(NSString*)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator*childFilesEnumerator = [[manager subpathsAtPath:folderPath]objectEnumerator];
    NSString* fileName;
    long long folderSize =0;
    while((fileName = [childFilesEnumerator nextObject]) !=nil)
    {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
    
}
#pragma mark 读取文件大小
+ (long long) fileSizeAtPath:(NSString*) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        // 总大小
        unsigned long long size = 0;
        NSFileManager *manager = [NSFileManager defaultManager];
        
        BOOL isDir = NO;
        BOOL exist = [manager fileExistsAtPath:filePath isDirectory:&isDir];
        
        // 判断路径是否存在
        if (!exist)
            return size;
        if (isDir) { // 是文件夹
            NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:filePath];
            for (NSString *subPath in enumerator.allObjects) {
                if (subPath.pathExtension.length > 0) {
                    NSString *fullPath = [filePath stringByAppendingPathComponent:subPath];
                    size += [manager attributesOfItemAtPath:fullPath error:nil].fileSize;
                }
            }
        }else{ // 是文件
            size += [manager attributesOfItemAtPath:filePath error:nil].fileSize;
        }
        return size;
    }
    return 0;
}

+ (UIImage *)noThumbImage:(int)nFileType{
    if(nFileType >= NDF_FILE_TXT && nFileType < NDF_FILE_JPG){
       return [UIImage imageNamed:@"wenbenIcon"];
    }else if(nFileType >= NDF_FILE_JPG && nFileType < NDF_FILE_MP3){
        return [UIImage imageNamed:@"tupianIcon"];
    }else if(nFileType >= NDF_FILE_MP3 && nFileType < NDF_FILE_MP4){
        return [UIImage imageNamed:@"yinyueIcon"];
    }else if(nFileType >= NDF_FILE_MP4 && nFileType < NDF_FILE_VIDEO_TAG){
        return [UIImage imageNamed:@"shipinIcon"];
    }else{
        return [UIImage imageNamed:@"weizhiIcon"];
    }
     return nil;
}

//MARK: 解压ZIP
+ (NSMutableArray <NSMutableDictionary *> *)readIniFile:(NSString *)filePath{
    // 检查文件是否存在
    NSMutableArray <NSMutableDictionary *>*sections = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        // 读取文件内容
        NSError *error = nil;
        // 读取文件的原始数据
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            // 使用 Core Foundation 的编码常量
            CFStringEncoding encoding = kCFStringEncodingGB_18030_2000; // GB18030，它包含了 GBK
            NSStringEncoding nsEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
            
            // 如果 nsEncoding 不是有效的 NSStringEncoding，那么转换会失败并返回 NSASCIIStringEncoding
            if (nsEncoding != NSASCIIStringEncoding) {
                // 将数据转换为字符串
                NSString *fileContent = [[NSString alloc] initWithData:data encoding:nsEncoding];
                if(!fileContent){
                    fileContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                if (fileContent) {
                    // 成功读取文件内容，现在你需要解析它
                    // 对于简单的 ini 文件，你可能只需要按行分割，然后解析每行
                    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
                    sections = [NSMutableArray new];
                    for (int i = 0;i<lines.count;i++) {
                        NSString *line = lines[i];
                        // 先检查 line 是否为空
                        if (![line isEqualToString:@""]) {
                            if([line hasPrefix:@"["]){
                                NSString *lineKey = [[[line stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                                [sections addObject:[[NSMutableDictionary alloc] initWithDictionary:@{@"section":lineKey,@"items":[NSMutableDictionary new]}]];
                            }
                            // 去除行首尾的空白字符
                            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            // 检查是否为注释行（例如，以 '#' 开头的行）
                            if (![line hasPrefix:@"#"]) {
                                // 这里你可以根据 ini 文件的格式来解析键值对
                                // 示例：假设 ini 文件格式是 "key=value"
                                NSArray *keyValuePair = [line componentsSeparatedByString:@"="];
                                if (keyValuePair.count == 2) {
                                    NSString *itemKey = [keyValuePair[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    NSString *value = [keyValuePair[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    NSLog(@"Key: %@, Value: %@", itemKey, value);
                                    
                                    NSMutableDictionary *items = [sections.lastObject[@"items"] mutableCopy];
                                    if(value){
                                        [items setObject:value forKey:itemKey];
                                    }
                                    [sections.lastObject setObject:items forKey:@"items"];
                                    
                                }
                            }
                        }
                    }
                    return sections;
                } else {
                    NSLog(@"Failed to convert data to GBK string");
                }
            } else {
                NSLog(@"Unsupported encoding");
            }
        } else {
            NSLog(@"Failed to read data from file %@", filePath);
        }
    } else {
        // 文件不存在
        NSLog(@"File not found at %@", filePath);
    }
    
    return sections;
    
}

+ (void)unArchive: (NSString *)filePath andPassword:(NSString*)password destinationPath:(NSString *)destPath completionBlock:(Completion) completionBlock failureBlock:(Failure) failureBlock{
    NSAssert(filePath, @"can't find filePath");
    SARUnArchiveANY *unarchive = [[SARUnArchiveANY alloc]initWithPath:filePath];
    if (password != nil && password.length > 0) {
        unarchive.password = password;
    }
    
    if (destPath != nil)
        unarchive.destinationPath = destPath;//(Optional). If it is not given, then the file is unarchived in the same location of its archive/file.
    
    if(failureBlock){
        unarchive.failureBlock = failureBlock;
    }
    else{
        unarchive.failureBlock = ^(){
            NSLog(@"Cannot be unarchived");
        };
    }
    if(completionBlock){
        unarchive.completionBlock = completionBlock;
    }
    else{
        unarchive.completionBlock = ^(NSArray *filePaths){
          NSLog(@"For Archive : %@",filePath);
            for (NSString *filename in filePaths) {
                NSLog(@"Extracted Filepath: %@", filename);
            }
        };
    }
    [unarchive decompress];
}

+ (void)openSite_Zip:(NSString * _Nonnull)zipPath outputPath:(NSString *)outputPath temppath:(NSString *)temppath vc:(UIViewController *)vc isInGem:(BOOL)isInGem {
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:outputPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSError *error = nil;
    NSArray *file_list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:outputPath error:&error];
    if([file_list count] > 0){
        
        NSString  *path = nil;
        
        NSString *iniFolder = [zipPath stringByDeletingLastPathComponent];
        NSArray *iniFilelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:iniFolder error:nil];
        for(NSString *filename in iniFilelist){
            if([filename.pathExtension.lowercaseString isEqualToString:@"ini"]){
                if([filename hasSuffix:[[zipPath.lastPathComponent stringByDeletingPathExtension] stringByAppendingPathExtension:@"ini"]]){
                    NSArray *sections = [self readIniFile:[iniFolder stringByAppendingPathComponent:filename]];
                    NSString *separator = @"\\";
                    NSArray *parts = [temppath componentsSeparatedByString:separator];
                    NSString *sectionkey = [parts lastObject];
                    
                    for (int i =0;i<sections.count;i++) {
                        if([sections[i][@"section"] isEqualToString:sectionkey]){
                            NSMutableDictionary *items = sections[i][@"items"];
                            if(items[@"homepage"]){
                                path = [outputPath stringByAppendingPathComponent:items[@"homepage"]];
                                break;
                            }
                        }
                    }
                    break;
                }
            }
        }
        if(!path){
            for (int i = 0; i<file_list.count; i++) {
                if([[[file_list[i] pathExtension] lowercaseString] isEqualToString:@"html"]){
                    path = [outputPath stringByAppendingPathComponent:file_list[i]];
                    break;
                }
            }
        }
        if(path){
            WebViewController *web = [[WebViewController alloc] init];
            web.path = path;
            web.modalPresentationStyle = UIModalPresentationOverFullScreen;
            if(vc.navigationController != nil){
                [vc.navigationController pushViewController:web animated:YES];
            }
            else{
                [vc presentViewController:web animated:true completion:nil];
            }
            [SVProgressHUD dismiss];
            return;
        }
        if (isInGem){
            GemFileDetailViewController *fileVC = [[GemFileDetailViewController alloc] init];
            fileVC._path = outputPath;
            fileVC.isGem = @(NO);
            fileVC.isHostAppRun = @(NO);
            fileVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            
            if(vc.navigationController != nil){
                [vc.navigationController pushViewController:fileVC animated:YES];
            }
            else{
                [vc presentViewController:fileVC animated:true completion:nil];
            }
        }
        else{
            FileListViewController *fileVC = [[FileListViewController alloc] init];
            fileVC._filePath = outputPath;
            fileVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            if(vc.navigationController != nil){
                [vc.navigationController pushViewController:fileVC animated:YES];
            }
            else{
                [vc presentViewController:fileVC animated:true completion:nil];
            }
        }
        [SVProgressHUD dismiss];
        return;
    }
    [self unArchive:zipPath andPassword:nil destinationPath:outputPath completionBlock:^(NSArray *filePaths) {
        
        NSLog(@"解压成功：zip_path:%@",zipPath);
        for (NSString *filename in filePaths) {
            NSLog(@"解压后的文件 Filepath: %@", filename);
        }
        [self openSite_Zip:zipPath outputPath:outputPath temppath:temppath vc:vc isInGem:isInGem];
    } failureBlock:^{
        NSLog(@"解压失败");
        [SVProgressHUD dismiss];
    }];
}
//MARK: 读取SITE文件导出到临时目录
+ (void )getFileData:(NSString *)filePath gem_hobj:(HNdfObject)gem_hobj output:(NSString *)outputPath{
    if(!gem_hobj){
        NSLog(@" func :%s line:%d error:hFile 打开失败",__func__,__LINE__);
        return;
    }
    unlink([outputPath UTF8String]);
    HNdfFile hFile = NDF_OpenFile(gem_hobj, [filePath UTF8String]);
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:outputPath]){
        [[NSFileManager defaultManager] createFileAtPath:outputPath contents:nil attributes:nil];
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:outputPath];
    if(hFile){
        int64_t itemPhotoSize = 0;
        NSData *zipData = nil;//[[NSMutableData alloc] init];
        int64_t  blockSize =  NDF_GetFileEncryptBlockSize(gem_hobj, hFile);//得到文件分块加密大小
        int64_t readingSize = 0;
        uint8_t *fileData = malloc(blockSize + 1);
        if (fileData)
        {
            memset(fileData, 0, blockSize + 1);
            DWORD word = 0;
            word = NDF_ReadFile(gem_hobj, hFile, NULL, &itemPhotoSize);
            if(blockSize >0){
                while (1) {
                    BOOL stop = NO;
                    if(itemPhotoSize>blockSize){
                        readingSize = blockSize;
                    }else{
                        readingSize = itemPhotoSize;
                        stop = YES;
                    }
                    word = NDF_ReadFile(gem_hobj, hFile, fileData, &readingSize);
                    if(word == 0){
                        //[zipData appendData: [NSData dataWithBytes:fileData length:readingSize]];
                        zipData = [NSData dataWithBytes:fileData length:readingSize];
                    }else{
                        NSLog(@"读取数据失败");
                        zipData = nil;
                    }
                    itemPhotoSize -= blockSize;
                    if(zipData != nil){
                        [handle seekToEndOfFile];
                        [handle writeData:zipData];
                    }
                    if(stop){break;}
                }
                free(fileData);
            }else{
                uint8_t *fileData = malloc(itemPhotoSize + 1);
                if (fileData)
                {
                    memset(fileData, 0, itemPhotoSize + 1);
                    word = NDF_ReadFile(gem_hobj, hFile, fileData, &itemPhotoSize);
                    if(word == 0){
                        //[zipData appendData: [NSData dataWithBytes:fileData length:itemPhotoSize]];
                        zipData = [NSData dataWithBytes:fileData length:itemPhotoSize];
                    }else{
                        NSLog(@"读取数据失败");
                        zipData = nil;
                    }
                    [handle seekToEndOfFile];
                    [handle writeData:zipData];
                }else{
                    NSLog(@"%s malloc failed!",__func__);
                    zipData = nil;
                }
                free(fileData);
            }
            NDF_CloseFile(gem_hobj, hFile);
        }else{
            NSLog(@"%s malloc failed!",__func__);
            zipData = nil;
        }
    }else{
        NSLog(@" func :%s line:%d error:hFile 打开失败",__func__,__LINE__);
    }
    [handle closeFile];
}

+ (NSString *)getFileMD5Code:(NSString *)path{
    char szMD5Code[NDF_MAX_PATH] = {0};
    DWORD d = GetMD5Code((char *)[path UTF8String], szMD5Code);
    NSString *pathMd5Code = [NSString stringWithUTF8String:szMD5Code];
    return pathMd5Code;
}

+ (NSString *)utf8ToString:(const char *)utf8Content {
    if (utf8Content) {
        return [NSString stringWithUTF8String:utf8Content];
    }
    return nil;
}


+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
#if 1   //20220105 使用保存到沙盒后再使用的方法iPhone6s（iOS13.7）会崩溃
    @autoreleasepool {
        UIGraphicsBeginImageContext(CGSizeMake(((int)(image.size.width * scaleSize))/2*2.0, ((int)(image.size.height * scaleSize))/2*2.0));
        [image drawInRect:CGRectMake(0, 0, ((int)(image.size.width * scaleSize))/2*2.0, ((int)(image.size.height * scaleSize))/2*2.0)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaledImage;
    }
#endif
}
+ (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = (totalSeconds / 3600) % 60;
    if(totalSeconds>3600){
        return [NSString stringWithFormat:@"%.02d:%02d:%02d",hours, minutes, seconds];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
}


#define CG_TRANSFORM_ROTATION (M_PI_2 / 3)//旋转角度(正旋45度 || 反旋45度)
/**
 根据目标图片制作一个盖水印的图片
 
 @param originalImage 源图片
 @param title 水印文字
 @param markFont 水印文字font(如果不传默认为23)
 @param markColor 水印文字颜色(如果不传递默认为源图片的对比色)
 @return 返回盖水印的图片
 */
+ (UIImage *)getWaterMarkImage: (UIImage *)originalImage andTitle: (NSString *)title andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor isThumb:(BOOL)isThumb{
    if(title.length == 0){
        return originalImage;
    }
    
    UIFont *font = markFont;
    UIColor *color = markColor;
    if(!font){
        font = [UIFont systemFontOfSize:16];
    }
    else{
        font = [UIFont systemFontOfSize:(isThumb ? 1 : [UIScreen mainScreen].scale)*markFont.pointSize* (isThumb ? 2 : (originalImage.size.width/kWIDTH))];
    }
    if(!color){
        color = [[UIColor blackColor] colorWithAlphaComponent:50/255.0];
    }else{
        color = [color colorWithAlphaComponent:50/255.0];
    }
    CGSize size = [title boundingRectWithSize:CGSizeMake(1000, 1000) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil].size;
    
    float HORIZONTAL_SPACE = font.pointSize * (isThumb ? 1 : [UIScreen mainScreen].scale);//(originalImage.size.width - size.width * 4)/3.0;
    float VERTICAL_SPACE = font.pointSize *(isThumb ? 1 : [UIScreen mainScreen].scale);//(originalImage.size.height - size.height * 6)/5.0;
    //原始image的宽高
    CGFloat viewWidth = originalImage.size.width;
    CGFloat viewHeight = originalImage.size.height;
    //为了防止图片失真，绘制区域宽高和原始图片宽高一样
    UIGraphicsBeginImageContext(CGSizeMake(viewWidth, viewHeight));
    //先将原始image绘制上
    [originalImage drawInRect:CGRectMake(0, 0, viewWidth, viewHeight)];
    //sqrtLength：原始image的对角线length。在水印旋转矩阵中只要矩阵的宽高是原始image的对角线长度，无论旋转多少度都不会有空白。
    CGFloat sqrtLength = sqrt(viewWidth*viewWidth + viewHeight*viewHeight);
    //文字的属性
    NSDictionary *attr = @{
        //设置字体大小
        NSFontAttributeName: font,
        //设置文字颜色
        NSForegroundColorAttributeName :color,
    };
    NSString* mark = title;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:mark attributes:attr];
    //绘制文字的宽高
    CGFloat strWidth = attrStr.size.width;
    CGFloat strHeight = attrStr.size.height;
    
    //开始旋转上下文矩阵，绘制水印文字
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //将绘制原点（0，0）调整到源image的中心
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(viewWidth/2, viewHeight/2));
    //以绘制原点为中心旋转
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(-CG_TRANSFORM_ROTATION));
    //将绘制原点恢复初始值，保证当前context中心和源image的中心处在一个点(当前context已经旋转，所以绘制出的任何layer都是倾斜的)
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-viewWidth/2, -viewHeight/2));
    
    //计算需要绘制的列数和行数
    int horCount = sqrtLength / (strWidth + HORIZONTAL_SPACE) + 1;
    int verCount = sqrtLength / (strHeight + VERTICAL_SPACE) + 1;
    
    //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
    CGFloat orignX = -(sqrtLength-viewWidth)/2;
    CGFloat orignY = -(sqrtLength-viewHeight)/2;
    
    //在每列绘制时X坐标叠加
    CGFloat tempOrignX = orignX;
    //在每行绘制时Y坐标叠加
    CGFloat tempOrignY = orignY;
    for (int i = 0; i < horCount * verCount; i++) {
        [mark drawInRect:CGRectMake(tempOrignX, tempOrignY, strWidth, strHeight) withAttributes:attr];
        if (i % horCount == 0 && i != 0) {
            tempOrignX = orignX;
            tempOrignY += (strHeight + VERTICAL_SPACE);
        }else{
            tempOrignX += (strWidth + HORIZONTAL_SPACE);
        }
    }
    //根据上下文制作成图片
    UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
    originalImage = nil;
    return finalImg;
}

+ (UIColor *)colorWithColors:(NSArray *)colors bounds:(CGRect)bounds {
    if(bounds.size.width > 0.0 && bounds.size.height > 0.0){
        CALayer *layer = [CALayer layer];
        layer.bounds = bounds;

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = bounds;
        gradientLayer.colors = colors;
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);

        UIGraphicsBeginImageContext(bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) {
            return [UIColor whiteColor];
        }
        
        [gradientLayer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIColor *color = [UIColor colorWithPatternImage:image];
        return color;
    }
    else{
        return [UIColor clearColor];
    }
    
}


+ (UIImage *)getThumbImageWithPath:(NSString *)path {
    NSURL *url;
    if([self isSystemPhotoPath:path]){
        url = [NSURL URLWithString:path];
        return [self getAlbumThumbnailImage:url maxSize:(100 * [UIScreen mainScreen].scale)];
    }else{
        if(!path){
            return nil;
        }
        url = [NSURL fileURLWithPath:path];
        if([self isImageUrl:url]){
            NSData *imagedata = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imagedata];
            if (MIN(image.size.width, image.size.height) > IMAGE_MAX_SIZE_WIDTH) {
                float scale;
                if (image.size.width >= image.size.height) {
                    scale = IMAGE_MAX_SIZE_WIDTH / image.size.width;
                }else {
                    scale = IMAGE_MAX_SIZE_WIDTH / image.size.height;
                }
                image = [self scaleImage:image toScale:(scale*(480.0/1080.0))];
            }
            image = [self fixOrientation:image];
            return image;//[UIImage imageWithContentsOfFile:url.path];
        }else{
            UIImage *image = [self assetGetThumImage:0.5 url:url urlAsset:nil];
            return image;
        }
    }
}
+ (BOOL)isSystemPhotoPath:(NSString *)path {
    BOOL isSystemUrl = YES;
    if([path isKindOfClass:[NSURL class]]){
        path = [NSString stringWithFormat:@"%@",path];
    }
    NSRange range = [path rangeOfString:@"Bundle/Application/"];
    if (range.location != NSNotFound) {
        isSystemUrl = NO;
    }else {
        range = [path rangeOfString:@"Data/Application/"];
        if (range.location != NSNotFound) {
            isSystemUrl = NO;
        }
    }
    return isSystemUrl;
}
+ (BOOL)isSystemPath:(NSString *)path {
    BOOL isSystemPath = YES;
    NSRange range = [path rangeOfString:@"Bundle/Application/"];
    if (range.location != NSNotFound) {
        isSystemPath = NO;
    }else {
        range = [path rangeOfString:@"Data/Application/"];
        if (range.location != NSNotFound) {
            isSystemPath = NO;
        }
    }
    return isSystemPath;
}

+ (BOOL)isSystemPhotoUrl:(NSURL *)url {
    BOOL isSystemUrl = YES;
    NSString *path = (NSString *)url;
    if ([url isKindOfClass:[NSURL class]]) {
        path = url.path;
    }
    NSRange range = [path rangeOfString:@"Bundle/Application/"];
    if (range.location != NSNotFound) {
        isSystemUrl = NO;
    }else {
        range = [path rangeOfString:@"Data/Application/"];
        if (range.location != NSNotFound) {
            isSystemUrl = NO;
        }
    }
    return isSystemUrl;
}
+ (BOOL)isImageUrl:(NSURL *)url{
    if (!url) {
        return NO;
    }
    NSString *pathExtension = [url.pathExtension lowercaseString];
    if([pathExtension isEqualToString:@"jpg"]
       || [pathExtension isEqualToString:@"jpeg"]
       || [pathExtension isEqualToString:@"png"]
       || [pathExtension isEqualToString:@"gif"]
       || [pathExtension isEqualToString:@"tiff"]
       || [pathExtension isEqualToString:@"heic"]
       || [pathExtension isEqualToString:@"webp"]
       ){
        return YES;
    }else{
        return NO;
    }
}

+ (UIImage *)getAlbumThumbnailImage:(NSURL *)url maxSize:(float)maxSize
{
    if (!url) {
        return nil;
    }
    __block UIImage *image;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;//解决草稿箱获取不到缩略图的问题
    PHFetchResult *phAsset = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    PHAsset * asset = [phAsset firstObject];
    if(!asset){
        NSData *data = [NSData dataWithContentsOfURL:url];
        if(data){
            image = [UIImage imageWithData:data];
            if (!image) {
                image = [self assetGetThumImage:0.0 url:url urlAsset:nil];
            }
            data = nil;
            options = nil;
            phAsset = nil;
        }
    }else{
        /** 20240516 如果targetSize 太小，且与图片比例不一致,如CGSizeMake(100 * [UIScreen mainScreen].scale, 100 * [UIScreen mainScreen].scale))，获取到的图片会有空白，导致显示有问题
         bug现象：iPhone12 截屏，选择这张截屏进入编辑，再选择这张添加画中画，UI 选中框有空白
         */
        CGSize targetSize = PHImageManagerMaximumSize;
        if (maxSize > 0) {
            float width = maxSize;
            float height = maxSize;
            float ratio = asset.pixelWidth / (float)asset.pixelHeight;
            if (ratio > 1.0) {
                height = width / ratio;
                if (height < maxSize) {
                    height = maxSize;
                    width = height * ratio;
                }
            }
            else if (ratio < 1.0) {
                width = height * ratio;
                if (width < maxSize) {
                    width = maxSize;
                    height = width / ratio;
                }
            }
            targetSize = CGSizeMake(width, height);
        }
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            image = result;
            result  = nil;
            info = nil;
        }];
    }
    
    options = nil;
    phAsset = nil;
    return image;
}

+ (UIImage *)assetGetThumImage:(CGFloat)second url:(NSURL * _Nullable) url urlAsset:(AVURLAsset * _Nullable) urlAsset{
    if(!urlAsset){
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        // 初始化媒体文件
        urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    }
//    if(![[NSFileManager defaultManager] fileExistsAtPath:urlAsset.URL.path]){
//        return nil;
//    }
    float duration = CMTimeGetSeconds(urlAsset.duration);
    // 根据asset构造一张图
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    // 设定缩略图的方向
    // 如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的（自己的理解）
    generator.appliesPreferredTrackTransform = YES;
    // 设置图片的最大size(分辨率)
    generator.maximumSize = CGSizeMake(100*[UIScreen mainScreen].scale, 80*[UIScreen mainScreen].scale);
    //如果需要精确时间
    //generator.requestedTimeToleranceAfter = kCMTimeZero;
    //generator.requestedTimeToleranceBefore = kCMTimeZero;
    //generator.requestedTimeToleranceBefore = CMTimeMakeWithSeconds(1.0, TIMESCALE);
    //generator.requestedTimeToleranceAfter = CMTimeMakeWithSeconds(2.0, TIMESCALE);
    float frameRate = 0.0;
    if ([[urlAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
        AVAssetTrack* clipVideoTrack = [[urlAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        frameRate = clipVideoTrack.nominalFrameRate;
    }
    // 初始化error
    NSError *error = nil;
    // 根据时间，获得第N帧的图片
    // CMTimeMake(a, b)可以理解为获得第a/b秒的frame
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(second, frameRate>0 ? frameRate : 30) actualTime:NULL error:&error];
    // 构造图片
    UIImage *image = [UIImage imageWithCGImage: img];
    CGImageRelease(img);
    
    if(error){
        error = nil;
    }
    urlAsset = nil;
    generator = nil;
    if(image){
        return image;
    }else{
        printf("\n\n============>%.f秒=====没有截图成功\n\n",second);
        return nil;
    }
}


/// 修正图片转向
+ (UIImage *)fixOrientation:(UIImage *)aImage {
//    return aImage;
    //if (!self.shouldFixOrientation) return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//获取字符串的文字域的高
+ (float)heightForString:(NSString *)value andWidth:(float)width fontSize:(float)fontSize
{
    CGSize sizeToFit = [value boundingRectWithSize:CGSizeMake(width,CGFLOAT_MAX)
                                           options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                           context:nil].size;
    return sizeToFit.height;
}

+ (NSString *)GetMD5WithContent:(NSString *)content{
    
    int64_t nFileSize = 0;
    MD5_CTX context;
    unsigned char digest[16] = {0};
    int i = 0;
    
    if (!content)
        return nil;
    NSData* temData = [content dataUsingEncoding:NSUTF8StringEncoding];
    nFileSize = temData.length;
    if(nFileSize >10*1024*1024)
        nFileSize = 10*1024*1024;
    
    NSData *data = [NSData dataWithBytes:[temData bytes] length:nFileSize];
    
    
    char *szMD5Code = malloc(2048);
    char* resultData =[data bytes];
    MD5Init(&context);
    MD5Update(&context, resultData, (int)(nFileSize));
    MD5Final(&context, digest);
    
    for(i = 0; i < 16; i++)
    {
        char szTmp[8] = {0};
        sprintf(szTmp,"%02x", digest[i]);
        strcat(szMD5Code,szTmp);
    }
    NSString *str=[NSString stringWithCString:szMD5Code encoding:NSUTF8StringEncoding];
    
    return str;
}


//+ (BOOL)OpenZip:(NSString*)zipPath  unzipto:(NSString*)_unzipto
//{
//    ZipArchive* zip = [[ZipArchive alloc] init];
//    if( [zip UnzipOpenFile:zipPath] )
//    {
//        //NSInteger index =0;
//        BOOL ret = [zip UnzipFileTo:_unzipto overWrite:YES];
//        if( NO==ret )
//        {
//            NSLog(@"error");
//        }else{
//            unlink([zipPath UTF8String]);
//        }
//        [zip UnzipCloseFile];
//        if (ret) {
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:_unzipto error:nil];
//            [fileArray enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
//                if([fileName containsString:@"__MACOSX"]) {
//                    [fileManager removeItemAtPath:[_unzipto stringByAppendingPathComponent:fileName] error:nil];
//                }
//            }];
//        }
//        return YES;
//    }
//    return NO;
//}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    ///下文中有分析
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}
+( UIViewController * )getCurrentViewController
{
    return  [HelpClass getCurrentVC];
}



+ (NSString *)getDocumentsDir{
    return kDocumentsDir;
}
+ (NSString *)getWebUploaderFolder{
    return kGSG_CDWebUploaderFolder;
}



@end
