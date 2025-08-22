//
//  PickerViewController.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/18.
//
//这个界面实现从相册中选择图片，并实现多选

import Foundation
import UIKit
import Photos

class PickerViewController: UIViewController {
    //MARK： 添加选中图片后的回调
    var selectedAssetsHandler: (([PHAsset]) -> Void)?
    
    var _isVideo : Bool = false
    
    private var _titleView: UIView!
    private var _backButton: UIButton!
    private var _titleLabel: UILabel!
    private var _doneButton: UIButton!
    private var collectionView: UICollectionView!
    private var assets: PHFetchResult<PHAsset>!
    private var selectedAssets: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkPhotoLibraryPermission()
    }
    
    @objc func backAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        // 设置CollectionView布局
        self.view.backgroundColor = .fromRGB(0x1a1a1c)
        
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
        if _isVideo == true {
            _titleLabel.text = NSLocalizedString("选择视频", comment: "")
        }
        else{
            _titleLabel.text = NSLocalizedString("选择图片", comment: "")
        }
        _titleLabel.textColor = .white
        _titleLabel.textAlignment = .center
        let titleLabelWidth = kWIDTH - 40 - (_backButton!.frame.width * 2)
        _titleLabel.frame = CGRect(x: _backButton!.frame.maxX + 20, y: (SafeAreaTopHeight - 44), width: titleLabelWidth, height: 44)
        _titleView!.addSubview(_titleLabel)
        self.view.addSubview(_titleView)
        
        _doneButton = UIButton()
        _doneButton!.setTitle(NSLocalizedString("完成", comment: ""), for: .normal)
        _doneButton!.setTitleColor(.fromRGB(0xffffff), for: .normal)
        _doneButton!.frame = CGRect(x: CGRectGetWidth(_titleView!.frame) - 60, y: (SafeAreaTopHeight - 44) + 5, width: 50, height: 34)
        _doneButton!.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        _titleView!.addSubview(_doneButton!)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let width = (view.bounds.width - 3) / 4
        layout.itemSize = CGSize(width: width, height: width)
        
        // 初始化CollectionView
        collectionView = UICollectionView(frame: CGRectMake(0, SafeAreaTopHeight, kWIDTH, kHEIGHT - SafeAreaTopHeight), collectionViewLayout: layout)
        collectionView.backgroundColor = self.view.backgroundColor
        collectionView.backgroundView = nil
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        view.addSubview(collectionView)
    }
    
    private func checkPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                if status == .authorized {
                    self?.fetchPhotos()
                } else {
                    // 处理未授权情况
                    self?.showPermissionAlert()
                }
            }
        }
    }
    
    private func fetchPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if _isVideo == true {
            assets = PHAsset.fetchAssets(with: .video, options: options)
        }
        else{
            assets = PHAsset.fetchAssets(with: .image, options: options)
        }
        collectionView.reloadData()
    }
    
    @objc private func doneButtonTapped() {
        // 处理选中的图片
        selectedAssetsHandler?(selectedAssets)
        dismiss(animated: true, completion: nil)
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("需要访问相册权限", comment: ""),
            message: NSLocalizedString("请在设置中允许访问相册", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("设置",comment: ""), style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消",comment: ""), style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension PickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.backgroundColor = self.view.backgroundColor
        cell.backgroundView = nil
        if let asset = assets?[indexPath.item] {
            cell.configure(with: asset)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let asset = assets?[indexPath.item] {
            selectedAssets.append(asset)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let asset = assets?[indexPath.item] {
            selectedAssets.removeAll { $0 == asset }
        }
    }
}

// MARK: - PhotoCell
class PhotoCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        label.textColor = .fromRGB(0xffffff)
        // 添加阴影
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 1.0
        return label
    }()
    
    private let checkmarkView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Checked_")
        iv.tintColor = .systemBlue
        iv.isHidden = true
        return iv
    }()
    
    override var isSelected: Bool {
        didSet {
            checkmarkView.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(durationLabel)
        addSubview(checkmarkView)
        
        imageView.frame = bounds
        durationLabel.frame = CGRect(x: 0, y: bounds.height - 15, width: bounds.width - 10, height: 15)
        checkmarkView.frame = CGRect(x: bounds.width - 40, y: 0, width: 40, height: 40)
    }
    
    func configure(with asset: PHAsset) {
        var duration = asset.duration
        if duration.isNaN {
            duration = 0
        }
        if duration > 0 {
            self.durationLabel.text = HelpClass.timeFormatted(Int32(duration))
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat  // 改为高质量模式
        options.isNetworkAccessAllowed = true      // 允许从 iCloud 下载
        options.resizeMode = .exact                // 精确的尺寸调整
    
        PHImageManager.default().requestImage(
        for: asset,
        targetSize: CGSize(width: 400, height: 400),
        contentMode: .aspectFill,
        options: options
        ) { [weak self] image, _ in
            self?.imageView.image = image
        }
    }
}
