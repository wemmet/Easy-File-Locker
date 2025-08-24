//
//  ViewController.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/5.
//

import UIKit
import Photos

class ViewController: UIViewController,UIDocumentPickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    var _selectedFiles : [String] = []
    var _inputView : UIView!;
    var _inputpasswordContentView : UIView!
    var _enablePasswordProtection : UIButton!
    var _enablePasswordImageView : UIImageView!
    var _progressView : UIProgressView!
    var _progressLabel : UILabel!
    var _confirmButton : UIButton!
    var _cancelButton : UIButton!
    var _stopButton : UIButton!
    var fileNameField : UITextField!
    var passwordField : UITextField!
    var passwordField2 : UITextField!
    var fileTitleLabel : UILabel!
    var line : UILabel!
    var line1 : UILabel!
    var line2 : UILabel!
    var _editField : UITextField!
    var _moreView : UIView? = nil
    var _hNDF : HNdfObject! = nil
    var _filePaths : [String] = []
    var _password : String! = ""
    var _fileName : String! = ""
    var _isEncryptFinished : Bool = false
    var _isEncryptFaile : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .fromRGB(0x1a1a1c)
        self.navigationController?.isNavigationBarHidden = true
        //注册通知事件
        //NotificationCenter.default.addObserver(self, selector: #selector(encryptFinished), name: NSNotification.Name(rawValue: "encryptFinished"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(encryptUpdate), name: NSNotification.Name(rawValue: "encryptUpdate"), object: nil)
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: SafeAreaTopHeight)
        view.addSubview(titleView)
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("appName", comment: "")
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        //文字内容过多时，省略前面内容
        titleLabel.lineBreakMode = .byTruncatingHead
        titleLabel.frame = CGRect(x: 0, y: (SafeAreaTopHeight - 44), width: kWIDTH, height: 44)
        titleView.addSubview(titleLabel)
        let titleLine = UIView()
        titleLine.frame = CGRect(x: 0, y: CGRectGetHeight(titleView.frame) - CGFloat(1.0/UIScreen.main.scale), width: kWIDTH, height: CGFloat(1.0/UIScreen.main.scale))
        titleLine.backgroundColor = UIColor.fromRGB(0x2d2d2d)
        titleView.addSubview(titleLine)
        
        let infoContent = UITextView()
        infoContent.text = NSLocalizedString("home_TipContent", comment: "")
        let tipHeight = HelpClass.height(for:infoContent.text, andWidth: Float(kWIDTH) - 20, fontSize: 17)
        infoContent.backgroundColor = UIColor.clear
        infoContent.isEditable = false
        infoContent.isSelectable = false  // 添加这行
        infoContent.isScrollEnabled = false
        infoContent.isUserInteractionEnabled = false
        infoContent.textColor = .fromRGB(0xa4a4a4)
        infoContent.font = .systemFont(ofSize: 16)
        infoContent.textAlignment = .left
        infoContent.frame = CGRect(x: 20, y: SafeAreaTopHeight + 40 /*CGRectGetMaxY(infoLabel.frame)*/, width: kWIDTH - 40, height: CGFloat(tipHeight) + 20)
        view.addSubview(infoContent)
        
        
        let items : [[String : Any]] =
        [
            ["name" : NSLocalizedString("Home_Item0", comment: ""),"id" : 1 ,"image" : "Home_Items1"],
            ["name" : NSLocalizedString("Home_Item3", comment: ""),"id" : 4 ,"image" : "Home_Items4"],
            ["name" : NSLocalizedString("Home_Item1", comment: ""),"id" : 2 ,"image" : "Home_Items3"],
            ["name" : NSLocalizedString("Home_Item2", comment: ""),"id" : 3 ,"image" : "Home_Items3"]
        ]
        var i = 0
        let itemHeight : CGFloat = 82
        for item in items {
            // 创建按钮
            let button = UIButton()
            button.frame = CGRect(x: 20, y: /*SafeAreaTopHeight + 40*/ CGRectGetMaxY(infoContent.frame) + 40 + (itemHeight + 20) * CGFloat(i), width: kWIDTH - 40, height: itemHeight)
            button.backgroundColor = .fromRGB(0x2f2e40).withAlphaComponent(0.6)
            button.layer.cornerRadius = 20
            button.layer.masksToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.fromRGB(0x2d2d2d).cgColor
            button.tag = (item["id"] as! Int)
            button.addTarget(self, action: #selector(itemBtnAction(_ : )), for: .touchUpInside)
            
            let imageView = UIImageView(image: UIImage(named: item["image"] as! String))
            imageView.frame = CGRectMake(6, (itemHeight - 44)/2.0, 44, 44)
            button.addSubview(imageView)
            let label = UILabel()
            label.text = (item["name"] as! String)
            label.textColor = .fromRGB(0xffffff)
            label.backgroundColor = .clear
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .left
            //文字内容过多时，省略前面内容
            label.lineBreakMode = .byTruncatingHead
            label.frame = CGRect(x: 55, y: (itemHeight - 44)/2.0, width: CGRectGetWidth(button.frame) - 60, height: 44)
            button.addSubview(label)
            
            
            self.view.addSubview(button)
            
            i += 1
        }
        
        // 假设 kGSG_CDWebUploaderFolder 是一个全局常量字符串
        let kWebUploaderFolder = HelpClass.getWebUploaderFolder()
        // 获取文件管理器
        let fileManager = FileManager.default

        // 检查上传文件夹是否存在，如果不存在则创建
        if !fileManager.fileExists(atPath: kWebUploaderFolder) {
            do {
                try fileManager.createDirectory(atPath: kWebUploaderFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建目录时出错: \(error)")
            }
        }

        // 构建解压路径和压缩文件路径
        let unzipPath = (kWebUploaderFolder as NSString).appendingPathComponent("GCDWebUploader.bundle")
        let zipPath = Bundle.main.path(forResource: "GCDWebUploader.zip", ofType: nil)

        // 检查压缩文件是否存在
        guard let zipPath = zipPath, fileManager.fileExists(atPath: zipPath) else {
            print("资源文件不存在")
            return
        }

        // 检查解压后的文件是否已经存在
        if fileManager.fileExists(atPath: unzipPath) {
            print("资源文件已存在")
            return
        }

        // 调用解压方法
        if HelpClass.openZip(zipPath, unzipto: kWebUploaderFolder) {
            print("解压WIFI资源文件到APP根目录文件夹下成功")
        }
    }
    
    // MARK: - 功能按钮点击事件
    @objc func itemBtnAction(_ sender : UIButton) {
        switch sender.tag {
        case 4://MARK: WIFI传输
            let Wifi = WifiSendFileViewController()
            Wifi.modalPresentationStyle = .overFullScreen
            self.present(Wifi, animated: true, completion: nil)
            print("视频文件加密")
        case 2://MARK: 视频文件加密
            print("视频文件加密")
            self.openpicker(false)
        case 3://MARK: 图片文件加密
            print("图片文件加密")
            self.openpicker(true)
        default://MARK: 播放加密文件
            print("播放加密文件")
            self._moreView = UIView()
            self._moreView!.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: kHEIGHT)
            self._moreView!.backgroundColor = .fromRGB(0x000000).withAlphaComponent(0.5)
            self._moreView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissMoreView)))
            
            // 添加弹窗视图
            let popupView = UIView()
            popupView.backgroundColor = .fromRGB(0x2f2e40)
            popupView.layer.cornerRadius = 12
            popupView.layer.masksToBounds = true
            popupView.frame = CGRect(x: 0, y: (kHEIGHT - 230 - SafeAreaBottomHeight), width: kWIDTH, height: 230 + SafeAreaBottomHeight)
            
            let titleLabel = UILabel()
            titleLabel.text = NSLocalizedString("moreplay.title", comment: "")
            titleLabel.textColor = .fromRGB(0xcccccc)
            titleLabel.textAlignment = .center
            titleLabel.frame = CGRect(x: 0, y: 0, width: popupView.frame.width, height: 50)
            popupView.addSubview(titleLabel)
            
            // 创建按钮
            let buttonHeight: CGFloat = 50
            let buttonWidth = popupView.frame.width
            
            let line0 = UIView()
            line0.backgroundColor = .fromRGB(0x1a1a1c)
            line0.frame = CGRect(x: 0, y: CGRectGetMaxY(titleLabel.frame) + 9, width: buttonWidth, height: 1.0/UIScreen.main.scale)
            popupView.addSubview(line0)
            
            let morePlayInFilesButton = UIButton(type: .system)
            morePlayInFilesButton.frame = CGRect(x: 0, y: CGRectGetMaxY(titleLabel.frame) + 10, width: buttonWidth, height: buttonHeight)
            morePlayInFilesButton.setTitle( NSLocalizedString("moreplay.Files", comment: ""), for: .normal)
            morePlayInFilesButton.setTitleColor(.white, for: .normal)
            morePlayInFilesButton.addTarget(self, action: #selector(self.morePlayInFilesButtonTapped), for: .touchUpInside)
            
            let morePlayInSandboxButton = UIButton(type: .system)
            morePlayInSandboxButton.frame = CGRect(x: 0, y: morePlayInFilesButton.frame.maxY + 10, width: buttonWidth, height: buttonHeight)
            morePlayInSandboxButton.setTitle( NSLocalizedString("moreplay.Sandbox", comment: ""), for: .normal)
            morePlayInSandboxButton.setTitleColor(.white, for: .normal)
            morePlayInSandboxButton.addTarget(self, action: #selector(self.morePlayInSandboxButtonTapped), for: .touchUpInside)
            
            let cancelButton = UIButton(type: .system)
            cancelButton.frame = CGRect(x: 0, y: morePlayInSandboxButton.frame.maxY + 10, width: buttonWidth, height: buttonHeight)
            cancelButton.setTitle( NSLocalizedString("moreplay.Cancel", comment: ""), for: .normal)
            cancelButton.setTitleColor(.white, for: .normal)
            cancelButton.addTarget(self, action: #selector(self.dismissMoreView), for: .touchUpInside)
            
            // 添加分割线
            let line1 = UIView()
            line1.backgroundColor = .fromRGB(0x1a1a1c)
            line1.frame = CGRect(x: 0, y: morePlayInFilesButton.frame.maxY, width: buttonWidth, height: 1.0/UIScreen.main.scale)
            
            let line2 = UIView()
            line2.backgroundColor = .fromRGB(0x1a1a1c)
            line2.frame = CGRect(x: 0, y: morePlayInSandboxButton.frame.maxY, width: buttonWidth, height: 1.0/UIScreen.main.scale)
            
            // 将按钮和分割线添加到弹窗视图
            popupView.addSubview(morePlayInFilesButton)
            popupView.addSubview(line1)
            popupView.addSubview(morePlayInSandboxButton)
            popupView.addSubview(line2)
            popupView.addSubview(cancelButton)
            
            self._moreView!.addSubview(popupView)
            self.view.addSubview(self._moreView!)
        }
    }
    //MARK: ======
    //播放手机中的文件
    @objc private func morePlayInFilesButtonTapped() {
        dismissMoreView(gesture: nil)
        self.showDocumentPicker()
        
    }
    //播放沙盒文件
    @objc private func morePlayInSandboxButtonTapped() {
        dismissMoreView(gesture: nil)
        self.showSandboxPicker()
    }

    @objc private func dismissMoreView(gesture: UITapGestureRecognizer? = nil) {
        self._moreView!.removeFromSuperview()
    }
    //MARK: =====
    
    
    @objc func showSandboxPicker(){
        //打开文件列表
        let fileListVC = FileListViewController()
        fileListVC.modalPresentationStyle = .overFullScreen
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath : URL = documentsDirectory
        fileListVC._filePath = filePath.path
        self.present(fileListVC, animated: true, completion: nil)
        //self.navigationController?.pushViewController(fileListVC, animated: true)
    }
    @objc func openpicker(_ isImage : Bool){
        let pickerVC = PickerViewController()
        if isImage {
            pickerVC.selectedAssetsHandler = { assets in
                // 处理选中的图片资源
                if assets.count == 0 {
                    return
                }else{
                    SVProgressHUD.show(withStatus: NSLocalizedString("图片处理中", comment: ""))
                }
                var index : Int = 0
                var imagePaths : [String] = []
                for asset in assets {
                    // 获取完整尺寸的图片
                    let options : PHImageRequestOptions = PHImageRequestOptions()
                    options.deliveryMode = .highQualityFormat
                    options.isSynchronous = false
                    options.isNetworkAccessAllowed = true
                    PHImageManager.default().requestImage(
                        for: asset,
                        targetSize: PHImageManagerMaximumSize,
                        contentMode: .aspectFit,
                        options: options
                    ) { image, info in
                        if let image = image {
                            index += 1
                            //将获取到的图片保存到沙盒
                            let fileManager : FileManager = FileManager.default
                            let tempDirectory = fileManager.temporaryDirectory
                            //let documentsDirectory : URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let imagePath : URL = tempDirectory.appendingPathComponent("image_\(index).jpg")
                            do {
                                try image.pngData()?.write(to: imagePath)
                                imagePaths.append(imagePath.path)
                            } catch {
                                print("保存图片失败: \(error)")
                            }
                            if index == assets.count {
                                SVProgressHUD .dismiss()
                                self.showAlertView(imagePaths)
                            }
                        }
                    }
                }
            }

        }
        else{
            pickerVC._isVideo = true
            pickerVC.selectedAssetsHandler = { assets in
                if assets.count == 0 {
                    return
                }else{
                    SVProgressHUD.show(withStatus: NSLocalizedString("视频处理中", comment: ""))
                }
                var index : Int = 0
                var imagePaths : [String] = []
                for asset in assets {
                    // 创建视频导出选项
                    let options = PHVideoRequestOptions()
                    options.version = .original
                    options.deliveryMode = .highQualityFormat
                    options.isNetworkAccessAllowed = true
                    
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
                        guard let avAsset = avAsset else { return }
                        
                        // 获取视频文件URL
                        if let urlAsset = avAsset as? AVURLAsset {
                            index += 1
                            // 将视频复制到沙盒目录
                            let fileManager : FileManager = FileManager.default
                            let tempDirectory = fileManager.temporaryDirectory
                            //let documentsDirectory : URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let videoPath : URL = tempDirectory.appendingPathComponent("video_\(index).mp4")
                            
                            do {
                                try fileManager.copyItem(at: urlAsset.url, to: videoPath)
                                imagePaths.append(videoPath.path)
                                
                                if index == assets.count {
                                    DispatchQueue.main.async {
                                        SVProgressHUD .dismiss()
                                        self.showAlertView(imagePaths)
                                    }
                                }
                            } catch {
                                print("保存视频失败: \(error)")
                            }
                        }
                    }
                }
            }
        }
        pickerVC.modalPresentationStyle = .overFullScreen
        present(pickerVC, animated: true)
    }
    @objc func createGemFile(){
        //创建一个gem文件
        _isEncryptFaile = false
        _isEncryptFinished = false
        var code : DWORD = 0
        if(_hNDF != nil){
//            NDF_CloseWriteObject(_hNDF)
//            for imagePath in _filePaths {
//               try? FileManager.default.removeItem(atPath: imagePath)
//            }
            _hNDF = nil
        }
        _hNDF =  NDF_CreateWriteObject()
        if _enablePasswordProtection.isSelected {
            var passwordData: [UInt8] = Array(_password.utf8)
            passwordData.withUnsafeMutableBufferPointer { bufferPointer in
                let rawPointer = UnsafeMutableRawPointer(bufferPointer.baseAddress!)
                code = NDF_SetPassword(_hNDF, rawPointer.assumingMemoryBound(to: UInt8.self), Int32(bufferPointer.count))
                if code != 0 {
                    print("设置密码失败:",code)
                    DispatchQueue.main.sync {
                        UIWindow.showTips(String(format: "%@:%d",[NSLocalizedString("设置密码失败", comment: ""),code]))
                    }
                }
            }
        }
        //创建根目录
        let hDir : HNdfDirectory = NDF_CreateRootDirectory(_hNDF, 0, 1)
        for imagePath in _filePaths {
            //添加文件
            //获取imagePath 的最后一级目录（文件名）
            let imagePathUrl : URL = URL(fileURLWithPath: imagePath)
            let name : String = imagePathUrl.lastPathComponent
            let szPath : String = imagePath;
            let szName : String = name
            //code = NDF_AddFile(_hNDF,hDir,szName,szPath,1,0,1);
            
            let thumb = HelpClass.getThumbImage(withPath: imagePath)
            let thumbnailSize = CGSize(width: 168, height: 168 * thumb.size.height/thumb.size.width) // 设置缩略图大小
            UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 1.0)
            thumb.draw(in: CGRect(origin: .zero, size: thumbnailSize))
            if let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext(),
               let thumbnailData = thumbnailImage.jpegData(compressionQuality: 1.0) {
                UIGraphicsEndImageContext()
                thumbnailData.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: thumbnailData.count)
                    buffer.initialize(from: bytes.bindMemory(to: UInt8.self).baseAddress!, count: thumbnailData.count)
                    
                    code = NDF_AddFile2(_hNDF, hDir, szName, szPath, 1, 0, 1,
                                        buffer,
                                        Int32(thumbnailData.count))
                    
                    buffer.deallocate()
                }
            } else {
                UIGraphicsEndImageContext()
                code = NDF_AddFile2(_hNDF, hDir, szName, szPath, 1, 0, 1, nil, 0)
            }
            
            if code != 0 {
                print("添加文件失败:",code)
                UIWindow.showTips(String(format: "%@:%d",[NSLocalizedString("添加文件失败", comment: ""),code]))
            }
        }
        
        //设置版本号
        code = NDF_SetVersion(_hNDF, "1.0.0")
        
        let itemName : String = _fileName + ".gfx"
        //把 fileName 文件保存到沙盒目录下
        let fileManager = FileManager.default
        //let tempDirectory = fileManager.temporaryDirectory
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath : URL = documentsDirectory.appendingPathComponent(itemName)
        var filePathData: [UInt8] = Array(filePath.path.utf8)
        filePathData.withUnsafeMutableBufferPointer { bufferPointer in
            let rawPointer = UnsafeMutableRawPointer(bufferPointer.baseAddress!)
            //开始制作
            let progressCallback: CB_NDFProgress = { progress, _ in
                // Convert progress from 0-1 to 0-100%
                let percentage = Int(progress)
                DispatchQueue.main.async {
                    print("加密进度：\(percentage)%")
                    UserDefaults.standard.setValue(percentage, forKey: "Encrypting_percentage")
                    UserDefaults.standard.synchronize()
                    if(percentage >= 100){
                        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "encryptFinished"), object: nil)
                    }
                    else{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "encryptUpdate"), object: nil)
                    }
                }
                return 0 // Return 0 to continue, non-zero to cancel
            }
            let outputPath = rawPointer.assumingMemoryBound(to: UInt8.self)
            code = NDF_BuildFile(_hNDF, outputPath , progressCallback, nil)
            print("制作文件-NDF_BuildFile:",code)
            if code != 0 {
                print("制作文件失败:",code)
                _isEncryptFaile = true
                //UIWindow.showTips(String(format: "制作文件失败:%d",[code]))
                //停止制作
                
                if(_inputView != nil){
                    if Thread.isMainThread {
                        _inputView.removeFromSuperview()
                    }
                    else {
                        DispatchQueue.main.async {
                            self._inputView.removeFromSuperview()
                        }
                    }
                }
                //延迟执行
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    for imagePath in self._filePaths {
                       try? FileManager.default.removeItem(atPath: imagePath)
                    }
                    try? FileManager.default.removeItem(atPath: filePath.path)
                }
                
                return
            }
            self.encryptFinished()
        }

    }
    @objc func encryptUpdate(){
        if(_isEncryptFaile == true){
            return
        }
        let percentage = UserDefaults.standard.integer(forKey: "Encrypting_percentage")
        if(self._inputView != nil){
            self._progressView.setProgress(Float(percentage) / 100.0, animated: false)
            self._progressLabel.text = String(format: NSLocalizedString("%d%%", comment: ""), percentage)
        }
    }
    @objc func encryptFinished(){
        if(_isEncryptFinished != true){
            _isEncryptFinished = true
            //判断当前线程是否是主线程
            if Thread.isMainThread {
                if(_inputView != nil){
                    _inputView.removeFromSuperview()
                }
                self.encryptFileStop()
            } else {
                // 如果不在主线程，切换到主线程并执行UI更新操作
                DispatchQueue.main.async {
                    if(self._inputView != nil){
                        self._inputView.removeFromSuperview()
                    }
                    self.encryptFileStop()
                }
            }
        }
        
    }
    @objc func encryptFileStop(){
        //停止制作
        let code = NDF_StopBuild(_hNDF)
        if code != 0 {
            print("停止制作失败:",code)
            UIWindow.showTips(String(format: "%@" + ":%d",[NSLocalizedString("制作文件失败", comment: ""),code]))
        }
        NDF_CloseWriteObject(_hNDF)
        print("文件加密完成");
        for imagePath in _filePaths {
           try? FileManager.default.removeItem(atPath: imagePath)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SVProgressHUD .dismiss()
        }
        if(_isEncryptFinished){
            self.showSandboxPicker()
        }
        _filePaths .removeAll()
    }

    //MARK: 显示文档选择器的方法
    @objc func showDocumentPicker() {
        let documentTypes: [String] = ["com.gilisoft.gem","com.gilisoft.gfx","com.gilisoft.gcp","com.adobe.pdf", "public.jpeg", "public.png", "public.mpeg-4", "public.movie"]
        // 创建并显示文档选择器视图控制器
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        documentPicker.delegate = self  // 确保你已经遵循了 UIDocumentPickerDelegate 协议
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    // UIDocumentPickerDelegate 方法
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // 用户选择文件后的回调
        guard let firstUrl = urls.first else { return }
        print("选中的文件 URL: \(firstUrl)")
        // 获取持久访问权限
        if firstUrl.startAccessingSecurityScopedResource() {
            // 获取文件扩展名并转换为小写
            let fileExtension = firstUrl.pathExtension.lowercased()
            // 判断文件扩展名并进行相应处理
            if (fileExtension == "gem") || (fileExtension == "gfx") || (fileExtension == "gcp") {
                print("处理 .\(fileExtension) 文件")
                SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.show()
                self.selectedFile(firstUrl)
            }
            else if fileExtension == "mp4" || fileExtension == "mov" {
                // 创建并展示视频播放器视图控制器
                let play = VideoPlayerViewController()
                play._isVideo = true
                play._playerPath = firstUrl.path
                self.navigationController?.pushViewController(play, animated: true)
            }
            else if fileExtension == "png" || fileExtension == "jpg" || fileExtension == "jpeg" {
                // 创建并展示视频播放器视图控制器
                let play = ImagePrewViewController()
                play._imageUrls = [firstUrl]
                play._isPDF = false;
                self.navigationController?.pushViewController(play, animated: true)
            }
            else if fileExtension == "pdf" {
                // 创建并展示视频播放器视图控制器
                HelpClass.openpdf(withPath: firstUrl.path, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pageIndex: 0) {( rotation, count, image) in
                    let play = ImagePrewViewController()
                    play._tempPath = firstUrl.path
                    play._sourceImage = image
                    play._isPDF = true;
                    play._selectIndex = 0
                    play._pdfCount = Int(count)
                    play._rotation = Int(rotation)
                    self.navigationController?.pushViewController(play, animated: true)
                }
            }
            else {
                // TODO: 处理未知文件类型，当前为空实现
                // 例如：显示错误提示或执行默认逻辑
                print("未知文件类型")
                UIWindow .showTips("未知文件类型")
            }
        }
        
        

            
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // 用户取消选择文件后的回调
        print("文件选择被取消")
    }
    
    func selectedFile(_ url: URL) {
        DispatchQueue.main.async {
            let array = url.absoluteString.components(separatedBy: "/")
            let fileName = array.last?.removingPercentEncoding ?? ""
            print("--->>>>\(fileName)")
            
            if !FileManager.default.fileExists(atPath: url.path) {
                return
            }
            
            let pathExtension = url.pathExtension.lowercased()
            if pathExtension == "gem" || pathExtension == "gcp" || pathExtension == "gfx" {
                HelpClass.shared().openGem(forPath: url.path ,supperVC: self)
            } else {
                let extensionStr = url.pathExtension.lowercased()
                if ["mp3", "mp4", "mov", "wav"].contains(extensionStr) {
                    SVProgressHUD.dismiss()
                    let playerVC = VideoPlayerViewController()
                    playerVC._isGemFile = false
                    playerVC._isHostAppRun = true
                    playerVC._isVideo = ["mp4", "mov"].contains(extensionStr)
                    playerVC._playerPath = url.path
                    self.navigationController?.pushViewController(playerVC, animated: true)
                } else if ["pdf", "gif", "png", "jpg", "tiff", "bmp"].contains(extensionStr) {
                    if extensionStr == "pdf" {
                        #if isDisableEx
                        let imageIV = GS_ImageViewController(nibName: "GS_ImageViewController", bundle: nil)
                        AppDelegate.sharedAppDelegate().openpdf(withPath: url.path, width: kWIDTH * UIScreen.main.scale, pageIndex: 0) { rotation, count, image in
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                imageIV.sourceImage = image
                                imageIV.gem_hobj = nil
                                imageIV.selectIndex = 0
                                imageIV.isPDF = true
                                imageIV.pdfCount = count
                                imageIV.tempPath = nil
                                imageIV.filePath = url.path
                                imageIV.isHostAppRun = true
                                self.navigationController?.pushViewController(imageIV, animated: true)
                            }
                        }
                        #endif
                    } else {
                        SVProgressHUD.dismiss()
                        let image = ImagePrewViewController()
                        if let data = try? Data(contentsOf: url) {
                            image._sourceImage = UIImage(data: data)
                        }
                        image._isHostAppRun = true
                        image._isPDF = extensionStr == "pdf"
                        self.navigationController?.pushViewController(image, animated: true)
                    }
                } else {
                    SVProgressHUD.dismiss()
                    let fileVC = GemFileDetailViewController()
                    fileVC._path = url.deletingLastPathComponent().path
                    fileVC.isGem = false
                    fileVC.isHostAppRun = true
                    self.navigationController?.pushViewController(fileVC, animated: true)
                }
            }
        }
    }
    
    // MARK: - Status bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - 隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }


    // MARK: - UIImagePickerControllerDelegate 方法
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingM0ediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        print("选中的图片: \(image ?? UIImage())")
    }
    // MARK: - UIImagePickerControllerDelegate 方法
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }


    func showAlertView(_ selectedFiles : [String]){
        
        _selectedFiles = selectedFiles
        
        // 创建自定义密码输入视图
        _inputView = UIView(frame: CGRect(x: 0, y: 0, width: kWIDTH, height: kHEIGHT))
        _inputView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        _inputView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(_ : ))))

        _inputpasswordContentView = UIView(frame: CGRect(x: (kWIDTH - 300)/2.0, y: (kHEIGHT - 340)/2 - 80, width: 300, height: 340))
        _inputpasswordContentView.backgroundColor = .fromRGB(0x2f2e40)
        _inputpasswordContentView.layer.cornerRadius = 10
        _inputView.addSubview(_inputpasswordContentView)
        _inputpasswordContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(_ : ))))

        
        _enablePasswordProtection = UIButton(frame: CGRect(x: 10, y: 20, width: CGRectGetWidth(_inputpasswordContentView.frame) - 20, height: 40))
        _enablePasswordProtection.backgroundColor = .clear
        _enablePasswordProtection.isSelected = true
        _enablePasswordProtection.addTarget(self, action: #selector(enablePasswordProtectionTapped(_:)), for: .touchUpInside)
        let enableLabel = UILabel(frame: CGRect(x: 40, y: 0, width: _enablePasswordProtection.frame.width - 50, height: CGRectGetHeight(_enablePasswordProtection.frame)))
        enableLabel.text = NSLocalizedString("enableLabel.title", comment: "")
        enableLabel.font = UIFont.systemFont(ofSize: 15)
        enableLabel.textColor = .white
        enableLabel.textAlignment = .left
        _enablePasswordProtection.addSubview(enableLabel)
        
        _enablePasswordImageView = UIImageView()
        _enablePasswordImageView.frame = CGRect(x: 0, y: (CGRectGetHeight(_enablePasswordProtection.frame) - 40)/2.0, width: 40, height: 40)
        _enablePasswordImageView.image = UIImage(named: "Unchecked_")
        _enablePasswordImageView.highlightedImage = UIImage(named: "Checked_")
        _enablePasswordImageView.contentMode = .scaleAspectFit
        _enablePasswordProtection.addSubview(_enablePasswordImageView)
        _enablePasswordImageView.isHighlighted = _enablePasswordProtection.isSelected
        _inputpasswordContentView.addSubview(_enablePasswordProtection)
        
        passwordField = UITextField(frame: CGRect(x: 30, y: CGRectGetMaxY(_enablePasswordProtection.frame), width: _inputpasswordContentView.frame.width - 60, height: 40))
        passwordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("inputView.passwordField", comment: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor.fromRGB(0xcccccc)])
        passwordField.textColor = .fromRGB(0xffffff)
        passwordField.layer.cornerRadius = 5
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        passwordField.leftViewMode = .never
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        passwordField.font = .systemFont(ofSize: 15)
        _inputpasswordContentView.addSubview(passwordField)
        line1 = UILabel(frame: CGRect(x: 20, y: CGRectGetMaxY(passwordField.frame), width: _inputpasswordContentView.frame.width - 40, height: 1.0/UIScreen.main.scale))
        line1.backgroundColor = .fromRGB(0xcccccc)
        _inputpasswordContentView.addSubview(line1)
        
        passwordField2 = UITextField(frame: CGRect(x: 30, y: CGRectGetMaxY(line1.frame), width: _inputpasswordContentView.frame.width - 60, height: 40))
        passwordField2.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("inputView.passwordField2", comment: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor.fromRGB(0xcccccc)])
        passwordField2.textColor = .fromRGB(0xffffff)
        passwordField2.layer.cornerRadius = 5
        passwordField2.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        passwordField2.leftViewMode = .never
        passwordField2.font = .systemFont(ofSize: 15)
        passwordField2.isSecureTextEntry = true
        passwordField2.delegate = self
        _inputpasswordContentView.addSubview(passwordField2)
        line2 = UILabel(frame: CGRect(x: 20, y: CGRectGetMaxY(passwordField2.frame), width: _inputpasswordContentView.frame.width - 40, height: 1.0/UIScreen.main.scale))
        line2.backgroundColor = .fromRGB(0xcccccc)
        _inputpasswordContentView.addSubview(line2)
        
        fileTitleLabel = UILabel()
        fileTitleLabel.frame = CGRect(x: 20, y: CGRectGetMaxY(passwordField2.frame) + 20, width: _inputpasswordContentView.frame.width - 40, height: 30)
        fileTitleLabel.text = NSLocalizedString("inputView.title", comment: "")
        fileTitleLabel.textColor = .white
        fileTitleLabel.textAlignment = .left
        fileTitleLabel.font = .systemFont(ofSize: 15)
        _inputpasswordContentView.addSubview(fileTitleLabel)
        

        fileNameField = UITextField()
        fileNameField.frame = CGRect(x: 30, y: CGRectGetMaxY(fileTitleLabel.frame), width: _inputpasswordContentView.frame.width - 60, height: 40)
        fileNameField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("inputView.fileNameField", comment: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor.fromRGB(0xcccccc)])
        fileNameField.textColor = .fromRGB(0xffffff)
        fileNameField.layer.cornerRadius = 5
        fileNameField.font = .systemFont(ofSize: 15)
        fileNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        fileNameField.leftViewMode = .never
        fileNameField.delegate = self
        _inputpasswordContentView.addSubview(fileNameField)
        //按当前时间命名文件
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        let currentDateString = dateFormatter.string(from: Date())
        fileNameField.text = currentDateString
        
        line = UILabel()
        line.frame = CGRect(x: 20, y: CGRectGetMaxY(fileNameField.frame), width: _inputpasswordContentView.frame.width - 40, height: 1.0/UIScreen.main.scale)
        line.backgroundColor = .fromRGB(0xcccccc)
        _inputpasswordContentView.addSubview(line)
        
        //这里加一个加密进度显示
        _progressView = UIProgressView()
        _progressView.frame = CGRect(x: 20, y: CGRectGetMaxY(line.frame) + 10 + 10 + 9, width: _inputpasswordContentView.frame.width - 20 - 44, height: 2)
        _progressView.progress = 0.0
        _progressView.progressViewStyle = .bar
        _progressView.progressTintColor = .fromRGB(0x5c69de)
        _progressView.trackTintColor = .fromRGB(0xcccccc)
        _progressView.isHidden = true
        _inputpasswordContentView.addSubview(_progressView)

        _progressLabel = UILabel()
        _progressLabel.frame = CGRect(x: CGRectGetMaxX(_progressView.frame), y: CGRectGetMaxY(line.frame) + 10 + 10, width: 44, height: 20)
        _progressLabel.text = "0%"
        _progressLabel.textColor = .fromRGB(0xffffff)
        _progressLabel.textAlignment = .center
        _progressLabel.font = .systemFont(ofSize: 12)
        _progressLabel.isHidden = true
        _inputpasswordContentView.addSubview(_progressLabel)
        
        _cancelButton = UIButton()
        _cancelButton.frame = CGRect(x: (_inputpasswordContentView.frame.width - 120)/2.0, y: CGRectGetMaxY(line.frame) + 20 + 24, width: 120, height: 40)
        _cancelButton.setTitle(NSLocalizedString("inputView.okBtn", comment: ""), for: .normal)
        _cancelButton.setTitleColor(.fromRGB(0xffffff), for: .normal)
        _cancelButton.layer.cornerRadius = 5
        _cancelButton.layer.masksToBounds = true
        _cancelButton.titleLabel?.font = .systemFont(ofSize: 15)
        _cancelButton.backgroundColor = HelpClass.color(withColors: [UIColor.fromRGB(0x5c69de).cgColor,UIColor.fromRGB(0xde5c93).cgColor], bounds: _confirmButton.bounds)
        _cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        _inputpasswordContentView.addSubview(_cancelButton)
        _cancelButton.isHidden = false
        
        _confirmButton = UIButton()
        _confirmButton.frame = CGRect(x: (_inputpasswordContentView.frame.width - 120)/2.0, y: CGRectGetMaxY(line.frame) + 20 + 24, width: 120, height: 40)
        _confirmButton.setTitle(NSLocalizedString("inputView.okBtn", comment: ""), for: .normal)
        _confirmButton.setTitleColor(.fromRGB(0xffffff), for: .normal)
        _confirmButton.layer.cornerRadius = 5
        _confirmButton.layer.masksToBounds = true
        _confirmButton.titleLabel?.font = .systemFont(ofSize: 15)
        _confirmButton.backgroundColor = HelpClass.color(withColors: [UIColor.fromRGB(0x5c69de).cgColor,UIColor.fromRGB(0xde5c93).cgColor], bounds: _confirmButton.bounds)
        _confirmButton.addTarget(self, action: #selector(confirmButtonTapped(_:)), for: .touchUpInside)
        _inputpasswordContentView.addSubview(_confirmButton)
        _confirmButton.isHidden = false
        
        _stopButton = UIButton(frame: CGRect(x: (_inputpasswordContentView.frame.width - 120)/2.0, y: CGRectGetMaxY(line.frame) + 20 + 24, width: 120, height: 40))
        _stopButton.setTitle(NSLocalizedString("inputView.CancelBtn", comment: ""), for: .normal)
        _stopButton.setTitleColor(.fromRGB(0xffffff), for: .normal)
        _stopButton.layer.cornerRadius = 5
        _stopButton.layer.masksToBounds = true
        _stopButton.titleLabel?.font = .systemFont(ofSize: 15)
        _stopButton.backgroundColor = HelpClass.color(withColors: [UIColor.fromRGB(0x5c69de).cgColor,UIColor.fromRGB(0xde5c93).cgColor], bounds: _confirmButton.bounds)
        _stopButton.addTarget(self, action: #selector(stopButtonTapped(_:)), for: .touchUpInside)
        _inputpasswordContentView.addSubview(_stopButton)
        _stopButton.isHidden = true
        
        self.view.addSubview(_inputView)
    }
    
    @objc func enablePasswordProtectionTapped(_ sender: UIButton) {
        _enablePasswordProtection.isSelected = !_enablePasswordProtection.isSelected;
        _enablePasswordImageView.isHighlighted = _enablePasswordProtection.isSelected
        if(_enablePasswordProtection.isSelected){
            passwordField.isHidden = false
            passwordField2.isHidden = false
            line1.isHidden = false
            line2.isHidden = false
            _inputpasswordContentView.frame = CGRect(x: (kWIDTH - 300)/2.0, y: (kHEIGHT - 340)/2 - 80, width: 300, height: 340)
            fileTitleLabel.frame = CGRect(x: 20, y: CGRectGetMaxY(passwordField2.frame) + 20, width: _inputpasswordContentView.frame.width - 40, height: 30)
            fileNameField.frame = CGRect(x: 30, y: CGRectGetMaxY(fileTitleLabel.frame), width: _inputpasswordContentView.frame.width - 60, height: 40)
            line.frame = CGRect(x: 20, y: CGRectGetMaxY(fileNameField.frame), width: _inputpasswordContentView.frame.width - 40, height: 1.0/UIScreen.main.scale)
            _progressView.frame = CGRect(x: 20, y: CGRectGetMaxY(line.frame) + 10 + 10 + 9, width: _inputpasswordContentView.frame.width - 20 - 44, height: 2)
            _progressLabel.frame = CGRect(x: CGRectGetMaxX(_progressView.frame), y: CGRectGetMaxY(line.frame) + 10 + 10, width: 44, height: 20)
            _confirmButton.frame = CGRect(x: (_inputpasswordContentView.frame.width - 120)/2.0, y: CGRectGetMaxY(line.frame) + 20 + 24, width: 120, height: 40)
            _stopButton.frame = _confirmButton.frame
        }
        else{
            passwordField.isHidden = true
            passwordField2.isHidden = true
            line1.isHidden = true
            line2.isHidden = true
            _inputpasswordContentView.frame = CGRect(x: (kWIDTH - 300)/2.0, y: (kHEIGHT - 260)/2 - 80, width: 300, height: 260)
            fileTitleLabel.frame = CGRect(x: 20, y: CGRectGetMinY(passwordField.frame) + 20, width: _inputpasswordContentView.frame.width - 40, height: 30)
            fileNameField.frame = CGRect(x: 30, y: CGRectGetMaxY(fileTitleLabel.frame), width: _inputpasswordContentView.frame.width - 60, height: 40)
            line.frame = CGRect(x: 20, y: CGRectGetMaxY(fileNameField.frame), width: _inputpasswordContentView.frame.width - 40, height: 1.0/UIScreen.main.scale)
            _progressView.frame = CGRect(x: 20, y: CGRectGetMaxY(line.frame) + 10 + 10 + 9, width: _inputpasswordContentView.frame.width - 20 - 44, height: 2)
            _progressLabel.frame = CGRect(x: CGRectGetMaxX(_progressView.frame), y: CGRectGetMaxY(line.frame) + 10 + 10, width: 44, height: 20)
            _confirmButton.frame = CGRect(x: (_inputpasswordContentView.frame.width - 120)/2.0, y: CGRectGetMaxY(line.frame) + 20 + 24, width: 120, height: 40)
            _stopButton.frame = _confirmButton.frame
        }
    }

    @objc func stopButtonTapped(_ sender : UIButton){
        _confirmButton.isHidden = false
        _cancelButton.isHidden = false
        _stopButton.isHidden = true
        passwordField.isEnabled = true
        passwordField2.isEnabled = true
        fileNameField.isEnabled = true
        _progressView.isHidden = true
        _progressLabel.isHidden = true
        _isEncryptFinished = false
        self.encryptFileStop()
        let itemName : String = fileNameField.text! + ".gfx"
        //把 fileName 文件保存到沙盒目录下
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        //let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath : URL = tempDirectory.appendingPathComponent(itemName)
        try? fileManager.removeItem(at: filePath)
        if(_inputView != nil){
            _inputView.removeFromSuperview()
        }
        
    }
    @objc func cancelButtonTapped(_ sender: UIButton) {
        if (_editField != nil) {
            _editField .resignFirstResponder()
        }
        _inputView.removeFromSuperview()
    }
    
    @objc func confirmButtonTapped(_ sender: UIButton) {
        if (_editField != nil) {
            _editField .resignFirstResponder()
        }
        let fileName = fileNameField.text ?? ""
        let password = passwordField.text ?? ""
        if _enablePasswordProtection.isSelected {
            if fileName.isEmpty {
                print("文件名不能为空")
                UIWindow.showTips(NSLocalizedString("showTips_1", comment: ""))
                return
            }
            
            if password.isEmpty {
                print("密码不能为空")
                UIWindow.showTips(NSLocalizedString("showTips_2", comment: ""))
                return
            }
            if fileName == "" {
                print("文件名不能为空")
                UIWindow.showTips(NSLocalizedString("showTips_1", comment: ""))
                return
            }
            if password == "" {
                print("密码不能为空")
                UIWindow.showTips(NSLocalizedString("showTips_2", comment: ""))
                return
            }
            if(passwordField.text != passwordField2.text){
                UIWindow.showTips(NSLocalizedString("showTips_3", comment: ""))
                return
            }
            _password = password
        }
        else{
            _password = ""
        }
        _fileName = fileName
        
        _confirmButton.isHidden = true
        _cancelButton.isHidden = true
        _stopButton.isHidden = false
        passwordField.isEnabled = false
        passwordField2.isEnabled = false
        fileNameField.isEnabled = false
        _progressView.isHidden = false
        _progressLabel.isHidden = false
        _isEncryptFinished = false
        _filePaths = self._selectedFiles
        let thread : Thread = Thread(target: self, selector: #selector(createGemFile), object: nil)
        thread.start()
    }
    @objc func tapGestureRecognizer(_ gesture : UITapGestureRecognizer) {
        if (_editField != nil){
            _editField.resignFirstResponder()
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        _editField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

