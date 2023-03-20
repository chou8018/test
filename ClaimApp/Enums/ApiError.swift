//
//  ApiError.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 21/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

public enum ApiError: Error {
    case unauthorized
    case invalidCredentials
    case generalError(message: String)
    case formError(message: String, errors: [String: [String]])
    case captchaError(message: String)
    case noConnection
    case unreachable
    case unknown
    
    case unconventionalError(message: String, errorInfo: [String: Any])
}
