//
//  ApiRouter.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 13/11/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import Alamofire

protocol ApiRouter: URLRequestConvertible {
    
    var baseUrlString: String { get }
    var authorizationFieldValue: String? { get }
    
    var requestConfiguration:
        (method: HTTPMethod,
        route: String,
        parameters: Parameters?,
        requiresAuthorization: Bool) { get }
    
}

extension ApiRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        let (method, route, params, requiresAuthorization) = self.requestConfiguration
        
        guard let url = URL(string: baseUrlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url.appendingPathComponent(route))
        request.httpMethod = method.rawValue
        
        if requiresAuthorization, let value = authorizationFieldValue {
            
            request.addValue(value, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        if let appId = AppConfig.appId {
            request.addValue(appId, forHTTPHeaderField: "X-App")
        }
        
        if method == HTTPMethod.post || method == HTTPMethod.put {
            return try JSONEncoding().encode(request, with: params)
        } else {
            return try URLEncoding(destination: .methodDependent).encode(request, with: params)
        }
        
    }
    
}

protocol CarroApiRouter: ApiRouter {}

extension CarroApiRouter {
    
    var baseUrlString: String {
        return AppConfig.carroApiBaseUrl
    }
    
    var authorizationFieldValue: String? { //user oauth token
        let tokenStore: UserAccessTokenStore! = AppServices.shared.find(UserAccessTokenStore.self)
        if let accessToken = tokenStore.userAccessToken {
            return "\(accessToken.type) \(accessToken.value)"
        }
        return nil
    }
}
