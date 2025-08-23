//
//  GemFileInfo.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/6.
//

import Foundation
import UIKit
class GemFileModel : NSObject {
    var isGemFile : Bool?
    var isDirectory : Bool?
    var path : NSString?
    var fileSize : NSString?
}

class GemFileInfo : NSObject {
    @objc public var fileName : String?
    @objc public var fileDate : String?
    @objc public var fileIcon : UIImage?
    @objc public var fileUrl : URL?
    
    //普通文件信息
    public var playCfg : VIDEO_PLAYER_CONFIG?
    //GCP文件信息
    public var gcpCfg : DRM_USB_COPY_CONFIG?
    @objc public var gemGUID : NSString?
    @objc public var cFileName :NSString? //显示名字
    @objc public var tempPath : NSString?//文件路径
    @objc public var codeMd5Path : NSString?//文件路径
    @objc public var password : NSString?
    @objc public var pwLenth : NSNumber? = 0;//Int

    //限制条件
    @objc public var szTimeout : NSString?
    @objc public var nMaxPlayTime : NSNumber? = 0
    @objc public var nMaxNum : NSNumber? = 0
    @objc public var nCheckTimeUseNetTime : NSNumber? = 0
    @objc public var playPageCount : NSNumber? = 0//pdf最大预览页数
    @objc public var nplaySeekDisable : NSNumber? = 0;
    @objc public var szLicence : NSString?//文件的licence
    //水印相关
    @objc public var waterText : NSString?
    @objc public var waterFont : UIFont?
    @objc public var waterColor : UIColor?
    @objc public var waterImage : UIImage?

    //防翻录问题
    @objc public var questionParams : NSMutableArray?//缩略图起始位置偏移量

    @objc public var nFileType : NSNumber?//文件类型
    @objc public var nFileSize : NSNumber?//文件原始数据大小
    @objc public var nThumbSize : NSNumber?//缩略图原始数据大小
    @objc public var dwFileAttributes : NSNumber?//文件属性
    @objc public var nFileDataOffset : NSNumber?//文件起始位置偏移量
    @objc public var nIndexOffset : NSNumber?//缩略图起始位置偏移量

    //gcp 用户设置信息
    public var user_param : DRM_USER_CONTROL_PARAM?
    @objc public var userName : NSString?
    @objc public var thumbImage : UIImage?//缩率图
    
    @objc func setuserParam(param : DRM_USER_CONTROL_PARAM) {
        self.user_param = param
    }
    @objc func setplayCfg(cfg : VIDEO_PLAYER_CONFIG) {
        self.playCfg = cfg
    }
    @objc func setgcpCfg(cfg : DRM_USB_COPY_CONFIG) {
        self.gcpCfg = cfg
    }
    
    @objc func getuserParam() -> DRM_USER_CONTROL_PARAM {
        return self.user_param!
    }
    @objc func getplayCfg() -> VIDEO_PLAYER_CONFIG {
        return self.playCfg!
    }
    @objc func getgcpCfg() -> DRM_USB_COPY_CONFIG {
        return self.gcpCfg!
    }
        
}
