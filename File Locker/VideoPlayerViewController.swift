//
//  VideoPlayerViewController.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/5.
//

import Foundation
import AVFoundation
import UIKit
enum PkgFileType : Int {
    case PkgFileType_Gem = 0
    case PkgFileType_Gcp = 1
    case PkgFileType_Gfx = 2
}
class VideoPlayerViewController: UIViewController,KanPlayerDelegate {
    func kanPlayerDelegateVideoRenderStart(_ KanPlayer: Any!) {
        //print("kanPlayerDelegateVideoRenderStart")
    }
    
    func kanPlayerDelegateBufferingStart(_ KanPlayer: Any!) {
        //print("kanPlayerDelegateBufferingStart")
    }
    
    func kanPlayerDelegateBufferingEnd(_ KanPlayer: Any!) {
        //print("kanPlayerDelegateBufferingEnd")
    }
    
    func kanPlayerDelegateTimeout(_ KanPlayer: Any!) {
        //print("kanPlayerDelegateTimeout")
    }
    
    func kanPlayerDelegateStop(_ KanPlayer: Any!) {
        //print("kanPlayerDelegateStop")
    }
    
    var playerBarView : UIView!
    var _isGemFile : Bool?
    var _isHostAppRun : Bool?
    var _isVideo : Bool?
    var _fileType : PkgFileType?
    var _waterImage : UIImage? = nil
    
    @objc var gem_hobj : HNdfObject? = nil
    var _playCfg : VIDEO_PLAYER_CONFIG? = nil
    var _gcpCfg : DRM_USB_COPY_CONFIG? = nil
    var _user_param : DRM_USER_CONTROL_PARAM? = nil
    @objc var _gemPath : String? = nil
    @objc var _md5Path : String? = nil
    @objc var _lience : String? = nil
    @objc var _playerPath : String? = nil
    var _passwordStr : String? = nil
    var _passwordlen : Int? = 0
    var _gemGUID : String? = ""
    var _nCheckSeekTimeDisable : Int? = 0
    
    var _nMaxPlayCount : Int? = 0
    var _nPlayTime : Int? = 0
    var _selectTemPathIndex : Int? = 0
    var _playerIndex : Int? = 0
    var _temPaths : [String]? = []
    var _questions : [Any]? = []
    
    var _freqLists : [Any]? = []
    
    var _configerKey : String? = ""
    var _isMute : Bool = false
    var _speedValue : CGFloat = 1.0
    var _currentTime : CMTime = .zero
    
    private var isDraggle: Bool = false
    // 视频播放器
    var _playerBgView : UITextField!
    var _kplayer: KanPlayer?
    var _playerRect : CGRect? = nil
    var _transform : CGAffineTransform? = nil
    var _isPlaying : Bool = false
    var _timer : Timer? = nil
    
    var _musicBG : UIImageView? = nil
    var _musicIconLogo : UIImageView? = nil
    var _coverBar : UIToolbar? = nil
        
    var _speedView : UIView? = nil;
    var _selectIconView : UIImageView? = nil
    var _speeds: [[String: Any]]?
    var _zoomBtn : UIButton?
    var _titleLabel : UILabel!
    var _setsButton : UIButton?
    var _leftTimeBtn : UIButton?
    var _rightTimeBtn : UIButton?
    var _isZoomIn : Bool = false
    var _titleView : UIView?
    var _backButton : UIButton?
    var _menuView : UIView?
    var _menuContentView: UIView?
    var _upBtn : UIButton?
    var _downBtn : UIButton?
    
    
    @objc public func setIsGemFile(_ isGemFile : Bool) {
        _isGemFile = isGemFile
    }
    @objc public func setIsVideo(_ isVideo : Bool) {
        _isVideo = isVideo
    }
    @objc public func setIsHostAppRun(_ isHostAppRun : Bool) {
        _isHostAppRun = isHostAppRun
    }
    
    func speeds() -> [[String: Any]] {
        if _speeds == nil {
            _speeds = [
                [
                    "title": String(format: " 1/4 %@", NSLocalizedString("倍", comment: "")),
                    "speed": 1 / 4.0
                ],
                [
                    "title": String(format: " 1/2 %@", NSLocalizedString("倍", comment: "")),
                    "speed": 1 / 2.0
                ],
                [
                    "title": String(format: " %@", NSLocalizedString("正常", comment: "")),
                    "speed": 1.0
                ],
                [
                    "title": String(format: " 1.5 %@", NSLocalizedString("倍", comment: "")),
                    "speed": 1.5
                ],
                [
                    "title": String(format: "  2 %@", NSLocalizedString("倍", comment: "")),
                    "speed": 2.0
                ]
            ]
        }
        return _speeds!
    }
    
