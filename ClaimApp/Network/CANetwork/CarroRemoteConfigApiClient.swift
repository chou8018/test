//
//  CarroRemoteConfigApiClient.swift
//  dealers
//
//  Created by Alexander Vuong on 7/2/19.
//  Copyright © 2019 Trusty Cars. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

protocol RemoteConfigApiClient {
    func fetchRemoteConfig() -> Promise<RemoteConfig>
    func fetchMobileVersionConfig() -> Promise<MobileVersion>
    
    func registerFcmToken(token: String) -> Promise<Bool>
    func unregisterFcmToken() -> Promise<Bool>
}

class CarroRemoteConfigApiClient: RemoteConfigApiClient, ApiClient {
    func fetchRemoteConfig() -> Promise<RemoteConfig> {
        return Promise { seal in
            self.request(CarroRemoteConfigApiRouter.defaultRoute)
                .checkedResponseJSON(seal.reject, success: makeHandlerForSingleResult(seal.fulfill, seal.reject))
        }
    }
    func fetchMobileVersionConfig() -> Promise<MobileVersion> {
        return Promise { seal in
            self.request(CarroRemoteConfigApiRouter.mobileVersion)
                .checkedResponseJSON(seal.reject, success: makeHandlerForSingleResult(seal.fulfill, seal.reject))

        }
    }
    
    func registerFcmToken(token: String) -> Promise<Bool> {
        return Promise { seal in
            self.request(CarroRemoteConfigApiRouter.registerFcmToken(token: token)).checkedResponseJSON(seal.reject, success: makeHandlerForBooleanResult(seal.fulfill, seal.reject))
        }
    }
    
    func unregisterFcmToken() -> Promise<Bool> {
        return Promise { seal in
            self.request(CarroRemoteConfigApiRouter.unregisterFcmToken).checkedResponseJSON(seal.reject, success: makeHandlerForBooleanResult(seal.fulfill, seal.reject))
        }
    }
}

enum CarroRemoteConfigApiRouter: CarroApiRouter {
    case defaultRoute
    case mobileVersion
    
    case registerFcmToken(token: String)
    case unregisterFcmToken
    
    var requestConfiguration: (method: HTTPMethod, route: String, parameters: Parameters?, requiresAuthorization: Bool) {
        switch self {
        case .defaultRoute:
            return (.get, "mobile/config/default", nil, true)
        case .mobileVersion:
            return (.get, "mobile/config/ios/version", nil, true)
            
        case let .registerFcmToken(token):
            
            let params: [String: Any] = [
                "fcm_uuid": token
            ]
            
            return (.post, "mobile/fcm", params.merging(additionalTrackingProperties, uniquingKeysWith: {$1}), true)
            
        case .unregisterFcmToken:
            return (.post, "mobile/fcm/unregister", nil, true)
        }
    }
}
