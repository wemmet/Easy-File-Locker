/************************************************************************/
//Project:		NDF FILE SYSTEM
//Module:		NDF Write Kernel
//Author:		                                                                      
//Version:		3.0                                                                      
//Date:			2016-06-01
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

/******************************************************************************************/
// 函数名       : NDF_CreateWriteObject
// 功能描述     : 创建NDF文件系统对象
// 参数			: 
// 返回值       : HNdfObject
/******************************************************************************************/
HNdfObject NDF_CreateWriteObject();

/******************************************************************************************/
// 函数名       : NDF_CloseWriteObject
// 功能描述     : 关闭NDF文件系统对象
// 参数			: hNDF			NDF文件系统对象
// 返回值       : 无
/******************************************************************************************/
void NDF_CloseWriteObject(HNdfObject hNDF);

/******************************************************************************************/
// 函数名       : NDF_SetVersion
// 功能描述     : 设置NDF文件版本信息
// 参数			: hNDF[IN]				NDF文件系统对象
//				: szVersion[IN]			版本号
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetVersion(HNdfObject hNDF, const utf8* szVersion);

/******************************************************************************************/
// 函数名       : NDF_SetFileId
// 功能描述     : 设置NDF文件唯一Id号
// 参数			: hNDF[IN]				NDF文件系统对象
//				: szFileId[IN]			文件唯一Id号
// 返回值       : DWORD		=0  成功	
//							>0  失败
//备注: 当前接口用于传递磁盘描述信息，用户反拷贝功能
/******************************************************************************************/
DWORD NDF_SetFileId(HNdfObject hNDF, const utf8* szFileId);

/******************************************************************************************/
// 函数名       : NDF_SetAuthorId
// 功能描述     : 设置NDF作者Id
// 参数			: hNDF[IN]				NDF文件系统对象
//				: szFileId[IN]			作者Id
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetAuthorId(HNdfObject hNDF, const utf8* szAuthorId);

/******************************************************************************************/
// 函数名       : NDF_SetPassword
// 功能描述     : 设置NDF文件用户密码
//					用处：	1 配合生成密钥
//							2 散列成16位的向量
// 参数			: hNDF[IN]		NDF文件系统对象
//				: password[IN]	密码数据
//				: size[IN]		密码长度
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetPassword(HNdfObject hNDF, uint8_t *password, int size);

/******************************************************************************************/
// 函数名       : NDF_SetEditPassword
// 功能描述     : 设置NDF文件用户编辑密码
//					用处：	1 配合生成密钥
//							2 散列成16位的向量
// 参数			: hNDF[IN]		NDF文件系统对象
//				: password[IN]	密码数据
//				: size[IN]		密码长度
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetEditPassword(HNdfObject hNDF, uint8_t *password, int size);


/******************************************************************************************/
// 函数名       : NDF_SetNDFFileType
// 功能描述     : 设置NDF文件类型
// 参数			: hNDF[IN]		NDF文件系统对象
//				: nFileType[IN]	文件类型
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetNDFPackageType(HNdfObject hNDF, int nType);

/******************************************************************************************/
// 函数名       : NDF_SetTitle
// 功能描述     : 设置NDF文件标题
// 参数			: hNDF[IN]				NDF文件系统对象
//				: szTitle[IN]			文件标题
// 返回值       : DWORD		=0  成功	
//							>0  失败
//
/******************************************************************************************/
DWORD NDF_SetTitle(HNdfObject hNDF, const utf8* szTitle);

/******************************************************************************************/
// 函数名       : NDF_SetPlayerConfig
// 功能描述     : 设置NDF文件播放端的控制
// 参数			: hNDF[IN]				NDF文件系统对象
//				: playCfg[IN]			文件标题
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetPlayerConfig(HNdfObject hNDF, VIDEO_PLAYER_CONFIG playCfg);


/******************************************************************************************/
// 函数名       : NDF_SetPlayerUSBCopyConfig
// 功能描述     : 设置NDF文件usb模式下的配置文件
// 参数			: hNDF[IN]				NDF文件系统对象
//				: playCfg[IN]			文件标题
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetPlayerUSBCopyConfig(HNdfObject hNDF, DRM_USB_COPY_CONFIG cfg);


//设置问题列表
DWORD NDF_SetAntiCopyQWContext(HNdfObject hNDF,ANTICOPYQA *pCtx, int nNum);


/******************************************************************************************/
// 函数名       : NDF_SetDescription
// 功能描述     : 设置NDF文件标题
// 参数			: hNDF[IN]					NDF文件系统对象
//				: szDescription[IN]			文件描述
// 返回值       : DWORD		=0  成功	
//							>0  失败
// 备注: 当前接口无效！szDescription的位置被VIDEO_PLAYER_CONFIG占领
/******************************************************************************************/
DWORD NDF_SetDescription(HNdfObject hNDF, const utf8* szDescription);

/******************************************************************************************/
// 函数名       : NDF_SetCoverPhoto
// 功能描述     : 设置NDF文件封皮图
// 参数			: hNDF[IN]					NDF文件系统对象
//				: szCoverPath[IN]			文件封皮图路径
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetCoverPhoto(HNdfObject hNDF, const utf8* szCoverPath);

/******************************************************************************************/
// 函数名       : NDF_SetVideoSnapshot
// 功能描述     : 设置NDF文件视频快照
// 参数			: hNDF[IN]					NDF文件系统对象
//				: index[IN]					序数 范围 1~6
//				: szSnapshotPath[IN]		快照路径 仅支持jpg格式
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetVideoSnapshot(HNdfObject hNDF, int index, const utf8* szSnapshotPath);

