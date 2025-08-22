//
//  KanPlayer.h
//  KanPlayer.h
//
//  Created by wind on 18/9/10.
//  Copyright © 2018年. All rights reserved.
//

typedef enum {
    VideoStreamColorFormatUnknown = 0,
    VideoStreamColorFormatYUV,
    VideoStreamColorFormatRGB
} VideoStreamColorFormat;

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
//#import "GLES2View.h"

typedef void (^PlayerDidEndBlock)();

typedef enum {
    KanPlayerStatusNone = 0,	 // 没有设置源
    KanPlayerStatusPlaying,   // 正在播放
    KanPlayerStatusPause,	 // 暂停
    KanPlayerStatusStop	     // 停止
}KanPlayerStatus;


#pragma mark- KanPlayerDelegate Delegate
@protocol KanPlayerDelegate<NSObject>
@required

-(void) KanPlayerDelegateVideoRenderStart:(id)KanPlayer;

-(void) KanPlayerDelegateBufferingStart:(id)KanPlayer;

-(void) KanPlayerDelegateBufferingEnd:(id)KanPlayer;

-(void) KanPlayerDelegateTimeout:(id)KanPlayer;

-(void) KanPlayerDelegateStop:(id)KanPlayer;

@end

@interface KanPlayer : NSObject

@property (nonatomic, readonly) UIView *view;

@property (nonatomic, assign) CGRect frame;

/**
 *  是否是流视频
 */
@property (nonatomic, assign) bool isStreamVideo;

- (id)initWithString:(NSString *)urlString frame:(CGRect)frame;

- (id)initKan:(NSString *)szKanPath
           pw:(uint8_t*)pw
       nPwLen:(int)nPwLen
   szFilePath:(NSString *)szFilePath
        frame:(CGRect)frame;


-(UInt32) AddImageWatermark:(NSString*)szPath  cx:(double)cx cy:(double)cy;

-(UInt32) AddImageWatermarkWithData:(NSData*)szImgData  cx:(double)cx cy:(double)cy;

-(UInt32) AddImageWatermarkWithBGRA:(int)w h:(int)h buff:(uint8_t*)buff  cx:(double)cx cy:(double)cy;
/**
 *  功能描述: update水印position
 *
 */
-(void) UpdateImageWatermarkPos:(UInt32)index cx:(double)cx cy:(double)cy;

/**
 *  功能描述: 清除所有水印
 *
 */
-(void) ClearWatermark;

/**
 *  Play Player
 */
- (UInt32) play;

/**
 *  Pausr Player
 */
- (void) pause;

/**
 *  Stop Player
 */
- (void) stop;

/**
 *  Seek Player
 */
- (void) seekTime:(CMTime )time;


/**
 *  功能描述: 设置音量
 */
- (void) SetVolume:(double)volume;


/**
 *  set Player speed
 */
- (void) setSpeed:(double)speed;


- (void)closePlayer;

/**
 *  帧率
 */
@property (nonatomic, readonly) float fps;

/**
 *  播放器状态
 */
@property (nonatomic, readonly) KanPlayerStatus playerStatus;

/**
 *  播放器当前时间
 */
@property (nonatomic, readonly) CMTime currentTime;

/**
 *  视频总长
 */
@property (nonatomic, readonly) CMTime duration;

/**
 *  视频解码后颜色格式 YUV 还是RGB
 */
@property (nonatomic, readonly) VideoStreamColorFormat videoStreamColorFormat;

/**
 *  视频宽
 */
@property (nonatomic, readonly) int frameWidth;

/**
 *  视频高
 */
@property (nonatomic, readonly) int frameHeight;

/**
 *  视频播放结束回调
 */
@property (nonatomic, copy) PlayerDidEndBlock playerDidEndBlock;

- (int)playerStatus:(int) status;

@end

