/************************************************************************/
//Project:		NDF FILE SYSTEM
//Module:		NDF Common Struct 
//Author:		                                                                      
//Version:		3.0                                                                      
//Date:			2016-06-01
/************************************************************************/

#ifndef UTF8_DEFINE
#define UTF8_DEFINE 1
typedef char utf8;
#endif

#if defined (_WINDOWS) 
#ifndef	WINDOWS_HEADER_DEFINE
#define WINDOWS_HEADER_DEFINE 1
#include <windows.h>
#include <stdio.h>
#include <io.h>
typedef unsigned char uint8_t;
typedef signed char int8_t;
typedef unsigned short uint16_t;
typedef short int16_t;
typedef unsigned int uint32_t;
typedef int	int32_t;
typedef unsigned __int64 uint64_t;
typedef __int64 int64_t;
#endif
#endif

#if defined (ANDROID)
#ifndef ANDROID_HEADER_DEFINE
#define ANDROID_HEADER_DEFINE 1
#include <stdint.h>
typedef uint32_t DWORD;
typedef signed char BOOL;
typedef int LONG;
#define MAX_PATH    260
#define FALSE       0
#define TRUE        1
#define INT_MAX     2147483647
#endif
#endif

#if defined (__APPLE__)
#ifndef APPLE_HEADER_DEFINE
#define APPLE_HEADER_DEFINE 1
#include <Mactypes.h>
#include <stdint.h>
typedef uint32_t DWORD;
//typedef signed char BOOL;
typedef int LONG;
#define MAX_PATH    260
#define FALSE       0
#define TRUE        1
#define INT_MAX     2147483647
#endif
#endif
	
typedef void* HNdfObject;
typedef void* HNdfDirectory;
typedef void* HNdfFile;
typedef void* HNdfSnapshot;

typedef int (*CB_NDFProgress)(double progress, void* pCbParam);

#define NDF_MAX_PATH		2048			//UI文件名最大长度		
#define NDF_MAX_NAME		128				//NDF目录名最大长度
#define LEN_VERSION			6				//NDF文件版本长度
#define LEN_FILE_ID			44				//NDF文件ID长度
#define LEN_AUTHOR_ID		10				//NDF文件作者长度
#define LEN_NDF_TITLE		150				//NDF文件标题长度
#define LEN_NDF_DES			800				//NDF文件描述信息长度
#define LEN_USER_PASSWORD	24				//NDF文件密码最大长度
#define LEN_AD_MAX_URL		512				//NDF文件广告链接最大长度

#define NDF_MAX_FILE_COUNT		1000000
#define NDF_MAX_DIR_COUNT		1000000

enum NDF_COMPRESS_STATUS
{
	NDF_COMPRESS_NO = 0,
	NDF_COMPRESS_YES = 1
};

enum NDF_ENCRYPT_STATUS
{
	NDF_ENCRYPT_NO = 0,
	NDF_ENCRYPT_YES = 1
};

enum NDF_EXPORT_STATUS
{
	NDF_EXPORT_NO = 0,
	NDF_EXPORT_YES = 1
};

enum NDF_PACKAGE_TYPE
{
	NDF_TYPE_NONE = 0,		//普通文件包
	NDF_TYPE_NOVELS = 1,	//文本小说集
	NDF_TYPE_PHOTOS = 2,	//图片集
	NDF_TYPE_WEBPAGE = 3,	//在线阅读网页网址集
	NDF_TYPE_VIDEO = 4,		//视频集
	NDF_TYPE_ONLINE_BOOK = 5 //在线电子杂志
};	

enum NDF_COVER_PHOTO_TYPE
{
	NDF_COVER_PHOTO_NONE = 0,	//没有封面
	NDF_COVER_PHOTO_JPG,		//JPG格式封面
	NDF_COVER_PHOTO_BMP,		//BMP格式封面
	NDF_COVER_PHOTO_PNG,		//PNG格式封面
	NDF_COVER_PHOTO_GIF			//GIF格式封面
};	

