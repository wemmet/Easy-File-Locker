/************************************************************************/
//Project:        NDF FILE SYSTEM
//Module:        NDF Read Kernel
//Author:
//Version:        3.0
//Date:            2016-06-09
/************************************************************************/


/******************************************************************************************/
// 函数名       : NDF_GetLastError
// 功能描述     : 得到错误号
// 返回值       : 错误号
/******************************************************************************************/
#ifndef _NDF_GETLAST_ERROR
#define _NDF_GETLAST_ERROR
DWORD NDF_GetLastError();
#endif


DWORD NDF_SetFileOffset(int64_t nOffset);

void NDF_SetOpenFileCallback(cb_open_file_priv cb_openFile);

/******************************************************************************************/
// 函数名       : NDF_GetVersion
// 功能描述     : 得到NDF文件版本信息
// 参数            : szFile[IN]            NDF文件路径
//                : szVersion[OUT]        版本号
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD    NDF_GetVersion(const utf8* szFile, utf8* szVersion);

/******************************************************************************************/
// 函数名       : NDF_GetFileId
// 功能描述     : 得到NDF文件唯一Id号
// 参数            : szFile[IN]            NDF文件路径
//                : szFileId[OUT]            唯一Id号
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetFileId(const utf8* szFile, utf8* szFileId);

/******************************************************************************************/
// 函数名       : NDF_GetAuthorId
// 功能描述     : 得到NDF文件作者Id
// 参数            : szFile[IN]            NDF文件路径
//                : szAuthorId[OUT]        作者Id
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetAuthorId(const utf8* szFile, utf8* szAuthorId);

/******************************************************************************************/
// 函数名       : NDF_IsExistPassword
// 功能描述     : NDF文件是否存在密码
// 参数            : szFile[IN]            NDF文件路径
// 返回值       : DWORD        =0  没有
//                            =1  存在
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_IsExistPassword(const utf8* szFile);

/******************************************************************************************/
// 函数名       : NDF_IsEditable
// 功能描述     : NDF文件是否可以编辑
// 参数            : szFile[IN]            NDF文件路径
// 返回值       : DWORD        =0  不可以
//                            =1  可以
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_IsEditable(const utf8* szFile);

/******************************************************************************************/
// 函数名       : NDF_GetPackageType
// 功能描述     : 得到NDF文件包类型
// 参数            : szFile[IN]            NDF文件路径
// 返回值       : DWORD        包类型
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetPackageType(const utf8* szFile);

/******************************************************************************************/
// 函数名       : NDF_GetTitle
// 功能描述     : 得到NDF文件标题
// 参数            : szFile[IN]            NDF文件路径
//                : szTitle[OUT]            文件标题 UTF-8
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetTitle(const utf8* szFile, utf8* szTitle);

/******************************************************************************************/
// 函数名       : NDF_GetTitle2
// 功能描述     : 得到NDF文件标题
// 参数            : szFile[IN]            NDF文件路径
//                : szTitle[OUT]            文件标题 UTF-8
//                : nTitleLen[OUT]        文件标题长度 不包含\0
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄 2.0版本后使用改接口
/******************************************************************************************/
DWORD NDF_GetTitle2(const utf8* szFile, utf8* szTitle, int *nTitleLen);

/******************************************************************************************/
// 函数名       : NDF_GetTitle2
// 功能描述     : 得到NDF文件标题
// 参数            : szFile[IN]            NDF文件路径
//                : szTitle[OUT]            文件标题 UTF-8
//                : nTitleLen[OUT]        文件标题长度 不包含\0
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 获取文件的GUID
/******************************************************************************************/
DWORD NDF_GetGuid(const utf8* szFile, utf8* szGuid, int *nGuid);

/******************************************************************************************/
// 函数名       : NDF_GetDescription
// 功能描述     : 得到NDF文件标题
// 参数            : szFile[IN]                NDF文件路径
//                : szDescription[OUT]        文件描述 UTF-8
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetDescription(const utf8* szFile, utf8* szDescription);

/******************************************************************************************/
// 函数名       : NDF_GetPlayerConfig
// 功能描述     : 得到NDF文件
// 参数            : szFile[IN]                NDF文件路径
//                : playCfg[OUT]
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetPlayerConfig(const utf8* szFile, VIDEO_PLAYER_CONFIG *playCfg);

