//
//  AccessToken.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 23/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

struct AccessToken {
    
    let type: String
    let value: String
    
    init?(json: [String: Any]) {
        
        guard
            let type: String = json["token_type"] as? String,
            let value: String = json["access_token"] as? String
            else {
                return nil
        }
        
        self.type = type
        self.value = value
    
    }
    
    init(type: String, value: String) {
        self.type = type
        self.value = value
    }
    
}