enum NDF_AD_TYPE
{
	NDF_AD_NONE=0,		//没有广告
	NDF_AD_TEXT,		//文字广告
	NDF_AD_WEBPAGE,		//网页广告
	NDF_AD_PHOTO		//图片广告
};


enum NDF_AD_PHOTO_TYPE
{
	NDF_AD_PHOTO_NONE = 0,	//没有图片
	NDF_AD_PHOTO_JPG,		//JPG格式广告图片
	NDF_AD_PHOTO_BMP,		//BMP格式广告图片
	NDF_AD_PHOTO_PNG,		//PNG格式广告图片
	NDF_AD_PHOTO_GIF		//GIF格式广告图片
};

//加入的文件格式
enum NDF_FILE_TYPE
{
	NDF_FILE_NONE=0,
	NDF_FILE_TXT=1,
	NDF_FILE_HTM=2,
	NDF_FILE_PDF=3,
	NDF_FILE_JPG=11,
	NDF_FILE_BMP=12,
	NDF_FILE_PNG=13,
	NDF_FILE_GIF=14,
	NDF_FILE_MP3=41,
	NDF_FILE_WAV=42,
	NDF_FILE_APE=43,
	NDF_FILE_MP2,
	NDF_FILE_WMA,
	NDF_FILE_OGG,
	NDF_FILE_RA,
	NDF_FILE_FLAC,
	NDF_FILE_M4A,
	NDF_FILE_M4R,
	NDF_FILE_AAC,
	NDF_FILE_AC3,
	NDF_FILE_AMR,
	NDF_FILE_AU,
	NDF_FILE_VOC,
	NDF_FILE_MKA,
	NDF_FILE_AIFF,
	NDF_FILE_MP4=61,
	NDF_FILE_AVI=62,
	NDF_FILE_FLV=63,
	NDF_FILE_WMV=64,
	NDF_FILE_MPG=65,
	NDF_FILE_3GP=66,
	NDF_FILE_MOV=67,
	NDF_FILE_MTS=68,
	NDF_FILE_TS=69,
	NDF_FILE_M2TS=70,
	NDF_FILE_MKV=71,
	NDF_FILE_RMVB=72,
	NDF_FILE_RM=73,
	NDF_FILE_M4V=74,
	NDF_FILE_VOB=75,
	NDF_FILE_MOD=76,
	NDF_FILE_DAT=77,
	NDF_FILE_WEBM,
	NDF_FILE_ASF,

	NDF_FILE_VIDEO_TAG
};

//字幕格式
enum NDF_SUBTITLE_TYPE
{
	NDF_SUBTITLE_NONE=0,
	NDF_SUBTITLE_SRT,
	NDF_SUBTITLE_ASS,
	NDF_SUBTITLE_SSA,
	NDF_SUBTITLE_LRC
};

//数据区文件导出标识 
enum NDF_PRIVILEGE_EXPORT
{
	NDF_PRIVILEGE_EXPORT_NONE=0,		//不允许导出
	NDF_PRIVILEGE_EXPORT_SINGLE=1,		//允许导出单个文件
	NDF_PRIVILEGE_EXPORT_ALL=2			//允许全部导出文件
};

//公开区用户查看数据权限
enum NDF_PUBLIC_PRIVILEGE_ACCESS
{
	NDF_PUBLIC_ACCESS_YES = 0			//数据公开可见
};

//VIP区用户查看数据权限
enum NDF_VIPVIP_PRIVILEGE_ACCESS
{
	NDF_VIPVIP_ACCESS_NONE = 0,			//任何用户不能预览
	NDF_VIPVIP_ACCESS_VIP = 1,			//VIP可见全部，但普通用户没有任何预览 
	NDF_VIPVIP_ACCESS_THUMB = 2,		//VIP可见全部，但普通用户可见预览小图
	NDF_VIPVIP_ACCESS_PART = 3			//VIP可见全部，普通用户根据附加属性来决定可见多少
};

//目录树类型
enum NDF_DIR_TREE_TYPE
{
	NDF_DIR_PUBLIC=0,
	NDF_DIR_VIPVIP=1,
	NDF_DIR_NONE=2,
	NDF_DIR_AD=3,
	NDF_DIR_ONLINE=4,
	NDF_DIR_CUSTOM=5
};


