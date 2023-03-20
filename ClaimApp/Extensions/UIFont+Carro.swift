//
//  UIFont+Carro.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 11/9/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//
import UIKit

extension UIFont {

    // weight 400
    class func customFont(ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "AvenirNext-Regular", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    // 500
    class func mediumCustomFont(ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "AvenirNext-Medium", size: size) else {
            return UIFont.boldSystemFont(ofSize: size)
        }
        return font
    }
    
    @nonobjc static var extraLargeMedium: UIFont {
        return UIFont.mediumCustomFont(ofSize: 18)
    }

    @nonobjc static var small: UIFont {
        return UIFont.customFont(ofSize: 13)
    }
    
    @nonobjc static var extraExtraLargeBold: UIFont {
        return UIFont.boldCustomFont(ofSize: 20)
    }
    
    @nonobjc static var largeBold: UIFont {
        return UIFont.boldCustomFont(ofSize: 16)
    }
    
    @nonobjc static var mediumBold: UIFont {
        return UIFont.boldCustomFont(ofSize: 14)
    }

    @nonobjc static var medium: UIFont {
        return UIFont.customFont(ofSize: 14)
    }

    // 600
    class func demiBoldCustomFont(ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "AvenirNext-DemiBold", size: size) else {
            return UIFont.boldSystemFont(ofSize: size)
        }
        return font
    }
    
    // 700
    class func boldCustomFont(ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "AvenirNext-Bold", size: size) else {
            return UIFont.boldSystemFont(ofSize: size)
        }
        return font
    }
    
}
