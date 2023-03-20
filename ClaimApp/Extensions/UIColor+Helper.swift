//
//  UIColor+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 18/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    @nonobjc static var cPrimary: UIColor {
        return UIColor(hexValue: 0x425CC8)
    }
    
    @nonobjc static var cNewPrimary: UIColor {
        return cPrimary
    }    
    
    @nonobjc static var cDarkText: UIColor {
        return UIColor(hexValue: 0x3B3B3B)
    }
    
    @nonobjc static var cLightText: UIColor {
        return UIColor(hexValue: 0x6C6C6C)
    }
    
    @nonobjc static var cPlaceholderBackground: UIColor {
        return UIColor(hexValue: 0x9d9d9d)
    }

    @nonobjc static var personalButtonUnselect: UIColor {
        return UIColor(hexValue: 0xC4CDD5)
    }
    
    @nonobjc static var titleGrayColor: UIColor {
        return UIColor(hexValue: 0x6E7882)
    }
    
    @nonobjc static var cLightGary: UIColor {
        return UIColor(hexValue: 0xBABABA)
    }
    
    @nonobjc static var cRemindRed: UIColor {
        return UIColor(hexValue: 0xF54165)
    }
    
    @nonobjc static var cCurrencySelectedColor: UIColor {
        return UIColor(hexValue: 0xF1F8FF)
    }
    
    @nonobjc static var greyScale3Color: UIColor {
        return UIColor(hexValue: 0x333333)
    }
    
    @nonobjc static var cBlue: UIColor {
        return UIColor(hexValue: 0x4082FF)
    }
    
    convenience init(hexValue: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hexValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((hexValue & 0xFF00) >> 8)/255.0
        let blue = CGFloat((hexValue & 0xFF))/255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(red: Int, green: Int, blue: Int , alp: CGFloat = 1.0 ) {
          assert(red >= 0 && red <= 255, "Invalid red component")
          assert(green >= 0 && green <= 255, "Invalid green component")
          assert(blue >= 0 && blue <= 255, "Invalid blue component")
          self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alp)
    }
    
}

extension UIColor {
    class func hexColorWithAlpha(color: String, alpha:CGFloat = 1) -> UIColor
     {
         var colorString = color.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
         
         if colorString.count < 6 {
             return UIColor.clear
         }
         
         if colorString.hasPrefix("0x") {
             colorString = (colorString as NSString).substring(from: 2)
         }
         if colorString.hasPrefix("#") {
             colorString = (colorString as NSString).substring(from: 1)
         }
         
         if colorString.count < 6 {
             return UIColor.clear
         }
         
         var rang = NSRange()
         rang.location = 0
         rang.length = 2
         
         let rString = (colorString as NSString).substring(with: rang)
         rang.location = 2
         let gString = (colorString as NSString).substring(with: rang)
         rang.location = 4
         let bString = (colorString as NSString).substring(with: rang)
         
         var r:UInt64 = 0, g:UInt64 = 0,b: UInt64 = 0
         
         Scanner(string: rString).scanHexInt64(&r)
         Scanner(string: gString).scanHexInt64(&g)
         Scanner(string: bString).scanHexInt64(&b)
         
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
     }
}


