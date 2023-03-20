//
//  UIButton+Helper.swift
//  dealers
//
//  Created by 付耀辉 on 2021/2/4.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import UIKit
extension UIButton {

    enum LNButtonPosition {
        case left
        case right
        case top
        case bottom
    }
    
    func layout(style:LNButtonPosition, space:CGFloat) {
        let imageW = self.imageView?.frame.width ?? 0
        let imageH = self.imageView?.frame.height ?? 0
        
        var labelW = self.titleLabel?.frame.size.width ?? 0
        var labelH = self.titleLabel?.frame.size.height ?? 0
        
        if #available(iOS 8.0, *) {
            labelW = self.titleLabel?.intrinsicContentSize.width ?? 0
            labelH = self.titleLabel?.intrinsicContentSize.height ?? 0
        }
        
        var imageEdge = UIEdgeInsets.zero
        var labelEdge = UIEdgeInsets.zero
        
        switch style {
        case .top:
            imageEdge = UIEdgeInsets.init(top: -labelH-space/2.0, left: 0, bottom: 0, right: -labelW)
            labelEdge = UIEdgeInsets.init(top: 0, left: -imageW, bottom: -imageH-space/2.0, right: 0)
        case .left:
            imageEdge = UIEdgeInsets.init(top: 0, left: -space/2.0, bottom: 0, right: space/2.0)
            labelEdge = UIEdgeInsets.init(top: 0, left: space/2.0, bottom: 0, right: -space/2.0)
        case .bottom:
            imageEdge = UIEdgeInsets.init(top: 0, left: 0, bottom: -labelH-space/2.0, right: -labelW)
            labelEdge = UIEdgeInsets.init(top: -imageH-space/2.0, left:-imageW,  bottom: 0, right: 0)
        case .right:
            imageEdge = UIEdgeInsets.init(top: 0, left: labelW+space/2.0, bottom: 0, right: -labelW-space/2.0)
            labelEdge = UIEdgeInsets.init(top: 0, left: -imageW-space/2.0,  bottom: 0, right: imageW+space/2.0)
        }
        self.titleEdgeInsets = labelEdge
        self.imageEdgeInsets = imageEdge
    }
    
    func buttonUnderlineWith(btnStr: String) {
        let attributedString = NSMutableAttributedString(string:btnStr)
        var range = NSRange()
        range.location = 0
        range.length = attributedString.length
        attributedString.addAttributes([NSAttributedString.Key.underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue)], range: range)
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