enum NDF_DIR_NODE_STATUS
{
	NDF_NODE_STATUS_DELETE	= 0,
	NDF_NODE_STATUS_NORMAL	= 1,
	NDF_NODE_STATUS_READY	= 10,
	NDF_NODE_STATUS_ADDING	= 11
};

#define NDF_FILE_ATTRIBUTE_DIRECTORY	0x00000001		//目录
#define NDF_FILE_ATTRIBUTE_ENCRYPTED	0x00000002		//已加密	
#define NDF_FILE_ATTRIBUTE_COMPRESSED	0x00000004		//已压缩
#define NDF_FILE_ATTRIBUTE_EXPORTED		0x00000008		//允许导出	
#define NDF_FILE_ATTRIBUTE_THUMBNAIL	0x00000010		//存在缩略图

typedef struct tagNtfFindData 
{	
	utf8 cFileName[NDF_MAX_NAME];			//显示名字
	int  nFileType;							//文件类型	
	DWORD dwFileAttributes;					//文件属性
	int64_t nFileSize;						//文件原始数据大小
	int64_t nFileDataOffset;				//文件起始位置偏移量
	int nThumbSize;							//缩略图原始数据大小
	int64_t nIndexOffset;					//缩略图起始位置偏移量
}NDF_FIND_DATA,*PNDF_FIND_DATA;


enum NDF_FILE_STRING_FORMAT
{
	NDF_FILE_STRING_UNKNOWN = 0,
	NDF_FILE_STRING_ANSI = 1,
	NDF_FILE_STRING_UNICODE = 2,
	NDF_FILE_STRING_UTF8
};

//加载网页的数据的回调函数
typedef int (*fnLoadInternetData)(char* szUTF8URL, uint8_t** data, int *size);
//释放数据
typedef int (*fnFreeInternetData)(uint8_t* data);

typedef int (*fnWideCharToMultiByte)(int nMultiByteFormat,wchar_t* szUnicode,int nNumWideChar,char* szMultiByte,int nNumMultiChar);

typedef int (*fnMultiByteToWideChar)(int nMultiByteFormat,char* szMultiByte, int nNumMultiChar,wchar_t* szUnicode,int nNumWideChar);

//打开文件回调
typedef int(*cb_open_file_priv)(const char *filename, int flags);

//在线电子书更新链表
typedef struct tagOnlineBook_Update_list 
{
	char* szUTF8URL;
	struct tagOnlineBook_Update_list *next;
}ONLINEBOOK_UPDATE_LIST,*PONLINEBOOK_UPDATE_LIST;

enum NDF_ONLINEBOOK_BROWN_MODE
{
	NDF_BROWN_DEFUALT = 0, //默认打开方式
	NDF_BROWN_IE = 1	   //IE
};

//在线电子书目录链表
typedef struct tagOnlineBook_Item_List
{
	int nVipVip;				//是否VIP
    char* szUTF8Text;           //显示文本
    char* szUTF8URL;            //URL
    DWORD dwBrownOpenFlag;      //浏览器打开方式
    struct tagOnlineBook_Item_List *next;
}ONLINEBOOK_ITEM_LIST,*PONLINEBOOK_ITEM_LIST;


typedef struct tagOnlineBook_Item_Update_List
{
	char szDate[32];
	ONLINEBOOK_ITEM_LIST *item_list;	
	ONLINEBOOK_UPDATE_LIST *update_list;
}ONLINEBOOK_ITEM_UPDATE_LIST,*PONLINEBOOK_ITEM_UPDATE_LIST;


#define MACHINE_CODE_HARDDISK		0x0001
#define MACHINE_CODE_MAINBOARD		0x0002
#define MACHINE_CODE_CPU			0x0004
#define MACHINE_CODE_REMOVEDISK		0x0008


#define ANTI_COPY_FAQ_NO			0x0000
#define ANTI_COPY_FAQ_AUTO			0x0001
#define ANTI_COPY_FAQ_USER			0x0002

