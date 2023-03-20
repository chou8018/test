//
//  AppTheme.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 11/9/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import UIKit

class AppTheme {
    
    class func applyTheme() {
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backgroundColor = UIColor.cPrimary
        UINavigationBar.appearance().barTintColor = UIColor.cPrimary
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UISegmentedControl.appearance().tintColor = UIColor.cPrimary
        UITabBar.appearance().tintColor = UIColor.cPrimary
        UIButton.appearance().tintColor = UIColor.cPrimary
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.white
    
        if #available(iOS 11, *) {
            UINavigationBar.appearance().prefersLargeTitles = false
        }
    }
    
}

