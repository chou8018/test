//
//  DataRequest+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 23/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {
    
    private func commonCheckedResponseJSON(
        _ failure: @escaping (Error) -> (),
        success: @escaping (_ statusCode: Int, _ response: DataResponse<Any>) -> () ) {
        
        self.responseJSON { response in
            LNDebugPrint(item: response.value)
            LNDebugPrint(item: response.request?.url?.absoluteString ?? "")

            guard response.result.isSuccess else {
                
                guard let error = response.result.error as? URLError else {
                    failure(ApiError.unknown)
                    return
                }
                
                switch error.code {
                    
                case .networkConnectionLost: fallthrough
                case .notConnectedToInternet:
                    failure(ApiError.noConnection)
                    
                case .timedOut: fallthrough
                case .cannotConnectToHost:
                    failure(ApiError.unreachable)
                    
                default:
                    failure(ApiError.unknown)
                }
                
                return
            }
            
            guard let statusCode = response.statusCode else {
                failure(ApiError.unknown)
                return
            }
            
            success(statusCode, response)
        }
        
    }
    
    func basicCheckedResponseJSON(
        _ failure: @escaping (Error) -> (),
        success: @escaping (_ statusCode: Int, _ response: DataResponse<Any>) -> () ) {
        commonCheckedResponseJSON(failure, success: success)
    }
    
    func checkedResponseJSON(
        _ failure: @escaping (Error) -> (),
        success: @escaping (_ statusCode: Int, _ response: DataResponse<Any>) -> () ) {
        
        self.commonCheckedResponseJSON(failure) { (statusCode, response) in
        
            if statusCode == HttpStatusCode.unauthorized.rawValue  {
                NotificationCenter.default
                    .post(name: AppUserAccessTokenDidExpireNotification, object: nil)
                failure(ApiError.unauthorized)
                return
            }
            if  let json = response.result.value as? [String: Any],
                let message = json.string("errors")  {
                failure(ApiError.generalError(message: message))
                return
            }
            
            if  let json = response.result.value as? [String: Any],
                let errorsJson = json.jsonObject("errors") {
                
                var allMessages = [String]()
                var errors = [String: [String]]()
                
                for (k, v) in errorsJson {
                    
                    if let messages = v as? [String] {
                        allMessages.append(contentsOf: messages)
                        errors[k] = messages
                        
                    } else if let message = v as? String {
                        let messages = [message]
                        allMessages.append(contentsOf: messages)
                        errors[k] = messages
                    }
                    
                }   
                
                let message = allMessages.joined(separator: "\n")
                
                failure(ApiError.formError(message: message, errors: errors))
                
                return
            }
            
            success(statusCode, response)
        }
        
    }
    
}
