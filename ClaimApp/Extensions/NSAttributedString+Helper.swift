//
//  NSAttributedString+Helper.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/28.
//

import UIKit

extension NSAttributedString {
    
    static func addRequireStatus(string: String) -> NSAttributedString {
        let usedString = NSString(string:string + " *")
        let attribute = NSMutableAttributedString(string:usedString as String)
        let theRange = usedString.range(of: "*")
        attribute.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.cRemindRed], range: theRange)
        return attribute
    }
    
    static func attributedString(string: String, rangeString: String , color: UIColor? = nil , font: UIFont? = nil) -> NSAttributedString {
        
        let c = NSString(string: string)
        
        let attribute = NSMutableAttributedString(string: string)
        let range = NSString(string: c.uppercased).range(of: rangeString.uppercased())
        if let rangeRont = font {
            attribute.addAttributes([NSAttributedString.Key.font:rangeRont], range: range)
        }
        
        if let rangeColor = color {
            attribute.addAttributes([NSAttributedString.Key.foregroundColor:rangeColor], range: range)
        }

        return attribute
    }
}