    func setupMenuView() {
        if _menuView == nil {
            _menuView = UIView(frame: CGRect(x: 0, y: 0, width: kWIDTH, height: kHEIGHT))
            if(_isZoomIn == false){
                let rotationTransform = CGAffineTransform(rotationAngle: 0)
                _menuView?.transform = rotationTransform;
                _menuView?.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: kHEIGHT)
            }
            else{
                let rotationTransform = CGAffineTransform(rotationAngle: .pi / 2)
                _menuView?.transform = rotationTransform;
                _menuView?.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: kHEIGHT)
            }
            _menuView?.backgroundColor = UIColor.fromRGB(0x000000).withAlphaComponent(0.5)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuAction))
            _menuView?.addGestureRecognizer(tapGesture)
            view.addSubview(_menuView!)
            if(_isZoomIn == true){
                _menuContentView = UIView(frame: CGRect(x: CGRectGetHeight(_menuView!.frame) - 160, y: 0, width: 150, height: 88))
            }
            else{
                _menuContentView = UIView(frame: CGRect(x: CGRectGetWidth(_menuView!.frame) - 160, y: SafeAreaTopHeight - 44, width: 150, height: 88))
            }
            _menuContentView?.backgroundColor = UIColor.fromRGB(0x1a1a1a).withAlphaComponent(1.0)
            _menuContentView?.layer.cornerRadius = 2
            _menuContentView?.layer.masksToBounds = true
            _menuView?.addSubview(_menuContentView!)
            _menuView?.isHidden = false
            for i in 0..<2 {
                let height: CGFloat = 44
                let label = UILabel(frame: CGRect(x: 0, y: height * CGFloat(i), width: _menuContentView!.frame.width, height: height))
                label.backgroundColor = .clear
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 13)
                label.text = "     \(i == 1 ? NSLocalizedString("strVolume", comment: "") : NSLocalizedString("strSpeed", comment: ""))"
                label.textAlignment = .left
                label.layer.cornerRadius = 5
                label.layer.masksToBounds = true
                label.tag = i + 1
                label.isUserInteractionEnabled = true
                let tapLabelGesture = UITapGestureRecognizer(target: self, action: #selector(menuItem(_:)))
                label.addGestureRecognizer(tapLabelGesture)
                let iconView = UIImageView(frame: CGRect(x: label.frame.width - 44, y: (label.frame.height - 34) / 2.0, width: 34, height: 34))
                iconView.image = UIImage(named: i == 1 ? (_isMute ? "BtnMute_" : "BtnMute_Off") : "Speed_Normal_")
                iconView.tag = 10000
                label.addSubview(iconView)
                _menuContentView?.addSubview(label)
                if i == 0 {
                    let line = UIView(frame: CGRect(x: 2, y: 44, width: _menuContentView!.frame.width - 4, height: 1))
                    line.backgroundColor = UIColor.fromRGB(0x272727).withAlphaComponent(1.0)
                    _menuContentView?.addSubview(line)
                }
            }
        }
    }
    @objc func setupSpeedView() {
        if _speedView == nil {
            _speedView = UIView(frame: CGRect(x: 0, y: kHEIGHT - SafeAreaBottomHeight - (44 * CGFloat(_speeds!.count)), width: kWIDTH, height: 44 * CGFloat(_speeds!.count) + SafeAreaBottomHeight))
            _menuView!.addSubview(_speedView!)
            if(_isZoomIn == false){
                _speedView!.frame = CGRect(x: kWIDTH - 160, y: SafeAreaTopHeight - 44, width: 150, height: 44 + 44 * CGFloat(_speeds!.count))
            }
            else{
                _speedView!.frame = CGRect(x: kHEIGHT - 160, y: SafeAreaTopHeight - 44, width: 150, height: 44 + 44 * CGFloat(_speeds!.count))
            }
            _speedView!.backgroundColor = UIColor.fromRGB(0x1a1a1a).withAlphaComponent(0.98)
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (_speedView?.frame.size.width)!, height: 44))
            titleLabel.backgroundColor = .clear
            titleLabel.textColor = UIColor.fromRGB(0x727272)
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            titleLabel.text = "     \(NSLocalizedString("strSpeed", comment: ""))"
            titleLabel.textAlignment = .left
            _speedView?.addSubview(titleLabel)
            let iconView = UIImageView(frame: CGRect(x: titleLabel.frame.width - 44, y: (titleLabel.frame.height - 34) / 2.0, width: 34, height: 34))
            iconView.image = UIImage(named: "Speed_Normal_")
            iconView.alpha = 0.5
            titleLabel.addSubview(iconView)
            let line = UIView(frame: CGRect(x: 2, y: 43, width: (_speedView?.frame.width)! - 4, height: 1))
            line.backgroundColor = UIColor.fromRGB(0x272727).withAlphaComponent(1.0)
            _speedView?.addSubview(line)
            _speedView?.layer.cornerRadius = 5
            _speedView?.layer.masksToBounds = true
            _selectIconView = UIImageView()
            _selectIconView?.image = UIImage(named: "speed_Selected")
            for i in 0..<_speeds!.count {
                let height = _zoomBtn!.isSelected ? (kWIDTH / CGFloat(_speeds!.count)) : 44
                let speedLabel = UILabel(frame: CGRect(x: 0, y: height * CGFloat(i) + (_zoomBtn!.isSelected ? 0 : 44), width: _zoomBtn!.isSelected ? (_speedView?.frame.height)! : (_speedView?.frame.width)!, height: height))
                speedLabel.backgroundColor = .clear
                speedLabel.textColor = .white
                speedLabel.font = UIFont.systemFont(ofSize: 13)
                if let title = _speeds![i]["title"] as? String {
                    speedLabel.text = "\t  \(title)"
                }
                speedLabel.textAlignment = .left
                speedLabel.layer.cornerRadius = 5
                speedLabel.layer.masksToBounds = true
                speedLabel.textColor = .white
                speedLabel.backgroundColor = .clear
                speedLabel.tag = i + 1
                if _speedValue == 0 {
                    _speedValue = 1.0
                    if speedLabel.tag == 3 {
                        _selectIconView?.frame = CGRect(x: 10, y: speedLabel.frame.midY - 12, width: 24, height: 24)
                    }
                } else {
                    let speed = _speeds![i]["speed"] as? NSNumber
                    if _speedValue == CGFloat(speed!.floatValue) {
                        _selectIconView?.frame = CGRect(x: 10, y: speedLabel.frame.midY - 12, width: 24, height: 24)
                    }
                }
                speedLabel.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeSpeed(_:)))
                speedLabel.addGestureRecognizer(tapGesture)
                _speedView?.addSubview(speedLabel)
                if i < _speeds!.count - 1 {
                    let line = UIView(frame: CGRect(x: 2, y: speedLabel.frame.maxY - 1, width: (_speedView?.frame.width)! - 4, height: 1))
                    line.backgroundColor = UIColor.fromRGB(0x272727).withAlphaComponent(1.0 / UIScreen.main.scale)
                    _speedView?.addSubview(line)
                }
            }
            _speedView?.addSubview(_selectIconView!)
        }
    }
    @objc func changeSpeed(_ sender: UITapGestureRecognizer) {
        // 实现改变速度的逻辑
        let tag = sender.view?.tag as? Int
        let speed = _speeds![tag! - 1]["speed"] as? NSNumber
        _speedValue = CGFloat(speed!.floatValue);
        _kplayer?.setSpeed(Double(speed!.floatValue))
        _selectIconView?.frame = CGRect(x: 10, y: (sender.view?.frame.midY)! - 12, width: 24, height: 24)
        menuAction();
    }
    @objc func menuAction() {
        _menuView?.removeFromSuperview()
        _menuView = nil
    }
    
    @objc func menuItem(_ sender: UITapGestureRecognizer) {
        let label = sender.view as? UILabel
        switch label?.tag {
        case 1:
            print("播放速度")
            if(_speedView != nil){
                _speedView!.alpha = 0.0
                _speedView!.removeFromSuperview()
                _speedView = nil
            }
            self.setupSpeedView()
        default:
            print("音量设置")
            _isMute = !_isMute;
            (sender.view!.viewWithTag(10000) as? UIImageView)?.image = UIImage(named: (_isMute ? "BtnMute_" : "BtnMute_Off"))
            _kplayer?.setVolume(_isMute ? 0 : 2)
            _menuView?.removeFromSuperview()
            _menuView = nil
        }
        
    }
    
    // 播放/暂停按钮
    var playPauseButton : UIButton?
    // 进度条
    var progressSlider: UISlider?
    // 播放时间标签
    var currentTimeLabel: UILabel?
    // 总时间标签
    var totalTimeLabel: UILabel?
    
    
        
    // 返回按钮的点击事件处理函数
    @objc func backAction() {
        if _isPlaying == true {
            self.playPauseTapped()
        }
        if(_isZoomIn){
            self.zoomAction()
            return
        }
        _kplayer?.stop()
        _kplayer?.close()
        _kplayer = nil
        // 执行返回操作，比如popViewController
        if (self.navigationController != nil) && ((self.navigationController?.children.count)! > 1){
            _ = self.navigationController?.popViewController(animated: true)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    func configforPath(currentTime: Float, duration: Float) {
        if let configerKey = _configerKey {
            let userDefaults = UserDefaults.standard
            var config = userDefaults.object(forKey: configerKey) as? [String: Any]
            if config == nil {
                config = [String: Any]()
            }
            let currentTimeValue: Float = (currentTime + 0.2 > duration) ? 0.1 : currentTime
            config?["currentTime"] = currentTimeValue
            userDefaults.set(config, forKey: configerKey)
            userDefaults.set(_isMute, forKey: "isMute")
            userDefaults.set(_speedValue, forKey: "speed")
            userDefaults.synchronize()
            
        }
    }
    
    @objc func appWillResignActiveNotification() {
        if (_kplayer != nil) {
            
            _currentTime = _kplayer!.currentTime
            self.configforPath(currentTime: Float(CMTimeGetSeconds(_currentTime)), duration: Float(CMTimeGetSeconds(_kplayer!.duration)))
            //[self configforPath:CMTimeGetSeconds(_currentTime) duration:CMTimeGetSeconds(_rdPlayer.duration)];
            _isPlaying = false
            _kplayer!.pause()
            _playerRect = _playerBgView.frame
            _transform = _playerBgView.transform
            _kplayer!.stop()
            _kplayer!.close()
            _kplayer?.view.layer .removeFromSuperlayer()
            _kplayer?.view.removeFromSuperview()
            _kplayer = nil
            _playerBgView .removeFromSuperview()
            _playerBgView = nil
            removeTimer()
        }
    }
    
    @objc func applicationDidBecomeActiveNotification() {
        
        self .setupPlayer()
        if (_isZoomIn) {
            _playerBgView.transform = _transform!
            _playerBgView.frame = _playerRect!
            _kplayer?.view.frame = CGRectMake(0, 0, kHEIGHT, kWIDTH)
        }
        if(_kplayer != nil){
            _kplayer?.setSpeed(_speedValue)
            _kplayer?.seekTime(_currentTime)
        }
        if(playPauseButton!.isSelected){
            _kplayer?.play()
            self.addTimer()
        }
        
        self.view.bringSubviewToFront(self._titleView!)
        self.view.bringSubviewToFront(self.playerBarView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)

        view.backgroundColor = .fromRGB(0x1a1a1c)
        _speeds = self.speeds()
        _speedValue = 1.0
        _isZoomIn = false
        _playerIndex = _selectTemPathIndex;
        _titleView = UIView()
        _titleView!.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: SafeAreaTopHeight)
        _titleView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        // 创建一个返回按钮
        _backButton = UIButton()
        _backButton?.setImage(UIImage(named: "Btn_Back"), for: .normal)
        _backButton?.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        _backButton?.frame = CGRect(x: 0, y: (SafeAreaTopHeight - 44), width: 40, height: 44)
        _titleView!.addSubview(_backButton!)

        _titleLabel = UILabel()
        if let path = _playerPath {
            let components = path.components(separatedBy: "\\")
            let lastName = components.last
            _titleLabel.text = lastName
        }
        _titleLabel.textColor = .white
        _titleLabel.textAlignment = .center
        let titleLabelWidth = kWIDTH - 40 - (_backButton!.frame.width * 2)
        _titleLabel.frame = CGRect(x: _backButton!.frame.maxX + 20, y: (SafeAreaTopHeight - 44), width: titleLabelWidth, height: 44)
        _titleView!.addSubview(_titleLabel)
        
        
        _setsButton = UIButton()
        _setsButton!.setImage(UIImage(named: "File-More"), for: .normal)
        _setsButton!.frame = CGRect(x: CGRectGetWidth(_titleView!.frame) - 44, y: (SafeAreaTopHeight - 44), width: 44, height: 44)
        _setsButton!.addTarget(self, action: #selector(setsAction), for: .touchUpInside)
        _titleView!.addSubview(_setsButton!)
        
        
        setupPlayer()
        setupUI()
        if (_isVideo == false) {
            self.setupMusicView()
            view.addSubview(_musicBG!)
        }
        self.updateProgress()
        setupGestureRecognizers()
        view.addSubview(_titleView!)
        
    }
    @objc func setsAction(_ sender : UIButton){
        if _menuView != nil {
            _menuView?.removeFromSuperview()
            _menuView = nil
        }
        self.setupMenuView()
    }
    private func setupPlayer() {
        guard _playerPath != nil else { return }
        var PlayCount_Key : String? = nil
        var player_path_md5 = "";
        if(_playerPath != nil){
            player_path_md5 = HelpClass.getMD5(withContent: _playerPath!)
        }
        if _lience != nil {
            PlayCount_Key = _lience! as String + "_" + _md5Path! + "_" + player_path_md5 + "_PlayCount"
        }
        else{
            PlayCount_Key =  _md5Path! + "_" + player_path_md5 + "_PlayCount";
        }
        let playCount : Int = UserDefaults().integer(forKey: PlayCount_Key!)
        UserDefaults().setValue((playCount + 1), forKey: PlayCount_Key!)
        //MARK: - 初始化视频播放源
        if _isGemFile == true {
            if !FileManager.default.fileExists(atPath: _gemPath!) {
                print("文件不存在")
                UIWindow .showTips(NSLocalizedString("文件不存在", comment: ""))
                return
            }
            if let path = _gemPath {
                let cPath = path.cString(using: .utf8)!
                let access = O_RDONLY
                let fNDF = open_file(cPath, access, 0o666)
                if fNDF != -1 {
                    print("文件打开成功，文件描述符: \(fNDF)")
                    close(fNDF)
                } else {
                    print("文件打开失败")
                    UIWindow .showTips(NSLocalizedString("文件打开失败", comment: ""))
                }
            } else {
                print("文件路径为空")
                UIWindow .showTips(NSLocalizedString("文件路径为空", comment: ""))
            }
        }
        else{
            if !FileManager.default.fileExists(atPath: _playerPath!) {
                print("文件不存在")
                UIWindow .showTips(NSLocalizedString("文件不存在", comment: ""))
                return
            }
        }
        
        let playerRect : CGRect = CGRectMake(0, 0, kWIDTH, kHEIGHT);
        _playerBgView = UITextField()
        _playerBgView.frame = playerRect;
        _playerBgView.isSecureTextEntry = true
        _playerBgView.backgroundColor = .black
        _playerBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playerTapGestureRecognizer(_ : ))))
        _playerBgView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(playerLongPressGestureRecognizer(_ : ))))
        self.view.addSubview(_playerBgView)
        
        var pw = [UInt8](repeating: 0, count: 1024)
        if let gemPath = _gemPath, gemPath.count > 0 {
            if let passwordStr = _passwordStr {
                let utf8Data = passwordStr.utf8
                for (index, byte) in utf8Data.enumerated() {
                    if index < pw.count {
                        pw[index] = byte
                    } else {
                        break
                    }
                }
                pw.withUnsafeMutableBufferPointer { bufferPointer in
                    if let pointer = bufferPointer.baseAddress {
                        _kplayer = KanPlayer(kan: gemPath, pw: pointer, nPwLen: Int32(passwordStr.count), szFilePath: _playerPath!, frame: playerRect)
                    }
                }
            }
            else{
                _kplayer = KanPlayer(kan: gemPath, pw: nil, nPwLen: 0, szFilePath: _playerPath!, frame: playerRect)
            }
        }
        else{
            _kplayer = KanPlayer(string: _playerPath!, frame: playerRect)
        }
        if(_kplayer == nil){
            NSLog("初始化播放器句柄失败");
            UIWindow .showTips(NSLocalizedString("初始化播放器句柄失败", comment: ""))
            return;
        }else{
            var pathMd5Code : String? = nil
            if(_gemPath != nil){
                var key : String = _playerPath!
                let list = _playerPath!.components(separatedBy: "/Documents/")
                if(list.count > 1){
                    key = list.last!;
                }
                pathMd5Code = HelpClass.getFileMD5Code(_gemPath!)
                _configerKey = pathMd5Code! + "_config_" + key
            }
            else{
                pathMd5Code = HelpClass.getFileMD5Code(_playerPath!)
                _configerKey = pathMd5Code! + "_config_" + "notGemFile"
            }
            
            print("\n_configerKey:",_configerKey)
            let userDefaults = UserDefaults.standard
            var config = userDefaults.object(forKey: _configerKey!) as? [String: Any]
            if config != nil {
                _isMute = userDefaults.bool(forKey: "isMute")
                _speedValue = CGFloat(userDefaults.float(forKey: "speed"))
                if(_speedValue == 0){
                    _speedValue = 1.0;
                }
                if let currentTime = config!["currentTime"] as? Double {
                    _currentTime = CMTimeMakeWithSeconds(currentTime, preferredTimescale: Int32(600))
                }
                else{
                    _currentTime = .zero
                }
                _kplayer?.setVolume(_isMute ? 0.0 : 2.0)
                _kplayer?.setSpeed(_speedValue)
                _kplayer?.seekTime(_currentTime)
            }
            else{
                _speedValue = 1.0;
                config = [:]
                config!["currentTime"] = 0
                userDefaults.set(config, forKey: _configerKey!)
                userDefaults.setValue(_speedValue, forKey: "speed")
                userDefaults.setValue(_isMute, forKey: "isMute")
                _kplayer?.setVolume(_isMute ? 0.0 : 2.0)
                _kplayer?.seekTime(CMTimeMakeWithSeconds(0.1,preferredTimescale:600))
            }
            var index: Int = 2
            for (i, speedDict) in _speeds!.enumerated() {
                if let speedValue = speedDict["speed"] as? CGFloat, speedValue == _speedValue {
                    index = i
                }
            }
            if self._speedView != nil {
                for lb in self._speedView!.subviews {
                    if let label = lb as? UILabel, label.tag == index + 1 {
                        self._selectIconView!.frame = CGRect(x: 10, y: label.frame.minY + label.frame.height / 2.0 - 12, width: 24, height: 24)
                    }
                }
            }

            if let speedValue = self._speeds![index]["speed"] as? CGFloat {
                self._speedValue = speedValue
            }
        }
        
        if(_isVideo == true && (_kplayer!.frameWidth > 0)){
            let vh = kWIDTH * CGFloat(CGFloat(_kplayer!.frameHeight)/CGFloat(_kplayer!.frameWidth));
            let r = CGRectMake(0, (kHEIGHT - vh)/2.0, kWIDTH, vh);
            _kplayer!.frame = r;
            if(_kplayer!.frameWidth < _kplayer!.frameHeight){
                if(_zoomBtn != nil){
                    _zoomBtn?.isHidden = true
                }
            }
            else{
                if(_zoomBtn != nil){
                    _zoomBtn?.isHidden = false
                }
            }
        }
        let layer = _playerBgView.layer
        let sublayers = layer.sublayers
        let firstLayer = sublayers?.first
        (firstLayer! as CALayer).addSublayer((_kplayer?.view)!.layer)
        
        
        _kplayer?.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playerTapGestureRecognizer(_ : ))))
        _kplayer?.view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(playerLongPressGestureRecognizer(_ : ))))
        
