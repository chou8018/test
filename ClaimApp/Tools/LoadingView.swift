//
//  LoadingView.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 22/9/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import UIKit
import SnapKit

private var loadingViewKey:Int = 0

enum LoadingViewTheme {
    case whiteBackground
    case darkBackground
}

final class LoadingView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var label: UILabel!
    
    class func showLoadingViewInView(view: UIView?, theme: LoadingViewTheme = .whiteBackground) {
        
        guard let view = view else {
            if let window = UIApplication.shared.keyWindow,
                let vc = window.rootViewController {
                showLoadingViewInView(view: vc.view, theme: theme)
            }
            return
        }
        
        self.hideLoadingViewInView(view: view)
        
        let loadingView = Bundle.main.loadNibNamed("LoadingView", owner: nil, options: nil)?.last as! LoadingView
        
        switch theme {
        case .whiteBackground:
            loadingView.backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            loadingView.label.backgroundColor = UIColor.clear
            loadingView.label.textColor = UIColor.black
            
        case .darkBackground:
            loadingView.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loadingView.label.backgroundColor = UIColor.clear
            loadingView.label.textColor = UIColor.white
        }
        
        loadingView.isUserInteractionEnabled = true
        loadingView.isExclusiveTouch = true
        
        view.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
            if view is UIScrollView {
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
        }
        
        objc_setAssociatedObject(view, &loadingViewKey, loadingView,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
    }
    
    
    class func hideLoadingViewInView(view: UIView?) {
        
        guard let view = view else {
            if let window = UIApplication.shared.keyWindow,
                let vc = window.rootViewController {
                hideLoadingViewInView(view: vc.view)
            }
            return
        }
        
        guard let loadingView = objc_getAssociatedObject(view, &loadingViewKey) as? LoadingView else { return }
        
        objc_setAssociatedObject(view, &loadingViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        loadingView.removeFromSuperview()
        
    }
    
    class func loadingViewInView(view: UIView?) -> LoadingView? {
        guard let view = view else {
            if let window = UIApplication.shared.keyWindow,
                let vc = window.rootViewController {
                return loadingViewInView(view: vc.view)
            }
            return nil
        }
        
        guard let loadingView = objc_getAssociatedObject(view, &loadingViewKey) as? LoadingView else { return nil }
        return loadingView
    }
    
    
    
}