/******************************************************************************************/
// 函数名       : NDF_GetAntiCopyQAContext
// 功能描述     : 得到NDF文件反拷贝问题
// 参数            : szFile[IN]                NDF文件路径
//                : pContext[OUT]
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetAntiCopyQAContext(const utf8* szFile,ANTICOPYQA *pContext);


/******************************************************************************************/
// 函数名       : NDF_GetPlayerUsbCopyConfig
// 功能描述     : 得到usb copy下的用户配置文件
// 参数            : szFile[IN]                NDF文件路径
//                : cfg[OUT]
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetPlayerUsbCopyConfig(const utf8* szFile, DRM_USB_COPY_CONFIG *cfg);


/******************************************************************************************/
// 函数名       : NDF_GetDescription2
// 功能描述     : 得到NDF文件标题
// 参数            : szFile[IN]                NDF文件路径
//                : szDescription[OUT]        文件描述 UTF-8
//                : nDesLen[OUT]                文件描述字符长度 不包含\0
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄 2.0版本后使用改接口
/******************************************************************************************/
DWORD NDF_GetDescription2(const utf8* szFile, utf8* szDescription, int *nDesLen);

/******************************************************************************************/
// 函数名       : NDF_GetCoverPhoto
// 功能描述     : 得到NDF文件封皮数据
// 参数            : szFile[IN]                NDF文件路径
//                : nPhotoType                图片类型
//                : pCoverPhotoBuff[IN/OUT]    图片数据
//                : size[IN/OUT]                数据长度
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 使用描述        : 分2次调用
//                            第一次获取长度 NDF_GetCoverPhoto(hNDF, &nPhotoType,NULL, &size);
//                            第二次获取数据 NDF_GetCoverPhoto(hNDF, &nPhotoType,pCoverPhotoBuff,&size);
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetCoverPhoto(const utf8* szFile, uint8_t *nPhotoType,uint8_t* pCoverPhotoBuff, int* size);

/******************************************************************************************/
// 函数名       : NDF_GetVideoSnapshot
// 功能描述     : 得到NDF文件视频快照
// 参数            : szFile[IN]                NDF文件路径
//                : index[IN]                    序号 范围 1~6
//                : pCoverPhotoBuff[IN/OUT]    图片数据 JPG格式
//                : size[IN/OUT]                数据长度
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 使用描述        : 分2次调用
//                            第一次获取长度 NDF_GetVideoSnapshot(hNDF, 1, NULL, &size);
//                            第二次获取数据 NDF_GetVideoSnapshot(hNDF, 1, pSnapshotBuff,&size);
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetVideoSnapshot(const utf8* szFile, int index, uint8_t* pSnapshotBuff, int* size);

/******************************************************************************************/
// 函数名       : NDF_GetPublicSize
// 功能描述     : 得到NDF文件公开区文件大小
// 参数            : szFile[IN]                NDF文件路径
//                : size[IN/OUT]                数据长度
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetPublicSize(const utf8* szFile, int64_t* size);

/******************************************************************************************/
// 函数名       : NDF_GetVipVipSize
// 功能描述     : 得到NDF文件VIP区文件大小
// 参数            : szFile[IN]                NDF文件路径
//                : size[IN/OUT]                数据长度
// 返回值       : DWORD        =0  成功
//                            >0  失败
// 说明            : 此接口不需要句柄
/******************************************************************************************/
DWORD NDF_GetVipVipSize(const utf8* szFile, int64_t* size);

/******************************************************************************************/
// 函数名       : NDF_UsbCopyLoginAdmin
// 功能描述     : 设置是否是管理员登录
// 参数            : nAdmin 0 非管理员 1管理员
// 返回值       :
/******************************************************************************************/
void    NDF_UsbCopyLoginAdmin(int nAdmin);

/******************************************************************************************/
// 函数名       : NDF_Open
// 功能描述     : 创建NDF解析文件系统对象
// 参数            : szFile            NDF文件路径
//                : pPassword            用户密码
//                : nLen                密码长度
// 返回值       : HNdfObject
/******************************************************************************************/
HNdfObject NDF_Open(const utf8* szFile,    uint8_t* pPassword, int nLen);

/******************************************************************************************/
// 函数名       : NDF_Close
// 功能描述     : 释放NDF文件系统对象
// 参数            : hNDF            NDF文件系统对象
// 返回值       : 无
/******************************************************************************************/
void NDF_Close(HNdfObject hNDF);

