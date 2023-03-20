//
//  ArrayBuilder.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 23/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

protocol ArrayBuildable {
    static func array(from jsonArray: [[String: Any]]) -> Array<Self>
}

protocol InitFailable {
    init?(json: [String: Any])
}

extension ArrayBuildable where Self: InitFailable {
    
    static func array(from jsonArray: [[String: Any]]) -> Array<Self> {
    
        var array = [Self]()
        
        for json in jsonArray {
            if let obj = Self.init(json: json) {
                array.append(obj)
            }
        }

        return array
        
    }
    
}

