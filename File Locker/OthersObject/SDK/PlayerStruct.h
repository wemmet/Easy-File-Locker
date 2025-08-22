#ifndef __RD_PLAYER_STRUCT_H__
#define __RD_PLAYER_STRUCT_H__

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

#if defined (__APPLE__)
typedef uint32_t DWORD;
#endif

//音频轨道信息
typedef struct AUDIO_TRACK_INFO
{
	int		nIndex;
	utf8	szCodec[64];
	utf8	szCodecTag[64];
	int		nChannels;
	int		nSamples;
	int		nBitrate;
	utf8	szLang[128];
	utf8	szTitle[256];
}AUDIO_TRACK_INFO;

//视频轨道信息
typedef struct VIDEO_TRACK_INFO 
{
	int		nIndex;
	utf8	szCodec[64];
	utf8	szCodecTag[64];
	int		nWidth;
	int		nHeight;
	int		nBitrate;
	double	dbFramerate;
	double	dbAspect;
	int     nAngle;
	utf8	szLang[128];
	utf8	szTitle[256];
}VIDEO_TRACK_INFO;

//字幕轨道信息
typedef struct SUBTITLE_TRACK_INFO 
{
	int		nIndex;
	utf8	szCodec[64];
	utf8	szLang[128];
	utf8	szTitle[256];
}SUBTITLE_TRACK_INFO;

//字幕参数
typedef struct PLAYER_SUBTITLE_PARAM
{
	utf8 szFontFamily[256];				//字体名
	int nFontFamilyEditable;		

	int nFontSize;						//字体大小	
	int nFontSizeEditable;
	
	DWORD nFontColor;					//字体颜色
	int nFontColorEditable;
	
	int nStrokeSize;					//描边
	int nStrokeEditable;
	DWORD nStrokeColor;					//描边颜色
	
	int nShadowSize;					//阴影
	int nShadowEditable;
	DWORD nShadowColor;					//阴影颜色
	
	int nSubtitlePosEditable;			//位置
	int nMarginV;						//文字的底部到最下面的距离
}PLAYER_SUBTITLE_PARAM;

typedef struct PLAYER_FONT_INFO
{
	utf8 szFontFamily[256];				//字体名
	utf8 szFontPath[1024];				//路径
}PLAYER_FONT_INFO;


#endif
