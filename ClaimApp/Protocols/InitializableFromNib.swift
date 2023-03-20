//
//  InitiableFromNib.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 6/10/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

protocol InitializableFromNib: AnyObject {

    static var nibName: String { get }
    static func fromNib() -> Self
    static var nib: UINib { get }
    
}

extension InitializableFromNib where Self: UIView {
    
    static func fromNib() -> Self {
        return Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.last as! Self
    }
    
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle.main)
    }
    
}
