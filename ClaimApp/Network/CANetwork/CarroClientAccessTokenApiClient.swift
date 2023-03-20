//
//  CarroClientAccessTokenApiClient.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 19/12/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

protocol ClientAccessTokenApiClient {
    func fetchClientAccessToken() -> Promise<AccessToken>
}

class CarroClientAccessTokenApiClient: ClientAccessTokenApiClient {
    
    func fetchClientAccessToken() -> Promise<AccessToken> {
        
        return Promise { seal in
            
            let params: Parameters = [
                "grant_type": "client_credentials",
                "client_id": 2,
                "client_secret": "HjporA2OU0KJOPCKpC0nj4aGCYTrUX5iO5B0rYee",
            ]
            
            Alamofire.request(AppConfig.clientOAuthUrlString, method: .post, parameters: params).basicCheckedResponseJSON(seal.reject, success: { (statusCode, response) in
                
                switch statusCode {
                case HttpStatusCode.ok.rawValue:
                    
                    guard let json = response.result.value as? [String: Any],
                        let token = AccessToken(json: json)
                        else {
                            seal.reject(ApiError.unknown)
                            return
                    }
                    
                    seal.fulfill(token)
                    
                default:
                    seal.reject(ApiError.unknown)
                }
                
            })
            
        }
        
        
    }
    
}