/******************************************************************************************/
// 函数名       : NDF_SetAdData
// 功能描述     : 设置NDF文件广告相关数据
// 参数			: hNDF[IN]				NDF文件系统对象
//				: adType[IN]			广告类型
//				: szText[IN]			
//				: szUrl[IN]
//				: szPhotoPath[IN]
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetAdData(HNdfObject hNDF, int adType, const utf8* szText, const utf8* szUrl,
					const utf8* szPhotoPath);

/******************************************************************************************/
// 函数名       : NDF_SetPublicPrivilege
// 功能描述     : 设置pubic区域属性[隐私级别]
// 参数			: hNDF[IN]					NDF文件系统对象	
//				: nPrivilegeAccess[IN]		读取权限 见enum NDF_PUBLIC_PRIVILEGE_ACCESS
//				: nPrivilegeExport[IN]		导出权限 见enum NDF_PRIVILEGE_EXPORT
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetPublicPrivilege(HNdfObject hNDF, int nPrivilegeAccess, int nPrivilegeExport);

/******************************************************************************************/
// 函数名       : NDF_SetVipPrivilege
// 功能描述     : 设置VIP区域属性[隐私级别]
// 参数			: hNDF[IN]					NDF文件系统对象	
//				: nPrivilegeAccess[IN]		读取权限 见enum NDF_VIPVIP_PRIVILEGE_ACCESS
//				: nPrivilegeExport[IN]		导出权限 见enum NDF_PRIVILEGE_EXPORT
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetVipPrivilege(HNdfObject hNDF, int nPrivilegeAccess, int nPrivilegeExport);

/******************************************************************************************/
// 函数名       : NDF_SetVipPrivilegeEx
// 功能描述     : 设置VIP区域扩展属性[隐私级别]
// 参数			: hNDF[IN]					NDF文件系统对象	
//				: szVipEx[IN]				扩展属性
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetVipPrivilegeEx(HNdfObject hNDF, const utf8* szVipEx);

/******************************************************************************************/
// 函数名       : NDF_CreateRootFolder
// 功能描述     : 创建根目录
// 参数			: hNDF[IN]				NDF文件系统对象		
//				: nDirType[IN]			目录区类型 NDF_DIR_TREE
//				:						NDF_DIR_PUBLIC 公共阅读区
//										NDF_DIR_VIPVIP Vip区
// 返回值       : HNdfDirectory			目录句柄
/******************************************************************************************/
HNdfDirectory NDF_CreateRootDirectory(HNdfObject hNDF, int nDirType, int nExport);

/******************************************************************************************/
// 函数名       : NDF_AddDirectory
// 功能描述     : 添加子目录
// 参数			: hNDF[IN]				NDF文件系统对象
//				: hParent[IN]			父目录句柄
//				: szItemName[IN]		目录显示名称
//				: nExport[IN]			此目录是否允许导出所有目录下的文件
// 返回值       : HNdfDirectory			目录句柄
/******************************************************************************************/
HNdfDirectory NDF_AddDirectory(HNdfObject hNDF,HNdfDirectory hParent,const utf8* szItemName,int nExport);

/******************************************************************************************/
// 函数名       : NDF_AddFile
// 功能描述     : 添加文件
// 参数			: hNDF[IN]				NDF文件系统对象
//				: hParent[IN]			父目录句柄	
//				: szItemName[IN]		文件显示名称
//				: szPath[IN]			文件路径
//				: nEncrypt[IN]			是否加密
//				: nCompress[IN]			是否压缩
//				: nExport[IN]			此文件是否允许导出为磁盘文件
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD	NDF_AddFile(HNdfObject hNDF, HNdfDirectory hParent, const utf8* szName, const utf8* szPath, 
					int nEncrypt, int nCompress, int nExport);
/******************************************************************************************/
// 函数名       : NDF_AddFile
// 功能描述     : 添加文件
// 参数            : hNDF[IN]                NDF文件系统对象
//                : hParent[IN]            父目录句柄
//                : szItemName[IN]        文件显示名称
//                : szPath[IN]            文件路径
//                : nEncrypt[IN]            是否加密
//                : nCompress[IN]            是否压缩
//                : nExport[IN]            此文件是否允许导出为磁盘文件
//                : thumbBuff[IN]            缩略图buff
//                : nThumbBuffSize[IN]    缩略图buff大小
// 返回值       : DWORD        =0  成功
//                            >0  失败
/******************************************************************************************/
DWORD    NDF_AddFile2(HNdfObject hNDF, HNdfDirectory hParent, const utf8* szName, const utf8* szPath,
    int nEncrypt, int nCompress, int nExport, uint8_t* thumbBuff, int nThumbBuffSize);

/******************************************************************************************/
// 函数名       : NDF_BuildFile
// 功能描述     : 制作NDF文件
// 参数			: hNDF[IN]					NDF文件系统对象
//				: szFile[IN]				NDF文件路径			
//				: CB_NdfMakeProgress[IN]	进度回调函数
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_BuildFile(HNdfObject hNDF, const utf8* szFile, CB_NDFProgress pCBProgress, void *pCbParam);

/******************************************************************************************/
// 函数名       : NDF_StopBuild
// 功能描述     : 取消制作NDF文件
// 参数			: hNDF[IN]					NDF文件系统对象
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_StopBuild(HNdfObject hNDF);


/******************************************************************************************/
// 函数名       : NDF_SetVolSize
// 功能描述     : 设置分卷大小
// 参数			: hNDF[IN]					NDF文件系统对象
//				: nVolumeSize				分卷大小 单位 字节	
// 返回值       : DWORD		=0  成功	
//							>0  失败
/******************************************************************************************/
DWORD NDF_SetVolSize(HNdfObject hNDF, int64_t nVolumeSize);
