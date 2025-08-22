//
//  GemFileDetailViewController.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/5.
//

import Foundation
import UIKit

class FileCell: UITableViewCell {
    
    let fileNameLabel = UILabel()
    let fileDetailLabel = UILabel()
    let fileImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 配置文件名标签
        fileNameLabel.font = UIFont.systemFont(ofSize: 16)
        fileNameLabel.textColor = .fromRGB(0xffffff)
        fileNameLabel.frame = CGRect(x: 64, y: 20, width: kWIDTH - 54 - 64 - 10, height: 44)
        self.contentView.addSubview(fileNameLabel)
        
        fileDetailLabel.font = UIFont.systemFont(ofSize: 13)
        fileDetailLabel.textColor = .fromRGB(0xffffff)
        fileDetailLabel.frame = CGRect(x: kWIDTH - 54, y: 20, width: 54, height: 44)
        self.contentView.addSubview(fileDetailLabel)
        self.contentView.backgroundColor = UIColor.clear
        // 配置缩略图视图
        fileImageView.contentMode = .scaleAspectFill
        fileImageView.frame = CGRect(x: 10, y: 20, width: 44, height: 44)
        fileImageView.clipsToBounds = true
        fileImageView.layer.cornerRadius = 10
        fileImageView.layer.masksToBounds = true
        self.contentView.addSubview(fileImageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withFileName fileName: String, image: UIImage?) {
        fileNameLabel.text = fileName
        fileImageView.image = image
    }
}

class GemFileDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @objc var fileUrl : URL?
    @objc var _path : String?
    @objc var _temppath : String? = "\\public"
    @objc var isGem : NSNumber? = true
    @objc var isHostAppRun : NSNumber? = true
    @objc var isDisTouchFile : NSNumber? = false
    @objc var gemFiles : NSMutableArray? = NSMutableArray()
    @objc var gem_hobj : HNdfObject? = nil
    
    @objc var _fileList : [GemFileModel]? = []
    
    // 定义table view
    let tableView = UITableView(frame: .zero, style: .plain)
    
    // 示例数据，代表文件列表
    @objc var files : [GemFileInfo] = []
    // 返回按钮的点击事件处理函数
    @objc func backAction() {
        // 执行返回操作，比如popViewController
        if (self.navigationController != nil) && ((self.navigationController?.children.count)! > 1) {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        files = []
        
        
        self.view.backgroundColor = .fromRGB(0x1a1a1c)
        view.backgroundColor = .fromRGB(0x1a1a1c)
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: SafeAreaTopHeight)
        view.addSubview(titleView)
        // 创建一个返回按钮
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "Btn_Back"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: (SafeAreaTopHeight - 44), width: 44, height: 44)
        titleView.addSubview(backButton)

        let titleLabel = UILabel()
        if let path = _path {
            titleLabel.text = (path as NSString).lastPathComponent
        }
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        //文字内容过多时，省略前面内容
        titleLabel.lineBreakMode = .byTruncatingHead
        let titleLabelWidth = kWIDTH - (backButton.frame.width * 2)
        titleLabel.frame = CGRect(x: backButton.frame.maxX, y: (SafeAreaTopHeight - 44), width: titleLabelWidth, height: 44)
        titleView.addSubview(titleLabel)
        
        let titleLine = UIView()
        titleLine.frame = CGRect(x: 0, y: CGRectGetMaxY(titleLabel.frame) - CGFloat(1.0/UIScreen.main.scale), width: kWIDTH, height: CGFloat(1.0/UIScreen.main.scale))
        titleLine.backgroundColor = UIColor.fromRGB(0x2d2d2d)
        titleView.addSubview(titleLine)
        
        // 设置tableView
        tableView.frame = CGRectMake(0, SafeAreaTopHeight, kWIDTH, kHEIGHT - SafeAreaTopHeight)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = nil
        tableView.backgroundColor = self.view.backgroundColor
        // 注册自定义单元格类
        tableView.register(FileCell.self, forCellReuseIdentifier: "fileCell")
        self.view.addSubview(tableView)
    }
    
    //MARK: - UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gemFiles!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    //MARK: - UITableViewDataSource 方法
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! FileCell
        cell.selectionStyle = .none
        cell.selectedBackgroundView = nil
        cell.backgroundView = nil;
        cell.backgroundColor = self.view.backgroundColor
        let item = (gemFiles![indexPath.row] as! GemFileInfo)
        // 假设你有一个方法或属性来获取相应的文件名和图像
        let fileName = item.cFileName ?? ""
        let fileImage = item.fileIcon ?? UIImage()
        let url = NSURL(fileURLWithPath: _path!)
        let pathExtension = (url.pathExtension)!.lowercased()
        if ["gem", "gcp", "gfx"].contains(pathExtension) {
            cell.fileNameLabel.text = fileName as String
            cell.fileDetailLabel.text = HelpClass.string(forAllFileSize: item.nFileSize as! UInt64)
            let tempPath = item.tempPath as? String
            let tempurl = NSURL(fileURLWithPath: tempPath!)
            if tempurl.pathExtension!.isEmpty {
                cell.fileImageView.image = UIImage(named: "folder")
            } else {
                let nTempPath = item.tempPath!.utf8String
                let hFile = NDF_OpenFile(gem_hobj, nTempPath!)
                if hFile != nil {
                    var itemPhotoSize: Int64 = 0
                    var imageData = NSMutableData()
                    let blockSize = NDF_GetFileEncryptBlockSize(gem_hobj, hFile)
                    var readingSize: Int64 = 0
                    var fileData = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(blockSize + 1))
                    fileData.initialize(repeating: 0, count: Int(blockSize + 1))
                    
                    var word = NDF_ReadThumbFile(gem_hobj, hFile, nil, &itemPhotoSize)
                    if blockSize > 0 {
                        while true {
                            var stop = false
                            if itemPhotoSize > blockSize {
                                readingSize = Int64(blockSize)
                            } else {
                                readingSize = itemPhotoSize
                                stop = true
                            }
                            word = NDF_ReadThumbFile(gem_hobj, hFile, fileData, &readingSize)
                            if word == 0 {
                                imageData.append(fileData, length: Int(readingSize))
                            } else {
                                if readingSize > 0 {
                                    print("读取数据失败")
                                }
                                let noThumbImage = HelpClass.noThumbImage(Int32(item.nFileType!))
                                if let data = noThumbImage.pngData() {
                                    imageData.append(data)
                                }
                            }
                            itemPhotoSize -= Int64(blockSize)
                            if stop {
                                break
                            }
                        }
                    } else {
                        fileData.deallocate()
                        fileData = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(itemPhotoSize + 1))
                        fileData.initialize(repeating: 0, count: Int(itemPhotoSize + 1))
                        word = NDF_ReadThumbFile(gem_hobj, hFile, fileData, &itemPhotoSize)
                        if word == 0 {
                            imageData.append(fileData, length: Int(itemPhotoSize))
                        } else {
                            if itemPhotoSize > 0 {
                                print("读取数据失败")
                            }
                            let noThumbImage = HelpClass.noThumbImage(Int32(item.nFileType!))
                            if let data = noThumbImage.pngData() {
                                imageData.append(data)
                            }
                        }
                    }
                    fileData.deallocate()
                    NDF_CloseFile(gem_hobj, hFile)
                    cell.fileImageView.image = UIImage(data: imageData as Data)
                    item.thumbImage = cell.fileImageView.image
                } else {
                    print(" func :\(#function) line:\(#line) error:hFile 打开失败")
                    cell.fileImageView.image = HelpClass.noThumbImage(Int32(item.nFileType!))
                    item.thumbImage = cell.fileImageView.image
                }
            }
        } else {
            cell.fileNameLabel.text = (_fileList![indexPath.row]).path!.lastPathComponent
            if (_fileList![indexPath.row]).path!.pathExtension.lowercased() == "" {
                cell.fileDetailLabel.text = HelpClass.string(forAllFileSize: UInt64(HelpClass.folderSize(atPath: _fileList![indexPath.row].path! as String)))
                cell.fileImageView.image = UIImage(named: "folder")
            } else {
                if _fileList![indexPath.row].isGemFile! {
                    cell.fileDetailLabel.text = HelpClass.string(forAllFileSize: UInt64(HelpClass.folderSize(atPath: _fileList![indexPath.row].path! as String)))
                    cell.fileImageView.image = UIImage(named: "Gem")
                } else {
                    cell.fileDetailLabel.text = HelpClass.string(forAllFileSize: UInt64(HelpClass.folderSize(atPath: _fileList![indexPath.row].path! as String)))
                }
            }
            let pathExtension = _fileList![indexPath.row].path!.pathExtension.lowercased()
            if ["png", "jpg", "tiff", "bmp"].contains(pathExtension) {
                cell.fileImageView.image = UIImage(named: "tupianIcon")
            } else if pathExtension == "pdf" {
                cell.fileImageView.image = UIImage(named: "weizhiIcon")
            } else if ["mp3", "wav"].contains(pathExtension) {
                cell.fileImageView.image = UIImage(named: "yinyueIcon")
            } else if ["mp4", "mov"].contains(pathExtension) {
                cell.fileImageView.image = UIImage(named: "shipinIcon")
            }
        }
        //cell.configure(withFileName: fileName as String, image: fileImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("You selected cell #\(indexPath.row)!")
        print("isGem:\((isGem?.boolValue) == true)")
        
        if ((isGem?.boolValue) == true) {
            let cPath = _path!.cString(using: .utf8)!
            let fHandle = open(cPath, O_RDONLY, 0o666)
            if fHandle <= 0 {
                print("打开文件失败：\(fHandle)")
            } else {
                print("打开文件成功：\(fHandle)")
            }

            guard let gemFile = gemFiles![indexPath.row] as? GemFileInfo else { return }
            _temppath = gemFile.tempPath as? String ?? ""
            let nFileType = gemFile.nFileType as? Int ?? 0
            
            let playCfg = gemFile.playCfg
            let gcpCfg = gemFile.gcpCfg
            let user_param = gemFile.user_param
            let url = URL(fileURLWithPath: _temppath!)
            let pathExtension = (url.pathExtension as String).lowercased()
            if pathExtension.count > 0 {
                var szMD5PathCode = ""
                if let path = _path {
                    szMD5PathCode = HelpClass.getFileMD5Code(path)
                }
                if pathExtension == "site" || pathExtension == "zip" || pathExtension == "7z" || pathExtension == "rar" {
//                    
                    let paths = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true)
                    let folderName = pathExtension == "site" ? "site_zip" : "gem_zip"
                    let zipFolderPath = paths[0].appendingFormat("/\(folderName)/%@", szMD5PathCode)
                    
                    if !FileManager.default.fileExists(atPath: zipFolderPath) {
                        try? FileManager.default.createDirectory(atPath: zipFolderPath, withIntermediateDirectories: true, attributes: nil)
                    }
                    let zipPath = zipFolderPath.appendingFormat("/%lu.zip", _temppath.hashValue)
                    let unZipPath = paths[0].appendingFormat("/zip/%lu", _temppath.hashValue)

                    SVProgressHUD.show(withStatus: NSLocalizedString("File parsing in progress... Please wait.", comment: ""))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                        guard let self = self else { return }
                        if FileManager.default.fileExists(atPath: zipPath) {
                            HelpClass.openSite_Zip(zipPath, outputPath: unZipPath, temppath: _temppath!, vc: self ,isInGem: true)
                        } else {
                            HelpClass.getFileData(_temppath!, gem_hobj: gem_hobj!, output: zipPath)
                            if !FileManager.default.fileExists(atPath: zipPath) {
                                print("导出文件失败-->path：\(self._temppath ?? "")")
                                return
                            }
                            HelpClass.openSite_Zip(zipPath, outputPath: unZipPath, temppath: _temppath!, vc: self ,isInGem: true)
                        }
                    }
//                    
                } else if (nFileType == NDF_FILE_PDF.rawValue) || (nFileType == NDF_FILE_NONE.rawValue) {
//                    #if isDisableEx
                    HelpClass.openPdf(gem_hobj!, temppath: _temppath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pdfImageIndex: 0) { [weak self] (rotation, count, image) in
                        guard let self = self else { return }
                        let imageVC = ImagePrewViewController()
                        imageVC._sourceImage = image
                        imageVC._tempPath = self._temppath!
                        imageVC._gem_hobj = self.gem_hobj
                        imageVC._selectIndex = 0
                        imageVC._isPDF = true
                        imageVC._pdfCount = Int(count)
                        
                        imageVC._readMaxPdfCount = ((self.gemFiles![indexPath.row]) as? GemFileInfo)!.playPageCount as? Int ?? 0
                        if let waterFont = ((self.gemFiles![indexPath.row]) as? GemFileInfo)!.waterFont {
                            imageVC._waterFont = UIFont(name: waterFont.fontName, size: waterFont.pointSize / 2.0)
                        }
                        imageVC._waterColor = ((self.gemFiles![indexPath.row]) as? GemFileInfo)!.waterColor
                        imageVC._waterText = ((self.gemFiles![indexPath.row]) as? GemFileInfo)!.waterText as? String
                        imageVC._tempPath = self._temppath
                        imageVC._isHostAppRun = self.isHostAppRun?.boolValue
                        imageVC.modalPresentationStyle = .overFullScreen
                        if self.navigationController != nil {
                            self.navigationController?.pushViewController(imageVC, animated: true)
                        } else {
                            self.present(imageVC, animated: true, completion: nil)
                        }
                    }
//                    #endif
                } else if (nFileType >= NDF_FILE_TXT.rawValue) && (nFileType < NDF_FILE_PDF.rawValue) {
//                    // 空实现
                } else if (nFileType >= NDF_FILE_JPG.rawValue) && (nFileType < NDF_FILE_MP3.rawValue) {
                    let imageVC = ImagePrewViewController()
                    var arr: [String] = []
                    for (i, gemFile) in gemFiles!.enumerated() {
                        if let fileType = (gemFile as? GemFileInfo)!.nFileType as? Int, fileType >= NDF_FILE_JPG.rawValue && fileType < NDF_FILE_MP3.rawValue {
                            if let pat = (gemFile as? GemFileInfo)!.tempPath as? String, pat.count > 0 {
                                if i == indexPath.row {
                                    imageVC._selectIndex = arr.count
                                }
                                arr.append(pat)
                            }
                        }
                    }
                    imageVC._readMaxPdfCount = gemFile.playPageCount as? Int ?? 0
                    if let waterFont = gemFile.waterFont {
                        imageVC._waterFont = UIFont(name: waterFont.fontName, size: waterFont.pointSize / 2.0)
                    }
                    imageVC._waterColor = gemFile.waterColor
                    imageVC._waterText = gemFile.waterText as? String
                    imageVC._gem_hobj = gem_hobj
                    imageVC._sourcePaths = arr
                    imageVC._isPDF = false
                    imageVC._isHostAppRun = isHostAppRun?.boolValue
                    imageVC.modalPresentationStyle = .overFullScreen
                    if (navigationController != nil) {
                        if isHostAppRun?.boolValue == true {
                            navigationController?.pushViewController(imageVC, animated: true)
                        } else {
                            present(imageVC, animated: true, completion: nil)
                        }
                    }
                    else{
                        imageVC.modalPresentationStyle = .overFullScreen
                        imageVC._isHostAppRun = false
                        self.present(imageVC, animated: true, completion: nil)
                    }
                    
                } else {
                    let playerVC = VideoPlayerViewController()
                    playerVC._isHostAppRun = isHostAppRun!.boolValue
                    playerVC.gem_hobj = gem_hobj!
                    playerVC._playCfg = playCfg
                    if(user_param != nil){
                        playerVC._fileType = .PkgFileType_Gcp
                    }
                    playerVC._gcpCfg = gcpCfg
                    playerVC._user_param = user_param
                    playerVC._isGemFile = true
                    playerVC._gemPath = _path
                    playerVC._md5Path = szMD5PathCode
                    playerVC._playerPath = gemFile.tempPath as? String ?? ""
                    playerVC._passwordStr = gemFile.password as? String ?? ""
                    playerVC._passwordlen = gemFile.pwLenth as? Int ?? 0
                    playerVC._gemGUID = gemFile.gemGUID as? String ?? ""
                    playerVC._nCheckTimeUseNetTime = gemFile.nCheckTimeUseNetTime as? Int ?? 0
                    let haspassword = gemFile.pwLenth as? Int ?? 0 > 0
                    if !haspassword {
                        playerVC._playCount = Int((playCfg?.noPwCellCfg.nPlayCount)!)
                        playerVC._maxCount = 0
                        playerVC._nPlayTime = Int((playCfg?.noPwCellCfg.nPlayTime)!)
                    } else {
                        playerVC._playCount = gemFile.nMaxNum as? Int ?? 0
                        playerVC._maxCount = gemFile.nMaxNum as? Int ?? 0
                        playerVC._nPlayTime = gemFile.nMaxPlayTime as? Int ?? 0
                    }
                    if nFileType >= NDF_FILE_MP3.rawValue && nFileType < NDF_FILE_MP4.rawValue {
                        playerVC._isVideo = false
                        playerVC._waterImage = nil
                        var arr: [String] = []
                        for (i, gemFile) in gemFiles!.enumerated() {
                            if let fileType = (gemFile as? GemFileInfo)!.nFileType as? Int, fileType < NDF_FILE_MP4.rawValue && fileType >= NDF_FILE_MP3.rawValue {
                                if let pat = (gemFile as? GemFileInfo)!.tempPath as? String, pat.count > 0 {
                                    if i == indexPath.row {
                                        playerVC._selectTemPathIndex = arr.count
                                    }
                                    arr.append(pat)
                                }
                            }
                        }
                        playerVC._temPaths = arr
                    } else if nFileType >= NDF_FILE_MP4.rawValue && nFileType < NDF_FILE_VIDEO_TAG.rawValue {
                        playerVC._isVideo = true
                        playerVC._waterImage = gemFile.waterImage
                        playerVC._questions = gemFile.questionParams as? [Any]
                        var arr: [String] = []
                        for (i, gemFile) in gemFiles!.enumerated() {
                            if let fileType = (gemFile as? GemFileInfo)!.nFileType as? Int, fileType < NDF_FILE_VIDEO_TAG.rawValue && fileType >= NDF_FILE_MP4.rawValue {
                                if let pat = (gemFile as? GemFileInfo)!.tempPath as? String, pat.count > 0 {
                                    if i == indexPath.row {
                                        playerVC._selectTemPathIndex = arr.count
                                    }
                                    arr.append(pat)
                                }
                            }
                        }
                        playerVC._temPaths = arr
                    }
                    if (navigationController != nil) {
                        if isHostAppRun?.boolValue == true {
                            navigationController?.pushViewController(playerVC, animated: true)
                        } else {
                            present(playerVC, animated: true, completion: nil)
                        }
                    }
                    else{
                        playerVC._isHostAppRun = false
                        playerVC.modalPresentationStyle = .overFullScreen
                        self.present(playerVC, animated: true, completion: nil)
                    }
                }
            }
            else {
                if isDisTouchFile?.boolValue == true {
                    return
                }
                isDisTouchFile = true
                SVProgressHUD.show(withStatus: NSLocalizedString("Files Analyzing...", comment: ""))
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                self.perform(#selector(openGemForPath(_ : )), with: _path, afterDelay: 0.25)
            }
        } 
        else {
            
        }
    }
    @objc func openGemForPath(_ path : String) {
        HelpClass.shared().openGem(forPath: path,supperVC: self)
    }
}

