//
//  UITableView+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 17/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    public var x:CGFloat{
        get{
            return self.frame.origin.x;
        }
        set{
            var frames = self.frame;
            frames.origin.x = CGFloat(newValue);
            self.frame = frames;
        }
    }
    
    public var y:CGFloat{
        get{
            return self.frame.origin.y;
        }
        set{
            var frames = self.frame;
            frames.origin.y = CGFloat(newValue);
            self.frame = frames;
        }
    }
    
    public var width:CGFloat{
        get{
            return self.frame.size.width;
        }
        set{
            var frames = self.frame;
            frames.size.width = CGFloat(newValue);
            self.frame = frames;
        }
    }
    
    public var height:CGFloat{
        get{
            return self.frame.size.height;
        }
        set{
            var frames = self.frame;
            frames.size.height = CGFloat(newValue);
            self.frame = frames;
        }
    }
    
    public var maxX:CGFloat{
        get{
            return self.x + self.width;
        }
        set{
            var frames = self.frame;
            frames.origin.x = CGFloat(newValue - self.width);
            self.frame = frames;
        }
    }
    
    public var maxY:CGFloat{
        get{
            return self.y + self.height;
        }
        set{
            var frames = self.frame;
            frames.origin.y = CGFloat(newValue - self.height);
            self.frame = frames;
        }
    }
    
    public var centerX:CGFloat{
        get{
            return self.center.x;
        }
        set{
            self.center = CGPoint(x:CGFloat(newValue),y:self.center.y);
        }
    }
    
    public var centerY:CGFloat{
        get{
            return self.center.y;
        }
        set{
            self.center = CGPoint(x:self.center.x,y:CGFloat(newValue));
        }
    }
  
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.masksToBounds = (newValue > 0)
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        } set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    var getCurrentVC: UIViewController? {
        var next = superview
        while (next != nil) {
            let nextResponder = next?.next
            if (nextResponder is UIViewController) {
                return nextResponder as? UIViewController
            }
            next = next?.superview
        }
        return nil
    }
    
    func setShadow(sColor:UIColor,offset:CGSize,opacity:Float,radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.shadowColor = sColor.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
        self.clipsToBounds = false
    }
    
    func setShadow(sColor:UIColor,offset:CGSize,opacity:Float,cornerRadius:CGFloat,shadowRadius:CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = sColor.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = offset
        self.clipsToBounds = false
    }
    
    func addCorner(conrners: UIRectCorner , radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: conrners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func addBottomShadow() {
        setShadow(sColor: .greyScale3Color, offset: CGSize(width: 0, height: -8), opacity: 0.11, cornerRadius: 0, shadowRadius: 8)
    }
}