/******************************************************************************************/
// 函数名       : NDF_IsOnlineBookUrl
// 功能描述     : 判断是否是在线电子书类型的网页地址列表
// 参数            : hNDF[IN]                NDF文件系统对象
//                nResult[IN/OUT]       结果
// 返回值       : DWORD        =0  成功
//                        >0  失败
// 如果是此类型，获取文件列表的方式，请调用NDF_GetOnlineBookItemList接口
/******************************************************************************************/
DWORD NDF_IsOnlineBookUrl(HNdfObject hNDF, int *nResult);


/******************************************************************************************/
// 函数名       : NDF_GetOnlineBookItemList
// 功能描述     : 获取电子书的网页列表
// 参数            : hNDF[IN]                NDF文件系统对象
//
// 返回值       : 列表
// 备注            : 1 如果返回NULL,再次调用NDF_GetOnlineBookUpdateList查看是否存在更新列表
//                    如果存在，走更新列表的相应逻辑
//                2 使用完成后需要调用NDF_FreeOnlineBookItemList释放内存
/******************************************************************************************/
ONLINEBOOK_ITEM_LIST* NDF_GetOnlineBookItemList(HNdfObject hNDF);

/******************************************************************************************/
// 函数名       : NDF_FreeOnlineBookItemList
// 功能描述     : 是否列表的内存
// 参数            : item_list[IN]                列表
//
// 返回值       :
/******************************************************************************************/
DWORD NDF_FreeOnlineBookItemList(ONLINEBOOK_ITEM_LIST* item_list);

/******************************************************************************************/
// 函数名       : NDF_GetOnlineBookUpdateList
// 功能描述     : 获取电子书的更新列表
// 参数            : hNDF[IN]                NDF文件系统对象
//
// 返回值       : 列表
// 备注            :
/******************************************************************************************/
ONLINEBOOK_UPDATE_LIST* NDF_GetOnlineBookUpdateList(HNdfObject hNDF);

/******************************************************************************************/
// 函数名       : NDF_GetOnlineBookUpdateList
// 功能描述     : 获取电子书的加密key
// 参数            : hNDF[IN]                NDF文件系统对象
//
// 返回值       :
// 备注            :
/******************************************************************************************/
DWORD NDF_GetOnlineBookEncryptKey(HNdfObject hNDF, char* szUTF8Key, int *nLenKey);

/******************************************************************************************/
// 函数名       : NDF_GetAdType
// 功能描述     : 获取广告类型
// 参数            : hNDF[IN]                NDF文件系统对象
//                : adType[OUT]
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_GetAdType(HNdfObject hNDF, uint8_t *adType);

/******************************************************************************************/
// 函数名       : NDF_GetAdText
// 功能描述     : 获取广告文本数据[NDF_AD_TEXT有效]
// 参数            : hNDF[IN]                NDF文件系统对象
//                : szText[IN/OUT]
//                : size[IN/OUT]
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_GetAdText(HNdfObject hNDF, utf8* szText, int *size);

/******************************************************************************************/
// 函数名       : NDF_GetAdUrl
// 功能描述     : 获取广告URL
// 参数            : hNDF[IN]                NDF文件系统对象
//                : szUrl[IN/OUT]
//                : size[IN/OUT]
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_GetAdUrl(HNdfObject hNDF, utf8* szUrl, int *size);

/******************************************************************************************/
// 函数名       : NDF_GetAdPhoto
// 功能描述     : 获取图片广告数据
// 参数            : hNDF[IN]                NDF文件系统对象
//                : nPhotoType[IN/OUT]
//                : pPhotoBuff[IN/OUT]
//                : size[IN/OUT]
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_GetAdPhoto(HNdfObject hNDF, uint8_t *nPhotoType, uint8_t* pPhotoBuff, int *size);

/******************************************************************************************/
// 函数名       : NDF_GetPublicPrivilege
// 功能描述     : 获取公开区区域属性[隐私级别]
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : nPrivilegeAccess[OUT]        见enum NDF_PUBLIC_PRIVILEGE_ACCESS
//                : nPrivilegeExport[OUT]        见enum NDF_PRIVILEGE_EXPORT
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_GetPublicPrivilege(HNdfObject hNDF, int *nPrivilegeAccess, int *nPrivilegeExport);

