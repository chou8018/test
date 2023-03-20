//
//  DataResponse+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 23/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import Alamofire

extension DataResponse {
    
    var statusCode: Int? {
        return self.response?.statusCode
    }
    
}
