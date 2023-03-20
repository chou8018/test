//
//  LineTextFieldView.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 16/4/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import UIKit
import SnapKit

@IBDesignable
class LineTextFieldView: UIView {

    var textField: UITextField!
    var lineView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        textField = UITextField(frame: .zero)
        textField.borderStyle = .none
        addSubview(textField)
        
//        lineView = UIView(frame: .zero)
//        addSubview(lineView)
        
//        lineColor = UIColor.darkGray
        
        textField.borderWidth = 1
        textField.cornerRadius = 6
        textField.borderColor = .init(hexValue: 0xC4CDD5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        lineView.frame = self.bounds.takeBottom(1)
        textField.frame = self.bounds.chopBottom(0)
    }
    
    @IBInspectable var lineColor: UIColor? {
        didSet {
//            lineView.backgroundColor = lineColor ?? UIColor.clear
            if let color = lineColor {
                textField.borderColor = color
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
    }

}


extension CGRect {

    func inset(insets: UIEdgeInsets) -> CGRect {
        return self
            .chopTop(insets.top)
            .chopBottom(insets.bottom)
            .chopLeft(insets.left)
            .chopRight(insets.right)
    }
    
    func chopLeft(_ amount: CGFloat) -> CGRect {
        guard width >= amount else { return self }
        return self.divided(atDistance: amount, from: .minXEdge).remainder
    }
    
    func chopRight(_ amount: CGFloat) -> CGRect {
        guard width >= amount else { return self }
        return self.divided(atDistance: amount, from: .maxXEdge).remainder
    }
    
    func chopTop(_ amount: CGFloat) -> CGRect {
        guard height >= amount else { return self }
        return self.divided(atDistance: amount, from: .minYEdge).remainder
    }
    
    func chopBottom(_ amount: CGFloat) -> CGRect {
        guard height >= amount else { return self }
        return self.divided(atDistance: amount, from: .maxYEdge).remainder
    }
    
    func takeLeft(_ amount: CGFloat) -> CGRect {
        guard width >= amount else { return self }
        return self.divided(atDistance: amount, from: .minXEdge).slice
    }
    
    func takeRight(_ amount: CGFloat) -> CGRect {
        guard width >= amount else { return self }
        return self.divided(atDistance: amount, from: .maxXEdge).slice
    }
    
    func takeCenter(_ amount: CGFloat) -> CGRect {
        guard width >= amount else { return self }
        let leftRight = floor((width - amount)/2)
        return self.chopLeft(leftRight).chopRight(leftRight)
    }
    
    func takeTop(_ amount: CGFloat) -> CGRect {
        guard height >= amount else { return self }
        return self.divided(atDistance: amount, from: .minYEdge).slice
    }
    
    func takeMiddle(_ amount: CGFloat) -> CGRect {
        guard height >= amount else { return self }
        let topBottom = floor((height - amount)/2)
        return self.chopTop(topBottom).chopBottom(topBottom)
    }
    
    func takeBottom(_ amount: CGFloat) -> CGRect {
        guard height >= amount else { return self }
        return self.divided(atDistance: amount, from: .maxYEdge).slice
    }
    
    func divideFromLeft(_ amount: CGFloat) -> (slice: CGRect, remainder: CGRect) {
        return self.divided(atDistance: amount, from: .minXEdge)
    }
    
    func divideFromRight(_ amount: CGFloat) -> (slice: CGRect, remainder: CGRect) {
        return self.divided(atDistance: amount, from: .maxXEdge)
    }
    
    func divideFromTop(_ amount: CGFloat) -> (slice: CGRect, remainder: CGRect) {
        return self.divided(atDistance: amount, from: .minYEdge)
    }
    
    func divideFromBottom(_ amount: CGFloat) -> (slice: CGRect, remainder: CGRect) {
        return self.divided(atDistance: amount, from: .maxYEdge)
    }
    
}