/******************************************************************************************/
// 函数名       : NDF_GetVipPrivilege
// 功能描述     : 获取VIP区域属性[隐私级别]
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : nPrivilegeAccess[OUT]        见enum NDF_VIPVIP_PRIVILEGE_ACCESS
//                : nPrivilegeExport[OUT]        见enum NDF_PRIVILEGE_EXPORT
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_GetVipPrivilege(HNdfObject hNDF, int *nPrivilegeAccess, int *nPrivilegeExport);

/******************************************************************************************/
// 函数名       : NDF_GetVipPrivilegeEx
// 功能描述     : 获取VIP区域扩展属性[隐私级别]
// 参数            : hNDF[IN]                NDF文件系统对象
//                : nViewPercent[OUT]        可见百分比【0~100】
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_GetVipPrivilegeEx(HNdfObject hNDF, utf8 *szVipEx);

/******************************************************************************************/
// 函数名       : NDF_GetPublicTotalFiles
// 功能描述     : 获取公开区文件总数
// 参数            : hNDF[IN]                NDF文件系统对象
//                : nTotalFiles[OUT]        文件总数
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD    NDF_GetPublicTotalFiles(HNdfObject hNDF, uint32_t *nTotalFiles);

/******************************************************************************************/
// 函数名       : NDF_GetPublicTotalDirs
// 功能描述     : 获取公开区目录总数
// 参数            : hNDF[IN]                NDF文件系统对象
//                : nTotalDirs[OUT]        目录总数
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD    NDF_GetPublicTotalDirs(HNdfObject hNDF, uint32_t *nTotalDirs);

/******************************************************************************************/
// 函数名       : NDF_GetVipVipTotalFiles
// 功能描述     : 获取VIP区文件总数
// 参数            : hNDF[IN]                NDF文件系统对象
//                : nTotalFiles[OUT]        文件总数
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD    NDF_GetVipVipTotalFiles(HNdfObject hNDF, uint32_t *nTotalFiles);

/******************************************************************************************/
// 函数名       : NDF_GetVipVipTotalDirs
// 功能描述     : 获取VIP区目录总数
// 参数            : hNDF[IN]                NDF文件系统对象
//                : nTotalDirs[OUT]        目录总数
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD    NDF_GetVipVipTotalDirs(HNdfObject hNDF, uint32_t *nTotalDirs);


/******************************************************************************************/
// 函数名       : NDF_FindFirstFile
// 功能描述     : 查找文件目录下的第一个文件
// 参数            : hNDF[IN]                NDF文件系统对象
//                : szPath[IN]            目标路径
//                                                    如果是公开区则以\public\开始 如根目录 \public\*.*
//                                                    如果是公开区则以\vipvip\开始 如根目录 \vipvip\*.*
//                : pFindFileData[OUT]    结果
// 返回值       : HNdfDirectory            查找句柄
/******************************************************************************************/
HNdfDirectory NDF_FindFirstFile(HNdfObject hNDF, utf8* szPath, NDF_FIND_DATA *pFindFileData);

/******************************************************************************************/
// 函数名       : NDF_FindNextFile
// 功能描述     : 查找文件目录的下一个文件
// 参数            : hNDF[IN]                NDF文件系统对象
//                : hFindFile[IN]            查找句柄
//                : pFindFileData[OUT]    结果属性
// 返回值       : int        >0  成功
//                            =0  查找完成
//                            <0  失败
/******************************************************************************************/
bool NDF_FindNextFile(HNdfObject hNDF, HNdfDirectory hFindFile, NDF_FIND_DATA *pFindFileData);

/******************************************************************************************/
// 函数名       : NDF_FindClose
// 功能描述     : 关闭文件句柄
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFindFile[IN]                查找句柄
// 返回值       : int        >0  成功
//                            <0  失败
/******************************************************************************************/
bool NDF_FindClose(HNdfObject hNDF,HNdfDirectory hFindFile);

/******************************************************************************************/
// 函数名       : NDF_OpenFile
// 功能描述     : 打开文件
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : szFileName[IN]            文件名[根目录下文件为为\public\sample.jpg]
//                                                 其它目录,如根目录下的TestDir文件夹\public\TestDir\sample.jpg
// 返回值       : HNdfFile                    文件句柄
/******************************************************************************************/
HNdfFile NDF_OpenFile(HNdfObject hNDF, const utf8* szFileName);


/******************************************************************************************/
// 函数名       : NDF_GetFileType
// 功能描述     : 得到文件类型
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFile[IN]                    文件句柄
// 返回值       : DWORD                        文件类型
/******************************************************************************************/
DWORD NDF_GetFileType(HNdfObject hNDF, HNdfFile hFile);

