//
//  ImagePrewViewController.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/6.
//

import Foundation
import UIKit
class ImageCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func setupViews() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.fromRGB(0x5c69de).cgColor
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

class ImagePrewViewController: UIViewController,UITextFieldDelegate, UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    @objc var _tempPath : String?
    @objc var _sourceImage : UIImage? = nil
    @objc var _gem_hobj : HNdfObject? = nil
    var _selectIndex : Int? = 0
    var _isPDF : Bool? = true
    var _pdfCount : Int? = 0
    var _isHostAppRun : Bool? = false
    
    var _readMaxPdfCount : Int? = 0
    var _waterFont : UIFont? = nil
    var _waterColor : UIColor? = nil
    var _waterText : String? = nil
    
    var _sourcePaths : [Any]? = []
    
    var _imageUrls: [URL] = []
    var _currentImageIndex = 0
    var _currentAngle: CGFloat = 0.0
    var _scrollView: UIScrollView!
    var _imageView: UIImageView!
    var _imageBgView : UITextField!
    var _rotateButton : UIButton!
    var _backButton : UIButton!
    var _titleLabel : UILabel!
    
    var _hudIndicatorView : UIActivityIndicatorView?
    var zoomScale : CGFloat! = 1
    var _rotation : Int? = 0
    let cellId = "cellId"
    let imageCache = NSCache<NSString, UIImage>()
    
    var collectionView: UICollectionView!
    var toolBarView : UIView!
    var pageBtn : UIButton!
    var gobackBtn : UIButton? = nil
    var forwardBtn : UIButton? = nil
    var alertView : UIView!
    var alertContentView : UIView!
    var pageTextField : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if(self._waterText == ""){
            self._waterText = nil
        }
        self.view.backgroundColor = .black
        _titleLabel = UILabel()
        setupButton()
        setupScrollView()
        if(_isPDF == true){
            self.setupPdfToolBarView()
            self.setupGestureRecognizers()
        }
        else{
            if (_imageUrls.count > 1 || _sourcePaths!.count > 1) {
                setupCollectionView()
            }
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
    @objc func swipeLeft() {
        if(_isPDF == true){
            self.forwardAction()
        }
        else{
            if (_sourcePaths!.count > 0){
                if _currentImageIndex < _sourcePaths!.count - 1 {
                    _currentImageIndex += 1
                    _selectIndex = _currentImageIndex;
                    _currentAngle = 0.0
                    setupScrollView()
                    collectionView.reloadData()
                    self.view.bringSubviewToFront(collectionView)
                    self.view.bringSubviewToFront(_backButton)
                    self.view.bringSubviewToFront(_rotateButton)
                }
            }
        }
        
    }

    @objc func swipeRight() {
        if(_isPDF == true){
            self.gobackAction()
        }
        else{
            if _currentImageIndex > 0 {
                _currentImageIndex -= 1
                _selectIndex = _currentImageIndex;
                _currentAngle = 0.0
                setupScrollView()
                collectionView.reloadData()
                self.view.bringSubviewToFront(collectionView)
                self.view.bringSubviewToFront(_backButton)
                self.view.bringSubviewToFront(_rotateButton)
            }
        }
    }
    
    @objc func tapGestureRecognizer(_ gesture : UITapGestureRecognizer){
        
    }
    @objc func longPressGestureRecognizer(_ gesture : UITapGestureRecognizer){
        
    }
    func setupScrollView() {
        if(_imageView != nil){
            _imageView .removeFromSuperview()
            _imageView = nil
        }
        if(_scrollView != nil){
            _scrollView .removeFromSuperview()
            _scrollView = nil
        }
        _scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kWIDTH, height: kHEIGHT))
        _scrollView.delegate = self
        _scrollView.backgroundColor = self.view.backgroundColor
        _scrollView.minimumZoomScale = 1.0
        _scrollView.maximumZoomScale = 6.0
        _scrollView.isPagingEnabled = false
        _scrollView.bounces = true
        _scrollView.contentInsetAdjustmentBehavior = .never
        _scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view.insertSubview(_scrollView, at: 0)
        
        _imageBgView = UITextField()
        _imageBgView.frame = _scrollView.bounds;
        _imageBgView.isSecureTextEntry = true
        _imageBgView.backgroundColor = .black
        _imageBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(_ : ))))
        _imageBgView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognizer(_ : ))))
        _scrollView.addSubview(_imageBgView)
        
        _imageView = UIImageView(frame: _imageBgView.bounds)
        _imageView.backgroundColor = .clear
        _imageView.contentMode = .scaleAspectFit
        _imageView.isUserInteractionEnabled = true
        _imageView.isMultipleTouchEnabled = true
        
        if(_sourceImage != nil){
            if(_waterText != nil){
                _imageView.image = HelpClass.getWaterMark(_sourceImage!, andTitle: _waterText!, andMark: _waterFont ?? .systemFont(ofSize: 15), andMark: _waterColor ?? .white, isThumb: false)
            }else{
                _imageView.image = _sourceImage;
            }
        }
        else{
            if (_gem_hobj != nil) {
                if(_waterText != nil){
                    _imageView.image = HelpClass.getWaterMark(UIImage(data: self.getFileData(filePath: _sourcePaths![_selectIndex!] as! String, isThumb: false) as Data)!, andTitle: _waterText!, andMark: _waterFont ?? .systemFont(ofSize: 15), andMark: _waterColor ?? .white, isThumb: false)
                }else{
                    _imageView.image = UIImage(data: self.getFileData(filePath: _sourcePaths![_selectIndex!] as! String, isThumb: false) as Data)!
                }
                if (_titleLabel != nil){
                    let path = (_sourcePaths![_selectIndex!] as! String)
                    let components = path.components(separatedBy: "\\")
                    let lastName = components.last
                    self.view .bringSubviewToFront(_titleLabel)
                    _titleLabel.text = lastName ?? path
                }
            }
            else{
                if _imageUrls.count > 0 {
                    let imageURL = _imageUrls[_currentImageIndex]
                    if let image = UIImage(contentsOfFile: imageURL.path) {
                        let newImage = UIImageManager.fixImageOrientation(image: image)
                        _imageView.image = newImage
                        if (_titleLabel != nil){
                            self.view .bringSubviewToFront(_titleLabel)
                            _titleLabel.text = imageURL.lastPathComponent
                        }
                    }
                }
            }
        }
        
        
        (_imageBgView.subviews.first)!.addSubview(_imageView!)
        _scrollView.addSubview(_imageBgView)
        _scrollView.contentSize = _imageBgView.bounds.size
    }
    //实现缩放
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _imageView
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        zoomScale = scrollView.zoomScale;
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if (_isPDF == true) {
            if(zoomScale > scale || self._sourceImage!.size.width >= kWIDTH * UIScreen.main.scale * scrollView.maximumZoomScale){
                return;
            }
            if(kWIDTH * UIScreen.main.scale * scale < _sourceImage!.size.width){
                return;
            }
            if (_hudIndicatorView == nil){
                _hudIndicatorView = UIActivityIndicatorView.init(frame: CGRectMake(0, 0, 30, 30))//指定进度轮的大小
                if #available(iOS 13.0, *) {
                    _hudIndicatorView?.style = .large
                } else {
                    // Fallback on earlier versions
                }
                _hudIndicatorView!.hidesWhenStopped = true
                _hudIndicatorView!.color = .black
                _hudIndicatorView!.tintColor = .black
                _hudIndicatorView!.center = self.view.center
                _hudIndicatorView!.hidesWhenStopped = true
                self.view .addSubview(_hudIndicatorView!)
            }

            _hudIndicatorView!.startAnimating()
            
            if (_gem_hobj != nil){
                HelpClass.openPdf(_gem_hobj!, temppath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pdfImageIndex: _selectIndex!) { [weak self] ( rotation, count, image) in
                    guard let self = self else { return }
                    self._sourceImage = image
                    var originalImage : UIImage
                    if(_waterText != nil){
                        originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: _waterText!, andMark: _waterFont!, andMark: _waterColor!, isThumb: false)
                    }else{
                        originalImage = self._sourceImage!
                    }
                    let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: _currentAngle)
                    _imageView.image = rotatedImage
                    _hudIndicatorView!.stopAnimating()
                }
            }
            else{
                HelpClass.openpdf(withPath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pageIndex: _selectIndex!) { [weak self] ( rotation, count, image) in
                    guard let self = self else { return }
                    self._sourceImage = image
                    var originalImage : UIImage
                    if(_waterText != nil){
                        originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: _waterText!, andMark: _waterFont!, andMark: _waterColor!, isThumb: false)
                    }else{
                        originalImage = self._sourceImage!
                    }
                    let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: _currentAngle)
                    _imageView.image = rotatedImage
                    _hudIndicatorView!.stopAnimating()
                }
            }
            
        }
    }
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
    func setupButton() {
        // 创建一个返回按钮
        _backButton = UIButton()
        _backButton.setImage(UIImage(named: "Btn_Back"), for: .normal)
        _backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        _backButton.frame = CGRect(x: 0, y: (SafeAreaTopHeight - 44), width: 40, height: 44)
        self.view.addSubview(_backButton)
        
        if (_gem_hobj != nil){
            if(_sourcePaths!.count > _selectIndex!) {
                if let path = _sourcePaths![_selectIndex!] as? String {
                    let components = path.components(separatedBy: "\\")
                    _titleLabel.text = components.last ?? path
                }
            }
        }
        else{
            if(_imageUrls.count > _currentImageIndex ){
                _titleLabel.text = _imageUrls[_currentImageIndex].lastPathComponent
            }
            if ( _sourcePaths!.count > _selectIndex!){
                if let path = _sourcePaths![_selectIndex!] as? String {
                    let components = path.components(separatedBy: "\\")
                    _titleLabel.text = components.last ?? path
                    _titleLabel.text = (path as NSString).lastPathComponent
                }
            }
        }
        _titleLabel.textColor = .white
        _titleLabel.textAlignment = .center
        let titleLabelWidth = kWIDTH - 40 - (_backButton!.frame.width * 2)
        _titleLabel.frame = CGRect(x: _backButton!.frame.maxX + 20, y: (SafeAreaTopHeight - 44), width: titleLabelWidth, height: 44)
        self.view.addSubview(_titleLabel)

        
        _rotateButton = UIButton()
        _rotateButton.setImage(UIImage(named: "Rotate_Normal"), for: .normal)
        _rotateButton.frame = CGRect(x: kWIDTH - 44, y: (SafeAreaTopHeight - 44), width: 44, height: 44)
        _rotateButton.addTarget(self, action: #selector(rotateImage), for: .touchUpInside)
        self.view.addSubview(_rotateButton)
    }
    @objc func rotateImage() {
        // 每次旋转90度
        let rotationAngle: CGFloat = 90
        
        // 累计旋转角度
        _currentAngle -= rotationAngle
        if _currentAngle == -360 {
            _currentAngle = 0
        }
        if(_gem_hobj != nil){
            var originalImage : UIImage? = nil
            if (_isPDF == true){
                HelpClass.openPdf(_gem_hobj!, temppath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pdfImageIndex: _selectIndex!) { [weak self] ( rotation, count, image) in
                    guard let self = self else { return }
                    self._sourceImage = image
                    if(_waterText != nil){
                        originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: _waterText!, andMark: _waterFont!, andMark: _waterColor!, isThumb: false)
                    }else{
                        originalImage = self._sourceImage!
                    }
                    let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: _currentAngle)
                    _imageView.image = rotatedImage
                }
            }
            else{
                if(_waterText != nil){
                    originalImage = HelpClass.getWaterMark(UIImage(data: self.getFileData(filePath: _sourcePaths![_selectIndex!] as! String, isThumb: false) as Data)!, andTitle: _waterText!, andMark: _waterFont!, andMark: _waterColor!, isThumb: false)
                }else{
                    originalImage = UIImage(data: self.getFileData(filePath: _sourcePaths![_selectIndex!] as! String, isThumb: false) as Data)!
                }
                let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: _currentAngle)
                _imageView.image = rotatedImage
            }
        }
        else{
            if (_isPDF == true){
                HelpClass.openpdf(withPath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pageIndex: _selectIndex!) {  [weak self] ( rotation, count, image) in
                    guard let self = self else { return }
                    var originalImage : UIImage? = nil
                    if(_waterText != nil){
                        originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: _waterText!, andMark: _waterFont!, andMark: _waterColor!, isThumb: false)
                    }else{
                        originalImage = self._sourceImage!
                    }
                    let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: _currentAngle)
                    _imageView.image = rotatedImage
                }
            }
            if _imageUrls.count > 0 {
                let imageURL = _imageUrls[_currentImageIndex]
                if let image = UIImage(contentsOfFile: imageURL.path) {
                    let originalImage = UIImageManager.fixImageOrientation(image: image)
                    let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: _currentAngle)
                    _imageView.image = rotatedImage
                }
            }
        }
        
    }
    
    //MARK: 创建一个PDF页码 展示的ToolBarView
    func setupPdfToolBarView(){
        toolBarView = UIView(frame: CGRect(x: 0, y: kHEIGHT - SafeAreaBottomHeight - 49, width: kWIDTH, height: (SafeAreaBottomHeight + 49)))
        toolBarView.backgroundColor = .black.withAlphaComponent(0.7)
        self.view .addSubview(toolBarView)
        
        let bgView  = UIView(frame: CGRect(x: CGRectGetWidth(toolBarView.frame)/2.0 - 40 , y: 5, width: 80, height: 34))
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = .fromRGB(0x272727)
        toolBarView .addSubview(bgView)
        let pagetitle = "\((_selectIndex ?? 0) + 1)/\(_pdfCount ?? 0)";
        pageBtn = UIButton(frame: bgView.frame)
        pageBtn.setTitle(pagetitle, for: .normal)
        pageBtn.setTitleColor(.white, for: .normal)
        pageBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        pageBtn.addTarget(self, action: #selector(pageBtnAction), for: .touchUpInside)
        pageBtn.backgroundColor = .clear
        toolBarView.addSubview(pageBtn)
        
        
        gobackBtn = UIButton(frame: CGRect(x: CGRectGetWidth(toolBarView.frame)/2.0 - 60 - 44, y: 0, width: 44, height: 44))
        gobackBtn!.setImage(UIImage(named: "Up_Music"), for: .normal)
        gobackBtn!.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        gobackBtn!.addTarget(self, action: #selector(gobackAction), for: .touchUpInside)
        gobackBtn!.backgroundColor = .clear
        toolBarView.addSubview(gobackBtn!)
        
        
        forwardBtn = UIButton(frame: CGRect(x: CGRectGetWidth(toolBarView.frame)/2.0 + 60, y: 0, width: 44, height: 44))
        forwardBtn!.setImage(UIImage(named: "Down_Music"), for: .normal)
        forwardBtn!.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        forwardBtn!.addTarget(self, action: #selector(forwardAction), for: .touchUpInside)
        forwardBtn!.backgroundColor = .clear
        toolBarView.addSubview(forwardBtn!)
        
        
        
    }
    @objc func gobackAction(){
        _selectIndex = _selectIndex! - 1
        _selectIndex = Int(HelpClass.max(Float(_selectIndex!), num2: 0))
        forwardBtn!.isEnabled = _selectIndex! < _pdfCount! - 1
        gobackBtn!.isEnabled = (_selectIndex! > 0)
        pageBtn.setTitle("\((_selectIndex ?? 0) + 1)/\(_pdfCount ?? 0)", for: .normal)
        if(_gem_hobj != nil){
            HelpClass.openPdf(_gem_hobj!, temppath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pdfImageIndex: _selectIndex!) { [weak self] ( rotation, count, image) in
                guard let self = self else { return }
                self._sourceImage = image
                var originalImage : UIImage? = nil
                if(self._waterText != nil){
                    originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: self._waterText!, andMark: self._waterFont!, andMark: self._waterColor!, isThumb: false)
                }else{
                    originalImage = self._sourceImage!
                }
                let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: self._currentAngle)
                self._imageView.image = rotatedImage
            }
        }
        else{
            if (_isPDF == true){
                HelpClass.openpdf(withPath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pageIndex: _selectIndex!) {  [weak self] ( rotation, count, image) in
                    guard let self = self else { return }
                    self._sourceImage = image
                    var originalImage : UIImage? = nil
                    if(self._waterText != nil){
                        originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: self._waterText!, andMark: self._waterFont!, andMark: self._waterColor!, isThumb: false)
                    }else{
                        originalImage = self._sourceImage!
                    }
                    let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: self._currentAngle)
                    self._imageView.image = rotatedImage
                }
            }
        }
    }
    @objc func forwardAction(){
        _selectIndex = _selectIndex! + 1
        _selectIndex = Int(HelpClass.min(Float(_selectIndex!), num2: Float(_pdfCount!) - 1))
        gobackBtn!.isEnabled = (_selectIndex! > 0)
        forwardBtn!.isEnabled = (_selectIndex! < _pdfCount! - 1)
        pageBtn.setTitle("\((_selectIndex ?? 0) + 1)/\(_pdfCount ?? 0)", for: .normal)
        if(_gem_hobj != nil){
            HelpClass.openPdf(_gem_hobj!, temppath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pdfImageIndex: _selectIndex!) { [weak self] ( rotation, count, image) in
                guard let self = self else { return }
                self._sourceImage = image
                var originalImage : UIImage? = nil
                if(self._waterText != nil){
                    originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: self._waterText!, andMark: self._waterFont ?? .systemFont(ofSize: 15) , andMark: self._waterColor ?? .white, isThumb: false)
                }else{
                    originalImage = self._sourceImage!
                }
                let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: self._currentAngle)
                self._imageView.image = rotatedImage
            }
        }
        else{
            if (_isPDF == true){
                HelpClass.openpdf(withPath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pageIndex: _selectIndex!) {  [weak self] ( rotation, count, image) in
                    guard let self = self else { return }
                    self._sourceImage = image
                    var originalImage : UIImage? = nil
                    if(self._waterText != nil){
                        originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: self._waterText!, andMark: self._waterFont!, andMark: self._waterColor!, isThumb: false)
                    }else{
                        originalImage = self._sourceImage!
                    }
                    let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: self._currentAngle)
                    self._imageView.image = rotatedImage
                }
            }
        }
    }
    @objc func alertViewTouchGesture(){
        if (pageTextField != nil){
            pageTextField.resignFirstResponder()
        }
    }
    @objc func pageBtnAction(){
        alertView = UIView()
        alertView.frame = CGRect(x: 0, y: 0, width: kWIDTH, height: kHEIGHT)
        alertView.backgroundColor = .black.withAlphaComponent(0.5)
        alertView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(alertViewTouchGesture)))
        self.view.addSubview(alertView)

        alertContentView = UIView()
        alertContentView.frame = CGRect(x: (CGRectGetWidth(alertView.frame) - 300)/2.0, y: (CGRectGetHeight(alertView.frame) - 200)/2.0 - 44, width: 300, height: 200)
        alertContentView.backgroundColor = .white
        alertContentView.layer.cornerRadius = 10
        alertContentView.layer.masksToBounds = true
        alertView.addSubview(alertContentView)

        let alertTitleLabel = UILabel()
        alertTitleLabel.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(alertContentView.frame), height: 44)
        alertTitleLabel.text = NSLocalizedString("跳至页面", comment: "")
        alertTitleLabel.font = UIFont.systemFont(ofSize: 16)
        alertTitleLabel.textAlignment = .center
        alertContentView.addSubview(alertTitleLabel)
        
        let alertMessageLabel = UILabel()
        alertMessageLabel.frame = CGRect(x: 0, y: CGRectGetMaxY(alertTitleLabel.frame), width: CGRectGetWidth(alertContentView.frame), height: 24)
        alertMessageLabel.text = NSLocalizedString("输入页码", comment: "")
        alertMessageLabel.font = UIFont.systemFont(ofSize: 12)
        alertMessageLabel.textAlignment = .center
        alertContentView.addSubview(alertMessageLabel)
        
        
