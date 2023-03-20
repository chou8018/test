//
//  HttpStatusCode.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 23/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

enum HttpStatusCode: Int {
    
    case badRequest        = 400
    case unauthorized      = 401
    case invalid         = 402
    case forbidden         = 403
    case notFound          = 404
    case gone              = 410
    case unprocessable     = 422
    case ok                = 200
    case createdOrUpdated  = 201
    case noContent         = 204
    
}