/******************************************************************************************/
// 函数名       : NDF_GetFileAttributes
// 功能描述     : 得到文件属性
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFile[IN]                    文件句柄
// 返回值       : DWORD                        文件属性
/******************************************************************************************/
DWORD NDF_GetFileAttributes(HNdfObject hNDF, HNdfFile hFile);

/******************************************************************************************/
// 函数名       : NDF_GetFileEncryptBlockSize
// 功能描述     : 得到文件分块加密大小
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFile[IN]                    文件句柄
// 返回值       : DWORD                        文件分块加密大小
/******************************************************************************************/
DWORD NDF_GetFileEncryptBlockSize(HNdfObject hNDF, HNdfFile hFile);

/******************************************************************************************/
// 函数名       : NDF_GetFileOffset
// 功能描述     : 得到文件在整个NDF文件的偏移地址
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFile[IN]                    文件句柄
// 返回值       : int64_t                    偏移地址
/******************************************************************************************/
int64_t NDF_GetFileOffset(HNdfObject hNDF, HNdfFile hFile);

/******************************************************************************************/
// 函数名       : NDF_ReadFile
// 功能描述     : 读取文件数据
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFile[IN]                    文件句柄
//                : pUnpacketFileData[IN/OUT]    解密解压后数据[当为NULL nSize返回需要分配的内存长度]
//                : nSize[IN/OUT]                分配的内存长度
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_ReadFile(HNdfObject hNDF, HNdfFile hFile, uint8_t *pUnpacketFileData, int64_t *nSize);

/******************************************************************************************/
// 函数名       : NDF_ReadThumbFile
// 功能描述     : 读取文件对应的缩略图数据[NDF_FILE_JPG,NDF_FILE_BMP,NDF_FILE_PNG]三种格式才存在
// 参数            : hNDF[IN]                        NDF文件系统对象
//                : hFile[IN]                        文件句柄
//                : pUnpacketFileData[IN/OUT]        解密解压后数据[当为NULL nSize返回需要分配的内存长度]
//                : nSize[IN/OUT]                    分配的内存长度
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_ReadThumbFile(HNdfObject hNDF, HNdfFile hFile, uint8_t *pUnpacketThumbData, int64_t *nSize);

/******************************************************************************************/
// 函数名       : NDF_GetTxtTotalChapters
// 功能描述     : 得到文本文件的章节数【文本文件才能调用该接口】
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFile[IN]                    文件句柄
// 返回值       : int                    <0 错误号 >=0 章节数
/******************************************************************************************/
int   NDF_GetTxtTotalChapters(HNdfObject hNDF, HNdfFile hFile);

/******************************************************************************************/
// 函数名       : NDF_GetTxtFileFormat
// 功能描述     : 得到文本文件的格式 参见NDF_FILE_STRING_FORMAT
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFile[IN]                    文件句柄
// 返回值       :                             参见NDF_FILE_STRING_FORMAT
/******************************************************************************************/
DWORD NDF_GetTxtFileFormat(HNdfObject hNDF, HNdfFile hFile);

/******************************************************************************************/
// 函数名       : NDF_ReadTxtChapter
// 功能描述     : 读取文本文件的章节内容【文本文件才能调用该接口】
// 参数            : hNDF[IN]                        NDF文件系统对象
//                : hFile[IN]                        文件句柄
//                : nChapter[IN]                    章节数 从1开始
//                : pUnpacketFileData[IN/OUT]        解密解压后数据(utf8字符串)[当为NULL nSize返回需要分配的内存长度]
//                : nSize[IN/OUT]                    分配的内存长度
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_ReadTxtChapter(HNdfObject hNDF, HNdfFile hFile, int nChapter, uint8_t *pUnpacketFileData, int64_t *nSize);
 

/******************************************************************************************/
// 函数名       : NDF_CloseFile
// 功能描述     : 关闭文件句柄
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : hFile[IN]                    文件句柄
// 返回值       : int        >0  成功
//                            <0  失败
/******************************************************************************************/
bool NDF_CloseFile(HNdfObject hNDF, HNdfFile hFile);


/******************************************************************************************/
// 函数名       : NDF_DeleteFile
// 功能描述     : 删除文件
// 参数            : hNDF[IN]                NDF文件系统对象
//                : szFileName[IN]        文件名
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_DeleteFile(HNdfObject hNDF, const utf8* szFileName);

