//
//  UIViewController+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 17/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func withNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
    func openSettings() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension UIViewController {
    static var current:UIViewController? {
        let delegate  = UIApplication.shared.delegate as? AppDelegate
        var current = delegate?.window?.rootViewController
        
        while (current?.presentedViewController != nil)  {
            current = current?.presentedViewController
        }
        
        if let tabbar = current as? UITabBarController , tabbar.selectedViewController != nil {
            current = tabbar.selectedViewController
        }
        
        while let navi = current as? UINavigationController , navi.topViewController != nil  {
            current = navi.topViewController
        }
        return current
    }
}
