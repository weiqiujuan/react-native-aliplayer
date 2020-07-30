//
//  ALIViewPlayer.m
//  NewsApp
//
//  Created by 宋族运 on 2020/7/29.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "RNAliplayer.h"

@implementation RNAliplayer

- (AliPlayer *)player{
  if (!_player) {
    _player = [[AliPlayer alloc] init];
    _player.delegate = self;
    _player.playerView = self;
  }
  return _player;
}

-(void)startPlay{
  if (self.source==nil) {
    return;
  }
  [self.player start];
}
-(void)pausePlay{
  [self.player pause];
}
-(void)stopPlay{
  [self.player stop];
}
-(void)reloadPlay{
  [self.player reload];
}
-(void)restartPlay{
  [self.player seekToTime:0 seekMode:AVP_SEEKMODE_INACCURATE];
  [self.player start];
}
-(void)destroyPlay{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.player destroy];
    self.player = nil;
  });
}
- (void)seekTo:(int)position{
  [self.player seekToTime:position*1000 seekMode:AVP_SEEKMODE_INACCURATE];
}

//定义要暴露属性
- (void)setSource:(NSString *)source{
  _source = source;
  AVPUrlSource * urlSource = [[AVPUrlSource alloc] urlWithString:source];
  [self.player setUrlSource:urlSource];
  [self.player prepare];
}
-(void)setSetAutoPlay:(BOOL)setAutoPlay{
  _setAutoPlay = setAutoPlay;
  [self.player setAutoPlay:setAutoPlay];
}
-(void)setSetLoop:(BOOL)setLoop{
  _setLoop = setLoop;
  [self.player setLoop:setLoop];
}
- (void)setSetMute:(BOOL)setMute{
  _setMute = setMute;
  [self.player setMuted:setMute];
}
- (void)setEnableHardwareDecoder:(BOOL)enableHardwareDecoder{
  _enableHardwareDecoder = enableHardwareDecoder;
  [self.player setEnableHardwareDecoder:enableHardwareDecoder];
}
- (void)setSetVolume:(float)setVolume{
  _setVolume = setVolume;
  [self.player setVolume:setVolume];
}
- (void)setSetSpeed:(float)setSpeed{
  _setSpeed = setSpeed;
  [self.player setRate:setSpeed];
}
- (void)setSetReferer:(NSString *)setReferer{
  _setReferer = setReferer;
  AVPConfig *config = [self.player getConfig];
  config.referer = setReferer;
  [self.player setConfig:config];
}
- (void)setSetUserAgent:(NSString *)setUserAgent{
  _setUserAgent = setUserAgent;
  AVPConfig *config = [self.player getConfig];
  config.userAgent = setUserAgent;
  [self.player setConfig:config];
}
- (void)setSetMirrorMode:(int)setMirrorMode{
  _setMirrorMode = setMirrorMode;
  switch (setMirrorMode) {
    case 0:
      [self.player setMirrorMode:AVP_MIRRORMODE_NONE];
      break;
    case 1:
      [self.player setMirrorMode:AVP_MIRRORMODE_HORIZONTAL];
      break;
    case 2:
      [self.player setMirrorMode:AVP_MIRRORMODE_VERTICAL];
      break;
    default:
      break;
  }
}
-(void)setSetRotateMode:(int)setRotateMode{
  _setRotateMode = setRotateMode;
  switch (setRotateMode) {
    case 0:
      [self.player setRotateMode:AVP_ROTATE_0];
      break;
    case 1:
      [self.player setRotateMode:AVP_ROTATE_90];
      break;
    case 2:
      [self.player setRotateMode:AVP_ROTATE_180];
      break;
    case 3:
      [self.player setRotateMode:AVP_ROTATE_270];
      break;
    default:
      break;
  }
}
- (void)setSetScaleMode:(int)setScaleMode{
  _setScaleMode = setScaleMode;
  switch (setScaleMode) {
    case 0:
      [self.player setScalingMode:AVP_SCALINGMODE_SCALEASPECTFIT];
      break;
    case 1:
      [self.player setScalingMode:AVP_SCALINGMODE_SCALEASPECTFILL];
      break;
    case 2:
      [self.player setScalingMode:AVP_SCALINGMODE_SCALETOFILL];
      break;
    default:
      break;
  }
}

#pragma mark - AVPDelegate
/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
  //提示错误，及stop播放
  self.onError(@{@"code":@(errorModel.code),@"message":errorModel.message});
  
}
/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
  switch (eventType) {
    case AVPEventPrepareDone:
      // 准备完成
      if (self.onPrepared) {
         self.onPrepared(@{@"duration":@(player.duration/1000)});
      }
      break;
    case AVPEventAutoPlayStart:
      // 自动播放开始事件
      if (self.onAutoPlayStart) {
         self.onAutoPlayStart(@{@"code":@"onAutoPlayStart"});
      }
      break;
    case AVPEventFirstRenderedStart:
      // 首帧显示
      if (self.onRenderingStart) {
        self.onRenderingStart(@{@"code":@"onRenderingStart"});
      }
      break;
    case AVPEventCompletion:
      // 播放完成
      if (self.onCompletion) {
        self.onCompletion(@{@"code":@"onCompletion"});
      }
      break;
    case AVPEventLoadingStart:
      // 缓冲开始
      if (self.onLoadingBegin) {
        self.onLoadingBegin(@{@"code":@"onLoadingBegin"});
      }
      break;
    case AVPEventLoadingEnd:
      // 缓冲完成
      if (self.onLoadingEnd) {
        self.onLoadingEnd(@{@"code":@"onLoadingEnd"});
      }
      break;
    case AVPEventSeekEnd:
      // 跳转完成
      if (self.onSeekComplete) {
        self.onSeekComplete(@{@"code":@"onSeekComplete"});
      }
      break;
    case AVPEventLoopingStart:
      // 循环播放开始
      if (self.onLoopingStart) {
        self.onLoopingStart(@{@"code":@"onLoopingStart"});
      }
      break;
    default:
      break;
  }
}
/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
  if (self.onCurrentPositionUpdate) {
     self.onCurrentPositionUpdate(@{@"position":@(position/1000)});
  }
}
/**
 @brief 视频缓存位置回调
 @param player 播放器player指针
 @param position 视频当前缓存位置
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {
  if (self.onBufferedPositionUpdate) {
    self.onBufferedPositionUpdate(@{@"position":@(position/1000)});
  }
}

/**
 @brief 视频缓冲进度回调
 @param player 播放器player指针
 @param progress 缓存进度0-100
 */
/****
 @brief Buffer progress callback.
 @param player Player pointer.
 @param progress Buffer progress: from 0 to 100.
 */
- (void)onLoadingProgress:(AliPlayer*)player progress:(float)progress{
  if (self.onLoadingProgress) {
    self.onLoadingProgress(@{@"percent":@(progress)});
  }
}

@end