/******************************************************************************************/
// 函数名       : NDF_DeleteDirectory
// 功能描述     : 删除目录
// 参数            : hNDF[IN]                NDF文件系统对象
//                : szDirName[IN]            目录名
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_DeleteDirectory(HNdfObject hNDF, const utf8* szDirName);

/******************************************************************************************/
// 函数名       : NDF_GetAppendRootDirctory
// 功能描述     : 得到需要增加文件&目录的目录节点
// 参数            : hNDF[IN]                NDF文件系统对象
//                : szDirName[IN]            目录名
// 返回值       : HNdfDirectory            目录句柄
/******************************************************************************************/
HNdfDirectory NDF_GetAppendRootDirctory(HNdfObject hNDF, const utf8* szDirNam);

/******************************************************************************************/
// 函数名       : NDF_AppendDirectory
// 功能描述     : 添加子目录
// 参数            : hNDF[IN]                NDF文件系统对象
//                : hParent[IN]            父目录句柄
//                : szItemName[IN]        目录显示名称
//                : nExport[IN]            此目录是否允许导出所有目录下的文件
// 返回值       : HNdfDirectory            目录句柄
/******************************************************************************************/
HNdfDirectory NDF_AppendDirectory(HNdfObject hNDF,HNdfDirectory hParent,const utf8* szItemName,int nExport);

/******************************************************************************************/
// 函数名       : NDF_AppendFile
// 功能描述     : 添加文件
// 参数            : hNDF[IN]                NDF文件系统对象
//                : hParent[IN]            父目录句柄
//                : szItemName[IN]        文件显示名称
//                : szPath[IN]            文件路径
//                : nEncrypt[IN]            是否加密
//                : nCompress[IN]            是否压缩
//                : nExport[IN]            此文件是否允许导出为磁盘文件
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD    NDF_AppendFile(HNdfObject hNDF, HNdfDirectory hParent, const utf8* szName, const utf8* szPath,
                    int nEncrypt, int nCompress, int nExport);

/******************************************************************************************/
// 函数名       : NDF_BudilAppend
// 功能描述     : 保存增加的文件&目录
// 参数            : hNDF[IN]                    NDF文件系统对象
//                : CB_NdfMakeProgress[IN]    进度回调函数
//                : pCbParam[IN]                回调函数参数
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_BuildAppend(HNdfObject hNDF,CB_NDFProgress pCBProgress, void *pCbParam);


/******************************************************************************************/
// 函数名       : NDF_StopAppend
// 功能描述     : 取消更新NDF文件
// 参数            : hNDF[IN]                    NDF文件系统对象
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD NDF_StopAppend(HNdfObject hNDF);


/******************************************************************************************/
// 函数名       : NDF_Encrypt_String
// 功能描述     : 加密字符串
// 参数            : szSrc[IN]                    需加密的字符串
//                : szKey[IN]                    加密密钥
// 返回值       : 加密后的字符串
// 备注            : 使用完成后需要调用NDF_Free_String释放内存
/******************************************************************************************/
wchar_t* NDF_Encrypt_String(wchar_t* szSrc, wchar_t* szKey);

/******************************************************************************************/
// 函数名       : NDF_Decrypt_String
// 功能描述     : 解密字符串
// 参数            : szSrc[IN]                    需解密的字符串
//                : szKey[IN]                    加密密钥
// 返回值       : 解密后的字符串
// 备注            : 使用完成后需要调用NDF_Free_String释放内存
/******************************************************************************************/
wchar_t* NDF_Decrypt_String(wchar_t* szSrc, wchar_t* szKey);

/******************************************************************************************/
// 函数名       : NDF_Free_String
// 功能描述     : 释放内存
// 参数            : szString[IN]
// 返回值       :
//
/******************************************************************************************/
void     NDF_Free_String(wchar_t* szString);


/******************************************************************************************/
// 函数名       : NDF_Encrypt_Buff
// 功能描述     : 加密内存数据
// 参数            : szKey[IN]                    加密密钥
//                : pBuff[IN]                    数据块
//                : nBuffSize[IN]                数据大小
//                : nCompress[IN]                是否压缩 1压缩 0不压缩
//                : nResultSize[OUT]            加密后数据大小
// 返回值       : 加密后的数据块
// 备注            : 1 使用完成后需要调用NDF_Free_Buff释放内存
//                  2 如果不压缩, 数据长度最好为8的整数倍，否则8的余数字节的数据不会被加密 因为采用AES256
/******************************************************************************************/
uint8_t* NDF_Encrypt_Buff(wchar_t* szKey,uint8_t *pBuff, int nBuffSize, int nCompress, int *nResultSize);

