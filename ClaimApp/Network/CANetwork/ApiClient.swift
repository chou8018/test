//
//  TowkayApiClient.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 23/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

protocol ApiClient {
    func request(_ URLRequest: Alamofire.URLRequestConvertible) -> DataRequest
}

extension ApiClient {
    
    func request(_ URLRequest: Alamofire.URLRequestConvertible) -> DataRequest {
        
        let manager = Alamofire.SessionManager.default
        
        let headers: HTTPHeaders = ["Accept": "application/json", "Content-Type": "application/json", "User-Agent": "ios"]
        manager.session.configuration.httpAdditionalHeaders = headers
        
        return manager.request(URLRequest)
        
    }
    
    func makeHandlerForBooleanResult(_ fulfill: @escaping (Bool) -> (), _ reject: @escaping (Error) -> ()) -> (Int, DataResponse<Any>) -> () {
        return { (statusCode, response) in
            switch statusCode {
            case HttpStatusCode.ok.rawValue: fallthrough
            case HttpStatusCode.createdOrUpdated.rawValue: fallthrough
            case HttpStatusCode.noContent.rawValue:
                fulfill(true)
            default:
                reject(ApiError.unknown)
            }
        }
    }
    
    func makeHandlerForSingleResult<T: InitFailable>(_ fulfill: @escaping (T) -> (), _ reject: @escaping (Error) -> (), pathToSingleJson: String = "data" ) -> (Int, DataResponse<Any>) -> () {
        
        return { (statusCode, response) in
            switch statusCode {
            case HttpStatusCode.ok.rawValue: fallthrough
            case HttpStatusCode.createdOrUpdated.rawValue:
                
                guard
                    let json = response.result.value as? [String: Any]
                    else {
                        reject(ApiError.unknown)
                        return
                }
                
                let parts = pathToSingleJson.components(separatedBy: ".")
                
                guard parts.count >= 1 else {
                    reject(ApiError.unknown)
                    return
                }
                
                var currentJson = json
                
                for i in 0..<parts.count where i != (parts.count - 1) {
                    guard let nextJson = currentJson[parts[i]] as? [String: Any] else {
                        reject(ApiError.unknown)
                        return
                    }
                    currentJson = nextJson
                }
                
                if let singleJson = currentJson[parts.last!] as? [String: Any],
                   let singleResult = T(json: singleJson) {
                    fulfill(singleResult)
                } else if currentJson.keys.contains("success") {
                    if let obj = T(json: ["status":"success"]) {
                        fulfill(obj)
                    }else{
                        reject(ApiError.generalError(message: "Failed to parse data"))
                    }
                } else {
                    reject(ApiError.unknown)
                }
                
            default:
                reject(ApiError.unknown)
            }
        }
        
    }
    
    
    func makeHandlerForArrayResult<T: ArrayBuildable>(_ fulfill: @escaping ([T]) -> (), _ reject: @escaping (Error) -> (), pathToArrayJson: String = "data", async: Bool = false) -> (Int, DataResponse<Any>) -> () {
        
        return { (statusCode, response) in
            switch statusCode {
            case HttpStatusCode.ok.rawValue: fallthrough
            case HttpStatusCode.createdOrUpdated.rawValue:
                guard
                    let json = response.result.value as? [String: Any]
                    else {
                        reject(ApiError.unknown)
                        return
                }
                
                let parts = pathToArrayJson.components(separatedBy: ".")
                
                guard parts.count >= 1 else {
                    reject(ApiError.unknown)
                    return
                }
                
                var currentJson = json
                
                for i in 0..<parts.count where i != (parts.count - 1) {
                    guard let nextJson = currentJson[parts[i]] as? [String: Any] else {
                        reject(ApiError.unknown)
                        return
                    }
                    currentJson = nextJson
                }
                
                guard let arrayJson = currentJson[parts.last!] as? [[String: Any]] else {
                    reject(ApiError.unknown)
                    return
                }
                
                if async {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let arr = T.array(from: arrayJson)
                        DispatchQueue.main.async {
                            fulfill(arr)
                        }
                    }
                } else {
                    fulfill(T.array(from: arrayJson))
                }
                
            default:
                reject(ApiError.unknown)
            }
        }
        
    }
    
}


