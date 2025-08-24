import UIKit

class FileItemTableViewCell: UITableViewCell {
    // MARK: - UI Elements
    private let fileIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .fromRGB(0xffffff)
        return label
    }()
    
    private let line: UILabel = {
        let label = UILabel()
        label.backgroundColor = .fromRGB(0x2f2e40)
        return label
    }()
    
    private let fileSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .fromRGB(0xcccccc)
        return label
    }()
    
    private let selectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Checked_"), for: .normal)
        button.setImage(UIImage(named: "UnChecked_"), for: .selected)
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "File-More"), for: .normal)
        return button
    }()
    
    // MARK: - Properties
    var onSelectButtonTapped: (() -> Void)?
    var onMoreButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(fileIconImageView)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(fileSizeLabel)
        contentView.addSubview(selectButton)
        contentView.addSubview(moreButton)
        contentView.addSubview(line)
        
        selectButton.isHidden = true
        moreButton.isHidden = false
        
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        
        self.fileIconImageView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        self.fileIconImageView.isHidden = true;
        self.fileNameLabel.frame = CGRect(x: /*CGRectGetMaxX(self.fileIconImageView.frame)*/10 + 10, y: (60 - 30)/2.0, width: UIScreen.main.bounds.width - (/*CGRectGetMaxX(self.fileIconImageView.frame)*/10 + 50 ), height: 30)
        self.fileSizeLabel.frame = CGRect(x: /*CGRectGetMaxX(self.fileIconImageView.frame)*/10 + 10, y: CGRectGetMaxY(self.fileNameLabel.frame), width: UIScreen.main.bounds.width - (/*CGRectGetMaxX(self.fileIconImageView.frame)*/10 + 50 ), height: 20)
        self.selectButton.frame = CGRectMake(kWIDTH - 44, (60 - 44)/2.0, 44, 44)
        self.moreButton.frame = CGRectMake(kWIDTH - 44, (60 - 44)/2.0, 44, 44)
        
        self.fileSizeLabel.isHidden = true
        self.line.frame = CGRect(x: 10, y: 59, width: kWIDTH - 20, height: 1.0/UIScreen.main.scale)
        
    }
    
    // MARK: - Actions
    @objc private func selectButtonTapped() {
        selectButton.isSelected.toggle()
        onSelectButtonTapped?()
    }
    
    @objc private func moreButtonTapped() {
        onMoreButtonTapped?()
    }
    
    // MARK: - Public Methods
    func configure(with fileName: String, fileSize: String, fileIcon: UIImage?) {
        fileNameLabel.text = fileName
        fileNameLabel.textColor = UIColor.fromRGB(0xffffff)
        fileSizeLabel.text = fileSize
        fileIconImageView.image = fileIcon
    }
}


class FileListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @objc var _filePath : String? = nil
    private var files: [String] = []
    private let tableView = UITableView()
    private var _backButton : UIButton? = nil
    private var _titleLabel : UILabel? = nil
    private var _moreView : UIView? = nil
    private var _moreFileURL : URL? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFiles()
    }
    @objc func backAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: SafeAreaTopHeight + 100, width: kWIDTH, height: 200)
        let imageView = UIImageView(image: UIImage(named: "empty-file"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: (CGRectGetWidth(view.frame) - 100)/2.0, y: (CGRectGetHeight(view.frame) - 100)/2.0, width: 100, height: 100)
        
        let label = UILabel()
        label.text = NSLocalizedString("fileList.empty", comment: "")
        label.textColor = .fromRGB(0xa4a4a4)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.frame = CGRect(x: 0, y: imageView.frame.maxY + 20, width: kWIDTH, height: 20)
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.center.x = view.bounds.width / 2
        label.center.x = view.bounds.width / 2
        
        view.isHidden = true
        return view
    }()

    private func setupUI() {
        view.backgroundColor = .fromRGB(0x1a1a1c)
        
        // Setup navigation bar
        navigationItem.title = ""
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        // 创建一个返回按钮
        _backButton = UIButton()
        _backButton!.setImage(UIImage(named: "Btn_Back"), for: .normal)
        _backButton!.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        _backButton!.frame = CGRect(x: 0, y: (SafeAreaTopHeight - 44), width: 40, height: 44)
        self.view.addSubview(_backButton!)
        
        _titleLabel = UILabel()
        _titleLabel!.text = NSLocalizedString("fileList.title", comment: "")
        _titleLabel!.textColor = .white
        _titleLabel!.textAlignment = .center
        let titleLabelWidth = kWIDTH - 40 - (_backButton!.frame.width * 2)
        _titleLabel!.frame = CGRect(x: _backButton!.frame.maxX + 20, y: (SafeAreaTopHeight - 44), width: titleLabelWidth, height: 44)
        self.view.addSubview(_titleLabel!)
        let titleLine = UIView()
        titleLine.frame = CGRect(x: 0, y: CGRectGetMaxY(_titleLabel!.frame) - CGFloat(1.0/UIScreen.main.scale), width: kWIDTH, height: CGFloat(1.0/UIScreen.main.scale))
        titleLine.backgroundColor = UIColor.fromRGB(0x2d2d2d)
        view.addSubview(titleLine)
        
        // Setup table view
        tableView.frame = CGRectMake(0, SafeAreaTopHeight, kWIDTH, kHEIGHT - SafeAreaTopHeight)
        tableView.backgroundView = nil
        tableView.backgroundColor = self.view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FileItemTableViewCell.self, forCellReuseIdentifier: "FileCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = self.view.backgroundColor
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

    }
    // 封装获取文件创建日期的函数
    func creationDate(ofFileAtPath filePath: URL, fileManager: FileManager) -> Date {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: filePath.path)
            return attributes[.creationDate] as? Date ?? Date.distantPast
        } catch {
            print("Error getting file attributes: \(error)")
            return Date.distantPast
        }
    }
    private func loadFiles() {
        let fileManager = FileManager.default
        let documentsPath = _filePath!
        let documentsURL = URL(fileURLWithPath: documentsPath)
        do {
            // Get files and their creation dates
            let filenames = try fileManager.contentsOfDirectory(atPath: documentsPath)
            // 过滤文件名是 __MACOSX 和后缀名是 psd 的文件
            let filteredFilenames = filenames.filter { filename in
                let fileURL = documentsURL.appendingPathComponent(filename)
                let lastPathComponent = fileURL.lastPathComponent
                return lastPathComponent != "__MACOSX" && !lastPathComponent.hasSuffix(".psd")
            }
            
            // 映射文件名到 (文件名, 创建日期) 元组
            let filesWithDates = filteredFilenames.map { filename in
                let fileURL = documentsURL.appendingPathComponent(filename)
                let creationDate = creationDate(ofFileAtPath: fileURL, fileManager: fileManager)
                return (filename, creationDate)
            }
            
            // Sort files by creation date (newest first)
            files = filesWithDates.sorted { $0.1 > $1.1 }.map { $0.0 }
            
            emptyStateView.isHidden = !files.isEmpty
            tableView.isHidden = files.isEmpty
        } catch {
            print("Error loading files: \(error)")
            emptyStateView.isHidden = false
            tableView.isHidden = true
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileItemTableViewCell
        cell.backgroundView = nil
        cell.backgroundColor = self.view.backgroundColor
        cell.selectionStyle = .none
        let fileSize = HelpClass.fileSize(atPath: files[indexPath.row])
        cell.configure(with: files[indexPath.row], fileSize: String(format: "%.2lf MB", [CGFloat(fileSize)/1024.0]), fileIcon: UIImage(named: "Gem"))
        
        cell.onSelectButtonTapped = {
            // 处理选中按钮点击事件
        }
        
        cell.onMoreButtonTapped = {
            // 处理更多按钮点击事件
            self._moreFileURL = URL(fileURLWithPath: "\(self._filePath!)/\(self.files[indexPath.row])")
            self._moreView = UIView()
            self._moreView!.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: kHEIGHT)
            self._moreView!.backgroundColor = .fromRGB(0x000000).withAlphaComponent(0.5)
            self._moreView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissMoreView)))
            
            // 添加弹窗视图
            let popupView = UIView()
            popupView.backgroundColor = .fromRGB(0x2f2e40)
            popupView.layer.cornerRadius = 12
            popupView.layer.masksToBounds = true
            popupView.frame = CGRect(x: 0, y: (kHEIGHT - 120 - SafeAreaBottomHeight), width: kWIDTH, height: 120 + SafeAreaBottomHeight)
            