#define CP_TYPE_NO_PW				0x0001	//没有播放密码
#define CP_TYPE_SAME_PW				0x0002	//相同密码
#define CP_TYPE_DIFF_PW				0x0003	//一机一码
#define CP_TYPE_USB_COPY			0x0004	//USB COPY 支持多用户

//-----------------------------------------下面不需要了

#define CP_TYPE_USB					0x0004	//USB
#define CP_TYPE_CDROM				0x0005	//光驱

//目标设备类型
#define DEVICE_TYPE_HARDDISK		0x0001
#define DEVICE_TYPE_USB				0x0002
#define DEVICE_TYPE_CDROM			0x0003


#define ASPECT_KEEP_SOURCE			0x0000
#define ASPECT_KEEP_SIZE			0x0001
#define ASPECT_KEEP_169				0x0002


#define MAX_LEN_MACHINE		20
#define MAX_LEN_WATERMARK	64
#define MAX_LEN_TIMEOUT		16
#define MAX_LEN_INFO		1024
#define MAX_LEN_URL			1024

//BASE64之前的固定size
#define LEN_LICENCE	150
	
typedef struct tagVideoPlayerNoPwConfigCell
{
	int nPlayTime;			//最长播放时间
	int nPlayCount;			//最多播放次数
	utf8 szWatermark[MAX_LEN_WATERMARK];	//播放水印	
	utf8 szPlayTimeOut[MAX_LEN_TIMEOUT];	//过期时间
	utf8 szMsg[MAX_LEN_INFO];				//消息提示
}VIDEOPLAYERNOPWCONFIGCELL,*PVIDEOPLAYERNOPWCONFIGCELL;

typedef struct tagAntiCopyQA
{
	utf8 szQueation[MAX_LEN_INFO];	//问题
	utf8 szAnswer[MAX_LEN_INFO];	//答案
	int	nTime;						//时间
}ANTICOPYQA,*PANTICOPYQA;


typedef struct DRM_USER_CONTROL_PARAM
{
	int nEnable;						//是否有效
	utf8 szUserName[NDF_MAX_NAME];		//用户名
	utf8 szUserPW[NDF_MAX_NAME];		//密码

	DWORD dwApsectType;			//播放比例
	int nAutoFullScreen;		//保持全屏

	int nPlayTime;					//最长播放时间
	int nPlayCount;					//最多播放次数
	int nPlayPageCount;				//最多播放页面	
	utf8 szWatermark[MAX_LEN_WATERMARK];	//播放水印	
	utf8 szPlayTimeOut[MAX_LEN_TIMEOUT];	//过期时间
	int nVerifyTimeOutMode;					//过期时间验证方式
	utf8 szMsg[MAX_LEN_INFO];				//消息提示

	//水印设置
	int nWatermarkFontSize;			//字体大小
	DWORD nWatermarkClr;			//字体颜色
	//0 固定出现
	//1 随机(边角)
	//2 随机(全屏)
	int nWatermarkRandom;			//随机出现
	int nWatermarkFreq;				//水印变化频率 单位s
	int	 nWatermarkLeft;			//距离左边
	int	 nWatermarkTop;				//距离上边

	//防翻录设置
	int nDisableVirMachine;			//禁止虚拟机运行
	int nDisableOnLine;				//禁止有网时候播放
	int nLockKeyborad;				//锁定键盘
	int nLockMouse;					//锁定鼠标
	int nDisableSnapshot;			//禁止截图
	int nCheckSRecoder;				//启用反录制检查
	int nEnableAntiCopy;			//是否反拷贝
	int nDisableCopy;				//拷贝
	int nDisablePaste;				//粘贴
	int nDisablePrinter;			//打印
	int nDisableClipBoard;			//剪贴板
	utf8 szRecoderProcessName[MAX_LEN_INFO]; //录制进程名
	uint8_t reverse[8192];			//保留数据区
}DRM_USER_CONTROL_PARAM;

