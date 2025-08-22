//
//  WebViewController.swift
//  File Locker
//
//  Created by MAC_RD on 2025/3/3.
//

import Foundation
import WebKit
class WebViewController : UIViewController,WKNavigationDelegate,WKUIDelegate,UITextFieldDelegate {
    @objc var path : String? = nil
    var _webView : WKWebView!
    var _backwardButton : UIButton!
    var _forwardButton : UIButton!
    var _refreshButton : UIButton!
    var _progressView : UIProgressView!
    var _backButton : UIButton!
    var _titleLabel : UILabel!
    var _gobackLevel : Int = 0
    var sourceBgView : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .fromRGB(0x1a1a1c)
        // 创建一个返回按钮
        _backButton = UIButton()
        _backButton!.setImage(UIImage(named: "Btn_Back"), for: .normal)
        _backButton!.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        _backButton!.frame = CGRect(x: 0, y: (SafeAreaTopHeight - 44), width: 40, height: 44)
        self.view.addSubview(_backButton!)
        
        _titleLabel = UILabel()
        _titleLabel!.textColor = .white
        _titleLabel!.textAlignment = .center
        _titleLabel!.frame = CGRectMake(60, CGRectGetMinY(_backButton.frame), kWIDTH - 88 - 44 - 60, 44)
        self.view.addSubview(_titleLabel!)
        let titleLine = UIView()
        titleLine.frame = CGRect(x: 0, y: CGRectGetMaxY(_titleLabel!.frame) - CGFloat(1.0/UIScreen.main.scale), width: kWIDTH, height: CGFloat(1.0/UIScreen.main.scale))
        titleLine.backgroundColor = UIColor.fromRGB(0x2d2d2d)
        view.addSubview(titleLine)
        

        self.sourceBgView = UITextField(frame: CGRectMake(0, CGRectGetMaxY(_titleLabel!.frame), kWIDTH, kHEIGHT - CGRectGetMaxY(_titleLabel!.frame)))
        self.sourceBgView .addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(sourceBgViewTapPressGestureRecognizer(_ : ))))
        self.sourceBgView .addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(sourceBgViewLongPressGestureRecognizer(_ : ))))
        self.sourceBgView.tag = -1
        self.sourceBgView.isUserInteractionEnabled = true
        self.sourceBgView.isSecureTextEntry = true
        self.sourceBgView.delegate = self
        view.addSubview(self.sourceBgView)
        
        
        //加载网页数据
        let wkWebConfig = WKWebViewConfiguration()
        _webView = WKWebView(frame: CGRect(x: 0, y: 0, width: kWIDTH, height: CGRectGetHeight(self.sourceBgView.frame)), configuration: wkWebConfig)
        _webView.autoresizingMask = .flexibleWidth
        _webView.uiDelegate = self
        _webView.navigationDelegate = self
        (self.sourceBgView.subviews.first)!.addSubview(_webView!)

        
        // 获取 HTML 文件的 URL
        let fileURL = URL(fileURLWithPath: path!)
        _webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        
        //添加进度条
        _progressView = UIProgressView()
        _progressView.frame = CGRect(x: 0, y: CGRectGetMaxY(_titleLabel!.frame), width: kWIDTH, height: 2)
        _progressView.progressViewStyle = .default
        self.view.addSubview(_progressView)

        //添加进度条监听
        //_webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        _forwardButton = UIButton()
        _forwardButton.frame = CGRectMake(kWIDTH - 88, SafeAreaTopHeight - 44, 44, 44)
        _forwardButton.setImage(UIImage(named: "forward"), for: .normal)
        _forwardButton.addTarget(self, action: #selector(forwardAction), for: .touchUpInside)
        self.view.addSubview(_forwardButton)
        
        
        _backwardButton = UIButton()
        _backwardButton.frame = CGRectMake(kWIDTH - 88 - 44, SafeAreaTopHeight - 44, 44 , 44)
        _backwardButton.setImage(UIImage(named: "goback"), for: .normal)
        _backwardButton.addTarget(self, action: #selector(backwardAction), for: .touchUpInside)
        self.view.addSubview(_backwardButton)

        _refreshButton = UIButton()
        _refreshButton.frame = CGRectMake(kWIDTH - 44, SafeAreaTopHeight - 44, 44, 44)
        _refreshButton.setImage(UIImage(named: "Reset_Normal"), for: .normal)
        _refreshButton.addTarget(self, action: #selector(refreshAction), for: .touchUpInside)
        self.view.addSubview(_refreshButton)
        
    }
    @objc func sourceBgViewLongPressGestureRecognizer(_ gesture: UILongPressGestureRecognizer){
        
    }
    @objc func sourceBgViewTapPressGestureRecognizer(_ gesture: UITapGestureRecognizer){
        
    }
    @objc func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    @objc func forwardAction(){
        if(_webView.canGoForward){
            _webView.goForward()
        }
        _gobackLevel = _gobackLevel - 1
        _backwardButton.isEnabled = true
        _forwardButton.isEnabled = _gobackLevel > 0;
    }
    @objc func backwardAction(){
        if(_webView .canGoBack){
            _webView.goBack()
        }
        else{
            _backwardButton.isEnabled = false
        }
        _gobackLevel = _gobackLevel + 1
        _forwardButton.isEnabled = true
    }
    @objc func refreshAction(){
        if (_webView != nil){
            _webView.reload()
        }
    }
    
    //MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        _progressView.progress = 0
        _progressView.isHidden = false
    }
    //decidePolicyForNavigationAction
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.targetFrame == nil) {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
        if(_webView.canGoBack){
            _backwardButton.isEnabled = true
        }
        else{
            _backwardButton.isEnabled = false
        }
    }
    //didFailNavigation
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NSLog("网页加载失败");
    }
    //didFailProvisionalNavigation
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog("网页加载失败");
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        _progressView.progress = 1
        NSLog("网页加载完成");
        _titleLabel!.text = webView.title;
    // 加载开始时显示加载指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if(_webView.canGoBack){
            _backwardButton.isEnabled = true
        }
        else{
            _backwardButton.isEnabled = false
        }
        _progressView.isHidden = true
    }
    
    @objc func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutableRawPointer){
        if(keyPath == "estimatedProgress"){
            let progress = _webView.estimatedProgress
            _progressView.progress = Float(progress)
        }
    }
    
    @objc func backAction(){
        if(self.navigationController != nil){
            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
}