/******************************************************************************************/
// 函数名       : NDF_Decrypt_Buff
// 功能描述     : 解密内存数据
// 参数            : szKey[IN]                    加密密钥
//                : pBuff[IN]                    数据块
//                : nBuffSize[IN]                数据大小
//                : nCompress[IN]                是否压缩过 1压缩 0不压缩
//                : nResultSize[OUT]            加密后数据大小
// 返回值       : 解密后的数据块
// 备注            : 使用完成后需要调用NDF_Free_Buff释放内存
/******************************************************************************************/
uint8_t* NDF_Decrypt_Buff(wchar_t* szKey,uint8_t *pBuff, int nBuffSize, int nCompress, int *nResultSize);

/******************************************************************************************/
// 函数名       : NDF_Free_Buff
// 功能描述     : 释放内存
// 参数            : pBuff[IN]
// 返回值       :
//
/******************************************************************************************/
void     NDF_Free_Buff(uint8_t* pBuff);

/******************************************************************************************/
// 函数名       : SetLoadInternetDataCallback
// 功能描述     : 设置从URL中加载源码或者图片数据的回调函数
// 参数            : pfnLoad[IN]
// 返回值       :
//
/******************************************************************************************/
DWORD SetLoadInternetDataCallback(fnLoadInternetData pfnLoad);

/******************************************************************************************/
// 函数名       : SetFreeInternetDataCallback
// 功能描述     : 设置从释放数据回调函数
// 参数            : pfnFree[IN]
// 返回值       :
//
/******************************************************************************************/
DWORD SetFreeInternetDataCallback(fnFreeInternetData pfnFree);

/******************************************************************************************/
// 函数名       : SetWideCharToMultiByteCallback
// 功能描述     : 设置宽字符转多字节回调函数
// 参数            : pfnWideCharToMultiByte[IN]
// 返回值       :
//
/******************************************************************************************/
DWORD SetWideCharToMultiByteCallback(fnWideCharToMultiByte pfnWideCharToMultiByte);

/******************************************************************************************/
// 函数名       : SetMultiByteToWideCharCallback
// 功能描述     : 设置多字节转宽字符回调函数
// 参数            : pfnMultiByteToWideChar[IN]
// 返回值       :
//
/******************************************************************************************/
DWORD SetMultiByteToWideCharCallback(fnMultiByteToWideChar pfnMultiByteToWideChar);

/******************************************************************************************/
// 函数名       : GetOnlineBookItemUpdateList
// 功能描述     : 根据URL得到在线电子杂志的显示列表与更新列表等相关信息
// 参数            : szUTF8URL[IN]
// 参数            : szUTF8Encrypt[IN]
// 参数            : pOnlineBookItemUpdateList[OUT]
// 返回值       :
//
/******************************************************************************************/
DWORD GetOnlineBookItemUpdateList(char* szUTF8URL, char *szUTF8Encrypt, ONLINEBOOK_ITEM_UPDATE_LIST *pOnlineBookItemUpdateList);

/******************************************************************************************/
// 函数名       : FreeOnlineBookItemUpdateList
// 功能描述     : 释放得到的在线杂志列表信息
// 参数            : pOnlineBookItemUpdateList[IN]
// 返回值       :
//
/******************************************************************************************/
DWORD FreeOnlineBookItemUpdateList(ONLINEBOOK_ITEM_UPDATE_LIST *pOnlineBookItemUpdateList);

//ios设置设备信息
DWORD SetDeveiceInfo(char* szMainborad, char* szHarddisk, char* szCpu);

DWORD SetGUIDString(char* szGuid);

//设置移动设备ID
DWORD SetUSBSeriIDString(char* szUSBSeriID);

//如果是DEVICE_TYPE_USB类型文件,GetMachineCode之前先调用该接口, 当MACHINE_CODE_REMOVEDISK时,用于计算机器码
//windows平台使用
DWORD SetCurrentRemoveDriver(char* szRemoveDriver);

//设置当前绑定设备ID当MACHINE_CODE_REMOVEDISK时,用于计算机器码
//移动平台使用(移动平台没有盘符概念)
DWORD SetCurrentRemoveGemBindDevID(char* szBindDevID);

