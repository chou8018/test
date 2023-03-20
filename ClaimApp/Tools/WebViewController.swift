//
//  WebViewController.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 3/10/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//


import UIKit
import WebKit
import Alamofire
import StoreKit

final class WebViewController: CABaseViewController {
    
    fileprivate var selfContext = 0
    
    fileprivate var pageTitle: String?
    fileprivate let url: URL?
    var leadId: String?
    
    fileprivate var webView: WKWebView!
    fileprivate var forwardButton: UIBarButtonItem!
    fileprivate var backButton: UIBarButtonItem!
    fileprivate var closeButton: UIBarButtonItem!
    fileprivate var actionButton: UIBarButtonItem!
    fileprivate var progressView: UIProgressView!
    
    convenience init(withTitle title: String?, urlString: String) {
        self.init(withTitle: title, url: URL(string: urlString))
    }
    init(withTitle title: String?, url aUrl: URL?) {
        pageTitle = title
        url = aUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = pageTitle
        

        webView = WKWebView(frame: CGRect.zero)
        webView.addObserver(self, forKeyPath: "title", options: [.new], context: &selfContext)
        webView.addObserver(self, forKeyPath: "loading", options: [.new], context: &selfContext)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new], context: &selfContext)
        webView.navigationDelegate = self
        webView.isOpaque = true
        webView.backgroundColor = UIColor.white
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = UIColor.cPrimary
        progressView.trackTintColor  = UIColor.clear
        progressView.progress = 0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(progressView, aboveSubview: webView)
        
//        forwardButton = UIBarButtonItem(
//            image: #imageLiteral(resourceName: "ic_keyboard_arrow_right"),
//            style: .plain,
//            target: self,
//            action: #selector(WebViewController.forward(_:))
//        )
        
//        forwardButton.isEnabled = false
//
//        backButton = UIBarButtonItem(
//            image: #imageLiteral(resourceName: "ic_keyboard_arrow_left"),
//            style: .plain,
//            target: self,
//            action: #selector(WebViewController.back(_:))
//        )
//
//        backButton.isEnabled = false
//
//        closeButton = UIBarButtonItem(
//            image: #imageLiteral(resourceName: "ic_close"),
//            style: .plain,
//            target: self,
//            action: #selector(WebViewController.close(_:))
//        )
//
//        actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(WebViewController.showActions(_:)))
//
//        navigationItem.rightBarButtonItems = [closeButton, actionButton]

        setupConstraints()
        webView.loadUrl(url)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    func getPDFUrl() {
        
        guard let lead_id = self.leadId else {
            return
        }
        
        let vieweduUrl = "/api/v2/mobile/sellers/lead-sell-forms/\(lead_id)/payment-document"
        let sellFlowController: SellFlowController! = AppServices.shared.find(SellFlowController.self)
//        LoadingView.showLoadingViewInView(view: self.view)
//        sellFlowController.getPDFUrlWithUrl(method: .post, url: vieweduUrl).done {
//            data in
//        }.catch { [weak self] error in
//            guard let self = self else { return }
//            UIAlertController.showErrorMessage(error: error, from: self)
//
//        }.finally { [weak self] in
//            guard let `self` = self else { return }
//            LoadingView.hideLoadingViewInView(view: self.view)
//        }
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
        webView.navigationDelegate = nil
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &selfContext else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        guard let keyPath = keyPath else {
            return
        }
        
        switch keyPath {
        case "loading":
            updateNavigationBar()
            if let loading = change?[NSKeyValueChangeKey.newKey] {
                if !(loading as AnyObject).boolValue {
                    progressView.progress = 0
                }
            }
            
        case "estimatedProgress":
            if let newValue = change?[NSKeyValueChangeKey.newKey] {
                progressView.progress = (newValue as AnyObject).floatValue
            }
            
        case "title":
                break
        default:
            return
        }
    }
    
    fileprivate func updateNavigationBar() {
//        backButton.isEnabled = webView.canGoBack
//        forwardButton.isEnabled = webView.canGoForward
//        
//        var items = [UIBarButtonItem]()
//        if backButton.isEnabled || forwardButton.isEnabled {
//            items = [backButton, forwardButton]
//        }
//        
//        navigationItem.setLeftBarButtonItems(items, animated: true)
    }
    
    // MARK: - Auto layout
    
    fileprivate func setupConstraints() {
        
        let vs: [String: AnyObject] = ["webView": webView, "progressView": progressView, "top": self.topLayoutGuide]
        
        [
            "V:[top][webView]|",
            "H:|[webView]|",
            "V:[top][progressView]",
            "H:|[progressView]|"
            
            ].forEach {
                view.addConstraints(
                    NSLayoutConstraint.constraints(
                        withVisualFormat: $0,
                        options: [],
                        metrics: nil,
                        views: vs
                    )
                )
        }
        
    }
    
    // MARK: - Button actions
    
    @objc fileprivate func close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func showActions(_ sender: AnyObject) {
        var items = [AnyObject]()
        
        if let title = title {
            items.append(title as AnyObject)
        }
        
        if let url = url {
            items.append(url as AnyObject)
        }
        
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = [
            .airDrop,
            .postToVimeo,
            .postToFlickr,
            .saveToCameraRoll,
            .assignToContact
        ]
        
        present(controller, animated: true, completion: nil)
    }
    
    @objc fileprivate func back(_ sender: AnyObject) {
        
        if webView.canGoBack {
            webView.goBack()
            
        } else {
            webView.loadUrl(url)
        }
    }
    
    @objc fileprivate func forward(_ sender: AnyObject) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
}

// MARK: - Extensions

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if !(self.isViewLoaded && self.view.window != nil) {
            return
        }
        progressView.progress = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
}

extension WKWebView {
    
    func loadUrl(_ url: URL?) {
        
        guard let url = url else {
            return
        }
        
        let request = URLRequest(url: url)
        load(request)
        
    }
    
}