//        let cancelBtn = UIButton()
//        cancelBtn.frame = CGRect(x: CGRectGetWidth(alertContentView.frame) - 44, y: 0, width: 44, height: 44)
//        cancelBtn.setImage(UIImage(named: "Tip_Close_"), for: .normal)
//        cancelBtn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
//        alertContentView.addSubview(cancelBtn)

        pageTextField = UITextField()
        pageTextField.frame = CGRect(x: 30, y: CGRectGetMaxY(alertMessageLabel.frame) + 10, width: CGRectGetWidth(alertContentView.frame) - 60, height: 34)
        pageTextField.textColor = .black
        pageTextField.backgroundColor = .fromRGB(0xf8f8f8);
        pageTextField.textAlignment = .center
        pageTextField.text = "\((_selectIndex ?? 0) + 1)"
        pageTextField.delegate = self;
        pageTextField.layer.cornerRadius = 5
        pageTextField.keyboardType = .numberPad
        pageTextField.layer.masksToBounds = true
        pageTextField.font = UIFont.systemFont(ofSize: 15)
        alertContentView.addSubview(pageTextField)
        
        
        
        
        let closeBtn = UIButton()
        closeBtn.frame = CGRect(x: (CGRectGetWidth(alertContentView.frame)/2.0 - 130)/2.0, y: CGRectGetHeight(alertContentView.frame) - 44, width: 130, height: 44)
        closeBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.layer.cornerRadius = 4;
        closeBtn.layer.masksToBounds = true
        closeBtn.setTitleColor(HelpClass.color(withColors: [UIColor.fromRGB(0x5c69de).cgColor,UIColor.fromRGB(0xde5c93).cgColor], bounds: closeBtn.bounds), for: .normal)
        closeBtn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        alertContentView.addSubview(closeBtn)
        
        let confirmBtn = UIButton()
        confirmBtn.frame = CGRect(x: CGRectGetWidth(alertContentView.frame)/2.0 + (CGRectGetWidth(alertContentView.frame)/2.0 - 130)/2.0, y: CGRectGetHeight(alertContentView.frame) - 44, width: 130, height: 44)
        confirmBtn.setTitle(NSLocalizedString("Ok", comment: ""), for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.layer.cornerRadius = 4;
        confirmBtn.layer.masksToBounds = true
        confirmBtn.setTitleColor(HelpClass.color(withColors: [UIColor.fromRGB(0x5c69de).cgColor,UIColor.fromRGB(0xde5c93).cgColor], bounds: confirmBtn.bounds), for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        alertContentView.addSubview(confirmBtn)

        let line = UIView.init(frame: CGRectMake(0, CGRectGetMinY(confirmBtn.frame) - 1, CGRectGetWidth(alertContentView.frame), 1.0/UIScreen.main.scale));
        line.backgroundColor = .fromRGB(0xb2b2b2);
        alertContentView.addSubview(line)
        let line1 = UIView.init(frame: CGRectMake(CGRectGetMinX(confirmBtn.frame), CGRectGetMinY(confirmBtn.frame) - 1, 1.0/UIScreen.main.scale, 44))
        line1.backgroundColor = .fromRGB(0xb2b2b2);
        alertContentView.addSubview(line1)
        
    }
    @objc func cancelBtnAction(){
        alertView.removeFromSuperview()
    }
    @objc func confirmBtnAction(){
        alertView.removeFromSuperview()
        _selectIndex = (Int(pageTextField.text!) ?? 1) - 1
        _selectIndex = Int(HelpClass.min(Float(_selectIndex!), num2: Float(_pdfCount!) - 1))
        _selectIndex = Int(HelpClass.max(Float(_selectIndex!), num2: 0))
        
        forwardBtn!.isEnabled = _selectIndex! < _pdfCount! - 1
        gobackBtn!.isEnabled = (_selectIndex! > 0)
        
        pageBtn.setTitle("\((_selectIndex ?? 0) + 1)/\(_pdfCount ?? 0)", for: .normal)
        if(_gem_hobj != nil){
            HelpClass.openPdf(_gem_hobj!, temppath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pdfImageIndex: _selectIndex!) { [weak self] ( rotation, count, image) in
                guard let self = self else { return }
                self._sourceImage = image
                var originalImage : UIImage? = nil
                if(self._waterText != nil){
                    originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: self._waterText!, andMark: self._waterFont!, andMark: self._waterColor!, isThumb: false)
                }else{
                    originalImage = self._sourceImage!
                }
                let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: self._currentAngle)
                self._imageView.image = rotatedImage
            }
        }
        else{
            if (_isPDF == true){
                HelpClass.openpdf(withPath: _tempPath!, width: Float(UIScreen.main.bounds.size.width * UIScreen.main.scale), pageIndex: _selectIndex!) {  [weak self] ( rotation, count, image) in
                    guard let self = self else { return }
                    self._sourceImage = image
                    var originalImage : UIImage? = nil
                    if(self._waterText != nil){
                        originalImage = HelpClass.getWaterMark(self._sourceImage!, andTitle: self._waterText!, andMark: self._waterFont!, andMark: self._waterColor!, isThumb: false)
                    }else{
                        originalImage = self._sourceImage!
                    }
                    let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: self._currentAngle)
                    self._imageView.image = rotatedImage
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.confirmBtnAction()
        return true
        
    }
    //MARK: 创建一个UICollectionView 展示 ImageURLS 里的图片缩率图
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 54, height: 54) // 设置你的缩略图大小
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: kHEIGHT - 54 - SafeAreaBottomHeight, width: kWIDTH, height: 54), collectionViewLayout: layout)
        collectionView.backgroundView = nil
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        self.view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(_gem_hobj != nil){
            return _sourcePaths!.count
        }
        return _imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ImageCollectionViewCell ?? ImageCollectionViewCell()
        cell.backgroundView = nil
        cell.backgroundColor = .clear
        if (_gem_hobj != nil) {
            cell.imageView?.image = UIImage(data: self.getFileData(filePath: _sourcePaths![indexPath.row] as! String, isThumb: true) as Data)!
            cell.imageView!.layer.borderWidth = _selectIndex == indexPath.row ? 2 : 0;
        }
        else{
            let imageURL = _imageUrls[_currentImageIndex]
            if let image = UIImage(contentsOfFile: imageURL.path) {
                let originalImage = UIImageManager.fixImageOrientation(image: image)
                let rotatedImage = UIImageManager.rotateImageDegrees(originalImage, degrees: _currentAngle)
                cell.imageView?.image = rotatedImage
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _currentImageIndex = indexPath.row
        _selectIndex = _currentImageIndex;
        _currentAngle = 0.0
        setupScrollView()
        collectionView.reloadData()
        self.view.bringSubviewToFront(collectionView)
        self.view.bringSubviewToFront(_backButton)
        self.view.bringSubviewToFront(_rotateButton)
    }
    func noThumbImageData() -> NSMutableData? {
        // 尝试加载名为 "tupianIcon" 的图像
        guard let image = UIImage(named: "tupianIcon"),
              let imageData = image.pngData() else {
            // 图像加载失败或无法转换为 PNG 数据，返回 nil
            return nil
        }
        
        // 直接使用 imageData 初始化 NSMutableData，因为 imageData 是非空的
        return NSMutableData(data: imageData)
    }
    
    func getFileData(filePath: String, isThumb: Bool) -> NSMutableData {
        guard let gemHobj = _gem_hobj else {
            print(" func :\(#function) line:\(#line) error:hFile 打开失败")
            return noThumbImageData()!
        }

        let hFilePath = filePath.cString(using: .utf8)!
        let hFile = NDF_OpenFile(gemHobj, hFilePath)

        if hFile != nil {
            var itemPhotoSize: Int64 = 0
            let imageData = NSMutableData()
            let blockSize = NDF_GetFileEncryptBlockSize(gemHobj, hFile)

            if blockSize > 0 {
                let bufferSize = Int(blockSize) + 1
                let fileData = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                fileData.initialize(repeating: 0, count: bufferSize)

                var word: DWORD = 0
                if isThumb {
                    word = NDF_ReadThumbFile(gemHobj, hFile, nil, &itemPhotoSize)
                } else {
                    word = NDF_ReadFile(gemHobj, hFile, nil, &itemPhotoSize)
                }

                while true {
                    var stop = false
                    var readingSize: Int64 = 0
                    if itemPhotoSize > blockSize {
                        readingSize = Int64(blockSize)
                    } else {
                        readingSize = itemPhotoSize
                        stop = true
                    }

                    if isThumb {
                        word = NDF_ReadThumbFile(gemHobj, hFile, fileData, &readingSize)
                    } else {
                        word = NDF_ReadFile(gemHobj, hFile, fileData, &readingSize)
                    }

                    if word == 0 {
                        let data = Data(bytes: fileData, count: Int(readingSize))
                        imageData.append(data)
                    } else {
                        print("读取数据失败")
                        return noThumbImageData()!
                    }

                    itemPhotoSize -= Int64(blockSize)
                    if stop {
                        break
                    }
                }
                fileData.deinitialize(count: bufferSize)
                fileData.deallocate()
            } else {
                var word: DWORD = 0
                if isThumb {
                    word = NDF_ReadThumbFile(gemHobj, hFile, nil, &itemPhotoSize)
                } else {
                    word = NDF_ReadFile(gemHobj, hFile, nil, &itemPhotoSize)
                }
                
                let bufferSize = Int(itemPhotoSize) + 1
                let fileData = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                fileData.initialize(repeating: 0, count: bufferSize)

                
                if isThumb {
                    word = NDF_ReadThumbFile(gemHobj, hFile, fileData, &itemPhotoSize)
                } else {
                    word = NDF_ReadFile(gemHobj, hFile, fileData, &itemPhotoSize)
                }

                if word == 0 {
                    let data = Data(bytes: fileData, count: Int(itemPhotoSize))
                    imageData.append(data)
                } else {
                    print("读取数据失败")
                    return noThumbImageData()!
                }

                fileData.deinitialize(count: bufferSize)
                fileData.deallocate()
            }

            NDF_CloseFile(gemHobj, hFile)
            return imageData
        } else {
            print(" func :\(#function) line:\(#line) error:hFile 打开失败")
            return noThumbImageData()!
        }
    }
    
    
        
    
    
}