//获取机器码
//000X-AAAA-BBBB-CCCC形式
DWORD GetMachineCode(DWORD dwCPType, DWORD dwFlag, char *szMachineCode);

//生成注册码
DWORD EncodeLicenceCode(char*szLicence, char *szMachineCode, char*szPw, utf8*szWaterMark, char* szTimeout, int nMaxNum, int nMaxTime);

//生成注册码(增加是否网络验证)
DWORD EncodeLicenceCode2(char*szLicence, char *szMachineCode, char*szPw, utf8*szWaterMark, char* szTimeout, int nMaxNum, int nMaxTime, int nCheckTimeUseNetTime);

//生成注册码(增加播放页面)
DWORD EncodeLicenceCode3(char*szLicence, char *szMachineCode, char*szPw, utf8*szWaterMark, char* szTimeout, int nMaxNum, int nMaxTime, int nCheckTimeUseNetTime, int nMaxPreviewPageCount);

//解析注册码
DWORD DecodeLicenceCode(char*szLicence, char *szMachineCode, char*szPw, utf8*szWaterMark, char* szTimeout, int *nMaxNum, int *nMaxTime);

//解析注册码(增加是否网络验证)
DWORD DecodeLicenceCode2(char*szLicence, char *szMachineCode, char*szPw, utf8*szWaterMark, char* szTimeout, int *nMaxNum, int *nMaxTime, int *nCheckTimeUseNetTime);

//解析注册码(增加播放页面)
DWORD DecodeLicenceCode3(char*szLicence, char *szMachineCode, char*szPw, utf8*szWaterMark, char* szTimeout, int *nMaxNum, int *nMaxTime, int *nCheckTimeUseNetTime, int *nMaxPreviewPageCount);

/*
szParamJson的格式如下
{
    "param0":    "0003-0D0A-038D-00E8",
        "param1" : "123456",
        "param2" : "Test Watermark",
        "param3" : " ",
        "param4" : "0",
        "param5" : "0",
        "param6" : "2",
        "param7" : "0"
}
*/
//生成注册码
DWORD EncodeLicenceCode4(char* szLicence, char* szParamJson);
//解析注册码
DWORD DecodeLicenceCode4(char* szLicence, char* szParamJson);



//得到文件的MD5码
DWORD GetMD5Code(utf8* szFilePath, char *szMD5Code);

//是否连网 WINDOWS
bool IsOnline( );

//是否虚拟机 WINDOWS
bool IsVirMache();

//是否U盘 WINDOWS
bool IsUsbDsik(char chDisk);

//是否CD盘 WINDOWS
bool IsCDRom(char chDisk);

//
bool IsRunVideoRecorder();

bool IsRunVideoRecorder2(utf8* szProcessName);

//制作文件
DWORD CreateUserPlayerCfgFile(VIDEOPLAYERUSERDEFINEPARAM userParam, utf8* szCfgPath);
//是否为有效的配置文件
bool IsUserPlayerCfgFile(utf8* szCfgPath);
//获取title
DWORD GetUserPlayerTitle(const utf8* szCfgPath, utf8* szTitle, int *nTitleLen);
//获取homepage
DWORD GetUserPlayerHomePage(const utf8* szCfgPath, utf8* szHomepage, int *nHomepage);
//获取icon图buff
DWORD GetUserPlayerIcon(const utf8* szCfgPath, uint8_t* pPhotoBuff, int* nBuffSize);
//BG Img
DWORD GetUserPlayerBgImg(const utf8* szCfgPath, uint8_t* pPhotoBuff, int* nBuffSize);
//更新反拷贝信息
DWORD Ndf_UpdateFileID(const utf8* szPath, utf8* szFileId);
//更新绑定类型
DWORD Ndf_UpdateBindType(const utf8* szPath, int nBindType);

//从服务器获取系统时间
#ifdef _WINDOWS
bool GetDateTimeFromServer(char* szServer,SYSTEMTIME *st);

//先检查当前USB盘上是否存在保存USB序列号的配置文件
bool GetUSBDiskSerialNum(char chDisk, utf8* szSerialNum);


//获取U盘的GUDI szSerialNum 长度为1024 szSerialNumALL 1024
bool GetUSBDiskSerialNumALL(char chDisk, utf8* szSerialNum,utf8* szSerialNumALL);

#endif