typedef struct DRM_USB_COPY_CONFIG
{
	utf8 szGemPw[LEN_USER_PASSWORD];					//加密密码
	int nRegister;										//是否注册
	int nBindType;										//绑定设备类型
	uint8_t szSN[64];									//注册序列号
	utf8 szBlackListGetUrl[MAX_LEN_URL];				//序列号召回网址	
	struct DRM_USER_CONTROL_PARAM pUserParam[3];		//账户信息
}DRM_USB_COPY_CONFIG;

typedef struct tagVideoPlayerConfig
{
	DWORD dwCPFileType;			//文件类型
	DWORD dwDeviceType;			//输出设备类型

	VIDEOPLAYERNOPWCONFIGCELL noPwCellCfg;	//无密码时候的限制配置
	DWORD dwMachineCodeStatus;	//硬件码类型

	utf8 szProjectID[MAX_LEN_INFO];		//文件编号	
	utf8 szVerifyHit[MAX_LEN_INFO];		//验证窗口提示语	
	utf8 szPlayerTitle[MAX_LEN_INFO];	//播放器窗口标题
	utf8 szVerifyTitle[MAX_LEN_INFO];	//验证窗口标题
	utf8 szBuyHit[MAX_LEN_INFO];		//购买链接提示
	utf8 szBuyUrl[MAX_LEN_URL];			//购买链接

	utf8 szStartPlayUrl[MAX_LEN_URL];	//开始播放时候弹出网页
	utf8 szEndPlayUrl[MAX_LEN_URL];	//结束播放时候弹出网页

	DWORD dwApsectType;			//播放比例
	int nAutoFullScreen;		//保持全屏

	//水印
	int nWatermarkFontSize;		//字体大小
	DWORD nWatermarkClr;		//字体颜色
	//0 固定出现
	//1 随机(边角)
	//2 随机(全屏)
	int nWatermarkRandom;		//随机出现//{0:左上角，1:随机出现窗口边缘，2:全屏随机，3:右上角，4:左下角，5:右下角}
	int nWatermarkFreq;			//水印变化频率 单位s
	int	 nWatermarkLeft;		//距离左边
	int	 nWatermarkTop;			//距离上边
	
	//防翻录设置
	int nDisableVirMachine;		//禁止虚拟机运行
	int nDisableOnLine;			//禁止有网时候播放
	int nLockKeyborad;			//锁定键盘
	int nLockMouse;				//锁定鼠标
	int nDisableSnapshot;		//禁止截图
	int nCheckSRecoder;			//启用反录制检查

	DWORD nAntiCopyMode;		//反copy状态
	int	nAntiCopyAutoFreq;		//自动时候的频率 单位分钟
	int nAntiCopyNum;			//问题个数
	utf8 szBlackListGetUrl[MAX_LEN_URL];	//密码召回网址	
	utf8 szRecoderProcessName[MAX_LEN_INFO]; //录制进程名

	DWORD dwExtraSize;
	//reverse 保留的长度为1024
	//目前使用情况
	//1 guid 128
	//2 nCheckTimeUseNetTime 4
	//
	utf8 guid[128];					//Guid
	int	nCheckTimeUseNetTime;		//过期时间是否网络验证
    utf8 szSN[36];                    //注册用户制作时候的SN
    uint8_t reverse[1024-128-4-36];
	//uint8_t reverse[1024];
}VIDEO_PLAYER_CONFIG,*PVIDEO_PLAYER_CONFIG;


typedef struct tagVideoPlayerUserDefineParam
{
	utf8 szTitle[MAX_LEN_INFO];				//标题
	utf8 szHomePageUrl[MAX_LEN_URL];		//Home Page URL
	utf8 szWindowIcon[MAX_LEN_INFO];		//图标文件信息--png格式
	utf8 szBgImg[MAX_LEN_INFO];				//背景图--png格式
}VIDEOPLAYERUSERDEFINEPARAM,*PVIDEOPLAYERUSERDEFINEPARAM;

#define USB_SERI_NUM_CONFIG	"CLSID_b9ff1a7d-8608-3b48-2100-d9eb07312f44_DRM_USB.ini"