//        //延迟0.5秒后添加
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
//            
//        }
        //视频水印
        if let waterImage = _waterImage, _isVideo == true {
            let width = Double(_kplayer!.view.bounds.size.width)
            let height = Double(_kplayer!.view.bounds.size.height)
            let cx = (_fileType != .PkgFileType_Gcp ? Double((_playCfg == nil) ? 0 : _playCfg!.nWatermarkLeft) : Double(_user_param!.nWatermarkLeft)) / width
            let cy = (_fileType != .PkgFileType_Gcp ? Double((_playCfg == nil) ? 0 : _playCfg!.nWatermarkTop) : Double(_user_param!.nWatermarkTop)) / height
            
            let nWatermarkRandom = _fileType != .PkgFileType_Gcp ? _playCfg!.nWatermarkRandom : _user_param!.nWatermarkRandom
            let xValue = _fileType != .PkgFileType_Gcp ? _playCfg!.nWatermarkLeft : _user_param!.nWatermarkLeft
            let yValue = _fileType != .PkgFileType_Gcp ? _playCfg!.nWatermarkTop : _user_param!.nWatermarkTop
            
            var finalCx = cx
            var finalCy = cy
            
            switch nWatermarkRandom {
            case 0:
                finalCx = Double(xValue)
                finalCy = Double(yValue)
            case 3:
                finalCx = -Double(xValue) - Double(waterImage.size.width)
                finalCy = Double(yValue)
            case 4:
                finalCx = Double(xValue)
                finalCy = -Double(yValue) - Double(waterImage.size.height)
            case 5:
                finalCx = -Double(xValue) - Double(waterImage.size.width)
                finalCy = -Double(yValue) - Double(waterImage.size.height)
            default:
                break
            }
            
            if let imageData = waterImage.pngData() {
                let image = UIImage(data: imageData, scale: 1.0)!
                let scaledImage = HelpClass.scale(image, toScale: 1.0 / Float(UIScreen.main.scale))
                if let scaledImageData = scaledImage.pngData() {
                    let error = _kplayer?.addImageWatermark(with: scaledImageData, cx: finalCx, cy: finalCy)
                    print("error:\(error ?? 0)")
                }
            }
            
            var freqLists : [Any] = []
            let watermarkFreq = _fileType != .PkgFileType_Gcp ? _playCfg!.nWatermarkFreq : _user_param!.nWatermarkFreq
            if watermarkFreq > 0 {
                let durationSeconds = CMTimeGetSeconds(_kplayer!.duration)
                let freqCount = Int(ceil(durationSeconds / Double(watermarkFreq)))
                var time = 0
                var index = 0
                while true {
                    time = Int(watermarkFreq) * index
                    let param = NSMutableDictionary()
                    param["show"] = NSNumber(value: false)
                    param["time"] = NSNumber(value: time)
                    index += 1
                    freqLists.append(param)
                    if freqCount < index {
                        break
                    }
                }
            }
        }
        _kplayer?.playerDidEndBlock = { [weak self] in
            //这里判断当前线程是主线程还是非主线程
            print("===========>> playerDidEndBlock")
            guard let bself = self else { return }
            bself._isPlaying = false
            bself._kplayer?.pause()
            bself.removeTimer()
            if Thread.isMainThread {
                bself.playPauseButton!.isSelected = false
                bself.playPauseButton!.setImage(UIImage(named:"Detail_Play"), for: .normal)
            } else {
                DispatchQueue.main.sync {
                    bself.playPauseButton!.isSelected = false
                    bself.playPauseButton!.setImage(UIImage(named:"Detail_Play"), for: .normal)
                }
            }
            bself._kplayer?.seekTime(CMTimeMakeWithSeconds(0, preferredTimescale:600))
            bself._playerIndex = bself._selectTemPathIndex
            bself.changePlayerSlider()
            if bself._gemPath != nil {
                if(bself._gemPath!.count > 0){
                    if let questions = bself._questions, !questions.isEmpty {
                        for (index, item) in questions.enumerated() {
                            if var question = item as? [String: Any] {
                                question["showed"] = false
                                bself._questions?[index] = question
                            }
                        }
                    }
                }
            }
        }
    }

    @objc func changePlayerSlider(){
        if isDraggle {
            return
        }
        if _kplayer == nil {
            return
        }
        if Thread.isMainThread {
            self.updateProgress()
        } else {
            DispatchQueue.main.sync {
                self.updateProgress()
            }
        }
    }
    
    func updateProgress(){
        
        var currentSeconds = CMTimeGetSeconds(_kplayer!.currentTime)
        var duration : Float64 = CMTimeGetSeconds(_kplayer!.duration)
        if duration.isNaN {
            duration = 0
        }
        
        if(currentSeconds > duration){
            currentSeconds = duration / _speedValue;
        }
        if(currentSeconds.isNaN){
            return
        }
        let progress : CGFloat = currentSeconds/CGFloat(duration)
        self.totalTimeLabel?.text = formatTime(seconds: duration,isTotalTime: true)
        self.currentTimeLabel?.text = self.formatTime(seconds: currentSeconds,isTotalTime: false)
        self.progressSlider?.value = Float(progress)
        
        if(_isVideo == true){
            if(currentSeconds + 0.25 >= duration){
                playPauseButton!.isSelected = false
                _isPlaying = false
                if(_zoomBtn!.isSelected){
                    _backButton?.isHidden = false
                }else{
                    _titleView?.isHidden = false
                }
            }
        }
        if _isPlaying {
            self.config(forPath: Float(currentSeconds), duration: Float(duration))
        }
//        if let startUrl = HelpClass.utf8(toString: self._playCfg?.szStartPlayUrl) {
//            if currentSeconds < 0.2 {
//                if !startUrl.isEmpty {
//                    if #available(iOS 10.0, *) {
//                        if let url = URL(string: startUrl) {
//                            UIApplication.shared.open(url, options: [:]) { success in
//                                // 这里可以添加打开 URL 完成后的处理逻辑
//                            }
//                        }
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }
//            }
//        }
//        
//        if(_fileType != .PkgFileType_Gcp){
//            if let endUrl = HelpClass.utf8(toString: _playCfg?.szEndPlayUrl) {
//                if(currentSeconds > CMTimeGetSeconds(_kplayer!.duration) - 0.2){
//                    if(endUrl.length>0){
//                        if #available(iOS 10.0, *) {
//                            if let url = URL(string: endUrl) {
//                                UIApplication.shared.open(url, options: [:]) { success in
//                                    // 这里可以添加打开 URL 完成后的处理逻辑
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
        if (_gemPath != nil) {
            if (Int(currentSeconds) > _nPlayTime! && _nPlayTime! > 0){
                _isPlaying = false
                self.removeTimer()
                _kplayer?.pause()
                _kplayer?.stop()
                _kplayer?.seekTime(CMTimeMake(value: 0, timescale: Int32(NSEC_PER_SEC)))
                self.progressSlider?.value = 0
                self.currentTimeLabel?.text = HelpClass.timeFormatted(0)
                self.config(forPath: 0, duration: Float(duration))
                UIWindow .showTips(NSLocalizedString("strNotPlayDuration", comment: ""))
                return
            }
            let time = currentSeconds
            if(_questions != nil){
                if _questions!.count > 0 {
                    for i in 0..<_questions!.count {
                        let tempItem = _questions![i]
                        let item = tempItem as! NSMutableDictionary
                        if let showed = item["showed"] as? Bool, showed {
                            continue
                        }
                        if let nTime = item["nTime"] as? Int {
                            let second = Double(nTime) * 60.0
                            if second > (time - 0.2) && second < (time + 0.2) {
                                item["showed"] = true
                                _questions![i] = item
                                
                                _isPlaying = false
                                removeTimer()
                                _kplayer?.pause()
                                
                                let alertVc = UIAlertController(title: NSLocalizedString("strEnterAnswer", comment: ""), message: nil, preferredStyle: .alert)
                                alertVc.addTextField { textField in
                                    textField.placeholder = item["szQueation"] as? String
                                }
                                
                                let action1 = UIAlertAction(title: NSLocalizedString("确认", comment: ""), style: .destructive) { [weak self] action in
                                    guard let self = self, let textFields = alertVc.textFields, let answer = textFields[0].text else { return }
                                    if answer.isEmpty {
                                        _kplayer?.pause()
                                        _kplayer?.seekTime(CMTimeMake(value: 0, timescale: Int32(NSEC_PER_SEC)))
                                        self.progressSlider?.value = 0
                                        self.currentTimeLabel?.text = HelpClass.timeFormatted(0)
                                        self.config(forPath: 0, duration: Float(duration))
                                    } else {
                                        if let correctAnswer = item["szAnswer"] as? String, answer == correctAnswer {
                                            _isPlaying = true
                                            self.addTimer()
                                            _kplayer?.play()
                                            return
                                        } else {
                                            _kplayer?.pause()
                                            _kplayer?.seekTime(CMTimeMake(value: 0, timescale: Int32(NSEC_PER_SEC)))
                                            self.progressSlider?.value = 0
                                            self.currentTimeLabel?.text = HelpClass.timeFormatted(0)
                                            self.config(forPath: 0, duration: Float(duration))
                                        }
                                    }
                                    if self._questions!.count > 0 {
                                        for i in 0..<self._questions!.count {
                                            let tempItem = _questions![i]
                                            let item = tempItem as! NSMutableDictionary
                                            item["showed"] = false
                                            self._questions![i] = item
                                        }
                                    }
                                }
                                
                                let action2 = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel) { [weak self] action in
                                    guard let self = self else { return }
                                    _kplayer?.pause()
                                    _kplayer?.seekTime(CMTimeMake(value: 0, timescale: Int32(NSEC_PER_SEC)))
                                    self.progressSlider?.value = 0
                                    self.currentTimeLabel?.text = HelpClass.timeFormatted(0)
                                    self.config(forPath: 0, duration: Float(duration))
                                    if self._questions!.count > 0 {
                                        for i in 0..<self._questions!.count {
                                            let tempItem = self._questions![i]
                                            let item = tempItem as! NSMutableDictionary
                                            item["showed"] = false
                                            self._questions![i] = item
                                        }
                                    }
                                }
                                
                                alertVc.addAction(action2)
                                alertVc.addAction(action1)
                                present(alertVc, animated: true, completion: nil)
                                break
                            }
                        }
                    }
                }
                
            }
            if let waterImage = _waterImage, _isVideo! {
                if !_freqLists!.isEmpty {
                    for (index, freqList) in _freqLists!.enumerated() {
                        let itemInfo : [String : Any] = (freqList as? [String : Any])!
                        if let timeValue = itemInfo["time"] as? Int, timeValue >= Int(time - 0.2) && timeValue < Int(time + 0.1) {
                            var dic = (freqList as AnyObject).mutableCopy() as! NSMutableDictionary
                            if let show = dic["show"] as? Bool, show {
                                return
                            }
                            //{0:左上角，1:随机出现窗口边缘，2:全屏随机，3:右上角，4:左下角，5:右下角}
                            let nWatermarkRandom = _fileType != .PkgFileType_Gcp ? _playCfg!.nWatermarkRandom : _user_param!.nWatermarkRandom
                            if nWatermarkRandom == 1 || nWatermarkRandom == 2 {
                                let screenScale : CGFloat = UIScreen.main.scale
                                let frameWidth  : CGFloat = (CGFloat(_kplayer!.frameWidth) * 1.0)
                                let frameHeight : CGFloat = (CGFloat(_kplayer!.frameHeight) * 1.0)
                                let maxx = 1 - ((waterImage.size.width / screenScale) / frameWidth )
                                let maxy = 1 - ((waterImage.size.height / screenScale) / frameHeight)
                                
                                var posx = max(min(Float(arc4random_uniform(100)) / 100.0, Float(maxx)), 0)
                                var posy = max(min(Float(arc4random_uniform(100)) / 100.0, Float(maxy)), 0)
                                if nWatermarkRandom == 1 {
                                    let xIndex = Int(arc4random_uniform(100)) % 3
                                    posx = xIndex == 0 ? 0 : (xIndex == 1 ? max(min(Float(arc4random_uniform(100)) / 100.0, Float(maxy)), 0) : Float(maxx))
                                    if xIndex == 1 {
                                        posy = Int(arc4random_uniform(100)) % 2 == 0 ? 0 : Float(maxy)
                                    }
                                }
                                _kplayer?.updateImageWatermarkPos(0, cx: CGFloat(posx), cy: CGFloat(posy))
                                dic["show"] = true
                                _freqLists![index] = dic
                            }
                        }
                    }
                }
            }
        }
        
    }
    @objc func playerTapGestureRecognizer(_ gesture : UITapGestureRecognizer){
        if(_isVideo == true){
            if (_isPlaying == true){
                self._titleView!.isHidden = false;
                self.playerBarView!.isHidden = false
                Thread.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenBootomtoolView), object: nil)
                self.perform(#selector(hiddenBootomtoolView), with: nil, afterDelay: 3)
            }
        }
        
    }
    @objc func playerLongPressGestureRecognizer(_ gesture : UILongPressGestureRecognizer){
        if(_isVideo == true){
            if (_isPlaying == true){
                self._titleView!.isHidden = false;
                self.playerBarView!.isHidden = false
                Thread.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenBootomtoolView), object: nil)
                self.perform(#selector(hiddenBootomtoolView), with: nil, afterDelay: 3)
            }
        }
    }
    @objc func hiddenBootomtoolView(){
        self._titleView!.isHidden = _isVideo!
        self.playerBarView!.isHidden = true
    }
    @objc func config(forPath currentTime: Float, duration: Float) {
        if let configerKey = _configerKey {
            // 获取存储的信息
            let userDefaults = UserDefaults.standard
            var config: [String: Any] = userDefaults.dictionary(forKey: configerKey) ?? [:]

            if currentTime + 0.2 > duration {
                config["currentTime"] = 0.1
            } else {
                config["currentTime"] = currentTime
            }

            // 保存配置信息
            userDefaults.set(config, forKey: configerKey)
            userDefaults.set(_isMute, forKey: "isMute")
            userDefaults.set(_speedValue, forKey: "speed")
        }
    }

    func addTimer(){
        self.removeTimer()
        _timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(changePlayerSlider), userInfo: nil, repeats: true)
        RunLoop.main.add(_timer!, forMode: .default)
        self.startAnimation()
        Thread.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenBootomtoolView), object: nil)
        self.perform(#selector(hiddenBootomtoolView), with: nil, afterDelay: 3)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self._titleView!.isHidden = false
        self.playerBarView!.isHidden = false
        if(_isPlaying){
            Thread.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenBootomtoolView), object: nil)
            self.perform(#selector(hiddenBootomtoolView), with: nil, afterDelay: 3)
        }
    }
    func removeTimer(){
        if _timer != nil {
            _timer!.invalidate()
            _timer = nil
        }
        self.removeAnimation()
        Thread.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hiddenBootomtoolView), object: nil)
        if Thread.isMainThread {
            self._titleView!.isHidden = false
            self.playerBarView!.isHidden = false
            self.view .bringSubviewToFront(self._titleView!)
        }
        else{
            DispatchQueue.main.sync {
                self._titleView!.isHidden = false
                self.playerBarView!.isHidden = false
                self.view .bringSubviewToFront(self._titleView!)
            }
        }
        
    }
    func startAnimation(){
        self.removeAnimation()
        let animation : CABasicAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        animation.fromValue = 0.0
        animation.toValue = NSNumber(value: Double.pi * 2)
        animation.duration = 5
        animation.autoreverses = false
        animation.fillMode = .forwards
        animation.repeatCount = MAXFLOAT
        //DispatchQueue.main.sync {
        if self._musicIconLogo != nil {
            self._musicIconLogo?.layer.add(animation, forKey: nil)
        }
        //}
    }

    func removeAnimation(){
        if(self._musicIconLogo != nil){
            if Thread.isMainThread {
                self._musicIconLogo!.layer.removeAllAnimations()
            }
            else{
                DispatchQueue.main.sync {
                    self._musicIconLogo!.layer.removeAllAnimations()
                }
            }
        }
    }
    
    @objc func setupMusicView() {
        // 加载图片
        if let image = UIImage(named: "musicLogo") {
            let playerRect : CGRect = CGRectMake(0, 0, kWIDTH, kHEIGHT - SafeAreaBottomHeight - 44 - 44);
            _musicBG = UIImageView(frame: playerRect)
            _musicBG!.layer.masksToBounds = true
            _musicBG!.image = image
            _musicIconLogo = UIImageView(frame: CGRect(x: (CGRectGetWidth(_musicBG!.frame) - 240.0)/2.0, y: (CGRectGetHeight(_musicBG!.frame) - 240.0)/2.0, width: 240, height: 240))
            _musicIconLogo!.image = image
            _musicIconLogo!.contentMode = .scaleAspectFill
            _musicBG?.addSubview(_musicIconLogo!)
            self.view .insertSubview(_musicBG!, at: 0)
            // 毛玻璃效果
            let blurEffect = UIBlurEffect(style: .light)
            let visualEfView = UIVisualEffectView(effect: blurEffect)
            visualEfView.frame = _musicBG!.bounds
            visualEfView.alpha = 1.0
            visualEfView.isUserInteractionEnabled = true
            _musicBG!.insertSubview(visualEfView, belowSubview: _musicIconLogo!)
            // 创建 UIToolbar
            _coverBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: _musicBG!.frame.size.width, height: _musicBG!.frame.size.height))
            _coverBar!.barStyle = .blackTranslucent
            _coverBar!.isUserInteractionEnabled = true
            _musicBG!.insertSubview(_coverBar!, belowSubview: _musicIconLogo!)
        }
    }
    
    private func setupUI() {
        
        if(playPauseButton != nil){
            playPauseButton?.removeFromSuperview()
            playPauseButton = nil
        }
        if(progressSlider != nil){
            progressSlider!.removeFromSuperview()
            progressSlider = nil
        }
        if(currentTimeLabel != nil){
            currentTimeLabel!.removeFromSuperview()
            currentTimeLabel = nil
        }
        if(totalTimeLabel != nil){
            totalTimeLabel!.removeFromSuperview()
            totalTimeLabel = nil
        }
        if(_zoomBtn != nil){
            _zoomBtn!.removeFromSuperview()
            _zoomBtn = nil
        }
        if(_leftTimeBtn != nil){
            _leftTimeBtn!.removeFromSuperview()
            _leftTimeBtn = nil
        }
        
        if(_rightTimeBtn != nil){
            _rightTimeBtn!.removeFromSuperview()
            _rightTimeBtn = nil
        }
        if(playerBarView != nil){
            playerBarView .removeFromSuperview()
            playerBarView = nil
        }
        
        playerBarView = UIView.init(frame: CGRect(x: 0, y: kHEIGHT - SafeAreaBottomHeight - 44 - 44, width: kWIDTH, height: 44 + 44 + SafeAreaBottomHeight))
        playerBarView.backgroundColor = UIColor.fromRGB(0x000000).withAlphaComponent(0.5)
        view.addSubview(playerBarView)
        
        
        // 添加播放/暂停按钮
        playPauseButton = UIButton()
        playPauseButton!.setImage(UIImage(named:"Detail_Play"), for: .normal)
        playPauseButton!.frame = CGRectMake(CGRectGetWidth(playerBarView.frame)/2.0 - 22, 44, 44, 44)
        playPauseButton!.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        playerBarView.addSubview(playPauseButton!)
        
        // 添加播放时间标签
        currentTimeLabel = UILabel()
        currentTimeLabel!.textColor = .fromRGB(0xcccccc)
        currentTimeLabel!.font = .systemFont(ofSize: 13)
        currentTimeLabel!.textAlignment = .center
        currentTimeLabel!.text = "0:00"
        currentTimeLabel!.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        playerBarView.addSubview(currentTimeLabel!)
        
        // 添加进度条
        progressSlider = UISlider()
        progressSlider!.minimumValue = 0
        progressSlider!.maximumValue = 1
        progressSlider!.value = 0
        progressSlider!.isEnabled = _nCheckSeekTimeDisable == 0 ? true : false;
        progressSlider!.setThumbImage(UIImage(named: "Detail_Drag_Normal"), for: .normal)
        progressSlider!.setThumbImage(UIImage(named: "Detail_Drag_Down"), for: .highlighted)
        playerBarView.addSubview(progressSlider!)
        progressSlider!.frame = CGRectMake(60, 7, kWIDTH - 60 - 60 - 54, 30)
        progressSlider!.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider!.addTarget(self, action: #selector(sliderValueChangeBegin), for: .touchDown)
        progressSlider!.addTarget(self, action: #selector(sliderValueChangeEnd), for: [.touchUpInside,.touchUpOutside,.touchCancel])
        
        // 添加总时间标签
        totalTimeLabel = UILabel()
        totalTimeLabel!.text = "0:00"
        totalTimeLabel!.textColor = .fromRGB(0xcccccc)
        totalTimeLabel!.font = .systemFont(ofSize: 13)
        totalTimeLabel!.textAlignment = .center
        totalTimeLabel!.frame = CGRect(x: kWIDTH - 60 - 54, y: 0, width: 60, height: 44)
        playerBarView.addSubview(totalTimeLabel!)
        
        _zoomBtn = UIButton.init(frame: CGRectMake(kWIDTH - 54, 0, 44, 44))
        _zoomBtn?.setImage(UIImage(named: "zoom_Normal_"), for: .normal)
        _zoomBtn?.addTarget(self, action: #selector(zoomAction), for: .touchUpInside)
        _zoomBtn?.adjustsImageWhenHighlighted = false;
        _zoomBtn?.isHidden = (_isVideo != true)
        playerBarView.addSubview(_zoomBtn!)
        
        _leftTimeBtn = UIButton.init(frame: CGRectMake(CGRectGetMinX(playPauseButton!.frame) - 64, 44, 44, 44))
        _leftTimeBtn!.setImage(UIImage(named: "last10_Normal"), for: .normal)
        _leftTimeBtn!.addTarget(self, action: #selector(leftTimeBtnAction), for: .touchUpInside)
        _leftTimeBtn!.adjustsImageWhenHighlighted = false;
        _leftTimeBtn!.isEnabled = progressSlider!.isEnabled
        playerBarView.addSubview(_leftTimeBtn!)
        
        _rightTimeBtn = UIButton.init(frame: CGRectMake(CGRectGetMaxX(playPauseButton!.frame) + 20, 44, 44, 44))
        _rightTimeBtn!.setImage(UIImage(named: "next30_Normal"), for: .normal)
        _rightTimeBtn!.addTarget(self, action: #selector(rightTimeBtnAction), for: .touchUpInside)
        _rightTimeBtn!.adjustsImageWhenHighlighted = false;
        _rightTimeBtn!.isEnabled = progressSlider!.isEnabled
        playerBarView.addSubview(_rightTimeBtn!)
        
        if(_isVideo == false){
            totalTimeLabel!.frame = CGRect(x: kWIDTH - 60, y: 0, width: 60, height: 44)
            progressSlider!.frame = CGRectMake(60, 7, kWIDTH - 60 - 60, 30)
            _leftTimeBtn!.setImage(UIImage(named: "Up_Music"), for: .normal)
            _rightTimeBtn!.setImage(UIImage(named: "Down_Music"), for: .normal)
            _leftTimeBtn?.isEnabled = (_selectTemPathIndex! > 0)
            _rightTimeBtn?.isEnabled = (_selectTemPathIndex! < (_temPaths!.count - 1))
            
        }
        else{
            if(_isVideo == true && (_kplayer!.frameWidth > 0)){
                if(_kplayer!.frameWidth <= _kplayer!.frameHeight){
                    _zoomBtn?.isHidden = true
                    totalTimeLabel!.frame = CGRect(x: kWIDTH - 60, y: 0, width: 60, height: 44)
                    progressSlider!.frame = CGRectMake(60, 7, kWIDTH - 60 - 60, 30)
                }
                else{
                    _zoomBtn?.isHidden = false
                }
            }
            
            _upBtn = UIButton.init(frame: CGRectMake(CGRectGetMinX(_leftTimeBtn!.frame) - 64, 44, 44, 44))
            _upBtn!.setImage(UIImage(named: "Up_Music"), for: .normal)
            _upBtn!.addTarget(self, action: #selector(swipeRight), for: .touchUpInside)
            _upBtn!.adjustsImageWhenHighlighted = false;
            playerBarView.addSubview(_upBtn!)
            
            _downBtn = UIButton.init(frame: CGRectMake(CGRectGetMaxX(_rightTimeBtn!.frame) + 20, 44, 44, 44))
            _downBtn!.setImage(UIImage(named: "Down_Music"), for: .normal)
            _downBtn!.addTarget(self, action: #selector(swipeLeft), for: .touchUpInside)
            _downBtn!.adjustsImageWhenHighlighted = false;
            playerBarView.addSubview(_downBtn!)
            _upBtn?.isEnabled = (_selectTemPathIndex! > 0)
            _downBtn?.isEnabled = (_selectTemPathIndex! < (_temPaths!.count - 1))
        }
    }
    @objc func zoomAction(){
        if(_kplayer!.frameWidth <= _kplayer!.frameHeight){
            return
        }
        if _isZoomIn {
            _isZoomIn = false
            let rotationTransform = CGAffineTransform(rotationAngle: 0)
            playerBarView.transform = rotationTransform
            playerBarView.frame = CGRect(x: 0, y: kHEIGHT - SafeAreaBottomHeight - 44 - 44, width: kWIDTH, height: 44 + 44 + SafeAreaBottomHeight)
            currentTimeLabel!.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
            progressSlider!.frame = CGRectMake(60, 7, CGRectGetWidth(playerBarView.frame) - 60 - 60 - 54, 30)
            totalTimeLabel!.frame = CGRect(x: CGRectGetWidth(playerBarView.frame) - 60 - 54, y: 0, width: 60, height: 44)
            _zoomBtn?.frame = CGRectMake(CGRectGetWidth(playerBarView.frame) - 54, 0, 44, 44)
            playPauseButton!.frame = CGRectMake(CGRectGetWidth(playerBarView.frame)/2.0 - 22, 44, 44, 44)
            _leftTimeBtn?.frame = CGRectMake(CGRectGetMinX(playPauseButton!.frame) - 64, 44, 44, 44)
            _rightTimeBtn?.frame = CGRectMake(CGRectGetMaxX(playPauseButton!.frame) + 20, 44, 44, 44)
            _upBtn?.frame = CGRectMake(CGRectGetMinX(_leftTimeBtn!.frame) - 64, 44, 44, 44)
            _downBtn?.frame = CGRectMake(CGRectGetMaxX(_rightTimeBtn!.frame) + 20, 44, 44, 44)
            _upBtn?.isHidden = false
            _downBtn?.isHidden = false
            
            _titleView!.transform = rotationTransform
            _titleView!.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: SafeAreaTopHeight)
            _backButton?.frame = CGRect(x: 0, y: (SafeAreaTopHeight - 44), width: 40, height: 44)
            let titleLabelWidth = kWIDTH - 40 - (_backButton!.frame.width * 2)
            _titleLabel.frame = CGRect(x: _backButton!.frame.maxX + 20, y: (SafeAreaTopHeight - 44), width: titleLabelWidth, height: 44)
            _setsButton!.frame = CGRect(x: CGRectGetWidth(_titleView!.frame) - 44, y: (SafeAreaTopHeight - 44), width: 44, height: 44)
            
            _playerBgView.transform = rotationTransform
            _playerBgView.frame = CGRectMake(0, 0, kWIDTH, kHEIGHT)
            _kplayer?.view.frame = CGRectMake(0, 0, kWIDTH, kHEIGHT)
        }
        else{
            _isZoomIn = true
            let rotationTransform = CGAffineTransform(rotationAngle: .pi / 2)
            playerBarView.transform = rotationTransform
            playerBarView.frame = CGRect(x: 0, y: 0, width: 44 + 44, height: kHEIGHT)
            currentTimeLabel!.frame = CGRect(x: SafeAreaTopHeight - 44, y: 0, width: 60, height: 44)
            progressSlider!.frame = CGRectMake(CGRectGetMaxX(currentTimeLabel!.frame), 7, CGRectGetHeight(playerBarView.frame) - 60 - CGRectGetMaxX(currentTimeLabel!.frame) - 54, 30)
            totalTimeLabel!.frame = CGRect(x: CGRectGetHeight(playerBarView.frame) - 60 - 54, y: 0, width: 60, height: 44)
            _zoomBtn?.frame = CGRectMake(CGRectGetHeight(playerBarView.frame) - 54, 0, 44, 44)
            playPauseButton?.frame = CGRectMake(CGRectGetHeight(playerBarView.frame)/2.0 - 22, 44, 44, 44)
            
            _leftTimeBtn?.frame = CGRectMake(CGRectGetMinX(playPauseButton!.frame) - 64, 44, 44, 44)
            _rightTimeBtn?.frame = CGRectMake(CGRectGetMaxX(playPauseButton!.frame) + 20, 44, 44, 44)
            _upBtn?.frame = CGRectMake(CGRectGetMinX(_leftTimeBtn!.frame) - 84, 44, 44, 44)
            _downBtn?.frame = CGRectMake(CGRectGetMaxX(_rightTimeBtn!.frame) + 30, 44, 44, 44)
            _upBtn?.isHidden = true
            _downBtn?.isHidden = true
            
            _titleView!.transform = rotationTransform
            _titleView!.frame = CGRect(x: kWIDTH - 44, y:0, width: 44, height:kHEIGHT )
            _backButton?.frame = CGRect(x: (SafeAreaTopHeight - 44), y: 0, width: 40, height: 44)
            let titleLabelWidth = CGRectGetHeight(_titleView!.frame) - 40 - (_backButton!.frame.width * 2)
            _titleLabel.frame = CGRect(x: _backButton!.frame.maxX + 20, y: 0, width: titleLabelWidth, height: 44)
            _setsButton!.frame = CGRect(x: CGRectGetHeight(_titleView!.frame) - 44, y: 0, width: 44, height: 44)
            
            _playerBgView.transform = rotationTransform
            _playerBgView.frame = CGRectMake(0, 0, kWIDTH, kHEIGHT)
            _kplayer?.view.frame = CGRectMake(0, 0, kHEIGHT, kWIDTH)
        }
    }
    @objc func leftTimeBtnAction(){
        if _isVideo == true {
            _kplayer?.pause()
            let currentTime = CMTimeGetSeconds(_kplayer!.currentTime)
            _kplayer?.seekTime(CMTimeMakeWithSeconds(currentTime - 10, preferredTimescale:600))
            self.updateProgress()
            if _isPlaying == true {
                _kplayer?.play()
            }
        }
        else{
            //音乐的话就上一曲
            swipeRight();
        }
    }
    @objc func rightTimeBtnAction(){
        if(_isVideo == true){
            _kplayer?.pause()
            let currentTime = CMTimeGetSeconds(_kplayer!.currentTime)
            _kplayer?.seekTime(CMTimeMakeWithSeconds(currentTime + 30, preferredTimescale:600))
            self.updateProgress()
            if _isPlaying == true {
                _kplayer?.play()
            }
        }
        else{
            //音乐的话就切一曲
            swipeLeft()
        }
    }
    
    private func setupGestureRecognizers() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
    }


    private func formatTime(seconds: TimeInterval,isTotalTime:Bool) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        if isTotalTime {
            return "\(formatter.string(from: seconds) ?? "0:00")"
        }
        else{
           return formatter.string(from: seconds) ?? "0:00"
        }
    }

    @objc private func playPauseTapped() {
        if _isPlaying == false {
            let reachability = HelpClass.reachability()
            if reachability.currentReachabilityStatus() != .notReachable {
                if(_playCfg!.nDisableOnLine == 1){
                    UIWindow .showTips(NSLocalizedString("strNotPlayWithNet", comment: ""))
                    return;
                }
            }
            
            var PlayCount_Key : String? = nil
            var player_path_md5 = "";
            if(_playerPath != nil){
                player_path_md5 = HelpClass.getMD5(withContent: _playerPath!)
            }
            if _lience != nil {
                PlayCount_Key = _lience! as String + "_" + _md5Path! + "_" + player_path_md5 + "_PlayCount"
            }
            else{
                PlayCount_Key =  _md5Path! + "_" + player_path_md5 + "_PlayCount";
            }
            let playCount : Int = UserDefaults().integer(forKey: PlayCount_Key!)
            if (playCount > (_nMaxPlayCount as? Int ?? 0) && ((_nMaxPlayCount as? Int ?? 0) > 0)) {
                UIWindow .showTips(NSLocalizedString("strErrorPlayTimes", comment: ""))
                return
            }
            _kplayer?.play()
            _isPlaying = true
            playPauseButton!.setImage(UIImage(named: "Detail_Pause"), for: .normal)
            addTimer()
        } else {
            _kplayer?.pause()
            _isPlaying = false
            playPauseButton!.setImage(UIImage(named:"Detail_Play"), for: .normal)
            removeTimer()
        }
    }
    
    @objc private func sliderValueChangeBegin() {
        isDraggle = true
        _kplayer?.pause()
    }
    @objc private func sliderValueChangeEnd() {
        isDraggle = false
        if _isPlaying {
            _kplayer?.play()
        }
    }
    
    @objc private func sliderValueChanged() {
        if let duration = _kplayer?.duration {
            var totalSeconds = CMTimeGetSeconds(duration)
            if totalSeconds.isNaN {
                totalSeconds = 0
            }
            let seekTime = CMTime(seconds: Double(progressSlider!.value) * totalSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            _kplayer?.seekTime(seekTime)
            
            let currentSeconds = CMTimeGetSeconds(seekTime)
            self.currentTimeLabel!.text = self.formatTime(seconds: currentSeconds,isTotalTime: false)
            
            
        }
    }

    @objc func swipeLeft() {
        if _selectTemPathIndex! < _temPaths!.count - 1 {
            _selectTemPathIndex! += 1
            playVideo(at: _selectTemPathIndex!)
            view.bringSubviewToFront(_titleView!)
        }
    }

    @objc func swipeRight() {
        if _selectTemPathIndex! > 0 {
            _selectTemPathIndex! -= 1
            playVideo(at: _selectTemPathIndex!)
            view.bringSubviewToFront(_titleView!)
        }
    }

    private func playVideo(at index: Int) {
        guard index < _temPaths!.count else { return }
        _playerPath = _temPaths![index]
        
        //MARK: - 更换视频播放源
        if let path = _playerPath {
            let components = path.components(separatedBy: "\\")
            let lastName = components.last
            _titleLabel.text = lastName
        }
        if(_isPlaying){
            self.playPauseTapped()
        }
        _kplayer?.stop()
        _kplayer?.view.removeFromSuperview()
        _kplayer = nil
        
        _playerBgView.removeFromSuperview()
        _playerBgView = nil
        
        self.setupPlayer()
        self.setupUI()
        self.updateProgress()
        if (_isVideo == false) {
            self.setupMusicView()
            view.addSubview(_musicBG!)
        }
        else{
            _upBtn?.isEnabled = (_selectTemPathIndex! > 0)
            _downBtn?.isEnabled = (_selectTemPathIndex! < (_temPaths!.count - 1))
        }
    }
}
