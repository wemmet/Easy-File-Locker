//
//  WifiSendFileViewController.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/28.
//

import Foundation

class WifiSendFileViewController: UIViewController,GCDWebUploaderDelegate {
    var _backButton : UIButton?
    var _titleLabel : UILabel?
    
    var _webServer : GCDWebUploader?
    
    @objc func backAction() {
        //这里弹出提示框，是否退出
        let alert = UIAlertController(title: NSLocalizedString("WifiSendFile.Alert.Title", comment: ""), message: NSLocalizedString("WifiSendFile.Alert.Message", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("WifiSendFile.Alert.Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("WifiSendFile.Alert.OK", comment: ""), style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _webServer!.stop()
        _webServer = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .fromRGB(0x1a1a1c);
        
        let reachability = HelpClass.reachability()
        if reachability.currentReachabilityStatus() == .notReachable {
            AlertView.showAlert(withTitle: NSLocalizedString("Alert.NetworkTitle", comment: ""), message: NSLocalizedString("Alert.NetworkMessage", comment: "")) {
                self.enterSystemSets()
            }
        }
        
        // 创建一个返回按钮
        _backButton = UIButton()
        _backButton!.setImage(UIImage(named: "Btn_Back"), for: .normal)
        _backButton!.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        _backButton!.frame = CGRect(x: 0, y: (SafeAreaTopHeight - 44), width: 40, height: 44)
        self.view.addSubview(_backButton!)
        
        _titleLabel = UILabel()
        _titleLabel!.text = NSLocalizedString("WifiSendFile.title", comment: "")
        _titleLabel!.textColor = .white
        _titleLabel!.textAlignment = .center
        let titleLabelWidth = kWIDTH - 40 - (_backButton!.frame.width * 2)
        _titleLabel!.frame = CGRect(x: _backButton!.frame.maxX + 20, y: (SafeAreaTopHeight - 44), width: titleLabelWidth, height: 44)
        self.view.addSubview(_titleLabel!)
        let titleLine = UIView()
        titleLine.frame = CGRect(x: 0, y: CGRectGetMaxY(_titleLabel!.frame) - CGFloat(1.0/UIScreen.main.scale), width: kWIDTH, height: CGFloat(1.0/UIScreen.main.scale))
        titleLine.backgroundColor = UIColor.fromRGB(0x2d2d2d)
        view.addSubview(titleLine)
        
        
        let label = UILabel(frame: CGRectMake(10, (UIScreen.main.bounds.size.height - 150)/2 , UIScreen.main.bounds.size.width - 20, 100));
        label.backgroundColor = .clear
        label.textColor = .fromRGB(0x888888)
        label.textAlignment = .center
        label.numberOfLines = 0
        view.addSubview(label)
        
        //自定义网页二
        // 文件存储位置
        let documentationDirectory = HelpClass.getDocumentsDir()//NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true).first!
        
        // 创建webServer，设置根目录
        _webServer = GCDWebUploader.init(uploadDirectory: documentationDirectory as! String) //[[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
        // 设置代理
        _webServer!.delegate = self
        _webServer!.allowHiddenItems = true
        
        // 限制文件上传类型
        _webServer!.allowedFileExtensions = ["7z","rar","zip","gcp","gfx","gem","mp3","aac","wav","mov","mp4","jpeg","tiff","pdf","gif","jpg","png"];
        // 设置网页标题
        _webServer!.title = NSLocalizedString("appName", comment: "")
        // 设置展示在网页上的文字(开场白)
        _webServer!.prologue = NSLocalizedString("注意:<br>  为了保证文件传输成功<br>- 请确保您的手机和电脑在同一个无线网络里;<br>-  请确保手机端PV软件不要离开Wi-Fi传输页面，且不要锁屏；<br><br>- 批量传输文件请使用Chrome浏览器<br><br>- 拖放文件到此窗口或者使用按钮\"传文件到手机\"以传输电脑上的文件到手机。", comment: "");
        // 设置展示在网页上的文字(收场白)
        _webServer!.epilogue = ""
        
        if (_webServer!.start(withPort: 80, bonjourName: "")){
            print("服务器启动成功")
            if(_webServer!.serverURL!.absoluteString.count == 0){
                label.text = NSLocalizedString("RDWifiServer not check", comment: "")
                label.numberOfLines = 0
                return
            }
            UIApplication.shared.isIdleTimerDisabled = true//不自动锁屏
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            
            let strContent = NSLocalizedString("WifiSendFileVC_labeltext1", comment: "") + NSLocalizedString("WifiSendFileVC_labeltext2",comment: "") + _webServer!.serverURL!.absoluteString + NSLocalizedString("WifiSendFileVC_labeltext3",comment: "")
            let att = NSMutableAttributedString.init(string: strContent, attributes: [NSAttributedString.Key.font: label.font as Any,
                                                                                      NSAttributedString.Key.foregroundColor: UIColor.fromRGB(0x888888)])
            
            if let serverURL = _webServer!.serverURL, let range = strContent.range(of: serverURL.absoluteString) {
                let nsRange = NSRange(range, in: strContent)
                att.addAttribute(.foregroundColor, value: UIColor.fromRGB(0xffffff), range: nsRange)
            }
            att.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: strContent.count))
            
            var r = att.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 20, height: 300), options: .usesLineFragmentOrigin, context: nil)
            r.size.width = UIScreen.main.bounds.size.width - 20
            r.size.height = r.size.height + 20
            r.origin.x = 10
            r.origin.y = (UIScreen.main.bounds.size.height - r.size.height)/2
            label.attributedText = att
            label.frame = r
            label.textAlignment = .center
            let imagev = UIImageView.init(frame: CGRectMake((kWIDTH - 56)/2.0, CGRectGetMinY(label.frame) - 60, 56, 56))
            imagev.contentMode = .scaleAspectFit
            imagev.image = UIImage(named: "important")
            view.addSubview(imagev)
        }
        else{
            label.text = NSLocalizedString("RDWifiServer not running!", comment: "")
        }
    }
    
    // MARK: - GCDWebUploaderDelegate
    func webUploader(_ uploader: GCDWebUploader!, didCreateDirectoryAtPath path: String!) {
        print("创建文件夹成功")
        
        if ((path as! NSString).range(of: "undefined").location != NSNotFound) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    func webUploader(_ uploader: GCDWebUploader!, didFailToCreateDirectoryAtPath path: String!, error: Error!) {
        print("创建文件夹失败")
    }
    func webUploader(_ uploader: GCDWebUploader!, didDeleteFileAtPath path: String!) {
        print("删除文件成功")
        if ((path as! NSString).pathExtension == "kan" || (path as! NSString).pathExtension == "kanb"){
            
            let str = (path! as NSString).components(separatedBy: "Documents/Documents").last
            let key = HelpClass.getMD5(withContent: str!)
            let ps_key = key + "_PS"
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: ps_key)
        }
    }
    
    
    
    func webUploader(_ uploader: GCDWebUploader!, didUploadFileAtPath path: String!) {
        print("文件上传成功")
    }
    func webUploader(_ uploader: GCDWebUploader!, didFailToUploadFileAtPath path: String!, error: Error!) {
        print("文件上传失败")
    }
    func webUploaderDidReceiveUnauthorizedAccess(_ uploader: GCDWebUploader!) {
        print("无权限访问")
    }
    func webUploaderDidReceiveForbiddenAccess(_ uploader: GCDWebUploader!) {
        print("禁止访问")
    }
    func webUploaderDidReceiveNotAcceptable(_ uploader: GCDWebUploader!) {
        print("不被接受")
    }
    func webUploaderDidReceiveRequestTimeout(_ uploader: GCDWebUploader!) {
        print("请求超时")
    }
    func webUploaderDidReceiveBadRequest(_ uploader: GCDWebUploader!) {
        print("错误的请求")
    }
    func webUploaderDidReceiveNotFound(_ uploader: GCDWebUploader!) {
        print("找不到")
    }
    func webUploaderDidReceiveInternalServerError(_ uploader: GCDWebUploader!) {
        print("内部服务器错误")
    }
    func webUploaderDidReceiveServiceUnavailable(_ uploader: GCDWebUploader!) {
        print("服务不可用")
    }
    func webUploaderDidReceiveRequestURITooLong(_ uploader: GCDWebUploader!) {
        print("请求的URI太长")
    }
    func webUploaderDidReceiveRequestURITooLong(_ uploader: GCDWebUploader!, filePath: String!) {
        print("请求的URI太长")
    }
    func webUploaderDidReceiveUnsupportedMediaType(_ uploader: GCDWebUploader!) {
        print("不支持的媒体类型")
    }
    func webUploaderDidReceiveRequestEntityTooLarge(_ uploader: GCDWebUploader!) {
        print("请求的实体太大")
    }
    func webUploaderDidReceiveRequestPayloadTooLarge(_ uploader: GCDWebUploader!) {
        print("请求的负载太大")
    }
    func webUploaderDidReceivePreconditionFailed(_ uploader: GCDWebUploader!) {
        print("前提条件失败")
    }
    func webUploaderDidReceiveUnprocessableEntity(_ uploader: GCDWebUploader!) {
        print("不可处理的实体")
    }
    func webUploaderDidReceiveLocked(_ uploader: GCDWebUploader!) {
        print("锁定")
    }
    func webUploaderDidReceiveFailedDependency(_ uploader: GCDWebUploader!) {
        print("依赖失败")
    }
    func webUploaderDidReceiveUpgradeRequired(_ uploader: GCDWebUploader!) {
        print("需要升级")
    }
    func webUploaderDidReceiveMethodNotAllowed(_ uploader: GCDWebUploader!) {
        print("不允许的方法")
    }
    func webUploaderDidReceiveNotImplemented(_ uploader: GCDWebUploader!) {
        print("未实现")
    }
    func webUploaderDidReceiveInsufficientStorage(_ uploader: GCDWebUploader!) {
        print("存储不足")
    }
    func webUploaderDidReceiveLoopDetected(_ uploader: GCDWebUploader!) {
        print("检测到循环")
    }
    func webUploaderDidReceiveBandwidthLimitExceeded(_ uploader: GCDWebUploader!) {
        print("带宽限制超过")
    }
    func webUploaderDidReceiveNotExtended(_ uploader: GCDWebUploader!) {
        print("未扩展")
    }
    func webUploaderDidReceiveNetworkAuthenticationRequired(_ uploader: GCDWebUploader!) {
        print("需要网络认证")
    }
    func webUploaderDidReceiveNetworkConnectionLost(_ uploader: GCDWebUploader!) {
        print("网络连接丢失")
    }
    func webUploaderDidReceiveNetworkReadTimeout(_ uploader: GCDWebUploader!) {
        print("网络读取超时")
    }
    func webUploaderDidReceiveNetworkWriteTimeout(_ uploader: GCDWebUploader!) {
        print("网络写入超时")
    }
    func webUploaderDidReceiveNetworkSSLHandshakeFailed(_ uploader: GCDWebUploader!) {
        print("网络SSL握手失败")
    }
    func webUploaderDidReceiveNetworkConnectionRefused(_ uploader: GCDWebUploader!) {
        print("网络连接被拒绝")
    }
    func webUploaderDidReceiveNetworkHostNotFound(_ uploader: GCDWebUploader!) {
        print("网络主机未找到")
    }
    func webUploaderDidReceiveNetworkCannotConnectToHost(_ uploader: GCDWebUploader!) {
        print("网络无法连接到主机")
    }
    func webUploaderDidReceiveNetworkDNSLookupFailed(_ uploader: GCDWebUploader!) {
        print("网络DNS查找失败")
    }
    func webUploaderDidReceiveNetworkConnectionReset(_ uploader: GCDWebUploader!) {
        print("网络连接重置")
    }
    func webUploaderDidReceiveNetworkSoftwareCausedConnectionAbort(_ uploader: GCDWebUploader!) {
        print("网络软件导致连接中止")
    }
    func webUploaderDidReceiveNetworkConnectionAborted(_ uploader: GCDWebUploader!) {
        print("网络连接中止")
    }
    func webUploaderDidReceiveNetworkWriteToClosedConnection(_ uploader: GCDWebUploader!) {
        print("网络写入到关闭的连接")
    }
    func webUploaderDidReceiveNetworkAddressNotAvailable(_ uploader: GCDWebUploader!) {
        print("网络地址不可用")
    }
    func webUploaderDidReceiveNetworkReadFromClosedConnection(_ uploader: GCDWebUploader!) {
        print("网络从关闭的连接读取")
    }
    func webUploaderDidReceiveNetworkResourceBusy(_ uploader: GCDWebUploader!) {
        print("网络资源繁忙")
    }
    func webUploaderDidReceiveNetworkOperationInProgress(_ uploader: GCDWebUploader!) {
        print("网络操作正在进行")
    }
    func webUploaderDidReceiveNetworkOutOfMemory(_ uploader: GCDWebUploader!) {
        print("网络内存不足")
    }
    func webUploaderDidReceiveNetworkNoRouteToHost(_ uploader: GCDWebUploader!) {
        print("网络没有路由到主机")
    }
    func webUploaderDidReceiveNetworkTimedOut(_ uploader: GCDWebUploader!) {
        print("网络超时")
    }
    func webUploaderDidReceiveNetworkNetworkDown(_ uploader: GCDWebUploader!) {
        print("网络不可用")
    }
    func webUploaderDidReceiveNetworkNetworkReset(_ uploader: GCDWebUploader!) {
        print("网络重置")
    }
    func webUploaderDidReceiveNetworkNetworkUnreachable(_ uploader: GCDWebUploader!) {
        print("网络不可达")
    }
    func webUploaderDidReceiveNetworkHostUnreachable(_ uploader: GCDWebUploader!) {
        print("主机不可达")
    }
    func webUploaderDidReceiveNetworkHostDown(_ uploader: GCDWebUploader!) {
        print("主机不可用")
    }
    func webUploaderDidReceiveNetworkNotConnected(_ uploader: GCDWebUploader!) {
        print("未连接")
    }
    func webUploaderDidReceiveNetworkPartialReply(_ uploader: GCDWebUploader!) {
        print("部分回复")
    }
    func webUploaderDidReceiveNetworkNetworkUnavailable(_ uploader: GCDWebUploader!) {
        print("网络不可用")
    }
    func webUploaderDidReceiveNetworkAborted(_ uploader: GCDWebUploader!) {
        print("中止")
    }
    func webUploaderDidReceiveNetworkCancelled(_ uploader: GCDWebUploader!) {
        print("已取消")
    }
    func webUploaderDidReceiveNetworkUnknownError(_ uploader: GCDWebUploader!) {
        print("未知错误")
    }
    func webUploaderDidReceiveNetworkUnknownError(_ uploader: GCDWebUploader!, filePath: String!) {
        print("未知错误")
    }
    func webUploaderDidReceiveNetworkUnknownError(_ uploader: GCDWebUploader!, filePath: String!, error: Error!) {
        print("未知错误")
    }
    func webUploaderDidReceiveNetworkUnknownError(_ uploader: GCDWebUploader!, filePath: String!, error: Error!, code: Int) {
        print("未知错误")
    }
    func webUploaderDidReceiveNetworkUnknownError(_ uploader: GCDWebUploader!, filePath: String!, error: Error!, code: Int, userInfo: [AnyHashable : Any]!){
        print("未知错误")
    }
        
        
        
        
    
    
    
    
    func enterSystemSets() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