//            let titleLabel = UILabel()
//            titleLabel.text = NSLocalizedString("more.title", comment: "")
//            titleLabel.textColor = .fromRGB(0xcccccc)
//            titleLabel.textAlignment = .center
//            titleLabel.frame = CGRect(x: 0, y: 0, width: popupView.frame.width, height: 50)
//            popupView.addSubview(titleLabel)
//            let line0 = UIView()
//            line0.backgroundColor = .fromRGB(0x1a1a1c)
//            line0.frame = CGRect(x: 0, y: /*CGRectGetMaxY(titleLabel.frame)*/10 + 9, width: buttonWidth, height: 1.0/UIScreen.main.scale)
//            popupView.addSubview(line0)
            
            // 创建按钮
            let buttonHeight: CGFloat = 60
            let buttonWidth = popupView.frame.width
            
            
            let shareButton = UIButton(type: .system)
            shareButton.frame = CGRect(x: 0, y: /*CGRectGetMaxY(titleLabel.frame)*/0, width: buttonWidth, height: buttonHeight)
            shareButton.setTitle( NSLocalizedString("more.share", comment: ""), for: .normal)
            shareButton.setTitleColor(.white, for: .normal)
            shareButton.addTarget(self, action: #selector(self.shareButtonTapped), for: .touchUpInside)
            
            let deleteButton = UIButton(type: .system)
            deleteButton.frame = CGRect(x: 0, y: shareButton.frame.maxY, width: buttonWidth, height: buttonHeight)
            deleteButton.setTitle( NSLocalizedString("more.delete", comment: ""), for: .normal)
            deleteButton.setTitleColor(.white, for: .normal)
            deleteButton.addTarget(self, action: #selector(self.deleteButtonTapped), for: .touchUpInside)
            
//            let cancelButton = UIButton(type: .system)
//            cancelButton.frame = CGRect(x: 0, y: deleteButton.frame.maxY + 10, width: buttonWidth, height: buttonHeight)
//            cancelButton.setTitle( NSLocalizedString("more.cancel", comment: ""), for: .normal)
//            cancelButton.setTitleColor(.white, for: .normal)
//            cancelButton.addTarget(self, action: #selector(self.dismissMoreView), for: .touchUpInside)
            
            // 添加分割线
            let line1 = UIView()
            line1.backgroundColor = .fromRGB(0x1a1a1c)
            line1.frame = CGRect(x: 0, y: shareButton.frame.maxY, width: buttonWidth, height: 1.0/UIScreen.main.scale)
            
//            let line2 = UIView()
//            line2.backgroundColor = .fromRGB(0x1a1a1c)
//            line2.frame = CGRect(x: 0, y: deleteButton.frame.maxY, width: buttonWidth, height: 1.0/UIScreen.main.scale)
            
            // 将按钮和分割线添加到弹窗视图
            popupView.addSubview(shareButton)
            popupView.addSubview(line1)
            popupView.addSubview(deleteButton)
//            popupView.addSubview(line2)
//            popupView.addSubview(cancelButton)
            
            self._moreView!.addSubview(popupView)
            self.view.addSubview(self._moreView!)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 处理行点击事件
        let path = files[indexPath.row]
        if (path as! NSString).pathExtension.count == 0 {
            let fileListVC = FileListViewController()
            fileListVC.modalPresentationStyle = .overFullScreen
            fileListVC._filePath = "\(_filePath!)/\(files[indexPath.row])"
            self.present(fileListVC, animated: true, completion: nil)
        }
        else{
            let url = URL(fileURLWithPath: path)
            let pathExtension = (url.pathExtension as String).lowercased()
            var szMD5PathCode = ""
            szMD5PathCode = HelpClass.getFileMD5Code(path)
            if pathExtension == "pptext" {
                return
            }
            else if pathExtension == "site" || pathExtension == "zip" || pathExtension == "7z" || pathExtension == "rar" {
                let paths = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true)
                let folderName = pathExtension == "site" ? "site_zip" : "gem_zip"
                var zipFolderPath = paths[0].appendingFormat("/\(folderName)/%@", szMD5PathCode)
                if(szMD5PathCode == ""){
                    zipFolderPath = paths[0].appendingFormat("/\(folderName)/%lu", path.hashValue)
                }
                if !FileManager.default.fileExists(atPath: zipFolderPath) {
                    try? FileManager.default.createDirectory(atPath: zipFolderPath, withIntermediateDirectories: true, attributes: nil)
                }
                let zipPath = zipFolderPath.appendingFormat("/%lu.zip", path.hashValue)
                let unZipPath = paths[0].appendingFormat("/zip/%lu", path.hashValue)

                SVProgressHUD.show(withStatus: NSLocalizedString("File parsing in progress... Please wait.", comment: ""))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                    guard let self = self else { return }
                    if FileManager.default.fileExists(atPath: zipPath) {
                        HelpClass.openSite_Zip(zipPath, outputPath: unZipPath, temppath: "", vc: self,isInGem: false)
                    } else {
                        let zipFilePath = self._filePath! + "/" + path
                        try? FileManager.default.copyItem(atPath: zipFilePath, toPath: zipPath)
                        HelpClass.openSite_Zip(zipPath, outputPath: unZipPath, temppath: "", vc: self,isInGem: false)
                    }
                }
            }
            else{
                self.selectedFile(URL(fileURLWithPath: "\(_filePath!)/\(files[indexPath.row])"))
            }
        }
        
    }
    
    func selectedFile(_ url: URL) {
        DispatchQueue.main.async {
            let array = url.absoluteString.components(separatedBy: "/")
            let fileName = array.last?.removingPercentEncoding ?? ""
            print("--->>>>\(fileName)")
            SVProgressHUD .show(withStatus: NSLocalizedString("请稍后...", comment: ""))
            if !FileManager.default.fileExists(atPath: url.path) {
                return
            }
            
            let pathExtension = url.pathExtension.lowercased()
            if pathExtension == "gem" || pathExtension == "gcp" || pathExtension == "gfx" {
                HelpClass.shared().openGem(forPath: url.path,supperVC: self)
            } else {
                let extensionStr = url.pathExtension.lowercased()
                if ["mp3", "mp4", "mov", "wav"].contains(extensionStr) {
                    SVProgressHUD.dismiss()
                    let playerVC = VideoPlayerViewController()
                    playerVC._isGemFile = false
                    playerVC._isHostAppRun = true
                    playerVC._isVideo = ["mp4", "mov"].contains(extensionStr)
                    playerVC._playerPath = url.path
                    playerVC.modalPresentationStyle = .overFullScreen
                    if self.navigationController != nil {
                        self.navigationController?.pushViewController(playerVC, animated: true)
                    }
                    else{
                        self .present(playerVC, animated: true, completion: nil)
                    }
                } else if ["pdf", "gif", "png", "jpg", "tiff", "bmp"].contains(extensionStr) {
                    if extensionStr == "pdf" {
                        // 创建并展示视频播放器视图控制器
                        HelpClass.openpdf(withPath: url.path, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pageIndex: 0) {( rotation, count, image) in
                            SVProgressHUD.dismiss()
                            let play = ImagePrewViewController()
                            play._tempPath = url.path
                            play._sourceImage = image
                            play._selectIndex = 0
                            play._pdfCount = Int(count)
                            play._rotation = Int(rotation)
                            play.modalPresentationStyle = .overFullScreen
                            if self.navigationController != nil {
                                self.navigationController?.pushViewController(play, animated: true)
                            }
                            else{
                                self .present(play, animated: true, completion: nil)
                            }
                        }
                    } else {
                        SVProgressHUD.dismiss()
                        let image = ImagePrewViewController()
                        if let data = try? Data(contentsOf: url) {
                            image._sourceImage = UIImage(data: data)
                        }
                        image._isHostAppRun = true
                        image._isPDF = extensionStr == "pdf"
                        image.modalPresentationStyle = .overFullScreen
                        if self.navigationController != nil {
                            self.navigationController?.pushViewController(image, animated: true)
                        }
                        else{
                            self .present(image, animated: true, completion: nil)
                        }
                    }
                } else {
                    SVProgressHUD.dismiss()
                    let fileVC = GemFileDetailViewController()
                    fileVC._path = url.deletingLastPathComponent().path
                    fileVC.isGem = false
                    fileVC.isHostAppRun = true
                    fileVC.modalPresentationStyle = .overFullScreen
                    if self.navigationController != nil {
                        self.navigationController?.pushViewController(fileVC, animated: true)
                    }
                    else{
                        self .present(fileVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    // 添加按钮事件处理方法
    @objc private func shareButtonTapped() {
        // 处理分享操作
        let activityVC = UIActivityViewController(activityItems: [self._moreFileURL!], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
        dismissMoreView(gesture: nil)
        
        
    }

    @objc private func deleteButtonTapped() {
        // 处理删除操作
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: self._moreFileURL!)
        } catch {
            print("Error deleting file: \(error)")
        }
        loadFiles();
        tableView.reloadData()
        dismissMoreView(gesture: nil)
    }

    @objc private func dismissMoreView(gesture: UITapGestureRecognizer? = nil) {
        self._moreView!.removeFromSuperview()
    }
    
}
